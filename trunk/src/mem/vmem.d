/* vmem.d - virtual memory stuffs
 *
 * So far just the page fault handler
 */


/* Handle faults -- the fault handler
 * This should handle everything when a page fault
 * occurs.
 */
module mem.vmem;

import kernel.vga;
import core.util;
import core.multiboot;
import pmem = mem.pmem;
static import idt = kernel.idt;

// CONST for page size
const ulong PAGE_SIZE = 4096;			// 4k pages for us right now
// Entry point in to the page table
pml4[] pageLevel4;


void handle_faults(idt.interrupt_stack* ir_stack) 
{
	// First we need to determine why the page fault happened
	// This ulong will contain the address of the section of memory being faulted on
	void* addr;
	// This is the dirty asm that gets the address for us...
	asm { "mov %%cr2, %%rax" ::: "rax"; "movq %%rax, %0" :: "m" addr; }
	// And this is a print to show us whats going on

	// Page fault error code is as follows (page 225 of AMD System docs):
	// Bit 0 = P bit - set to 0 if fault was due to page not present, 1 otherwise
	// Bit 1 = R/W bit - 0 for read, 1 for write fault
	// Bit 2 = U/S bit - 0 if fault in supervisor mode, 1 if usermode
	// Bit 3 = RSV bit - 1 if processor tried to read from a reserved field in PTE
	// Bit 4 = I/D bit - 1 if instruction fetch, otherwise 0
	// The rest of the error code byte is considered reserved

	// The easiest way to find if a bit is set is by & it with a mask and check for ! 0

	kprintfln!("\n Page fault. Code = {}, IP = 0x{x}, VA = 0x{x}, RBP = 0x{x}\n")(ir_stack.err_code, ir_stack.rip, addr, ir_stack.rbp);

	if((ir_stack.err_code & 1) == 0) 
	{
		kprintfln!("Error due to page not present!")();

		if((ir_stack.err_code & 2) != 0)
		{
			kprintfln!("Error due to write fault.")();
		}
		else
		{
			kprintfln!("Error due to read fault.")();
		}

		if((ir_stack.err_code & 4) != 0)
		{
			kprintfln!("Error occurred in usermode.")();
			// In this case we need to send a signal to the libOS handler
		}
		else
		{
			kprintfln!("Error occurred in supervised mode.")();
			// In this case we're super concerned and need to handle the fault
		}

		if((ir_stack.err_code & 8) != 0)
		{
			kprintfln!("Tried to read from a reserved field in PTE!")();
		}

		if((ir_stack.err_code & 16) != 0)
		{
			kprintfln!("Instruction fetch error!")();
		}
	}
}

// Page table structures
align(1) struct pml4
{
	ulong pml4e;
	mixin(Bitfield!(pml4e, "p", 1, "rw", 1, "us", 1, "pwt", 1, "pcd", 1, "a", 1,
	"ign", 1, "mbz", 2, "avl", 3, "pdpba", 41, "available", 10, "nx", 1));
}

// Page directory pointer entry
align(1) struct pml3 
{
	ulong pml3e;
	mixin(Bitfield!(pml3e, "p", 1, "rw", 1, "us", 1, "pwt", 1, "pcd", 1, "a", 1,
	"ign", 1, "o", 1, "mbz", 1, "avl", 3, "pdba", 41, "available", 10, "nx", 1));
}


align(1) struct pml2
{
	ulong pml2e;
	mixin(Bitfield!(pml2e, "p", 1, "rw", 1, "us", 1, "pwt", 1, "pcd", 1, "a", 1,
	"ign1", 1, "o", 1, "ign2", 1, "avl", 3, "pdba", 41, "available", 10, "nx", 1));
}


align(1) struct pml1
{
	ulong pml1e;
	mixin(Bitfield!(pml1e, "p", 1, "rw", 1, "us", 1, "pwt", 1, "pcd", 1, "a", 1,
	"d", 1, "pat", 1, "g", 1, "avl", 3, "pdba", 41, "available", 10, "nx", 1));
}

void reinstall_page_tables()
{
	// Allocate the physical page for the top-level page table.
 	pageLevel4 = (cast(pml4*)pmem.request_phys_page())[0 .. 512];

	// zero it out.
	pageLevel4[] = pml4.init;
	
	// Remapping time!  This will remap the kernel in to high memory (again)
	// Though we did this in the asm, we are doing it again in here so that it
	// is easier to work with (has structs, etc that we can play with)
	
	// 3rd level page table
	pml3[] pageLevel3 = (cast(pml3*)pmem.request_phys_page())[0 .. 512];
	
	pageLevel3[] = pml3.init;
	
	// Set the 511th entry of level 4 to a level 3 entry
	pageLevel4[511].pml4e = cast(ulong)pageLevel3.ptr;
	// Set correct flags, present, rw, usable
	pageLevel4[511].pml4e |= 0x7;
	
	pageLevel4[0].pml4e = pageLevel4[511].pml4e;
	
	// Create a level 2 entry
	pml2[] pageLevel2 = (cast(pml2*)pmem.request_phys_page())[0 .. 512];
	
	pageLevel2[] = pml2.init;
	
	// Set the 511th entry of level 3 to a level 2 entry
	pageLevel3[510].pml3e = cast(ulong)pageLevel2.ptr;
	// Set correct flags, present, rw, usable
	pageLevel3[510].pml3e |= 0x7;
	pageLevel3[0].pml3e = pageLevel3[510].pml3e;
	
	// Put the kernel in to the top X pages of vmemory
	
	// So where does our kernel actually live in physical memory?
	// Well if our physical page allocator works correctly then
	// we know that we have the first page after the kernel for
	// our PML4.  This means we can just jack that address,
	// and used it to determine our kernel size (we hope)!
	
	auto kernel_size = (cast(ulong)pageLevel4.ptr / PAGE_SIZE);
	// We know we start at 1m anyway, so we can just -0x100
	//kernel_size -= 0x100;
	
	auto addr = 0x00; 		// Current addr 
	
	for(int i = 0, j = 0; i < kernel_size; i += 512, j++) {
		// Make some page table entries
		pml1[] pageLevel1 = (cast(pml1*)pmem.request_phys_page())[0 .. 512];
		// Set pml2e to the pageLevel 1 entry
		pageLevel2[j].pml2e = cast(ulong)pageLevel1.ptr;
		pageLevel2[j].pml2e |= 0x7;
		
		// Now map all the physical addresses :)  YAY!
		for(int z = 0; z < 512; z++) {
			pageLevel1[z].pml1e = addr;
			pageLevel1[z].pml1e |= 0x87;
			addr += 4096;
		}
	}
	
	kprintfln!("kernel_size = {}")(kernel_size);
	kprintfln!("PageLevel 4 addr = {}")(pageLevel4.ptr);
	kprintfln!("Pagelevel 3 addr = {}, {x}")(pageLevel3.ptr, pageLevel4[511].pml4e);
	kprintfln!("Pagelevel 2 addr = {}, {x}")(pageLevel2.ptr, pageLevel3[510].pml3e);
	kprintfln!("Pagelevel 1 addr = {x}")(pageLevel2[0].pml2e);
	
	pml1[] tmp = (cast(pml1*)(pageLevel2[1].pml2e - 0x7))[0 .. 512];
	
	kprintfln!("Page address: {x}")(tmp[0].pml1e);
	
	asm {
		"mov %0, %%rax" :: "o" pageLevel4.ptr;
		"mov %%rax, %%cr3";
	}
}

//void* find_free_page() {
	
//}

//void allocate_virtual_page() {
	
//}
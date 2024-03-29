/* pmem.d - physical memory stuffs
 *
 * This file contains all of the physical memory handler stuffs
 * including the bitmap that maps used and unused physical pages!
 */


module kernel.mem.pmem;

import kernel.arch.select;

import kernel.arch.locks;

import kernel.error;
import kernel.core.util;
import kernel.core.multiboot;

import kernel.globals;

import kernel.dev.vga;

import config;

struct pMem
{
	static:

	// Bitmap of free pages
	ubyte[] bitmap;
	// CONST for page size
	const ulong PAGE_SIZE = 4096;			// 4k pages for us right now
	// Address of first available page
	ubyte* pages_start_addr;
	ulong mem_size;

	kmutex pMemMutex;

	ErrorVal install(multiboot_info_t* mbi) 
	{
		// we do not lock this, this is executed only by the main cpu
		// before other cpus use the rest of the routines

		// install the pmem bitmap
		auto mod = cast(module_t*)(cast(module_t*)mbi.mods_addr + mbi.mods_count - 1);
		ulong endAddr = mod.mod_end;
		mem_size = endAddr;

		// print out the number of modules loaded by GRUB, and the physical memory address of the first module in memory.
		//kdebugfln!(DEBUG_PMEM, "mods_count = {}, mods_addr = 0x{x}")(cast(int)mbi.mods_count, cast(int)mbi.mods_addr);
		//kdebugfln!(DEBUG_PMEM, "mods_end = 0x{x}")(endAddr);

		// If endAddr is aligned already we'll just add 0, so no biggie
		// Address of where to start pages
		pages_start_addr = cast(ubyte*)(endAddr + (endAddr % PAGE_SIZE));			// Available start address for paging
		// Free space avail for pages
		ulong pages_free_size = (cast(ulong)mbi.mem_upper * 1024) - cast(ulong)pages_start_addr;		// Free space available to us

		//kdebugfln!(DEBUG_PMEM, "Free space avail : {}KB")(pages_free_size / 1024);
		
		
		//kdebugfln!(DEBUG_PMEM, "pages_start_addr = 0x{x}")(pages_start_addr);
		//kdebugfln!(DEBUG_PMEM, "Mem upper = {u}KB")(mbi.mem_upper);
		
		// Page allocator
		// Find the total number of pages in the system
		// Determine bitmap size
		// Total number of pages in teh system

		mem_size = mbi.mem_upper * 1024;
		ulong num_pages =  mem_size / PAGE_SIZE;

		//kdebugfln!(DEBUG_PMEM, "Num of pages = {}")(num_pages);
		
		// Size the bitmap needs to be
		ulong bitmap_size = (num_pages / 8);			// Bitmap size in bytes
		if(bitmap_size % PAGE_SIZE != 0) {			// If it is not 4k aligned
			bitmap_size += PAGE_SIZE - (bitmap_size % PAGE_SIZE);	// Pad the size off to keep things page aligned
		}
		
		//kdebugfln!(DEBUG_PMEM, "Bitmap size in bytes = {}")(bitmap_size);		

		// Set up bitmap
		// Return a ulong a ptr to the bitmap

		// The bitmap :)
		bitmap = (pages_start_addr + cast(ulong)Globals.kernelVMemBase)[0 .. bitmap_size];

		// Now we need to properly set the used pages
		// First find the number of pages that are used
		// Number of used pages to init the mapping
		ulong num_used = (cast(ulong)pages_start_addr + bitmap_size) / PAGE_SIZE;	// Find number of used pages so far
		//kdebugfln!(DEBUG_PMEM, "Number of used pages = {}")(num_used);

		// Set the first part of the bitmap to all used
		bitmap[0 .. num_used / 8] = cast(ubyte)0xFF;
		
		// Where we change from used to unused, figure out the bit pattern to put in that slot
		bitmap[num_used / 8] = 0xFF >> (8 - (num_used % 8));
		
		// The reset of the bitmap is 0 to mean unused
		bitmap[num_used / 8 + 1 .. $] = 0;

		return ErrorVal.Success;
	}


	// Request a page
	// request_page(uint bitmap)
	//	bitmap => pointer to the bitmap of allocated pages
	// returns => uint pointer to a page

	void* requestPage() {

		pMemMutex.lock();

		// Iterate through the entire bitmap
		for(int i = 0; i < bitmap.length; i++) {
			// Iterate through the bitmap and check for a byte that is not full (free page)
			if(bitmap[i] < 0xFF) {
				// Find which page it is by shifting through the possible bits
				int z = 0;
				for(ubyte p = 1; p != 0; p <<= 1, z++) {
					// And anding it with the byte with free pages
					if((bitmap[i] & p) == 0) {
						// Now set that bit to taken
						bitmap[i] |= p;
						// Calculate the address of the page we need
						void* addr = cast(void*)(((i * 8) + z) * PAGE_SIZE);
						// Return the address of the free page

						pMemMutex.unlock();
						return (addr);
					}
					
				}
			}
		}

		pMemMutex.unlock();
		return null;
	}

	void freePage(void* address) {

		pMemMutex.lock();

		// Figure out which bit in the map we need to reset to 0
		ulong page = cast(ulong)(address) / PAGE_SIZE;
		ulong byte_num = page / 8;
		ulong bit_num = page % 8;
		
		ubyte mask = 1 << bit_num;
		
		bitmap[byte_num] &= (~mask);

		pMemMutex.unlock();
		
		//kdebugfln!(DEBUG_PMEM, "Returning bit {}; in byte {} of page {}\n")(bit_num, byte_num, page);
	}

	void test()
	{
		// Request a page for testing
		void* someAddr = requestPage();
		void* someAddr2 = requestPage();
		// Print the address for debug
		kdebugfln!(DEBUG_PMEM, "The address is 0x{x}\n")(someAddr);
		kdebugfln!(DEBUG_PMEM, "The address is 0x{x}\n")(someAddr2);

		freePage(someAddr2);

		void* someAddr3 = requestPage();
		kdebugfln!(DEBUG_PMEM, "The address is 0x{x}\n")(someAddr3);
	}
}

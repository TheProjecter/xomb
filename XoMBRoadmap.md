## TODO ##
  * lock-free/synchronization primitives FTW
  * make existing stuff (memory allocator) Multi-threaded safe

  * Map bios region (FFFFFFFF - 16MB) for HPET

  * deallocate page function
  * syscall for page alloc and dealloc
  * D runtime using page allocators
  * other userspace library stuff
  * console printf syscall

  * run a test userspace program, loaded as a grub module

  * runtime detection of MultiProcessing from BIOS MP table
  * set up IO APIC (and figure out how this relates to the IDT)
  * set up the local apic on the bootstrap processor
  * use lapic to boot up other processors
  * boot up from 8-bit real mode to 64 bit mode (ignore IDT? and use existing GDT and post- upper half kernel page table)
  * set up lapic

  * set up HPET to use IO APIC
  * write context switch code (usermode or kernel mode we will need both)
  * write a simple scheduler using HPET for 'tickless' quantuum
  * demo three program scheduling mayhem

# Current Workings #

  * Page faults + Intarrupts
  * Syscalls
  * Environments

# Future Workings #

  * User programs / LibOS for testing
  * Page Table - Swap
  * Scheduling
  * LibOS
  * APIC + Multi-processing

# Long Term #

  * Network
  * Storage
  * Paging + Swap
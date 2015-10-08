## Current Tasks ##
  * APIC / multiprocessor support
  * IPI
  * MP-sanctify the kernel and vga driver
    * vga, pmem, and vmem are locked
  * Timers
  * memory management for kernel (where do we link in RAM and devices)
  * video memory region?
  * investigate real world issues
  * create an environment (process) concept for the exokernel

## Design ##
  * test kgdb serial debugging (and allow kernel to process interrupts after gdb gets a shake)
  * execute an ELF64 multiboot module as a user space environment
  * Vitual Memory exokernel interface
  * interrupt inferface (MP)
  * scheduler interface
  * security scheme

## LibOS ##
  * userspace program loader
  * bare bones LibOS
  * init program / basic app. libs
  * Filesystem (+ device) libos
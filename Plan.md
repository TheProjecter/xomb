# Introduction #

Add your content here.


# Details #

## Proposed XOmB (the exokernel) Features ##
  * securely multiplexes hardware (resource protection), exposing as close to the bare metal as possible
  * when we must do something on the user's behalf, provide mechanism not policy
  * capability-based security
  * tickless scheduling
  * kgdb support

## Proposed PaGanOS (the rest of the OS, that sits on top of XOmB) Features ##
  * Integrated package manager that understands multiple versions of LibOSes (for different, workload-specific tradeoffs) and our security scheme
  * principle of least privilege exposed at all levels
  * new crypto-based security capabilites integrated at all levels, kprivd
  * tools for managing composable LibOSes that we want to link a specific/all executables against
  * DTrace suppport: [if they can put it in a microkernel without modifying The Kernel](http://sendreceivereply.wordpress.com/2007/11/08/i-trace-you-trace-what-about-dtrace/), we can too!

## Proposed LibOS Features ##
General Categories of LibOSes:
  * Vitual Machine LibOSes
  * Free OS (Linux/`*`BSD) as a LibOS
  * API Compatability layer (POSIX/LibC/MPI... Wine?)
  * Language environment (Java VM, logo interpreter, etc.)
  * Optimized subsystems (Zero copy network stack, write optimized I/O, etc.)


The list below is a rough compilation of some of the proposed functionality of LibOS extensions.
  * a Xen Hypervisor compatability layer (lets us run Windows + linux right beside 'native' PaGanOS APPs)
  * a VMware 'paravirt\_ops' compat layer (same reason as above)
  * MPI libOS (the supercomputing crowd loves MPI and x64, and they should love on exokernels too!)
  * JVM - anything that speeds up java wins the people's hearts (and corporate wallets :)
  * an 'arch/paganos' for linux to run directly on PaGanOS (compare to 'arch/xen')
  * a libDatabase with raw access to disk/cache behavior and paging. Databases are the most common application that break every assumption of OS abstractions.
  * composable LibOSes - customise based on your needs.
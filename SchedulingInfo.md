## Scheduling Citations ##
  * [Cheat: monopolizing the CPU without superuser privs](http://www.cs.huji.ac.il/~dants/papers/Cheat07Security.pdf) - Cool paper about scheduling and h4x
  * [Scheduler Activations: Effective Kernel Support for the User-Level Management of Parallelism](http://people.freebsd.org/~deischen/docs/p95-anderson.pdf) - This is the basis for the XOK exokernel's scheduling, although they used a simplified version.
  * [Intel's "Process Scheduling Challenges in the Era of Multi-Core Processors"](http://www.intel.com/technology/itj/2007/v11i4/9-process/5-multi-core-scheduling.htm) affinity and power aware scheduling, implemented in Linux.
  * [the Multicore association is coming.](http://arstechnica.com/news.ars/post/20080523-new-api-could-bring-multicore-mastery-to-embedded-devices.html)

### Market-foo ###
  * [free-market resource scheduling in GNU Hurd](http://www.walfield.org/papers/20050706-walfield-resource-scheduling.pdf)  I think that market-based scheduling is the ultimate way to handle the interdepencies of resource allocation (e.g. when thrashing, CPU, disk and memory allocations are all related).  Markets provide a sensible representation of power management trade-offs.  Markets should also encourage better programming (like, if you want your code to run fast you should also limit memory bloat).  If nothing else, we can steal this paper's citations.
  * [Market mechanisms in a programmed system](http://citeseer.ist.psu.edu/45731.html) again, if nothing else, Citeseer list some promising citations.

## Relevant ExoPC code ##
  * Get the code for the original XOK from http://pdos.csail.mit.edu/exo/distrib.html

## Prerequisites ##
  * Something to schedule: processes or XOK's same-but-not enviroments.
  * for Preemptive scheduling, one needs a timer device and the ability to set and respond to timing interrupts.


# Scheduling Questions #
  * how is general computation tim fairly divided?
  * how is interrupt handling scheduled?
  * how are events (request to run at a specific? future time) handled?


## Discussion ##
We don't have to follow the same path as XOK, so lets figure out what they did and then what we want to do, using the Scheduler Activations paper as a starting point (or using the Design and Implementation of 4.4 BSD book as a starting point if you want to get really into it).

### XOK vs Activations ###
  * Unlike most OSes, we do not believe an exokernel performs blocking operations, this should greatly simplify the Activation interactions.
  * Activations solve an M to N mapping for threads to processors, but the original XOK was uniprocessor.  The way that multiprocessor XOK was implemented was to give all processors to all processes, rather than Activation's idea of dynamically scaling the number of CPUs

### Want we what to DO ###
At the most basic level, XOmB understands quantum.  These quantum can be expressed in the form of a timeline, that scheduler libOSes can request quantum from.  LibOSes can either collaborate on scheduling, or each [environment](EnvironmentInfo.md) can contain its own scheduler.  Each scheduler requests a quantum or number of quanta from XOmB, which it delegates by giving quantum to the schedulers in some sort of fair manner.  The schedulers are then free to break up those quanta in any way they see fit.  Though XOmB does not ensure that each process gets its fair share of the CPU, by providing the schedulers time in a fair manner life is good.  There is still no consensus as to the best method of providing quanta to the scheduler.


# Proposal #
Market-based scheduling.  Each environment provides a vector of bids, i.e. how much it is willing to pay for each time slot.  The winner can be the high bid, second highest bid (a trick to keep everyone honest), or lottery scheduled where you bid is also the number of tickets you get.

Processes can reschedule at any time, periodic scheduling should be a part of a LibOS's prologue or epilogue stub.

Credits are refreshed periodically and remaining balances are 'decayed' or experience inflation to discourage hoarding, This should effectively enforce a cap to the number of credits it is possible to accumulate.

Interrupts are billed at the going rate, provided they take longer than some minimum time.
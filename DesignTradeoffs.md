# Introduction #
We need to make decisions now, in order to get a system going, without knowing the full implications.  In order to speed the process, we want a basic decision framework and documentation of tradeoffs so we can re-examine them later.

# Links #
  * [Worse is Better](http://en.wikipedia.org/wiki/Worse_is_better)  a wikipedia page about the Worse is Better (New Jersey) design philosophy.

# Tradeoffs #
  * **multicore x64, no legacy**
This hardware is already over 50% of the market, and as old designs are milked for extra life this paradigm will trickle down, even to the high-end embedded market.


  * **bitmap page allocator** vs linked-list free-map or crazy trie/b+tree foo.
Do it simple first.


  * **no drivers in XOmB**
We want to avoid putting anything in the way of the use abusing hardware as they see fit.


  * **Batch syscalls vs. register syscalls  also, nonblocking?**
while testing and timing will be required, we expect that most exokernel system calls will see more benefit from batching than speeding the turn around time of single requests.  it is also possible that the two are not mutually exclusive.  As system calls are not expected to interact with devices (since XOmB doesn't speak device) we do not expect the need for system calls to block.  However, if an unlimited number of system calls can be batch processed, either a cap or resource accounting must be used to prevent abuse.


  * **Static MP Configuration Table Entry arrays vs Dynamic MP Configuration Table Entry arrays**
Static arrays were chosen for the sake of simplicity. If dynamic arrays are used later we will have to decide what page we want to place this in and then get and format it as needed.
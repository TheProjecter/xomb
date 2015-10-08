# Introduction #

All processes in XOmB will utilize the idea of an environment.  An environment is essentially a page in memory (4k in size) that contains the basic elements essential to that process:
  * Timeline - the virtual timeline presented to the process by the scheduler
  * Pointer to relevant [prologue and epilogue code](PrologueAndEpilogue.md).
  * Space for context switching needs (since all processes will effectively switch themselves out)


# Details #
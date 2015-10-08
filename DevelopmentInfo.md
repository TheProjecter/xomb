We are using subversion as our version tracking, the code can be checked out via http://xomb.googlecode.com/svn .  We also have a development server to minimize the time spent getting a build environment working (contact someone for an account).  Since XOmB is x86\_64 many of us would have to use a D cross compiler to produce 64bit code from a 32bit environment, **however** if you would like to develop locally feel free to use the links below to establish your build environment.

## Build Tools ##
You'll need a number of tools to build locally including:

  * [SVN](http://subversion.tigris.org) - for accessing and contributing code
    * [svn tips](http://www.onlamp.com/pub/a/onlamp/2004/08/19/subversiontips.html)
    * [SVN properties](http://svnbook.red-bean.com/en/1.0/ch07s02.html) - these are the tags you can insert in code (Id, revision, etc)
    * add something about SVN tags and branches
  * [The D compiler](http://www.digitalmars.com/d) - the D compiler for compiling and building the code
  * [Bochs](http://bochs.sourceforge.net/) or [QEMU](http://fabrice.bellard.free.fr/qemu/)  for testing, though bochs is recommended.
    * If you are using Bochs, compile it with the information contained in 'xomb/doc/bochs-install.txt' from svn


If you're on a 32 bit machine you'll need to build a cross compiler instead of just the native D compiler.  Information on how to do this can be found here: [Cross Compiling Guide](http://www.osdev.org/osfaq2/index.php/GCC%20Cross-Compiler).
# malc

Mal (Make A Lisp) compiler

## Overview

[Mal](https://github.com/kanaka/mal) is Clojure inspired Lisp language invented
by Joel Martin as a learning tool.  It has interpreter implementations in dozens
of programming languages, including self-hosted interpreter written in Mal
itself.

malc is a compiler for Mal, written in Mal itself.  It compiles a Mal program to
[LLVM assembly language (IR)](http://llvm.org/docs/LangRef.html), and then uses
the LLVM optimizer, assembler and gcc linker to produce a binary executable.

This project main goal was a way for me to learn about Lisp, compilation and
LLVM.  It is not intended for use in any serious application or system.


## Installation

malc depends on LLVM, of course. Moreover, the executables generated by malc
are dynamically linked with the Boehm Garbage Collection shared library
(`libgc.so`) and with the readline shared library.

To install the dependencies on Debian/Ubuntu:

    sudo apt-get install llvm libgc-dev libreadline6

To install the dependencies on RedHat/CentOS:

    sudo yum install llvm gc-devel readline

Besides these dependencies, malc needs a working Mal interpreter; malc comes
bundled with the Ruby implementation of the Mal interpreter (in
`mal-interpreter` directory) to easier invocation of malc.  Hence, a working
Ruby runtime is required.


## Usage

Run the `malc` wrapper script with the mal program file as the argument:

    ./malc myprogram.mal

If successful, this will generate the executable `myprogram`.  The executable
dynamically links with `libc` and `libgc` (the Boehm Garbage Collection
shared library).


## Running tests

The functional tests for malc are in files under the `tests/` directory.

To run all the tests:

    ./runtests.sh

To run a specific test file:

    ./runtests.sh tests/integer_compare.mal


## Running performance tests

The Mal performance tests are copied over and can be run with:

    ./runperf.sh

Please note the caveat from [Mal's own
README](https://github.com/kanaka/mal#performance-tests):

> Warning: These performance tests are neither statistically valid nor
> comprehensive; runtime performance is a not a primary goal of mal. If you
> draw any serious conclusions from these performance tests, then please
> contact me about some amazing oceanfront property in Kansas that I'm willing
> to sell you for cheap.


## Implementation details

See [internals documentation](doc/internals.md).


## Additions to Mal

The following functions were added:

* `(os_exit EXITCODE)` - exits the process with the given integer exit code.
* `(gc-get-heap-size)` - Boehm GC's `GC_get_heap_size()`
* `(gc-get-total-bytes)` - Boehm GC's `GC_get_total_bytes()`


## What's missing?

A lot. See the [TODO list](doc/TODO.md).


## License

malc (make-a-lisp compiler) is licensed under the MPL 2.0 (Mozilla Public
License 2.0). See LICENSE.txt for more details.

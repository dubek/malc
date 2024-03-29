# malc

Mal (Make A Lisp) compiler

## Overview

[Mal](https://github.com/kanaka/mal) is Clojure inspired Lisp language invented
by Joel Martin as a learning tool.  It has interpreter implementations in dozens
of programming languages, including self-hosted interpreter written in Mal
itself.

malc is a compiler for Mal, written in Mal itself.  It compiles a Mal program to
[LLVM assembly language (IR)](http://llvm.org/docs/LangRef.html), and then uses
the LLVM optimizer, assembler and linker to produce a binary executable.

This project main goal was a way for me to learn about Lisp, compilation and
LLVM.  It is not intended for use in any serious application or system.


## Using malc from a ready-made Docker image

The public Docker image `dubek/malc` has malc installed in /opt/malc (also in
`$PATH`). Here's an example of compiling and running a small Mal program:

    $ docker run -it --rm dubek/malc
    root@c6cf6e2ec3eb:/# cd tmp
    root@c6cf6e2ec3eb:/tmp# echo '(prn "test" (+ 23 45))' > test.mal
    root@c6cf6e2ec3eb:/tmp# malc -v -c test.mal
    malc: Source file: /tmp/test.mal
    malc: Compile mode: release
    malc: Intermediate LLVM IR file: /tmp/test.ll
    malc: Compiling Mal program to LLVM IR
    malc: Using binary compiler: /opt/malc/mal-to-llvm
    malc: Optimizing LLVM IR to: /tmp/test.opt.ll
    malc: Compiling LLVM IR to object file: /tmp/test.o
    malc: Linking executable file: /tmp/test
    malc: Cleaning up
    malc: Done
    root@c6cf6e2ec3eb:/tmp# ./test
    "test" 68


## Installation

### Dependencies

malc depends on LLVM, of course, including its linker (`lld`); this requires
LLVM 4.0 or newer. Moreover, the executables generated by malc are dynamically
linked with libstdc++ (for exception handling routines), with the Boehm Garbage
Collection shared library (`libgc.so`) and with the readline shared library.

To install the dependencies on Debian/Ubuntu:

    sudo apt install libreadline-dev libgc-dev llvm clang lld

Besides these dependencies, malc needs a working Mal interpreter in order to
compile itself.  malc comes bundled with the Python implementation of the Mal
interpreter (in `mal-interpreter` directory) for an easier invocation of malc.
Hence, a working Python runtime is required (`sudo apt install python3` should
do it).  Alternatively, you can choose another Mal interpreter implementation
using the `MAL_IMPL` environment variable; see below.

### Bootstrapping

The main logic of malc is the `mal-to-llvm` program, written in Mal itself.  As
part of the installation, we compile mal-to-llvm with itself (you can go and
read this sentence again now).  The `bootstrap.sh` script does exactly that:

    ./bootstrap.sh

This will create the `mal-to-llvm` executable, which is used by the `malc`
wrapper script.  Now malc is ready to use.

By default, `bootstrap.sh` uses the bundled Python implementation of the Mal
interpreter.  To use another implementation during bootstrapping, set the
`MAL_IMPL` environment variable to the path of the Mal implementation
executable.  For example:

    # Bootstrap using the Ruby implementation:
    MAL_IMPL=../mal/impls/ruby/run ./bootstrap.sh

    # Bootstrap using the OCaml implementation:
    MAL_IMPL=../mal/impls/ocaml/stepA_mal ./bootstrap.sh


## Usage

    malc [-g] [-l] [-v] -c source_file.mal [-o executable_file]

Where the options are:

* `-h/-?`: Display the help message
* `-c FILENAME`: Mal source file name to compile
* `-g`: Enable debug mode (mark functions as external for clearer stack traces)
* `-l`: Keep intermediate LLVM IR filse
* `-o FILENAME`: Output executable file name
* `-v`: Enable verbose logging

### Basic usage

Run the `malc` as follows with the Mal program file:

    ./malc -c myprogram.mal

If successful, this will generate the executable `myprogram`.

Add the `-v` switch to enable verbose logging of the malc stages.

Add the `-o FILENAME` switch to chooose another name for the resulting
executable file:

    ./malc -c myprogram.mal -o prog

If successful,  this will generate the executable `prog`.

### Adding debug information

If you want to debug the binary (with gdb), use the `-g` switch:

    ./malc -g -c myprogram.mal

This will instruct the compiler to mark the generated LLVM functions with
`external` linkage type (as opposed to the `private` linkage type).  This
leaves the functions names in the resulting executable, thereby allowing more
readable stack traces; however, it might prevent the optimizer from inlining
some functions.

Note that currently malc doesn't add full-fledged debug information.

### Examining generated LLVM IR code

If you want to look at the LLVM code generated by malc, use the `-l` switch:

    ./malc -l -c myprogram.mal

This will generate `myprogram.ll` (the LLVM code produced by `mal-to-llvm`),
`myprogram.opt.ll` (LLVM code after the LLVM optimizer) and `myprogram` (the
executable file).

### Running malc with a Mal interpreter

By default malc uses the `mal-to-llvm` executable which is created during the
boostrapping step.  Since `mal-to-llvm` is written in Mal, you may chooose to
run it with any Mal interpreter you want, instead of running the compiled
(bootstrapped) executable. (At the time of writing there are
[56](https://github.com/kanaka/mal) Mal interpreter implementations!)

Use the `MAL_IMPL` (path to the Mal implementation) environment variable to
instruct malc to use another Mal interpreter.  For example:

    # Run malc using the Python implementation:
    MAL_IMPL=../mal/python/run ./malc -c myprogram.mal

    # Run malc using the OCaml implementation:
    MAL_IMPL=../mal/ocaml/run ./malc -c myprogram.mal

At this point there's a limitation - when malc is invoked using a Mal
interpreter it must be invoked from the malc project root directory.


## Running tests

The functional tests for malc are under the `tests/` directory.

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

* `(os-exit EXITCODE)` - exits the process with the given integer exit code.
* `(gc-get-heap-size)` - Boehm GC's `GC_get_heap_size()`
* `(gc-get-total-bytes)` - Boehm GC's `GC_get_total_bytes()`

The following variables were added:

* `*ARGV0*` - string which holds the value of argv[0] from the executable
  `main()` entry function.


## Bonus: Compiling the Mal interpreter

Compilers are nice, but what if you want an interpreter with interactive REPL?
No worries; the Mal project comes with a Mal interepreter implemented in Mal.
We can compile it with malc to get an standalone executable interpreter.

First, clone the Mal project and go into its `mal` sub-directory:

    git clone https://github.com/kanaka/mal
    cd mal/mal

Compile the interpreter (I chose stepA here):

    /path-to-malc/malc -v -c stepA_mal.mal

The executable `stepA_mal` is ready; you can run it to get an interactive REPL:

    $ ./stepA_mal
    Mal [malc-mal]
    mal-user> (+ 4 5)
    9
    mal-user> *host-language*
    "malc-mal"

You can also run the extensive tests that come with the Mal project (for all
steps):

    $ ../runtest.py ../tests/stepA_mal.mal -- ./stepA_mal
    ...

    Testing readline
    TEST: (readline "mal-user> ") -> ['',*] -> SUCCESS
    TEST: "hello" -> ['',"\"hello\""] -> SUCCESS

    ...

    Testing metadata on mal functions
    TEST: (meta (fn* (a) a)) -> ['',nil] -> SUCCESS
    TEST: (meta (with-meta (fn* (a) a) {"b" 1})) -> ['',{"b" 1}] -> SUCCESS
    TEST: (meta (with-meta (fn* (a) a) "abc")) -> ['',"abc"] -> SUCCESS
    TEST: (def! l-wm (with-meta (fn* (a) a) {"b" 2})) -> ['',*] -> SUCCESS
    TEST: (meta l-wm) -> ['',{"b" 2}] -> SUCCESS

    ...

    TEST RESULTS (for ../tests/stepA_mal.mal):
        0: soft failing tests
        0: failing tests
       81: passing tests
       81: total tests

And run the interpreter performance benchmark:

    $ ./stepA_mal ../tests/perf3.mal
    iters/s: 77

The `run-mal-tests.sh` clones the Mal project repository, compiles the Mal
implementation and runs all the Mal interpreter tests.


## What's missing?

A lot. See the [TODO list](doc/TODO.md).


## Related reading

* [Structure and Interpretation of Computer Programs: 5.5 - Compilation](https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book-Z-H-35.html#%_sec_5.5) by Harold Abelson and Gerald Jay Sussman with Julie Sussman
* [LLVM Language Reference Manual](http://llvm.org/docs/LangRef.html)
* [Exception Handling](http://llvm.org/docs/ExceptionHandling.html)
* [Mapping High-Level Constructs to LLVM IR](https://mapping-high-level-constructs-to-llvm-ir.readthedocs.io/en/latest/README.html#) by Mikael Lyngvig and 
Michael Rodler
* [Boehm-Demers-Weiser Garbage Collector](http://www.hboehm.info/gc/)


## License

malc (make-a-lisp compiler) is licensed under the MPL 2.0 (Mozilla Public
License 2.0). See LICENSE.txt for more details.

malc includes a whole Mal interpreter written in Mal. The files
`macros-eval.mal`, `macros-env.mal` and `macros-core.mal` are taken from the
[Mal project](https://github.com/kanaka/mal), Copyright (C) 2015 Joel Martin,
licensed under the MPL 2.0 (Mozilla Public License 2.0).

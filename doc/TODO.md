# malc TODO

Functions missing from the Mal core:

- eval (requires JIT compiling?)

Compiler features:

- memory structure: since elementarray and bytearray sizes are known during
  allocation, we can allocate one continuous space for header + data (instead
  of allocating the data array separately).
- better error detection during compilation (for example, calling `+` with
  non-integer arguments, or wrong number of arguments)
- add debugging symbols (-g)
- hide malc's internal functions (those defined in nativefuncs.mal) so they
  won't be visible from the user's Mal program (but will be visible to
  `runtime-core-funcs.mal`)

Performance:

- don't compile the "standard library" every time.  Compile `nativefuncs.mal`
  into an object file or archive once, and just link it to any Mal program that
  is compiled.
- hash tables are linear lists with O(n) lookup/add/remove complexity.

Tests:

- automatically convert test suites from the Mal project to executable testable
  programs compiled by malc

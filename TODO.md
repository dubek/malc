# malc TODO

Functions missing from the Mal core:

- conj
- exceptions / throw / try-catch
- str / pr-str / prn / println
- meta / with-meta
- read-string (that's a big one)
- eval (requires JIT compiling?)

Fetaures missing from the runtime:

- TCO
- exceptions

Compiler features:

- separate macro namespace (currently we expand macros in malc's namespace, which is ugly)
- better error detection (for example, calling `+` with non-integer arguments,
  or wrong number of arguments)
- deduplicate strings list
- add debugging symbols (-g)

Tests:

- Automatically convert test suites from the Mal project to executable testable
  programs compiled by malc

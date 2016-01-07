# malc

mal (Make A Lisp) compiler

## Object structure

`mal_val_t` is a 32-bit value which can be one of the following:

* Integer
* Constant (nil, false, true)
* Pointer to object

### Integers

(`the_int_value << 1`) & 0x1

### Constants

nil = 0x00000002
false = 0x00000004
true = 0x00000006

### Objects

12 bytes header:

```
struct mal_obj_t {
  uint32_t flags;
  uint32_t len;
  byte* data;
}
```

flags:

17 - 0x11 - symbol
18 - 0x12 - string
19 - 0x13 - keyword

 len - N number of chars in data
 data - points to char array of length N

33 - 0x21 - list
34 - 0x22 - vector
35 - 0x23 - hash-map

  len = N number of elements
  data - points to array of N `mal_val_t` entries

49 - 0x31 - atom - implemented as a vector of size 1.

65 - 0x41 - Env - implemented as a vector with two elements:

* Index 0: `outer` - an outer environment, or `nil` if this is the root environment
* Index 1: `data` - a hash-map from variables names to their values

66 - 0x42 - Func - implemented as a vector with three elements:

* Index 0: `arg_names` - Vector of symbols (argument names)
* Index 1: `env` - Env
* Index 2: `func_ptr` - Function pointer (of type: %mal_obj fn(%mal_obj env))

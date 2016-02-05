# malc internals

This document specifies some internal details about the implementation of malc
(Mal compiler).

### Object structure

`%mal_obj` is a 64-bit value which can hold one of the following:

* Integer
* Constant (nil, false, true)
* Pointer to object

### Integers

Integers are represent as a `%mal_obj` value which has its least significant
bit set. The upper 63 bits hold the integer itself. To represent an integer `X`
as `%mal_obj`:

    mal_obj_value = (X << 1) | 0x1

### Constants

The three constant values are represented by the following 64-bit values:

* 2 - `nil`
* 4 - `false`
* 6 - `true`

### Objects

If a `%mal_obj` is not an integer and not a constant, it is treated as a
pointer to a `%mal_obj_header_t` struct (16 bytes struct):

```
struct %mal_obj_header_t {
  uint32_t type;
  uint32_t len;
  void* data;
}
```

The `data` field can point into either a bytearray (`char*`) or an elementarray
(`%mal_obj*`), depending on the value of `type`.

#### Bytearray objects ####

Mal types *symbol*, *string* and *keyword* are held internally as bytearray
objects.  For these objects, the `len` field in the object header holds the
length of the string pointed by `data` in bytes (including a terminating null
char).  `data` of course points to the byte array itself.

The type field indicates the Mal type:

* 17 - Symbol
* 18 - String
* 19 - Keyword

#### Elementarray objects ####

All other Mal types (list, vector, hash-map and atom), are held internally as
elementarray objects.  In those objects, the `len` fields holds the number of
elements in the `data`, and `data` points to an array of `%mal_obj` elements
(which in turn can be of any type - integer, boolean, string, vector, etc.).

The type field indicates the Mal type:

* 33 - List
* 34 - Vector
* 35 - Hash-map
* 49 - Atom

*Lists* and *vectors* are simple - an N-element list (or vector) is stored as
an elementarray with length N.

*Hash-maps* are stored as an element array of alternating keys and values (K1,
V1, K2, V2, ...); note that the `len` field for hash-maps will be twice than
the number of keys in the hash. Also note that this is a very naive (read:
slow) implementation; key lookup is performed with an O(n) linear search.

*Atoms* are stored as an elementarray with exactly one element (the atom's
value).

#### Internal types ####

The three internal types Env, Func and NativeFunc are held as elementarrays
with special designation for each "slot" (poor man's struct).

##### Env #####

For Env objects, `type` is 65 and `len` is 2. The `data` elements are:

* Index 0: `outer` - Outer environment (Env object), or `nil` if this is the
  root environment
* Index 1: `data` - Hash-map from variables names (symbols) to their values
  (any Mal value)

##### Func #####

For Func objects, `type` is 66 and `len` is 3. The `data` elements are:

* Index 0: `arg_names` - Arguments names (vector of symbols)
* Index 1: `env` - Env object
* Index 2: `func_ptr` - Function pointer (of type: `%mal_obj fn(%mal_obj env)`)

##### NativeFunc #####

For NativeFunc objects, `type` is 67 and `len` is 3. The `data` elements are:

* Index 0: `arg_names` - Arguments names (vector of symbols)
* Index 1: `name` - Function name (symbol)
* Index 2: `func_ptr` - Function pointer, of one of the following types (according to length of `arg_names`):
  - 0 arguments: `%mal_obj()`
  - 1 arguments: `%mal_obj(%mal_obj)`
  - 2 arguments: `%mal_obj(%mal_obj,%mal_obj)`
  - 3 arguments: `%mal_obj(%mal_obj,%mal_obj,%mal_obj)`

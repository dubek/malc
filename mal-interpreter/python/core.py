import copy, time
from itertools import chain

import mal_types as types
from mal_types import MalException, List, Vector
import mal_readline
import reader
import printer

# Errors/Exceptions
def throw(obj): raise MalException(obj)


# String functions
def pr_str(*args):
    return " ".join(map(lambda exp: printer._pr_str(exp, True), args))

def do_str(*args):
    return "".join(map(lambda exp: printer._pr_str(exp, False), args))

def prn(*args):
    print(" ".join(map(lambda exp: printer._pr_str(exp, True), args)))
    return None

def println(*args):
    print(" ".join(map(lambda exp: printer._pr_str(exp, False), args)))
    return None


# Hash map functions
def assoc(src_hm, *key_vals):
    hm = copy.copy(src_hm)
    for i in range(0,len(key_vals),2): hm[key_vals[i]] = key_vals[i+1]
    return hm

def dissoc(src_hm, *keys):
    hm = copy.copy(src_hm)
    for key in keys:
        hm.pop(key, None)
    return hm

def get(hm, key):
    if hm is not None:
        return hm.get(key)
    else:
        return None

def contains_Q(hm, key): return key in hm

def keys(hm): return types._list(*hm.keys())

def vals(hm): return types._list(*hm.values())


# Sequence functions
def coll_Q(coll): return sequential_Q(coll) or hash_map_Q(coll)

def cons(x, seq): return List([x]) + List(seq)

def concat(*lsts): return List(chain(*lsts))

def nth(lst, idx):
    if idx < len(lst): return lst[idx]
    else: throw("nth: index out of range")

def first(lst):
    if types._nil_Q(lst): return None
    else: return lst[0]

def rest(lst):
    if types._nil_Q(lst): return List([])
    else: return List(lst[1:])

def empty_Q(lst): return len(lst) == 0

def count(lst):
    if types._nil_Q(lst): return 0
    else: return len(lst)

def apply(f, *args): return f(*(list(args[0:-1])+args[-1]))

def mapf(f, lst): return List(map(f, lst))

# retains metadata
def conj(lst, *args):
    if types._list_Q(lst): 
        new_lst = List(list(reversed(list(args))) + lst)
    else:
        new_lst = Vector(lst + list(args))
    if hasattr(lst, "__meta__"):
        new_lst.__meta__ = lst.__meta__
    return new_lst

def seq(obj):
    if types._list_Q(obj):
        return obj if len(obj) > 0 else None
    elif types._vector_Q(obj):
        return List(obj) if len(obj) > 0 else None
    elif types._string_Q(obj):
        return List([c for c in obj]) if len(obj) > 0 else None
    elif obj == None:
        return None
    else: throw ("seq: called on non-sequence")

# Metadata functions
def with_meta(obj, meta):
    new_obj = types._clone(obj)
    new_obj.__meta__ = meta
    return new_obj

def meta(obj):
    return getattr(obj, "__meta__", None)


# Atoms functions
def deref(atm):    return atm.val
def reset_BANG(atm,val):
    atm.val = val
    return atm.val
def swap_BANG(atm,f,*args):
    atm.val = f(atm.val,*args)
    return atm.val


ns = { 
        '=': types._equal_Q,
        'throw': throw,
        'nil?': types._nil_Q,
        'true?': types._true_Q,
        'false?': types._false_Q,
        'number?': types._number_Q,
        'string?': types._string_Q,
        'symbol': types._symbol,
        'symbol?': types._symbol_Q,
        'keyword': types._keyword,
        'keyword?': types._keyword_Q,
        'fn?': lambda x: (types._function_Q(x) and not hasattr(x, '_ismacro_')),
        'macro?': lambda x: (types._function_Q(x) and
                             hasattr(x, '_ismacro_') and
                             x._ismacro_),

        'pr-str': pr_str,
        'str': do_str,
        'prn': prn,
        'println': println,
        'readline': lambda prompt: mal_readline.readline(prompt),
        'read-string': reader.read_str,
        'slurp': lambda file: open(file).read(),
        '<':  lambda a,b: a<b,
        '<=': lambda a,b: a<=b,
        '>':  lambda a,b: a>b,
        '>=': lambda a,b: a>=b,
        '+':  lambda a,b: a+b,
        '-':  lambda a,b: a-b,
        '*':  lambda a,b: a*b,
        '/':  lambda a,b: int(a/b),
        'time-ms': lambda : int(time.time() * 1000),

        'list': types._list,
        'list?': types._list_Q,
        'vector': types._vector,
        'vector?': types._vector_Q,
        'hash-map': types._hash_map,
        'map?': types._hash_map_Q,
        'assoc': assoc,
        'dissoc': dissoc,
        'get': get,
        'contains?': contains_Q,
        'keys': keys,
        'vals': vals,

        'sequential?': types._sequential_Q,
        'cons': cons,
        'concat': concat,
        'vec': Vector,
        'nth': nth,
        'first': first,
        'rest': rest,
        'empty?': empty_Q,
        'count': count,
        'apply': apply,
        'map': mapf,

        'conj': conj,
        'seq': seq,

        'with-meta': with_meta,
        'meta': meta,
        'atom': types._atom,
        'atom?': types._atom_Q,
        'deref': deref,
        'reset!': reset_BANG,
        'swap!': swap_BANG}


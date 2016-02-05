# Mal interpreter

This directory includes a copy of the code of the Ruby implementation of Mal
interpreter written by Joel Martin. It is copied from the [`ruby` directory of
the Mal project](https://github.com/kanaka/mal/tree/master/ruby).

The interpreter is used to run malc, which is itself written in Mal.

Supposedly you could use any mal interpreter implementation from the [Mal
project](https://github.com/kanaka/mal).  However, as of February 2016 there
are no string operations in Mal, and we utilize the Ruby implementation duck
typing to use the `count` function to measure strings length.  Once a proper
string handling functions are added to all Mal implementations, we could use
any Mal implementation to run malc.

## License

Mal (make-a-lisp) is licensed under the MPL 2.0 (Mozilla Public License 2.0).
See LICENSE.txt in this directory for more details.

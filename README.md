![graph-includes](graph-includes.png)

`graph-includes`
================
Print `#include` graph in graphviz format.

Why
---
Regular expressions are not enough, and clang is too much.

What
----
`graph-includes` is a `raco` command that, given a list of files and/or
directories, constructs a dependency graph from `#include` directives in the
source files, and prints the graph in graphviz (dot) format to standard output.

How
---
### Example Usage
```console
$ git clone https://github.com/lua/lua
$ raco graph-includes lua/ | dot -Tsvg -o examples/lua.svg
$ firefox examples/lua.svg
```

### Install
```console
$ raco pkg install
```

More
----
Here's an `svg` rendering of the output for Lua's source code (might want to
"Open image in new tab"):
![lua #include dependnecy graph](examples/lua.svg)
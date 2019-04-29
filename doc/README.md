Package documentation tools
===========================

This is Andrew Janke's summary of how the doco generation tools in this `doc/` directory work.

# How it works now

## The files

Code files:
  * *.pl, *.pm, Makefile

User-maintained input files:
  * ../INDEX
  * chrono.texi.in
  * chrono.qhcp

Generated intermediate files:
  * chrono.texi
  * DOCSTRINGS.texi.tmp
  * TIMESTAMP
  * html/*
  * *.dvi
  * chrono.log
  * chrono.qhp

Generated output target files:
  * chrono.html
  * chrono.info
  * chrono.pdf
  * chrono.qch

`html/*` is an intermediate file because it's just used for packaging up into `chrono.qch`, the QHelp collection file. It's not intended for users to read directly; the single-node `chrono.html` is for that.

DOCSTRINGS.texi.tmp is not a regular texinfo file. It is a list of blocks, separated by ASCII Unit Separator characters. Each block contains the function/node name on the first line, and then the rest of the block is Texinfo (starting with a `-*- texinfo -*-` line; I don't know if that's part of the actual texinfo code).

## The process

  * You launch `make doc` using the `Makefile`. It causes the rest to happen.
  * `mkdoc.pl` reads the source files (in `../inst` and `../src`) and extracts their embedded Texinfo blocks to `DOCSTRINGS.texi.tmp`
    * `mkdoc.pl` discovers all .m and .cc files directly under a given directory
  * `mktexi.pl`
    * Reads `<pkg>.texi.in`
    * Reads `../INDEX`
    * Reads `DOCSTRINGS.texi.tmp`
    * Substitues stuff in `<pkg>.texi.in`
      * `%%%%PACKAGE_VERSION%%%%` with package version from `../DESCRIPTION`
      * `@DOCSTRING(...)` lines with something drawn from `func_doco()`
        * It's the full doco text from `DOCSTRINGS.texi.tmp`; treating function name as an item/block
      * `@REFERENCE_SECTION(<name>)` lines with the full generated API reference section
        * The `<name>` seems to be ignored
        * “Functions by Category” is generated based on what's in `../INDEX`, with just summary lines under each function. INDEX line order governs the order of items in Functions by Category.
        * “Functions Alphabetically” is also generated based on `../INDEX`, but includes the full item doco for each function. This is done alphabetically by function name.
    * Writes `<pkg>.texi`


`mktexi.pl` automatically emits the `@node`, `@section`, and `@subsection` nodes.
  * Functions by Category is a `@section`; within it, each category is a `@subsection`, and each function is an `@item` within a `@table`.
  * Functions Alphabetically is a `@section`; within it, each function is a `@subsection`.

# What I want to happen

* During file discovery, it should recurse into namespace directories, and `@<classname>` class definition directories; but not arbitrary directories, because Octave paths don't work like that
* In the reference section, it should be a generic "items" instead of functions, where each item is a global function or a class.
* Methods, Static Methods, Events, and other things under classes should be `@subsubsection`s under the class `@section` in Functions Alphabetically.
* Should it require that all methods be included in the INDEX? Or should you just include a class in the INDEX, and that will automatically pull in all its methods that are documented? I think the latter.
* Each class thing (method, event, maybe property? Or a special Properties node? Maybe constructors?) should be included in the QHelp keyword index

To do this, I think I need to structure the parsed help text more. It should be stored in a 2-level "top things" and "sub-things" structure, where the "top things" are the global identifier-named things (that turn into `@subsection`s), and "sub-things" for each top thing holds the blocks for class things (methods, events) (which should turn into `@subsubsection`s). Each of these things should be a node.

Should the keyword index be generated from all `@node`s found in an intermediate .texi file that contains just the API Reference stuff? Or directly from the things structure? Or does that even make a difference.

I think I want to preserve the order of class things subsubsections within a class, so you get things grouped by topic, instead of alphabetically.

Instead of storing namespaced things hierarchically, I think I'll just flatten them, and store everything under its fully-namespace-qualified name in the top level things structure.

I want to support files in `@<classname>` dirs, having their texinfo blocks go under their defining class as sub-things.

For the file format, I think I'll keep the first block in the files as is — no `@node` or `@subsection` lines — for back-compatibility. Then require secondary blocks in files, or blocks in `@<classname>/<method>.m` files, to have explicit `@node` lines. (Otherwise how are you going to know what they're for? I don't want to scan the file for the next function or whatever.) But no `@subsubsection` lines; those will be inserted by the code generator, based on context.

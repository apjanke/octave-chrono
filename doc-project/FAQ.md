Chrono FAQ
==========

# Build issues

## I'm getting weird `sed: ...@documenten...` warnings in the `make doc` step

Like this?

```
$ make doc
[...]
/usr/local/opt/texinfo/bin/texi2pdf --quiet --clean -o chrono.pdf chrono.texi
sed: 2: "s/\(^\|.* \)@documenten ...": whitespace after branch
sed: 4: "s/\(^\|.* \)@documenten ...": whitespace after label
sed: 6: "s/\(^\|.* \)@documenten ...": undefined label 'found
```

Those warnings are produced by older Texinfo programs, like Texinfo 4.8, which is the default on
macOS 10.13 and 10.14. Install a newer Texinfo using Homebrew and pull that in explicitly for your build.

```
brew install texinfo
PATH="$(brew --prefix texinfo)/bin:$PATH" make doc
```

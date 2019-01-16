Chrono
======

Date/time functionality for GNU Octave.

This package attempts to provide a set of mostly-Matlab-compatible date/time classes and functions, including `datetime`, `duration`, and `calendarDuration`. It has support for time zones (or rather, it will, once it's fully implemented).

All the code in here is currently experimental. Do not use it in any production code!

## Installation and usage

### Quick start

To get started using or testing this project, install it using Octave's `pkg` function:

```
pkg install https://github.com/apjanke/octave-addons-chrono/archive/master.zip
pkg load chrono
```

### Installation for development

* Clone the repo.
  * `git clone https://github.com/apjanke/octave-addons-chrono`
* Add the `inst/` directory from the repo to your Octave path.
* Build the octfiles.
  * `make_local` will do this.

## Requirements

Chrono runs on Octave 4.0.0 and later.

On Windows 7 and earlier, Java is required to detect the system default time zone.

Building Chrono requires a compiler. That means you need to [install Visual Studio
Community](https://visualstudio.microsoft.com/downloads/) on Windows.

## License

Chrono contains material licensed under the GPL, the Unicode license, and Public Domain.

* All the code in this package is GPLv3.
* The Unicode `windowsZones.xml` file redistributed with this package is under the Unicode license. See LICENSE-Unicode for details. Full info is available [on the Unicode website](http://www.unicode.org/copyright.html).
* The IANA time zone database ("zoneinfo") redistributed with this package is Public Domain.

## Naming conventions

Anything in a namespace with `internal` in its name is for the internal use of this package, and is not intended for use by user code.

## Documentation

See the `doc-project/` directory for notes on this project, especially for [Developer Notes](doc-project/Developer-Notes.md). Also see [CONTRIBUTING](CONTRIBUTING.md) if you would like to contribute to this project.

Real user documentation is hopefully coming soon.

## Author

Chrono is created by [Andrew Janke](https://apjanke.net).

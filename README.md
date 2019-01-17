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

## Documentation

The user documentation is in the `doc/` directory. See `doc/chrono.html` or `doc/html/index.html` for
the manual.

The developer documentation (for people hacking on Chrono itself) is in `doc-project/`. Also see 
[CONTRIBUTING](CONTRIBUTING.md) if you would like to contribute to this project.

## License

Chrono contains material licensed under the GPL, the Unicode license, and Public Domain.

* All the code in this package is GPLv3.
* The Unicode `windowsZones.xml` file redistributed with this package is under the Unicode license. See LICENSE-Unicode for details. Full info is available [on the Unicode website](http://www.unicode.org/copyright.html).
* The IANA time zone database ("zoneinfo") redistributed with this package is Public Domain.

## Naming conventions

Anything in a namespace with `internal` in its name is for the internal use of this package, and is not intended for use by user code.

## Author and Acknowledgments

Chrono is created by [Andrew Janke](https://apjanke.net).

Shout out to [Mike Miller](https://mtmxr.com/) for showing me how to properly structure an Octave package repo, and encouraging me to contribute.

Thanks to [Sebastian Schöps](https://github.com/schoeps) for getting me more involved in Octave development in the first place, via his [Octave.app](https://octave-app.org) project.
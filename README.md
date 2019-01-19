Chrono for GNU Octave
=====================

| WARNING: All the code in here is currently in the alpha stage. (Pre-beta, that is.) Do not use it in any production or business code! Seriously!! |
| ---- |

Date/time functionality for GNU Octave.

This package attempts to provide a set of mostly-Matlab-compatible date/time classes and functions, including `datetime`, `duration`, `calendarDuration`, and their related functions. It has support for time zones and time zone conversion.

This is an improvement over `datenum` and `datevec` for both advanced applications and basic everyday use. It brings both more advanced functionality (time zones, variable-length calendar math) and friendly basics (dates that display as human-readable dates instead of big numbers).

A quick example:

```
% Old and busted:
>> date = now
date =  737442.0260426451
>> convertTimeZone(date, 'America/New_York', 'Europe/Berlin')
error: 'convertTimeZone' undefined near line 1 column 1

% New hotness:
>> date = datetime
date =
 17-Jan-2019 00:37:40
>> date.TimeZone = 'America/New_York'; date.TimeZone = 'Europe/Berlin'
date =
 17-Jan-2019 06:37:40 Europe/Berlin
```

## Installation and usage

### Quick start

To get started using or testing this project, install it using Octave's `pkg` function:

```
pkg install https://github.com/apjanke/octave-addons-chrono/releases/download/v0.1.1/chrono-0.1.1.tar.gz
pkg load chrono
```

### Installation for development

* Clone the repo.
  * `git clone https://github.com/apjanke/octave-addons-chrono`
* Add the `inst/` directory from the repo to your Octave path.
* Build the octfiles.
  * `octave_chrono_make_local.m` will do this. Just run `octave_chrono_make_local` in Octave while your cwd is the `octave-addons-chrono` repo.

## Requirements

Chrono runs on Octave 4.4.0 and later. It would be nice to have it work on Octave 4.0.0
and later (since Ubuntu 16 Xenial has Octave 4.0 and Ubuntu 18 Bionic has Octave 4.2); maybe we'll do that.

It should run on any OS supported by Octave. It's only tested on Linux, Mac, and Windows.

On Windows 7 and earlier, Java is required to detect the system default time zone.

Building Chrono requires a compiler. That means you need to [install Visual Studio
Community](https://visualstudio.microsoft.com/downloads/) on Windows.

## Documentation

The user documentation is in the `doc/` directory. See `doc/chrono.html` or `doc/html/index.html` for
the manual.

The developer documentation (for people hacking on Chrono itself) is in `doc-project/`. Also see
[CONTRIBUTING](CONTRIBUTING.md) if you would like to contribute to this project.

## “Internal” code

Anything in a namespace with `internal` in its name is for the internal use of this package, and is not intended for use by user code. Don't use those! Resist the urge! If you really have a use case for them, post an Issue and we'll see about making some public API for them.

## License

Chrono is Free Software. Chrono contains material licensed under the GPL, the Unicode license, and Public Domain.

* All the code in this package is GPLv3.
* The Unicode `windowsZones.xml` file redistributed with this package is under the Unicode license. See LICENSE-Unicode for details. Full info is available [on the Unicode website](http://www.unicode.org/copyright.html).
* The IANA time zone database ("zoneinfo") redistributed with this package is Public Domain.

## Author and Acknowledgments

Chrono is created by [Andrew Janke](https://apjanke.net).

Shout out to [Mike Miller](https://mtmxr.com/) for showing me how to properly structure an Octave package repo, and encouraging me to contribute.

Thanks to [Sebastian Schöps](https://github.com/schoeps) for getting me more involved in Octave development in the first place, via his [Octave.app](https://octave-app.org) project.

Thanks to David Bateman and the creators of the [Octave-Forge communications package](https://octave.sourceforge.io/communications/index.html) for providing an example of what a good Octave pkg doco generation setup looks like.

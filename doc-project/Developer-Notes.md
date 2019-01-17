Chrono Developer Notes
======================

# TODO

## Overall

* Documentation
* Add more BISTs
* Consider using GNU FDL for the documentation license
* Propagate NaN-filling fix for planargen back to Janklab

* Report crash: giving duration a days method while it has a days property results in a crash.

## Areas

* `datetime`
  * Time zone support
    * Normalization of "nonexistent" times like between 02:00 and 03:00 on DST leap ahead days
  * Leap second conversion
  * `Format` support
    * Needs LDML format support, not datestr() format placeholders
  * between() - calendarDuration diffs between datetimes
  * caldiff
  * dateshift
  * week() - ISO calendar week-of-year calculation
  * isdst/isweekend
  * Additional `ConvertFrom` types
  * SystemTimeZone detection on pre-Vista Windows without using Java
  * POSIX zone rule support for dates outside range of Olson database
    * This affects dates before around 1880 and after around 2038
    * It also affects current dates for time zones that don't use DST!
    * TODO: First, implement simplified no-DST POSIX time zones. That'll at least get us
      Tokyo time support. Sheesh.
* `TzDb`
  * timezones() function: add UTCOffset/DSTOffset
* `calendarDuration` and its associated functions
  * split()
  * Can different fields be mixed positive/negative, in addition to the overall Sign? Current
    arithmetic implementation can result in this. Should that be normalized? Maybe. Not sure it can be fully normalized.
  * proxykeys: pull isnan up to front of precedence? Maybe invert so NaNs sort to end?
  * Fix expansion filling?
    * e.g. `d = datetime; d(5) = d` produced bad `d(2:4)` before patch; this probably does similar now
    * It's in the expansion of numerics: their default value is 0, not NaN.
  * Refactor out promote()
* Plotting support
  * Maybe with just shims and conversion to datenums
* `duration`
  * `InputFmt` support
  * `Format` support
* Miscellaneous
  * Reproduce crash - double setter/getters cause it? (Had duplicates for datetime.Month.)
* Documentation
  * Fix Travis CI doco build
  * Figure out how to get `doc/chrono.texi.in` to draw its version number from `DESCRIPTION`
  * Correct asciibetical ordering in Functions Alphabetically
  * Fix this:
```
warning: doc_cache_create: unusable help text found in file 'datetime'
```
  * Make my Texinfo documentation work with Octave's `doc` command
    * Expose it as QHelpEngine file?
  * Get `help datetime` to recognize my datetime
```
>> which datetime
'datetime' is a built-in function
>> help datetime
error: help: 'datetime' is not documented
```
  * Get `mkdoc.pl` to ignore files in `+internal` namespaces.
  * Get `mkdoc.pl` to include namespaces in class/function definition items.

## Wishlist and maybes

* MAT-file representation compatibility with Matlab?
* Documentation
  * A new Texinfo `@defmfcn` macro for Matlab's idiosyncratic function signatures

# References

See `man 5 tzfile` or [the online man page](http://man7.org/linux/man-pages/man5/tzfile.5.html) for the time zone file format definition.

Matlab documentation: 
  * [Dates and Time](https://www.mathworks.com/help/matlab/date-and-time-operations.html).

# Developer guidelines

## Code Style

GNU Octave standard code style.

That is:
  * space between function name and opening paren
  * space between elements in comma-separated lists in any context (except maybe array indexing?)

GNU copyright notice as header in every source file.

# Goals

Chrono's goal is to provide a full-ish implementation of Matlab's new object-oriented (*ahem* that is, decent)
date/time support embodied by the `datetime` family of classes and functions. My hope is to have this
eventually be incorporated into Octave Forge and then core GNU Octave to bring Octave up to parity with
Matlab in this regard.

Chrono will not include support for functionality beyond Matlab-equivalence (beyond some little type-conversion
and display things that I couldn't help including). That should go in a separate 
package built on top of Chrono.

# Known differences from Matlab

Intentional:

* `datetime` `disp` output includes the time zone for zoned `datetime`s.

I think these differences are important, and Chrono's way is superior to Matlab's, and will not cause significant compatibility problems with M-code applications migrated from Matlab.

Unintentional, and should be fixed:

* ???, aside from all the TODOs listed above
* `timezones()` returns struct, not `table`
  * This depends on having a `table` in the first place, which is beyond the scope of Chrono. The current `struct` return format is largely signature-compatible with `table`, so we can probably get away with it.

# Release checklist

* Run all the tests.
  * `make test`, duh.
  * Wouldn't hurt to do `make test`/`make clean`/`git status`/manual-cleanup a few times, just to be sure.
* Update the version number and date in `DESCRIPTION` and `doc/chrono.texi.in` and rebuild the documentation.
  * `(cd doc; make maintainer-clean; make all)`
* Update the installation instructions in README to use the upcoming release tarball URL.
  * Format is: `https://github.com/apjanke/octave-addons-chrono/releases/download/v<version>/chrono-<version>.tar.gz`
* Commit all the files changed by the above steps.
  * Use form: `git commit -a -m "Cut release v<version>"`
* Create a git tag.
  * `git tag v<version>`
* Push the changes and tag to GitHub.
  * `git push`
  * `git push --tags`
* Make sure your repo is clean: `git status` should show no local changes
* `make dist`
* Create a new GitHub release from the tag.
  * Upload the dist tarball as a file for the release.
* Test installing the release using `pkg install` against the new release URL.
  * On macOS
  * On Ubuntu
* Post an announcement comment on the "Updates" issue.
* Post an announcement on the [Savannah bug for datetime support](https://savannah.gnu.org/bugs/index.php?47032).
* Update version number in `DESCRIPTION` and `doc/chrono.texi.in` to SNAPSHOT of next minor version.

* If there were any problems following these instructions exactly as written, report it as a bug.




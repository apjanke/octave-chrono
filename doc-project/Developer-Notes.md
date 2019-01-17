Chrono Developer Notes
======================

# TODO

## Overall

* Documentation
* Add more BISTs
* Consider using GNU FDL for the documentation license
* Propagate NaN-filling fix for planargen back to Janklab

* Report crash: giving duration a days method while it has a days property results in a crash.

## Sections

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
* `TzDb`
  * timezones() function: add UTCOffset/DSTOffset
* `calendarDuration` and its associated functions
  * split()
  * Can different fields be mixed positive/negative, in addition to the overall Sign? Current
    arithmetic implementation can result in this. Should that be normalized? Maybe. Not sure it can be fully normalized.
  * proxykeys: pull isnan up to front of precedence? Maybe invert so NaNs sort to end?
  * Fix expansion filling?
    * e.g. `d = datetime; d(5) = d` produced bad `d(2:4)`
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
  * A new Texinfo `@deftypemfn` for Matlab's idiosyncratic function signatures

# References

See `man tzfile` or [here](http://man7.org/linux/man-pages/man5/tzfile.5.html) for the time zone file format definition.

Matlab doco: [Dates and Time](https://www.mathworks.com/help/matlab/date-and-time-operations.html).


# Release checklist

* Run all the tests: `make test`
* Update the version number and date in `DESCRIPTION` and `doc/chrono.txi` and rebuild the documentation.
* Create a git tag.
* `make dist`
* Push the tag to GitHub.

Chrono Developer Notes
======================

# TODO

## Overall

* See if Ubuntu can install a newer Octave; on Travis it's on Octave 3.8.1 and that breaks my tests.
* Documentation
* Add more BISTs
* Remove planar-gen boilerplate and isnan2()s once I'm sure class structure is set
* Consider using GNU FDL for the documentation license
* Propagate NaN-filling fix for planargen back to Janklab

* Report crash: giving duration a days method while it has a days property results in a crash.

## Sections

* `datetime`
  * Leap second conversion
  * `Format` support
    * Needs LDML format support, not datestr() format placeholders
  * between() - calendarDuration diffs between datetimes
  * caldiff
  * dateshift
  * week()
  * isdst/isweekend
  * Additional `ConvertFrom` types
  * SystemTimeZone detection on pre-Vista Windows without using Java
  * POSIX zone rule support for dates outside range of Olson database
  * Test conversion to explicit GMT zone - does it hit POSIX zone rule logic?
* `TzDb`
  * timezones() function: add UTCOffset/DSTOffset
* `calendarDuration` and its associated functions
  * split()
  * Can different fields be mixed positive/negative, in addition to the overall Sign? Current
    arithmetic implementation can result in this. Should that be normalized? Maybe. Not sure it can be fully normalized.
  * proxykeys: pull isnan up to front of precedence? Maybe invert so NaNs sort to end?
  * Fix expansion filling?
    * e.g. `d = datetime; d(5) = d` produces bad `d(2:4)`
    * It's in the expansion of doubles: their default value is 0, not NaN.
* Plotting support
  * Maybe with just shims and conversion to datenums
* `duration`
  * `InputFmt` support
  * `Format` support
* Miscellaneous
  * Reproduce crash - double setter/getters cause it? (Had duplicates for datetime.Month.)
* Documentation
  * Get `mkdoc.pl` to ignore files in `+internal` namespaces.
  * Get `mkdoc.pl` to include namespaces in class/function definition items.
  * Fix this:
```
warning: doc_cache_create: unusable help text found in file 'datetime'
```
  * Make my Texinfo documentation work with Octave's `doc` command
  * Get `help datetime` to recognize my datetime
```
>> which datetime
'datetime' is a built-in function
>> help datetime
error: help: 'datetime' is not documented
```

## Wishlist and maybes

* MAT-file representation compatibility with Matlab?
* Documentation
  * A new Texinfo `@deftypemfn` for Matlab's idiosyncratic function signatures

# References

See `man tzfile` or [here](http://man7.org/linux/man-pages/man5/tzfile.5.html) for the time zone file format definition.

Matlab doco: [Dates and Time](https://www.mathworks.com/help/matlab/date-and-time-operations.html).


# Release checklist

* Run all the tests: `make test`
* Update the version number and date in `doc/chrono.txi` and rebuild the documentation.
* Create a git tag.
* Push the tag to GitHub.

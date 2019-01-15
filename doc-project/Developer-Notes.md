Chrono Developer Notes
======================

# TODO

## Overall

* Documentation
* Remove planar-gen boilerplate and isnan2()s
* Add BISTs
* CI tests, once BISTs are in place

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
    arithmetic implementation can result in this. Should that be normalized? Maybe. Not sure it
    can be fully normalized.
  * proxykeys: pull isnan up to front of precedence? Maybe invert so NaNs sort to end?
* Plotting support
  * Maybe with just shims and conversion to datenums
* `duration`
  * `InputFmt` support
  * `Format` support
* Miscellaneous
  * Reproduce crash - double setter/getters cause it? (Had duplicates for datetime.Month.)
## Wishlist and maybes

* MAT-file representation compatibility with Matlab?

# References

See `man tzfile` or [here](http://man7.org/linux/man-pages/man5/tzfile.5.html) for the time zone file format definition.

Matlab doco: [Dates and Time](https://www.mathworks.com/help/matlab/date-and-time-operations.html).


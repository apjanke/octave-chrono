Chrono Developer Notes
======================

# TODO

## Overall

* Documentation
* Convert to GNU code style
* Add BISTs
* CI tests, once BISTs are in place

## Sections

* `datetime`
  * `Format` support
    * Needs LDML format support, not datestr() format placeholders
  * week() function
  * isdst/isweekend
  * between, caldiff, dateshift, isbetween
  * Time zone conversion
  * Leap second conversion
  * Additional `ConvertFrom` types
  * SystemTimeZone detection on pre-Vista Windows without using Java
* `TzDb`
  * timezones() function: add UTCOffset/DSTOffset
* `calendarDuration` and its associated functions
  * split()
  * Determine how to expose NaNs in component getters
    * Should probably normalize NaNs so that all components of NaN values are themselves NaN
  * calYears() and related functions
  * Can different fields be mixed positive/negative, in addition to the overall Sign? Current
    arithmetic implementation can result in this.
  * Better display: omit trailing fields that are zeros
* Plotting support
  * Maybe with just shims and conversion to datenums
* `duration`
  * `InputFmt` support
  * `Format` support

## Wishlist and maybes

* MAT-file representation compatibility with Matlab?

# References

See `man tzfile` or [here](http://man7.org/linux/man-pages/man5/tzfile.5.html) for the time zone file format definition.

Matlab doco: [Dates and Time](https://www.mathworks.com/help/matlab/date-and-time-operations.html).
Chrono Developer Notes
======================

# TODO

## Overall

* Convert to GNU code style
* Stick a license header on all the files?
* Add BISTs
* CI tests, once BISTs are in place
* Documentation

## Sections

* Display
  * 3-D and higher support in format_dispstr_strings
    * Check Janklab's dispstr API: this may already be written
* `datetime`
  * `Format` support
    * Needs LDML format support, not datestr() format placeholders
  * week() function
  * isdst/isweekend
  * between, caldiff, dateshift, isbetween
  * Time zone conversion
  * Leap second conversion
  * Additional `ConvertFrom` types
  * Trailing name/val option support in constructor
  * SystemTimeZone non-Java implementation
* `TzDb`
  * timezones() function: add UTCOffset/DSTOffset
  * bundled or other tzinfo distribution for Windows (which doesn't provide it in the OS)
* `calendarDuration` and its associated functions
  * Determine whether and how to represent NaNs
  * Arithmetic: adding/subtracting/multiplying durations
  * split()
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
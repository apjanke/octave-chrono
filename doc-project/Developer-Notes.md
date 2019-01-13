Chrono Developer Notes
======================

# TODO

* Package as an Octave pkg package
* Convert to GNU code style
* Stick a license header on all the files?
* Add BISTs

* `datetime`
  * `Format` support
    * Needs LDML format support, not datestr() format placeholders
  * week() function
  * isdst/isweekend
  * between, caldiff, dateshift, isbetween
  * Time zone conversion
  * Leap second conversion
  * Additional `ConvertFrom` types
  * Remove proxykeys
  * Trailing name/val option support in constructor
  * SystemTimeZone non-Java implementation
* `TzDb`
  * timezones() function: add UTCOffset/DSTOffset
  * bundled or other tzinfo distribution for Windows (which doesn't provide it in the OS)
* Fix parsing bug with that trailing data/time zone in the zoneinfo files
* `calendarDuration` and its associated functions
  * Determine whether and how to represent NaNs
  * Arithmetic: adding/subtracting/multiplying durations
  * Find a non-table-dependent implementation of proxykeys
    * Or just make this take a dependency on table
* Plotting support
  * Maybe with just shims and conversion to datenums
* `duration`
  * `InputFmt` support
  * `Format` support
  * Remove proxykeys
  * split()
  * linspace()
  * colon operator?

# References

See `man tzfile` or [here](http://man7.org/linux/man-pages/man5/tzfile.5.html) for the time zone file format definition.

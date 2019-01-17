Chrono Developer Notes
======================

* See also: [TODO](TODO.md)
* See also: [Release Checklist](Release-Checklist.md)

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


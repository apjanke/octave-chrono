## Copyright (C) 2019 Andrew Janke <floss@apjanke.net>
##
## This file is part of Octave.
##
## Octave is free software: you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <https://www.gnu.org/licenses/>.

function out = days (x)
  %DAYS duration in days
  %
  % out = days (x)
  %
  % If x is numeric, then out is a duration array in units of fixed-length 24-hour
  % days.
  %
  % If x is a duration, then returns a double array indicating the number of
  % days that duration is.
  if isnumeric (x)
    out = duration.ofDays (double (x));
  else
    error ('Invalid input: expected numeric or duration; got %s', class (x));    
  end
end

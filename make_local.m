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

function make_local
  %MAKE_LOCAL Build the octfiles for this repo
  %
  % Call this function if you are working with a local copy of this repo instead
  % of installing it as a package.
  octfcns = {
    '__oct_time_binsearch__'
    };
  for i = 1:numel (octfcns)
    octfcn = octfcns{i};
    mkoctfile (sprintf ('src/%s.cc', octfcn));
    delete (sprintf ('%s.o', octfcn));
    movefile (sprintf ('%s.oct', octfcn), 'inst');
    printf (sprintf ('Built %s\n', octfcn));
  endfor
endfunction

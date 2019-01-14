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

classdef TzInfo
  %TZINFO Zone definition for a single time zone
  
  properties
    id
    formatId
    transitions
    timeTypes
    ttinfos
    leapTimes
    leapSecondTotals
    isStd
    isGmt
    goingForwardPosixZone
  end
  
  methods
    
    % Display
    
    function display(this)
      %DISPLAY Custom display.
      in_name = inputname(1);
      if ~isempty(in_name)
        fprintf('%s =\n', in_name);
      end
      disp(this);
    end

    function disp(this)
      %DISP Custom display.
      if isempty(this)
        fprintf('Empty %s %s\n', size2str(size(this)), class(this));
      elseif isscalar(this)
        fprintf('TzInfo: %s\n', this.id);
        displayCommonInfo(this);
      else
        fprintf('%s: %s\n', class(this), size2str(size(this)));
      end
    end
    
    function prettyprint(this)
      %PRETTYPRINT Display this' data in human-readable format.
      if ~isscalar(this)
        fprintf('%s: %s\n', class(this), size2str(size(this)));
        return;
      end
      fprintf('TzInfo: %s\n', this.id);
      displayCommonInfo(this);
      fprintf('transitions:\n');
      for i = 1:numel(this.transitions)
        dnum = datetime.posix2datenum(this.transitions(i));
        abbr = this.ttinfos.abbr{this.timeTypes(i)+1};
        fprintf('  %d  %s  %d  => %s\n', this.transitions(i), datestr(dnum), ...
          this.timeTypes(i), abbr);
      end
      fprintf('ttinfos:\n');
      fprintf('  %12s %5s %8s %-8s\n', 'gmtoff', 'isdst', 'abbrind', 'abbr');
      tti = this.ttinfos;
      for i = 1:numel(this.ttinfos.gmtoff)
        fprintf('  %12d %5d %8d %-8s\n', ...
          tti.gmtoff(i), tti.isdst(i), tti.abbrind(i), tti.abbr{i});
      end
      fprintf('leap times:\n');
      if isempty(this.leapTimes)
        fprintf('  <none>\n');
      else
        fprintf('  %12s  %20s\n', 'time', 'leap seconds');
        for i = 1:numel(this.leapTimes)
          fprintf('  %12d  %20d\n', this.leapTimes(i), this.leapSecondsTotal(i));
        end        
      end
      fprintf('is_std:\n');
      function out = num2cellstr(x)
        out = reshape(strtrim(cellstr(num2str(x(:)))), size(x));
      end
      fprintf('  %s\n', strjoin(num2cellstr(this.isStd), '  '));
      fprintf('is_gmt:\n');
      fprintf('  %s\n', strjoin(num2cellstr(this.isGmt), '  '));
    end
  end
  
  methods (Access = private)
    function displayCommonInfo(this)
      %DISPLAYCOMMONINFO Info common to disp() and prettyprint()
      formatId = this.formatId;
      if formatId == 0
        formatId = '1';
      end
      if ismember(this.formatId, {'2','3'})
        time_size = '64-bit';
      else
        time_size = '32-bit';
      end
      fprintf('  Version %s (%s time values)\n', this.formatId, time_size);
      fprintf('  %d transitions, %d ttinfos, %d leap times\n', ...
        numel(this.transitions), numel(this.ttinfos.gmtoff), numel(this.leapTimes));
      fprintf('  %d is_stds, %d is_gmts\n', ...
        numel(this.isStd), numel(this.isGmt));
      if ~isempty(this.goingForwardPosixZone)
        fprintf('  Forward-looking POSIX zone: %s\n', this.goingForwardPosixZone);
      end
    end
  end
end

function out = size2str(sz)
%SIZE2STR Format an array size for display
%
% out = size2str(sz)
%
% Sz is an array of dimension sizes, in the format returned by SIZE.
%
% Examples:
%
% size2str(magic(3))

strs = cell(size(sz));
for i = 1:numel(sz)
	strs{i} = sprintf('%d', sz(i));
end

out = strjoin(strs, '-by-');
end
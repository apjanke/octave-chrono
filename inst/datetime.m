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

classdef datetime
  %DATETIME Date/time values
  %
  % Datetime represents points in time using the ISO calendar.
  %
  % This is an attempt to reproduce the functionality of Matlab's @datetime. It
  % also contains some Octave-specific extensions.
  %
  % TODO: Time zone support
  
  % @planarprecedence(dnums)
  % @planarsetops
  % @planarrelops
  
  properties (Access = private)
    dnums % @planar
  end
  properties
    % Time zone code as charvec. Assigning a new TimeZone performs time zone conversion.
    TimeZone = ''
    % Format to display these dates in. Changing the format is currently unimplemented.
    Format = 'default'
  end
  properties (Dependent = true)
    Year
    Month
    Day
    Hour
    Minute
    Second
  end
  properties (Constant)
    PosixEpochDatenum = datenum(1970, 1, 1);
    SystemTimeZone = octave.time.internal.detect_system_timezone();
  end
  
  methods (Static)
    function out = ofDatenum(dnums)
      %OFDATENUM Convert datenums to datetimes.
      %
      % This is an Octave extension.
      out = datetime(dnums, 'ConvertFrom', 'datenum');
    end
    
    function out = ofDatestruct(dstruct)
      %OFDATESTRUCT Convert "datestruct" to datetimes.
      dnums = datetime.datestruct2datenum(dstruct);
      out = datetime(dnums, 'ConvertFrom', 'datenum');
    end
    
    function out = datestruct2datenum(dstruct)
      sz = size(dstruct.Year);
      n = numel(dstruct.Year);
      dvec = NaN(n, 6);
      dvec(:,1) = dstruct.Year(:);
      dvec(:,2) = dstruct.Month(:);
      dvec(:,3) = dstruct.Day(:);
      dvec(:,4) = dstruct.Hour(:);
      dvec(:,5) = dstruct.Minute(:);
      dvec(:,6) = dstruct.Second(:);
      out = datenum(dvec);
    end
    
    function out = NaT()
      out = datetime(NaN, 'Backdoor');
    end
        
    function out = posix2datenum(pdates)
      %POSIX2DATENUM Convert POSIX times to datenums
      %
      % out = posix2datenum(pdates)
      %
      % Pdates (numeric) is an array of POSIX dates. A POSIX date is the number
      % of seconds since January 1, 1970 UTC, excluding leap seconds.
      out = (double(pdates) / (24 * 60 * 60)) + datetime.PosixEpochDatenum;
    end
    
    function out = datenum2posix(dnums)
      %DATENUM2POSIX Convert datenums to POSIX times
      %
      % Returns int64.
      out = int64((dnums - datetime.PosixEpochDatenum) * (24 * 60 * 60));
    end
  end

  methods
    
    function this = datetime(varargin)
      %DATETIME Construct a new datetime array.
      
      % Peel off options
      args = varargin;
      knownOptions = {'Format','InputFormat','Locale','PivotYear','TimeZone'};
      opts = struct;
      while numel(args) >= 3 && isa(args{end-1}, 'char') ...
          && ismember(args{end-1}, knownOptions)
        opts.(args{end-1}) = args{end};
        args(end-1:end) = [];
      end
      
      % Handle inputs
      timeZone = '';
      switch numel(args)
        case 0
          dnums = now;
        case 1
          x = varargin{1};
          if isnumeric(x)
            % Convert date vectors
            dnums = datenum(x);
          elseif ischar(x) || iscellstr(x) || isa(x, 'string')
            x = cellstr(x);
            tfRelative = ismember(x, {'today','tomorrow','yesterday','now'});
            if all(tfRelative)
              if ~isscalar(x)
                error('Multiple arguments not allowed for relativeDay format');
              end
              switch x{1}
                case 'yesterday'
                  dnums = floor(now) - 1;
                case 'today'
                  dnums = floor(now);
                case 'tomorrow'
                  dnums = floor(now) + 1;
                case 'now'
                  dnums = now;
              end
            else
              % They're datestrs
              % TODO: Support Locale option
              if isfield(opts, 'Locale')
                error('Locale option is unimplemented');
              end
              % TODO: Support PivotYear option
              if isfield(opts, 'PivotYear')
                error('PivotYear option is unimplemented');
              end
              if isfield(opts, 'TimeZone')
                timeZone = opts.TimeZone;
              end
              if isfield(opts, 'InputFormat')
                dnums = datenum(x, opts.InputFormat);
              else
                dnums = datenum(x);
              end
              dnums = reshape(dnums, size(x));
            end
          end
        case 2
          % Undocumented calling form for Octave's internal use
          if ~isequal(varargin{2}, 'Backdoor')
            error('Invalid number of inputs: %d', nargin);
          end
          dnums = varargin{1};
        case 3
          [in1,in2,in3] = varargin{:};
          if isequal(in2, 'ConvertFrom')
            switch in3
              case 'datenum'
                dnums = double(in1);
              case 'posixtime'
                dnums = datetime.posix2datenum(in1);
                timeZone = 'UTC';
              otherwise
                error('Unsupported ConvertFrom format: %s', in3);
                % TODO: Implement more formats
            end
          elseif isnumeric(in2)
            [Y,M,D] = varargin{:};
            dnums = datenum(Y, M, D);
          end
        case 4
          error('Invalid number of inputs: %d', nargin);
        case 5
          error('Invalid number of inputs: %d', nargin);
        case 6
          [Y,M,D,H,MI,S] = varargin{:};
          dnums = datenum(Y, M, D, H, MI, S);
        case 7
          [Y,M,D,H,MI,S,MS] = varargin{:};
          dnums = datenum(Y, M, D, H, MI, S, MS);
        otherwise
          error('Invalid number of inputs: %d', nargin);
      end
      
      % Construct
      this.dnums = dnums;
      if isfield(opts, 'Format')
        this.Format = opts.Format;
      end
      if ~isempty(timeZone)
        this.TimeZone = timeZone;
      end
    end
    
    function [keysA,keysB] = proxyKeys(a, b)
      %PROXYKEYS Proxy key values for sorting and set operations
      keysA = a.dnums(:);
      keysB = b.dnums(:);
    end

    function this = set.TimeZone(this, x)
      if ~ischar(x) || ~isrow(x)
        error('TimeZone must be a char row vector; got a %s %s', ...
          size2str(size(x)), class(x));
      end
      tzdb = octave.time.internal.tzinfo.TzDb.instance;
      if ~ismember(x, tzdb.definedZones)
        error('Undefined TimeZone: %s', x);
      end
      if ~isempty(this.TimeZone) && ~isempty(x)
        this.dnums = datetime.convertDatenumTimeZone(this.dnums, this.TimeZone, x);
      end
      this.TimeZone = x;
    end
    
    function this = set.Format(this, x)
      error('Changing datetime format is currently unimplemented');
    end
    
    function out = get.Year(this)
      s = datestruct(this);
      out = s.Year;
    end
    
    function this = set.Year(this, x)
      s = datestruct(this);
      s.Year(:) = x;
      this.dnums = datetime.datestruct2datenum(s);
    end
      
    function out = get.Month(this)
      s = datestruct(this);
      out = s.Month;
    end
    
    function this = set.Month(this, x)
      s = datestruct(this);
      s.Month(:) = x;
      this.dnums = datetime.datestruct2datenum(s);
    end
      
    function out = get.Month(this)
      s = datestruct(this);
      out = s.Month;
    end
    
    function this = set.Month(this, x)
      s = datestruct(this);
      s.Month(:) = x;
      this.dnums = datetime.datestruct2datenum(s);
    end
      
    function out = get.Day(this)
      s = datestruct(this);
      out = s.Day;
    end
    
    function this = set.Day(this, x)
      s = datestruct(this);
      s.Day(:) = x;
      this.dnums = datetime.datestruct2datenum(s);
    end
      
    function out = get.Hour(this)
      s = datestruct(this);
      out = s.Hour;
    end
    
    function this = set.Hour(this, x)
      s = datestruct(this);
      s.Hour(:) = x;
      this.dnums = datetime.datestruct2datenum(s);
    end
      
    function out = get.Minute(this)
      s = datestruct(this);
      out = s.Minute;
    end
    
    function this = set.Minute(this, x)
      s = datestruct(this);
      s.Minute(:) = x;
      this.dnums = datetime.datestruct2datenum(s);
    end
      
    function out = get.Second(this)
      s = datestruct(this);
      out = s.Second;
    end
    
    function this = set.Second(this, x)
      s = datestruct(this);
      s.Second(:) = x;
      this.dnums = datetime.datestruct2datenum(s);
    end
    
    function out = year(this)
      out = this.Year;
    end
      
    function out = month(this)
      out = this.Month;
    end
      
    function out = day(this)
      out = this.Day;
    end
      
    function out = hour(this)
      out = this.Hour;
    end
      
    function out = minute(this)
      out = this.Minute;
    end
      
    function out = second(this)
      out = this.Second;
    end
    
    function out = quarter(this)
      out = ceil(this.Month / 3);
    end
    
    function [y,m,d] = ymd(this)
      s = datestruct(this);
      y = s.Year;
      m = s.Month;
      d = s.Day;
    end
    
    function [h,m,s] = hms(this)
      st = datestruct(this);
      h = st.Hour;
      m = st.Minute;
      s = st.Second;
    end
    
    function [y,m,d,h,mi,s] = ymdhms(this)
      %YMDHMS Get the year, month, day, etc components of this.
      %
      % This is an Octave extension.
      ds = datestruct(this);
      y = ds.Year;
      m = ds.Month;
      d = ds.Day;
      h = ds.Hour;
      mi = ds.Minute;
      s = ds.Second;
    end
    
    function out = timeofday(this)
      %TIMEOFDAY Elapsed time since midnight.
      
      % Use mod, not rem, so negative dates give correct result
      out = duration.ofDays(mod(this.dnums, 1));
    end
    
    function out = week(this)
      error('week() is unimplemented');
    end
      
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
        str = dispstrs(this);
        str = str{1};
        if ~isempty(this.TimeZone)
          str = [str ' ' this.TimeZone];
        end
        fprintf(' %s\n', str);
      else
        txt = octave.time.internal.format_dispstr_array(dispstrs(this));
        fprintf('%s\n', txt);
        if ~isempty(this.TimeZone)
          fprintf('  %s\n', this.TimeZone);
        end
      end
    end
    
    function out = dispstrs(this)
      %DISPSTRS Custom display strings.
      % This is an Octave extension.
      out = cell(size(this));
      tfNaN = isnan(this.dnums);
      out(tfNaN) = {'NaT'};
      if any(~tfNaN)
        out(~tfNaN) = cellstr(datestr(this.dnums(~tfNaN)));
      end
    end
    
    function out = datestr(this, varargin)
      %DATESTR Format as date string.
      out = datestr(this.dnums, varargin{:});
    end
    
    function out = datestrs(this, varargin)
      %DATESTSRS Format as date strings.
      % Returns cellstr.
      % This is an Octave extension.
      s = datestr(this);
      c = cellstr(s);
      out = reshape(c, size(this));
    end
    
    function out = datestruct(this)
      %DATESTRUCT Convert to a "datestruct" broken-down time
      %
      % This is an Octave extension.
      dvec = datevec(this.dnums);
      sz = size(this);
      out.Year = reshape(dvec(:,1), sz);
      out.Month = reshape(dvec(:,2), sz);
      out.Day = reshape(dvec(:,3), sz);
      out.Hour = reshape(dvec(:,4), sz);
      out.Minute = reshape(dvec(:,5), sz);
      out.Second = reshape(dvec(:,6), sz);
    end

    function out = isnat(this)
      %ISNAT True if input is NaT.
      out = isnan(this.dnums);
    end
    
    function out = isnan(this)
      %ISNAN Alias for isnat.
      % This is an Octave extension
      out = isnat(this);
    end
    
    % Relational operations

    function out = lt(A, B)
      %LT Less than.
      [A, B] = promote(A, B);
      out = A.dnums < B.dnums;
    end

    function out = le(A, B)
      %LE Less than or equal.
      [A, B] = promote(A, B);
      out = A.dnums <= B.dnums;
    end

    function out = ne(A, B)
      %NE Not equal.
      [A, B] = promote(A, B);
      out = A.dnums ~= B.dnums;
    end

    function out = eq(A, B)
      %EQ Equals.
      [A, B] = promote(A, B);
      out = A.dnums == B.dnums;
    end

    function out = ge(A, B)
      %GE Greater than or equal.
      [A, B] = promote(A, B);
      out = A.dnums >= B.dnums;
    end

    function out = gt(A, B)
      %GT Greater than.
      [A, B] = promote(A, B);
      out = A.dnums > B.dnums;
    end

    % Arithmetic
    
    function out = plus(A, B)
      %PLUS Addition.
      if ~isa(A, 'datetime')
        error('Expected left-hand side of A + B to be a datetime; got a %s', ...
          class(A));
      end
      if isa(B, 'duration')
        out = A;
        out.dnums = A.dnums + B.days;
      elseif isa(B, 'calendarDuration')
        if ~isscalar(B)
          error('calendarDuration inputs must be scalar');
        end
        ds = datestruct(A);
        out = A;
        if B.Sign < 0
          ds.Year = ds.Year - B.Years;
          ds.Month = ds.Month - B.Months;
          ds.Day = ds.Day - B.Days;
          tmp = datetime.ofDatestruct(ds);
          tmp.dnums = tmp.dnums - B.Time;
          out.dnums = tmp.dnums;
        else
          ds.Year = ds.Year + B.Years;
          ds.Month = ds.Month + B.Months;
          ds.Day = ds.Day + B.Days;
          tmp = datetime.ofDatestruct(ds);
          tmp.dnums = tmp.dnums + B.Time;
          out.dnums = tmp.dnums;
        end
      elseif isa(B, 'double')
        out = A + duration.ofDays(B);
      else
        error('Invalid input type: %s', class(B));
      end
    end
    
    function out = minus(A, B)
      %MINUS Subtraction.
      if isa(A, 'datetime') && isa(B, 'datetime')
        out = duration.ofDays(A.dnums - B.dnums);
      else
        out = A + -B;
      end
    end
    
    function out = diff(this)
      %DIFF Differences between elements
      out = duration.ofDays(diff(this.dnums));
    end
    
    function out = colon(this, varargin)
      narginchk(2, 3);
      switch nargin
        case 2
          limit = varargin{1};
          increment = 1;
        case 3
          increment = varargin{1};
          limit = varargin{2};
      end
      if isnumeric(increment)
        increment = duration.ofDays(increment);
      end
      if ~isa(increment, 'duration')
        error('increment must be a duration object');
      end
      if ~isscalar(this) || ~isscalar(limit)
        error('base and limit must both be scalar');
      end
      out = this;
      out.dnums = this.dnums:increment.days:limit.dnums;
    end
    
    function out = linspace(from, to, n)
      %LINSPACE Linearly-spaced values
      narginchk(2, 3);
      if nargin < 3; n = 100; end
      if isnumeric(from)
        from = datetime.ofDatenum(from);
      end
      [from, to] = promote(from, to);
      if ~isscalar(from) || ~isscalar(to)
        error('Inputs must be scalar');
      end
      out = from;
      out.dnums = linspace(from.dnums, to.dnums, n);
    end
  end

  %%%%% START PLANAR-CLASS BOILERPLATE CODE %%%%%
  
  % This section contains code auto-generated by Janklab's genPlanarClass.
  % Do not edit code in this section manually.
  % Do not remove the "%%%%% START/END .... %%%%%" header or footer either;
  % that will cause the code regeneration to break.
  % To update this code, re-run jl.code.genPlanarClass() on this file.
  
  methods

    function out = numel(this)
    %NUMEL Number of elements in array.
    out = numel(this.dnums);
    end
    
    function out = ndims(this)
    %NDIMS Number of dimensions.
    out = ndims(this.dnums);
    end
    
    function out = size(this)
    %SIZE Size of array.
    out = size(this.dnums);
    end
    
    function out = isempty(this)
    %ISEMPTY True for empty array.
    out = isempty(this.dnums);
    end
    
    function out = isscalar(this)
    %ISSCALAR True if input is scalar.
    out = isscalar(this.dnums);
    end
    
    function out = isvector(this)
    %ISVECTOR True if input is a vector.
    out = isvector(this.dnums);
    end
    
    function out = iscolumn(this)
    %ISCOLUMN True if input is a column vector.
    out = iscolumn(this.dnums);
    end
    
    function out = isrow(this)
    %ISROW True if input is a row vector.
    out = isrow(this.dnums);
    end
    
    function out = ismatrix(this)
    %ISMATRIX True if input is a matrix.
    out = ismatrix(this.dnums);
    end
        
    function this = reshape(this, varargin)
    %RESHAPE Reshape array.
    this.dnums = reshape(this.dnums, varargin{:});
    end
    
    function this = squeeze(this, varargin)
    %SQUEEZE Remove singleton dimensions.
    this.dnums = squeeze(this.dnums, varargin{:});
    end
    
    function this = circshift(this, varargin)
    %CIRCSHIFT Shift positions of elements circularly.
    this.dnums = circshift(this.dnums, varargin{:});
    end
    
    function this = permute(this, varargin)
    %PERMUTE Permute array dimensions.
    this.dnums = permute(this.dnums, varargin{:});
    end
    
    function this = ipermute(this, varargin)
    %IPERMUTE Inverse permute array dimensions.
    this.dnums = ipermute(this.dnums, varargin{:});
    end
    
    function this = repmat(this, varargin)
    %REPMAT Replicate and tile array.
    this.dnums = repmat(this.dnums, varargin{:});
    end
    
    function this = ctranspose(this, varargin)
    %CTRANSPOSE Complex conjugate transpose.
    this.dnums = ctranspose(this.dnums, varargin{:});
    end
    
    function this = transpose(this, varargin)
    %TRANSPOSE Transpose vector or matrix.
    this.dnums = transpose(this.dnums, varargin{:});
    end
    
    function [this, nshifts] = shiftdim(this, n)
    %SHIFTDIM Shift dimensions.
    if nargin > 1
        this.dnums = shiftdim(this.dnums, n);
    else
        [this.dnums,nshifts] = shiftdim(this.dnums);
    end
    end
    
    function out = cat(dim, varargin)
    %CAT Concatenate arrays.
    args = varargin;
    for i = 1:numel(args)
        if ~isa(args{i}, 'datetime')
            args{i} = datetime(args{i});
        end
    end
    out = args{1};
    fieldArgs = cellfun(@(obj) obj.dnums, args, 'UniformOutput', false);
    out.dnums = cat(dim, fieldArgs{:});
    end
    
    function out = horzcat(varargin)
    %HORZCAT Horizontal concatenation.
    out = cat(2, varargin{:});
    end
    
    function out = vertcat(varargin)
    %VERTCAT Vertical concatenation.
    out = cat(1, varargin{:});
    end
    
    function this = subsasgn(this, s, b)
    %SUBSASGN Subscripted assignment.
    
    % Chained subscripts
    if numel(s) > 1
        rhs_in = subsref(this, s(1));
        rhs = subsasgn(rhs_in, s(2:end), b);
    else
        rhs = b;
    end
    
    % Base case
    switch s(1).type
        case '()'
            this = subsasgnParensPlanar(this, s(1), rhs);
        case '{}'
            error('{}-subscripting is not supported for class %s', class(this));
        case '.'
            this.(s(1).subs) = rhs;
    end
    end
    
    function out = subsref(this, s)
    %SUBSREF Subscripted reference.
    
    % Base case
    switch s(1).type
        case '()'
            out = subsrefParensPlanar(this, s(1));
        case '{}'
            error('{}-subscripting is not supported for class %s', class(this));
        case '.'
            out = this.(s(1).subs);
    end
    
    % Chained reference
    if numel(s) > 1
        out = subsref(out, s(2:end));
    end
    end
        
    function [out,Indx] = sort(this)
    %SORT Sort array elements.
    if isvector(this)
        isRow = isrow(this);
        this = subset(this, ':');
        % NaNs sort stably to end, so handle them separately
        tfNan = isnan(this);
        nans = subset(this, tfNan);
        nonnans = subset(this, ~tfNan);
        ixNonNan = find(~tfNan);
        proxy = proxyKeys(nonnans);
        [~,ix] = sortrows(proxy);
        out = [subset(nonnans, ix); nans];
        Indx = [ixNonNan(ix); find(tfNan)];
        if isRow
            out = out';
        end
    elseif ismatrix(this)
        out = this;
        Indx = NaN(size(out));
        for iCol = 1:size(this, 2)
            [sortedCol,Indx(:,iCol)] = sort(subset(this, ':', iCol));
            out = asgn(out, {':', iCol}, sortedCol);
        end
    else
        % I believe this multi-dimensional implementation is correct,
        % but have not tested it yet. Use with caution.
        out = this;
        Indx = NaN(size(out));
        sz = size(this);
        nDims = ndims(this);
        ixs = [{':'} repmat({1}, [1 nDims-1])];
        while true
            col = subset(this, ixs{:});
            [sortedCol,sortIx] = sort(col);
            Indx(ixs{:}) = sortIx;
            out = asgn(out, ixs, sortedCol);
            ixs{end} = ixs{end}+1;
            for iDim=nDims:-1:3
                if ixs{iDim} > sz(iDim)
                    ixs{iDim-1} = ixs{iDim-1} + 1;
                    ixs{iDim} = 1;
                end
            end
            if ixs{2} > sz(2)
                break;
            end
        end
    end
    end
    
    function [out,Indx] = unique(this, varargin)
    %UNIQUE Set unique.
    flags = setdiff(varargin, {'rows'});
    if ismember('rows', varargin)
        [~,proxyIx] = unique(this);
        proxyIx = reshape(proxyIx, size(this));
        [~,Indx] = unique(proxyIx, 'rows', flags{:});
        out = subset(this, Indx, ':');
    else
        isRow = isrow(this);
        this = subset(this, ':');
        tfNaN = isnan(this);
        nans = subset(this, tfNaN);
        nonnans = subset(this, ~tfNaN);
        ixNonnan = find(~tfNaN);
        keys = proxyKeys(nonnans);
        if isa(keys, 'table')
            [~,ix] = unique(keys, flags{:});
        else
            [~,ix] = unique(keys, 'rows', flags{:});
        end
        out = [subset(nonnans, ix); nans];
        Indx = [ixNonnan(ix); find(tfNaN)];
        if isRow
            out = out';
        end
    end
    end
    
    function [out,Indx] = ismember(a, b, varargin)
    %ISMEMBER True for set member.
    if ismember('rows', varargin)
        error('ismember(..., ''rows'') is unsupported');
    end
    if ~isa(a, 'datetime')
        a = datetime(a);
    end
    if ~isa(b, 'datetime')
        b = datetime(b);
    end
    [proxyA, proxyB] = proxyKeys(a, b);
    [out,Indx] = ismember(proxyA, proxyB, 'rows');
    out = reshape(out, size(a));
    Indx = reshape(Indx, size(a));
    end
    
    function [out,Indx] = setdiff(a, b, varargin)
    %SETDIFF Set difference.
    if ismember('rows', varargin)
        error('setdiff(..., ''rows'') is unsupported');
    end
    [tf,~] = ismember(a, b);
    out = parensRef(a, ~tf);
    Indx = find(~tf);
    [out,ix] = unique(out);
    Indx = Indx(ix);
    end
    
    function [out,ia,ib] = intersect(a, b, varargin)
    %INTERSECT Set intersection.
    if ismember('rows', varargin)
        error('intersect(..., ''rows'') is unsupported');
    end
    [proxyA, proxyB] = proxyKeys(a, b);
    [~,ia,ib] = intersect(proxyA, proxyB, 'rows');
    out = parensRef(a, ia);
    end
    
    function [out,ia,ib] = union(a, b, varargin)
    %UNION Set union.
    if ismember('rows', varargin)
        error('union(..., ''rows'') is unsupported');
    end
    [proxyA, proxyB] = proxyKeys(a, b);
    [~,ia,ib] = union(proxyA, proxyB, 'rows');
    aOut = parensRef(a, ia);
    bOut = parensRef(b, ib);
    out = [parensRef(aOut, ':'); parensRef(bOut, ':')];
    end
    
  end
  
  methods (Access=private)
  
    function this = subsasgnParensPlanar(this, s, rhs)
    %SUBSASGNPARENSPLANAR ()-assignment for planar object
    if ~isa(rhs, 'datetime')
        rhs = datetime(rhs);
    end
    this.dnums(s.subs{:}) = rhs.dnums;
    end
    
    function out = subsrefParensPlanar(this, s)
    %SUBSREFPARENSPLANAR ()-indexing for planar object
    out = this;
    out.dnums = this.dnums(s.subs{:});
    end
    
    function out = parensRef(this, varargin)
    %PARENSREF ()-indexing, for this class's internal use
    out = subsrefParensPlanar(this, struct('subs', {varargin}));
    end
    
    function out = subset(this, varargin)
    %SUBSET Subset array by indexes.
    % This is what you call internally inside the class instead of doing 
    % ()-indexing references on the RHS, which don't work properly inside the class
    % because they don't respect the subsref() override.
    out = parensRef(this, varargin{:});
    end
    
    function out = asgn(this, ix, value)
    %ASGN Assign array elements by indexes.
    % This is what you call internally inside the class instead of doing 
    % ()-indexing references on the LHS, which don't work properly inside
    % the class because they don't respect the subsasgn() override.
    if ~iscell(ix)
        ix = { ix };
    end
    s.type = '()';
    s.subs = ix;
    out = subsasgnParensPlanar(this, s, value);
    end
  
  end
  
  %%%%% END PLANAR-CLASS BOILERPLATE CODE %%%%%

  methods (Static)
    function out = convertDatenumTimeZone(dnum, fromZone, toZone)
      error('TimeZone conversion is unimplemented. Sorry.');
    end
  end
end


%%%%% START PLANAR-CLASS BOILERPLATE LOCAL FUNCTIONS %%%%%

% This section contains code auto-generated by Janklab's genPlanarClass.
% Do not edit code in this section manually.
% Do not remove the "%%%%% START/END .... %%%%%" header or footer either;
% that will cause the code regeneration to break.
% To update this code, re-run jl.code.genPlanarClass() on this file.

function out = isnan2(x)
%ISNAN2 True if input is NaN or NaT
% This is a hack to work around the edge case of @datetime, which 
% defines an isnat() function instead of supporting isnan() like 
% everything else.
if isa(x, 'datetime')
    out = isnat(x);
else
    out = isnan(x);
end
end

function out = slurpTextFile(file)
  [fid,msg] = fopen(file, 'r');
  if fid == -1
    error('Could not open file %s: %s', file, msg);
  end
  cleanup.fid = onCleanup(@() fclose(fid));
  txt = fread(fid, Inf, 'char=>char');
  txt = txt';
  out = txt;
end



%%%%% END PLANAR-CLASS BOILERPLATE LOCAL FUNCTIONS %%%%%

function varargout = promote(varargin)
  %PROMOTE Promote inputs to be compatible
  args = varargin;
  for i = 1:numel(args)
    if ~isa(args{i}, 'datetime')
      args{i} = datetime(args{i});
    end
  end
  tz0 = args{1}.TimeZone;
  for i = 2:numel(args)
    if ~isequal(args{i}.TimeZone, tz0)
      if isempty(tz0) || isempty(args{i}.TimeZone)
        error('Cannot mix zoned and zoneless datetimes.');
      else
        args{i}.TimeZone = tz0;
      end
    end
  end
  varargout = args;
end


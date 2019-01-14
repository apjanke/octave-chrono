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

classdef calendarDuration
  %CALENDARDURATION Lengths of time in variable-length calendar units
  
  % @planarprecedence(IsNaN,Sign,Years,Months,Days,Time)
  % @planarsetops
  
  properties (SetAccess = private)
    Sign = 1     % @planar
    Years = 0    % @planar
    Months = 0   % @planar
    Days = 0     % @planar
    % Time as datenum-style double
    Time = 0     % @planar
    % Flag for whether this element is NaN/NaT
    IsNaN = false  % @planar @planarnanflag
  end
  properties
    % Display format
    Format
  end
  
  methods
    function this = calendarDuration(varargin)
      %CALENDARDURATION Construct a new calendar duration.
      %
      % this = calendarDuration(Y,M,D)
      % this = calendarDuration(Y,M,D,H,MI,S)
      % this = calendarDuration(Y,M,D,T)
      % this = calendarDuration(X)
      %
      % this = calendarDuration(..., 'Format',displayFormat)
      
      args = varargin;
      % Peel off options
      knownOptions = {'Format'};
      opts = struct;
      while numel(args) >= 3 && isa(args{end-1}, 'char') ...
          && ismember(args{end-1}, knownOptions)
        opts.(args{end-1}) = args{end};
        args(end-1:end) = [];
      end
      % Parse inputs
      switch numel(args)
        case 1
          X = args{1};
          Y = X(:,1);
          M = X(:,2);
          D = X(:,3);
          if size(X, 2) > 3
            T = X(:,4);
          else
            T = zeros(size(Y));
          end
        case 3
          [Y,M,D] = args{:};
          T = zeros(size(Y));
        case 4
          [Y,M,D,T] = args{:};
        case 6
          [Y,M,D,h,mi,s] = args{:};
          T = (h / 24) + (mi / (24 * 60)) + (s / (24 * 60 * 60));
        otherwise
          error('Invalid number of inputs');
      end
      % Input validation
      Y = double(Y);
      M = double(M);
      D = double(D);
      T = double(T);
      [Y, M, D, T] = octave.time.internal.scalarexpand(Y, M, D, T);
      % Construction
      this.Years = Y;
      this.Months = M;
      this.Days = D;
      this.Time = T;
      if isfield(opts, 'Format')
        this.Format = opts.Format;
      end
      this = normalizeNaNs(this);
    end
    
    % Structure
    
    function [keysA,keysB] = proxyKeys(a, b)
      %PROXYKEYS Proxy key values for sorting and set operations
      keysA = [a.Sign(:) a.Years(:) a.Months(:) a.Days(:) a.Time(:) double(a.IsNaN(:))];
      keysB = [b.Sign(:) b.Years(:) b.Months(:) b.Days(:) b.Time(:) double(b.IsNaN(:))];
    end
    
    % These setters cause Octave to crash if they are enabled.
    
    %function this = set.Sign(this, x)
    %  if ~isscalar(x) || ~isnumeric(x)
    %    error('Sign must be scalar numeric');
    %  end
    %  if ~ismember(x, [-1 1])
    %    error('Sign must be -1 or 1; got %f', x);
    %  end
    %  this.Sign = x;
    %end
    
    %function this = set.Years(this, Years)
    %  mustBeIntVal(Years);
    %  this.Years = Years;
    %end
    
    %function this = set.Months(this, Months)
    %  mustBeIntVal(Months);
    %  this.Months = Months;
    %end
    
    %function this = set.Days(this, Days)
    %  mustBeIntVal(Days);
    %  this.Days = Days;
    %end
    
    %function this = set.Time(this, Time)
    %  this.Time = Time;
    %  this = normalizeNaNs(this);
    %end
    
    % Arithmetic
    
    function out = uminus(this)
      out = this;
      out.Sign = -out.Sign;
    end
    
    function out = plus(this, B)
      if ~isa(this, 'calendarDuration')
        error('Left-hand side of + must be a calendarDuration');
      end
      if isnumeric(B)
        B = calendarDuration.ofDays(B);
      end
      if isa(B, 'calendarDuration')
        out = this;
        out.Years = this.Years + B.Sign * B.Years;
        out.Months = this.Months + B.Sign * B.Months;
        out.Days = this.Days + B.Sign * B.Days;
        out.Time = this.Time + B.Sign * B.Time;
        out.IsNaN = this.IsNaN | B.IsNaN;
        out = normalizeNaNs(out);
      else
        error('Invalid input: B must be numeric or calendarDuration; got a %s', ...
          class(B));
      end
    end
    
    function out = times(this, B)
      if isnumeric(this) && isa(B, 'calendarDuration')
        out = times(B, this);
      end
      if ~isa(this, 'calendarDuration')
        error('Left-hand side of * must be numeric or calendarDuration');
      end
      if ~isnumeric(B)
        error('B must be numeric; got a %s', class(B));
      end
      out = this;
      tfNeg = B < 0;
      if any(any(tfNeg))
        out.Sign(tfNeg) = -out.Sign(tfNeg);
        B = abs(B);
      end
      out.Years = this.Years .* B;
      out.Months = this.Months .* B;
      out.Days = this.Days .* B;
      out.Time = this.Time .* B;
      out.IsNaN = this.IsNaN | isnan(B);
      out = normalizeNaNs(out);
    end
    
    function out = minus(A, B)
      out = A + -B;
    end
    
    % Display
    
    function disp(this)
      if isempty(this)
        fprintf('Empty %s %s\n', size2str(size(this)), class(this));
        return
      end
      fprintf('%s\n', octave.time.internal.format_dispstr_array(dispstrs(this)));
    end
    
    function out = dispstrs(this)
      out = cell(size(this));
      for i = 1:numel(this)
        out{i} = dispstrScalar(subset(this, i));
      end
    end
  end
  
  methods (Access = private)
    function out = dispstrScalar(this)
      mustBeScalar(this);
      els = {};
      if this.Sign < 0
        els{end+1} = '-';
      end
      if this.Years ~= 0
        els{end+1} = sprintf('%d y', this.Years);
      end
      if this.Months ~= 0
        els{end+1} = sprintf('%d mo', this.Months);
      end
      if this.Days ~= 0
        els{end+1} = sprintf('%d d', this.Days);
      end
      time_str = dispstrs(duration.ofDays(this.Time));
      time_str = time_str{1};
      els{end+1} = time_str;
      out = strjoin(els, ' ');
    end

    function this = normalizeNaNs(this)
      this.IsNaN = this.IsNaN ...
        | isnan(this.Years) ...
        | isnan(this.Months) ...
        | isnan(this.Days) ...
        | isnan(this.Time);
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
    out = numel(this.Sign);
    end
    
    function out = ndims(this)
    %NDIMS Number of dimensions.
    out = ndims(this.Sign);
    end
    
    function out = size(this)
    %SIZE Size of array.
    out = size(this.Sign);
    end
    
    function out = isempty(this)
    %ISEMPTY True for empty array.
    out = isempty(this.Sign);
    end
    
    function out = isscalar(this)
    %ISSCALAR True if input is scalar.
    out = isscalar(this.Sign);
    end
    
    function out = isvector(this)
    %ISVECTOR True if input is a vector.
    out = isvector(this.Sign);
    end
    
    function out = iscolumn(this)
    %ISCOLUMN True if input is a column vector.
    out = iscolumn(this.Sign);
    end
    
    function out = isrow(this)
    %ISROW True if input is a row vector.
    out = isrow(this.Sign);
    end
    
    function out = ismatrix(this)
    %ISMATRIX True if input is a matrix.
    out = ismatrix(this.Sign);
    end
    
    function out = isnan(this)
    %ISNAN True for Not-a-Number.
    out = isnan2(this.Days) ...
            | isnan2(this.Months) ...
            | isnan2(this.Sign) ...
            | isnan2(this.Time) ...
            | isnan2(this.Years);
    out(this.IsNaN) = true;
    end
    
    function this = reshape(this, varargin)
    %RESHAPE Reshape array.
    this.Sign = reshape(this.Sign, varargin{:});
    this.Years = reshape(this.Years, varargin{:});
    this.Months = reshape(this.Months, varargin{:});
    this.Days = reshape(this.Days, varargin{:});
    this.Time = reshape(this.Time, varargin{:});
    this.IsNaN = reshape(this.IsNaN, varargin{:});
    end
    
    function this = squeeze(this, varargin)
    %SQUEEZE Remove singleton dimensions.
    this.Sign = squeeze(this.Sign, varargin{:});
    this.Years = squeeze(this.Years, varargin{:});
    this.Months = squeeze(this.Months, varargin{:});
    this.Days = squeeze(this.Days, varargin{:});
    this.Time = squeeze(this.Time, varargin{:});
    this.IsNaN = squeeze(this.IsNaN, varargin{:});
    end
    
    function this = circshift(this, varargin)
    %CIRCSHIFT Shift positions of elements circularly.
    this.Sign = circshift(this.Sign, varargin{:});
    this.Years = circshift(this.Years, varargin{:});
    this.Months = circshift(this.Months, varargin{:});
    this.Days = circshift(this.Days, varargin{:});
    this.Time = circshift(this.Time, varargin{:});
    this.IsNaN = circshift(this.IsNaN, varargin{:});
    end
    
    function this = permute(this, varargin)
    %PERMUTE Permute array dimensions.
    this.Sign = permute(this.Sign, varargin{:});
    this.Years = permute(this.Years, varargin{:});
    this.Months = permute(this.Months, varargin{:});
    this.Days = permute(this.Days, varargin{:});
    this.Time = permute(this.Time, varargin{:});
    this.IsNaN = permute(this.IsNaN, varargin{:});
    end
    
    function this = ipermute(this, varargin)
    %IPERMUTE Inverse permute array dimensions.
    this.Sign = ipermute(this.Sign, varargin{:});
    this.Years = ipermute(this.Years, varargin{:});
    this.Months = ipermute(this.Months, varargin{:});
    this.Days = ipermute(this.Days, varargin{:});
    this.Time = ipermute(this.Time, varargin{:});
    this.IsNaN = ipermute(this.IsNaN, varargin{:});
    end
    
    function this = repmat(this, varargin)
    %REPMAT Replicate and tile array.
    this.Sign = repmat(this.Sign, varargin{:});
    this.Years = repmat(this.Years, varargin{:});
    this.Months = repmat(this.Months, varargin{:});
    this.Days = repmat(this.Days, varargin{:});
    this.Time = repmat(this.Time, varargin{:});
    this.IsNaN = repmat(this.IsNaN, varargin{:});
    end
    
    function this = ctranspose(this, varargin)
    %CTRANSPOSE Complex conjugate transpose.
    this.Sign = ctranspose(this.Sign, varargin{:});
    this.Years = ctranspose(this.Years, varargin{:});
    this.Months = ctranspose(this.Months, varargin{:});
    this.Days = ctranspose(this.Days, varargin{:});
    this.Time = ctranspose(this.Time, varargin{:});
    this.IsNaN = ctranspose(this.IsNaN, varargin{:});
    end
    
    function this = transpose(this, varargin)
    %TRANSPOSE Transpose vector or matrix.
    this.Sign = transpose(this.Sign, varargin{:});
    this.Years = transpose(this.Years, varargin{:});
    this.Months = transpose(this.Months, varargin{:});
    this.Days = transpose(this.Days, varargin{:});
    this.Time = transpose(this.Time, varargin{:});
    this.IsNaN = transpose(this.IsNaN, varargin{:});
    end
    
    function [this, nshifts] = shiftdim(this, n)
    %SHIFTDIM Shift dimensions.
    if nargin > 1
        this.Sign = shiftdim(this.Sign, n);
        this.Years = shiftdim(this.Years, n);
        this.Months = shiftdim(this.Months, n);
        this.Days = shiftdim(this.Days, n);
        this.Time = shiftdim(this.Time, n);
        this.IsNaN = shiftdim(this.IsNaN, n);
    else
        this.Sign = shiftdim(this.Sign);
        this.Years = shiftdim(this.Years);
        this.Months = shiftdim(this.Months);
        this.Days = shiftdim(this.Days);
        this.Time = shiftdim(this.Time);
        [this.IsNaN,nshifts] = shiftdim(this.IsNaN);
    end
    end
    
    function out = cat(dim, varargin)
    %CAT Concatenate arrays.
    args = varargin;
    for i = 1:numel(args)
        if ~isa(args{i}, 'calendarDuration')
            args{i} = calendarDuration(args{i});
        end
    end
    out = args{1};
    fieldArgs = cellfun(@(obj) obj.Sign, args, 'UniformOutput', false);
    out.Sign = cat(dim, fieldArgs{:});
    fieldArgs = cellfun(@(obj) obj.Years, args, 'UniformOutput', false);
    out.Years = cat(dim, fieldArgs{:});
    fieldArgs = cellfun(@(obj) obj.Months, args, 'UniformOutput', false);
    out.Months = cat(dim, fieldArgs{:});
    fieldArgs = cellfun(@(obj) obj.Days, args, 'UniformOutput', false);
    out.Days = cat(dim, fieldArgs{:});
    fieldArgs = cellfun(@(obj) obj.Time, args, 'UniformOutput', false);
    out.Time = cat(dim, fieldArgs{:});
    fieldArgs = cellfun(@(obj) obj.IsNaN, args, 'UniformOutput', false);
    out.IsNaN = cat(dim, fieldArgs{:});
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
    if ~isa(a, 'calendarDuration')
        a = calendarDuration(a);
    end
    if ~isa(b, 'calendarDuration')
        b = calendarDuration(b);
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
    if ~isa(rhs, 'calendarDuration')
        rhs = calendarDuration(rhs);
    end
    this.Sign(s.subs{:}) = rhs.Sign;
    this.Years(s.subs{:}) = rhs.Years;
    this.Months(s.subs{:}) = rhs.Months;
    this.Days(s.subs{:}) = rhs.Days;
    this.Time(s.subs{:}) = rhs.Time;
    this.IsNaN(s.subs{:}) = rhs.IsNaN;
    end
    
    function out = subsrefParensPlanar(this, s)
    %SUBSREFPARENSPLANAR ()-indexing for planar object
    out = this;
    out.Sign = this.Sign(s.subs{:});
    out.Years = this.Years(s.subs{:});
    out.Months = this.Months(s.subs{:});
    out.Days = this.Days(s.subs{:});
    out.Time = this.Time(s.subs{:});
    out.IsNaN = this.IsNaN(s.subs{:});
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

%%%%% END PLANAR-CLASS BOILERPLATE LOCAL FUNCTIONS %%%%%


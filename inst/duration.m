classdef duration
  %DURATION Lengths of time in fixed-length units
  %
  % Duration values are stored as double numbers of days, so they are an
  % approximate type. In display functions, by default, they are displayed with
  % millisecond precision, but their actual precision is closer to nanoseconds
  % for typical times.
  
  % @planarprecedence(days)
  % @planarsetops
  % @planarrelops
  
  properties
    % Duration length in whole and fractional days (double)
    days = 0 % @planar
  end
  
  methods (Static)
    function out = ofDays(dnums)
      %OFDAYS Convert days/datenums to durations
      out = duration(dnums, 'Backdoor');
    end
  end

  methods
    function this = duration(varargin)
      %DURATION Construct a new duration array
      args = varargin;
      % Peel off options
      knownOptions = {'InputFormat','Format'};
      opts = struct;
      while numel(args) >= 3 && isa(args{end-1}, 'char') ...
          && ismember(args{end-1}, knownOptions)
        opts.(args{end-1}) = args{end};
        args(end-1:end) = [];
      end
      % Handle inputs
      switch numel(args)
        case 1
          in = args{1};
          if isnumeric(in)
            switch size(in, 2)
              case 3
                [H,MI,S] = deal(in(:,1), in(:,2), in(:,3));
                this.days = duration.hms2datenum(H, MI, S, 0);
              case 4
                [H,MI,S,MS] = deal(in(:,1), in(:,2), in(:,3), in(:,4));
                this.days = duration.hms2datenum(H, MI, S, MS);
              otherwise
                error('Numeric inputs must be 3 or 4 columns wide.');
            end
          else
            in = cellstr(in);
            if isfield(opts, 'InputFormat')
              this.days = duration.parseTimeStringsToDatenumWithFormat(in, opts.InputFormat);
            else
              this.days = duration.parseTimeStringsToDatenum(in);
            end
          end
        case 2
          % Undocumented calling form for internal use
          if ~isequal(args{2}, 'Backdoor')
            error('Invalid number if inputs: %d', numel(args));
          end
          if ~isnumeric(args{1})
            error('Input must be numeric; got a %s', class(args{1}));
          end
          this.days = double(args{1});
        case 3
          [H,MI,S] = args{:};
          this.days = duration.hms2datenum(H, MI, S, 0);
        case 4
          [H,MI,S,MS] = args{:};
          this.days = duration.hms2datenum(H, MI, S, MS);
        otherwise
          error('Invalid number if inputs: %d', numel(args));
      end
    end

    function [keysA,keysB] = proxyKeys(a, b)
      %PROXYKEYS Proxy key values for sorting and set operations
      keysA = a.days(:);
      keysB = b.days(:);
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
        return;
      end
      out = octave.internal.util.format_dispstr_array(dispstrs(this));
      fprintf('%s', out);
    end
    
    function out = dispstrs(this)
      %DISPSTRS Custom display strings.
      % This is an Octave extension.
      out = cell(size(this));
      for i = 1:numel(this)
        d = this.days(i);
        if isnan(d)
          out{i} = 'NaT';
          continue
        end
        str = '';
        if d < 0
          str = [str '-'];
          d = abs(d);
        end
        if d > 1
          str = [str sprintf('%d days ', floor(d))];
          d = mod(d,1);
        end
        millis = round(d * 24 * 60 * 60 * 1000);
        sec = millis / 1000;
        fracSec = rem(sec,1);
        x = floor(sec);
        hours = floor(x / (60 * 60));
        x = rem(x, (60 * 60));
        minutes = floor(x / 60);
        x = rem(x, 60);
        seconds = x;
        msec = round(fracSec * 1000);
        if msec == 1000
          seconds = seconds + 1;
          msec = 0;
        end
        str = [str sprintf('%02d:%02d:%02d', hours, minutes, seconds)];
        if msec >= 1
          str = [str '.' sprintf('%03d', msec)];
        end
        out{i} = str;
      end
    end
    
    % Arithmetic
    
    function out = times(A, B)
      %TIMES Multiplication
      if isa(A, 'double')
        out = B;
        out.days = out.days .* A;
      elseif isa(B, 'double')
        out = A;
        out.days = out.days .* B;
      else
        error('Invalid inputs to times: %s * %s', class(A), class(B));
      end
    end

    function out = mtimes(A, B)
      %MTIMES Multiplication
      if isa(A, 'double')
        out = B;
        out.days = out.days * A;
      elseif isa(B, 'double')
        out = A;
        out.days = out.days * B;
      else
        error('Invalid inputs to mtimes: %s * %s', class(A), class(B));
      end
    end
  
    function out = rdivide(A, B)
      %RDIVIDE Element-wise right division
      if ~isa(A, 'duration')
        error('When dividing using duration, the left-hand side must be a duration; got a %s', ...
          class(A));
      end
      if isa(B, 'duration')
        out = A.days ./ B.days;
      elseif isa(B, 'double')
        out = A;
        out.days = A.days ./ B;
      else
        error('Invalid input: RHS must be duration or double; got a %s', class(B));
      end
    end
    
    function out = mrdivide(A, B)
      %MRDIVIDE Matrix right division
      if ~isa(A, 'duration')
        error('When dividing using duration, the left-hand side must be a duration; got a %s', ...
          class(A));
      end
      if isa(B, 'double')
        out = A;
        out.days = A.days / B;
      else
        error('Invalid input: RHS must be double; got a %s', class(B));      
      end
    end
  
    function out = plus(A, B)
      %PLUS Addition
      if isa(A, 'datetime') && isa(B, 'duration')
        out = A;
        out.dnums = out.dnums + B.days;
      elseif isa(A, 'duration') && isa(B, 'datetime')
        out = B + A;
      elseif isa(A, 'duration') && isa(B, 'duration')
        out = A;
        out.days = A.days + B.days;
      elseif isa(A, 'duration') && isa(B, 'double')
        out = A;
        out.days = A.days + B;
      elseif isa(A, 'double') && isa(B, 'duration')
        out = B + A;
      end
    end
    
    function out = minus(A, B)
      %MINUS Subtraction
      out = A + (-1 * B);
    end
    
    function out = uminus(A)
      %UMINUS Unary minus
      out = A;
      out.days = -1 * A.days;
    end
    
    function out = uplus(A)
      %UPLUS Unary plus
      out = A;
    end
  end
  
  methods (Static, Access = private)
    function out = hms2datenum(H, MI, S, MS)
      if nargin < 4; MS = 0; end
      [H, MI, S, MS] = deal(double(H), double(MI), double(S), double(MS));
      out = (H / 24) + (MI / (24 * 60)) + (S / (24 * 60 * 60)) ...
        + (MS / (24 * 60 * 60 * 1000));
    end
    
    function out = parseTimeStringsToDatenum(strs)
      strs = cellstr(strs);
      out = NaN(size(strs));
      for i = 1:size(strs)
        strIn = strs{i};
        str = strIn;
        ixDot = find(str == '.');
        if numel(ixDot) > 1
          error('Invalid TimeString: ''%s''', strIn);
        elseif ~isempty(ixDot)
          fractionalSecStr = str(ixDot+1:end);
          str(ixDot:end) = [];
          nFracs = str2double(fractionalSecStr);
          fractionalSec = nFracs / (10^numel(fractionalSecStr));
          MS = fractionalSec * 1000;          
        else
          MS = 0;
        end
        els = strsplit(str, ':');
        if numel(els) == 3
          D = 0;
          [H,MI,S] = deal(str2double(els{1}), str2double(els{2}), str2double(els{3}));
        elseif numel(els) == 4
          [D,H,MI,S] = deal(str2double(els{1}), str2double(els{2}), ...
            str2double(els{3}));
        else
          error('Invalid TimeString: ''%s''', strIn);
        end
        out(i) = duration.hms2datenum(D * 24 + H, MI, S, MS);
      end
    end
    
    function out = parseTimeStringsToDatenumWithFormat(strs)
      error('InputFormat support for time strings is unimplemented');
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
    out = numel(this.days);
    end
    
    function out = ndims(this)
    %NDIMS Number of dimensions.
    out = ndims(this.days);
    end
    
    function out = size(this)
    %SIZE Size of array.
    out = size(this.days);
    end
    
    function out = isempty(this)
    %ISEMPTY True for empty array.
    out = isempty(this.days);
    end
    
    function out = isscalar(this)
    %ISSCALAR True if input is scalar.
    out = isscalar(this.days);
    end
    
    function out = isvector(this)
    %ISVECTOR True if input is a vector.
    out = isvector(this.days);
    end
    
    function out = iscolumn(this)
    %ISCOLUMN True if input is a column vector.
    out = iscolumn(this.days);
    end
    
    function out = isrow(this)
    %ISROW True if input is a row vector.
    out = isrow(this.days);
    end
    
    function out = ismatrix(this)
    %ISMATRIX True if input is a matrix.
    out = ismatrix(this.days);
    end
    
    function out = isnan(this)
    %ISNAN True for Not-a-Number.
    out = isnan2(this.days);
    end
    
    function this = reshape(this, varargin)
    %RESHAPE Reshape array.
    this.days = reshape(this.days, varargin{:});
    end
    
    function this = squeeze(this, varargin)
    %SQUEEZE Remove singleton dimensions.
    this.days = squeeze(this.days, varargin{:});
    end
    
    function this = circshift(this, varargin)
    %CIRCSHIFT Shift positions of elements circularly.
    this.days = circshift(this.days, varargin{:});
    end
    
    function this = permute(this, varargin)
    %PERMUTE Permute array dimensions.
    this.days = permute(this.days, varargin{:});
    end
    
    function this = ipermute(this, varargin)
    %IPERMUTE Inverse permute array dimensions.
    this.days = ipermute(this.days, varargin{:});
    end
    
    function this = repmat(this, varargin)
    %REPMAT Replicate and tile array.
    this.days = repmat(this.days, varargin{:});
    end
    
    function this = ctranspose(this, varargin)
    %CTRANSPOSE Complex conjugate transpose.
    this.days = ctranspose(this.days, varargin{:});
    end
    
    function this = transpose(this, varargin)
    %TRANSPOSE Transpose vector or matrix.
    this.days = transpose(this.days, varargin{:});
    end
    
    function [this, nshifts] = shiftdim(this, n)
    %SHIFTDIM Shift dimensions.
    if nargin > 1
        this.days = shiftdim(this.days, n);
    else
        [this.days,nshifts] = shiftdim(this.days);
    end
    end
    
    function out = cat(dim, varargin)
    %CAT Concatenate arrays.
    args = varargin;
    for i = 1:numel(args)
        if ~isa(args{i}, 'duration')
            args{i} = duration(args{i});
        end
    end
    out = args{1};
    fieldArgs = cellfun(@(obj) obj.days, args, 'UniformOutput', false);
    out.days = cat(dim, fieldArgs{:});
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
            error('jl:BadOperation',...
                '{}-subscripting is not supported for class %s', class(this));
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
            error('jl:BadOperation',...
                '{}-subscripting is not supported for class %s', class(this));
        case '.'
            out = this.(s(1).subs);
    end
    
    % Chained reference
    if numel(s) > 1
        out = subsref(out, s(2:end));
    end
    end
    
    function n = numArgumentsFromSubscript(this,~,indexingContext) %#ok<INUSL>
    switch indexingContext
        case matlab.mixin.util.IndexingContext.Statement
            n = 1; % nargout for indexed reference used as statement
        case matlab.mixin.util.IndexingContext.Expression
            n = 1; % nargout for indexed reference used as function argument
        case matlab.mixin.util.IndexingContext.Assignment
            n = 1; % nargin for indexed assignment
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
    if ~isa(a, 'duration')
        a = duration(a);
    end
    if ~isa(b, 'duration')
        b = duration(b);
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
    if ~isa(rhs, 'duration')
        rhs = duration(rhs);
    end
    this.days(s.subs{:}) = rhs.days;
    end
    
    function out = subsrefParensPlanar(this, s)
    %SUBSREFPARENSPLANAR ()-indexing for planar object
    out = this;
    out.days = this.days(s.subs{:});
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


classdef calendarDuration
  %CALENDARDURATION Lengths of time in variable-length calendar units
  
  properties (SetAccess = private)
    Sign = 1
    Years
    Months
    Days
    % Time as datenum-style double
    Time
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
      mustBeScalar(Y);
      mustBeScalar(M);
      mustBeScalar(D);
      mustBeScalar(T);
      mustBeIntVal(Y);
      mustBeIntVal(M);
      mustBeIntVal(D);
      % Construction
      this.Years = Y;
      this.Months = M;
      this.Days = D;
      this.Time = T;
      if isfield(opts, 'Format')
        this.Format = opts.Format;
      end
    end
    
    function out = uminus(this)
      out = this;
      out.Sign = out.Sign * -1;
    end
    
    % Display
    
    function disp(this)
      if ~isscalar(this)
        fprintf('%s %s\n', sizestr(size(this)), class(this));
        return
      end
      s = dispstrScalar(this);
      fprintf('%s\n', s{1});
    end
    
    function out = dispstrs(this)
      out = cell(size(this));
      for i = 1:numel(this)
        out{i} = dispstrScalar(this);
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
  end
end

function mustBeScalar(x)
  if ~isscalar(x)
    error('Input %s must be scalar', inputname(1));
  end
end

function mustBeIntVal(x)
  if fix(x) ~= x
    error('Input %s must be an integer value', inputname(1));
  end
end

function varargout = scalarexpand(varargin)
%SCALAREXPAND Expand scalar inputs to be same size as nonscalar inputs

sz = [];

for i = 1:nargin
	if ~isscalar(varargin{i})
		sz_i = size(varargin{i});
		if isempty(sz)
			sz = sz_i;
		else
			if ~isequal(sz, sz_i)
				error('Matrix dimensions must agree (%s vs %s)',...
					size2str(sz), size2str(sz_i))
			end
		end
	end
end

varargout = varargin;

if isempty(sz)
	return
end

for i = 1:nargin
	if isscalar(varargin{i})
    varargout{i} = repmat(varargin{i}, sz);
	end
end

end
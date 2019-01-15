classdef PosixZoneRule
  %POSIXZONERULE A POSIX-style time zone rule
  
  properties
    local_timezone
    std_name
    dst_name
    gmt_offset_hours
    dst_start_rule
    dst_end_rule
  end
  
  methods (Static)
    function out = parseZoneRule(str)
      out = octave.time.internal.algo.PosixZoneRule;
      if ~isrow(in)
        error('in must be charvec; got non-row char');
      end
      els = strsplit(in, ',');
      if numel(els ~= 3)
        error('Invalid POSIX time zone rule specification: ''%s''', in);
      end
      out.local_timezone = els{1};
      out.dst_start_rule = els{2};
      out.dst_end_rule = els{3};
      tok = regexp(out.local_timezone, '^([A-Za-z]+)(\d+)([A-Za-z]+)$', 'tokens');
      tok = tok{1};
      if numel(tok) ~= 3
        error('Failed parsing POSIX zone name: ''%s''', out.local_timezone);
      end
      out.std_name = tok{1};
      out.gmt_offset_hours = str2double(tok{2});
      out.dst_name = tok{3};
    end
  end

  methods
    function this = PosixZoneRule(in)
      if nargin == 0
        return
      end
      if ischar(in)
        this = octave.time.internal.tzinfo.PosixZoneRule.parseZoneRule(in);
      end
    end
    
    function out = gmtToLocalDatenum(this, dnums)
      error('Unimplemented');
    end
    
    function out = localToGmtDatenum(this, dnums, isDst)
      error('Unimplemented');
    end
  end
end

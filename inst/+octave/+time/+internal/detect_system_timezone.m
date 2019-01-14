function out = detect_system_timezone
  try
    out = do_detection();
    tzdb = octave.time.internal.tzinfo.TzDb;
    if ~ismember(out, tzdb.definedZones)
      warning('System time zone ''%s'' is not defined in the tzinfo database.', ...
        out);
    end
  catch err
    warning(['Failed detecting system time zone: %s\n'...
      'Falling back to '''''], ...
      err.message);
    out = '';
  end
end

function out = do_detection()
  % TODO: find a way to detect and convert Windows system time zone without 
  % using Java or .NET. 'systeminfo | findstr /C:"Time Zone"' is too slow.
  
  % Let TZ env var take precedence
  tz_env = getenv('TZ');
  if ~isempty(tz_env)
    out = tz_env;
  else
    % Get actual system default
    if exist('/etc/localtime', 'file')
      % This exists on macOS and RHEL/CentOS 7/some Fedora
      [target,err,msg] = readlink('/etc/localtime');
      if err
        error('Can''t determine time zone: Failed reading /etc/localtime: %s', ...
          msg);
      end
      out = regexprep(target, '.*/zoneinfo/', '');
    elseif exist('/etc/timezone')
      % This exists on Debian
      out = strtrim(slurpTextFile('/etc/timezone'));
    else
      if ~usejava('jvm')
        error('Detecting time zone on this OS requires Java, which is not available in this Octave.');
      end
      zone = javaMethod('getDefault', 'java.util.TimeZone');
      out = char(zone.getID());
    end
  end
end
classdef WindowsIanaZoneConverter
  %WINDOWSIANAZONECONVERTER Converts between Windows and IANA zone ids
  
  methods
    function out = windows2iana(this, winZoneId)
      map = getZoneMap(this);
      ix = find(strcmp(winZoneId, map.Windows));
      if isempty(ix)
        error('Unrecognized Windows time zone ID: ''%s''', winZoneId);
      end
      territories = map.Territory(ix);
      ianas = map.Iana(ix);
      if isscalar(ix)
        out = ianas{1};
      else
        [tf,loc] = ismember('001', territories);
        if ~tf
          out = ianas{1};
          warning(['No "001" territory found for Windows time zone ''%s'' in map file. ' ...
            'Guessing IANA zone randomly as ''%s''.'], ...
            winZoneId, out);
        else
          out = ianas{loc};
        end
      end
    end
    
    function out = iana2windows(this, ianaZoneId)
      map = getZoneMap(this);
      [tf,loc] = ismember(ianaZoneId, map.Iana);
      if ~tf
        error('Unrecognized IANA time zone ID: ''%s''', ianaZoneId);
      end
      out = map.Windows{loc};
    end

    function out = getZoneMap(this)
      persistent cache
      if isempty(cache)
        cache = readWindowsZonesFile(this);
      end
      out = cache;
    end
    
    function out = readWindowsZonesFile(this)
      this_dir = fileparts(mfilename('fullpath'));
      zones_file = fullfile(this_dir, 'resources', 'windowsZones', 'windowsZones.xml');
      txt = slurpTextFile(zones_file);
      % Base Octave doesn't have XML reading, so we'll kludge it with regexps
      pattern = '<mapZone +other="([^"]*)" +territory="([^"]*)" type="([^"]*)" */>';
      [starts,tok] = regexp(txt, pattern, 'start', 'tokens');
      tok = cat(1, tok{:});
      out.Windows = tok(:,1);
      out.Territory = tok(:,2);
      out.Iana = tok(:,3);
    end
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

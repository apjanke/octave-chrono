classdef TzDb
  %TZDB Interface to the tzinfo database
  %
  % This class is an interface to the tzinfo database (AKA the Olson database)
  
  properties
    % Path to the zoneinfo directory
    path
  end
  
  methods (Static)
    function out = instance()
      %INSTANCE Shared global instance of TzDb
      persistent value
      if isempty(value)
        value = octave.time.internal.tzinfo.TzDb;
      end
      out = value;
    end
  end

  methods
    function this = TzDb(path)
      %TZDB Construct a new TzDb object
      %
      % this = TzDb(path)
      %
      % path (char) is the path to the tzinfo database directory. If omitted or
      % empty, it defaults to the default path ('/usr/share/zoneinfo' on Unix,
      % and an error on Windows).
      if nargin < 1;  path = [];  end
      if isempty(path)
        this.path = octave.time.internal.tzinfo.TzDb.defaultPath;
      else
        this.path = path;
      end
    end
    
    function out = dbVersion(this)
      %DBVERSION Version of the zoneinfo database this is reading
      %
      % out = dbVersion(this)
      %
      % Returns the zoneinfo database version as a string.
      versionFile = [this.path '/+VERSION'];
      txt = slurpTextFile(versionFile);
      out = strtrim(txt);
    end
        
    function out = zoneTab(this)
      %ZONETAB Get the zone definition table
      %
      % This lists the metadata from the "zone.tab" file included in the
      % zoneinfo database.
      %
      % Returns a struct with fields:
      %   CountryCode
      %   Coordinates
      %   TZ
      %   Comments
      % Each of which contains a cellstr column vector.
      persistent data
      if isempty(data)
        data = this.readZoneTab();
      end
      out = data;
    end
    
    function out = definedZones(this)
      %DEFINEDZONES List defined zone IDs
      %
      % out = definedZones(this)
      persistent value
      if isempty(value)
        specialFiles = {'+VERSION', 'iso3166.tab', 'zone.tab', 'posixrules'};
        files = findFiles(this.path);
        if ispc
          files = strrep(files, '\', '/');
        end
        value = setdiff(files', specialFiles);
      end
      out = value;
    end
    
    function out = zoneDefinition(this, zoneId)
      %ZONEDEFINITION Get the time zone definition for a given time zone
      %
      % out = zoneDefinition(this, zoneId)
      %
      % zoneId (char) is the time zone identifier in IANA format. For example,
      % 'UTC' or 'America/New_York'.
      %
      % Returns the zone definition as an object. (This is currently under
      % construction; it now returns a placeholder struct.)
      s = this.readZoneFile(zoneId);

      % We prefer the version 2 stuff
      out = octave.time.internal.tzinfo.TzInfo;
      if isfield(s, 'section2')
        defn_s = s.section2;
        out.goingForwardPosixZone = s.goingForwardPosixZone;
      else
        defn_s = s.section1;
      end
      out.id = zoneId;
      out.formatId = defn_s.header.format_id;
      out.transitions = defn_s.transitions;
      out.timeTypes = defn_s.time_types;
      out.ttinfos = defn_s.ttinfos;
      out.leapTimes = defn_s.leap_times;
      out.leapSecondTotals = defn_s.leap_second_totals;
      out.isStd = defn_s.is_std;
      out.isGmt = defn_s.is_gmt;
    end
  end
  
  methods (Access = private)
    function out = readZoneTab(this)
      %READZONETAB Actually read and parse the zonetab file
      
      % Use the "deprecated" plain zone.tab because zone1970.tab is not present
      % on all systems.
      zoneTabFile = [this.path '/zone.tab'];
      
      txt = slurpTextFile(zoneTabFile);
      lines = strsplit(txt, sprintf('\n'));
      starts = regexp(lines, '^\s*#|^\s*$', 'start', 'once');
      tfComment = ~cellfun('isempty', starts);
      lines(tfComment) = [];
      tfBlank = cellfun('isempty', lines);
      lines(tfBlank) = [];
      pattern = '^(\w+)\s+(\S+)\s+(\S+)\s*(.*)';
      [match,tok] = regexp(lines, pattern, 'match', 'tokens');
      tfMatch = ~cellfun('isempty', match);
      if ~all(tfMatch)
        ixBad = find(~tfMatch);
        error('Failed parsing line in zone.tab file: "%s"', lines{ixBad(1)});
      end
      tok = cat(1, tok{:});
      tok = cat(1, tok{:});
      
      out = struct;
      out.CountryCode = tok(:,1);
      out.Coordinates = tok(:,2);
      out.TZ = tok(:,3);
      out.Comments = tok(:,4);
    end
    
    function out = readZoneFile(this, zoneId)
      %READZONEFILE Read and parse a zone definition file
      if ~ismember(zoneId, this.definedZones)
        error('Undefined time zone: %s', zoneId);
      end
      zoneFile = [this.path '/' zoneId];
      if ~exist(zoneFile)
        error(['tzinfo time zone file for zone %s does not exist: %s\n' ...
          'This is probably an error in the tzinfo database files.'], ...
            zoneId, zoneFile);
      end
      data = slurpBinaryFile(zoneFile);
      
      % Parse tzinfo format file
      ix = 1;
      [section1, n_bytes_read] = this.parseZoneSection(data(ix:end), 1);
      out.section1 = section1;
      
      % Version 2 stuff
      if ismember(section1.header.format_id, {'2','3'})
        % A whole nother header/data, except using 8-byte transition/leap times
        ix = ix + n_bytes_read;
        % Scan for the magic cookie to double-check our parsing.
        magic_ixs = strfind(char(data(ix:end)), 'TZif');
        if isempty(magic_ixs)
          % No second section found
        else
          % Advance to where we found the magic cookie
          if magic_ixs(1) ~= 1
            warning(['Unexpected extra data at end of section in tzinfo file for %s.\n' ...
              'Possible bug in chrono''s parsing code.'], zoneId);
          end
          ix = ix + magic_ixs(1) - 1;
          [out.section2, n_bytes_read_2] = this.parseZoneSection(data(ix:end), 2);
          ix = ix + n_bytes_read_2;
          % And then there's the going-forward zone at the end.
          % The first LF should be the very next byte.
          data_left = data(ix:end);
          ixLF = find(data_left == uint8(sprintf('\n')));
          if numel(ixLF) >= 2
            out.goingForwardPosixZone = char(data_left(ixLF(1)+1:ixLF(2)-1));
          end
        end
      end
    end

    function [out, nBytesRead] = parseZoneSection(this, data, sectionFormat)
      %PARSEZONESECTION Parse one section of a tzinfo file
      
      % "cursor" index pointing to current point of parsing
      ix = 1; 
      % "get" functions read/convert data; "take" functions read/convert and
      % advance the cursor
      function out = get_int(my_bytes)
        out = swapbytes(typecast(my_bytes, 'int32'));
      end
      function out = get_int64(my_bytes)
        out = swapbytes(typecast(my_bytes, 'int64'));
      end
      function out = get_null_terminated_string(my_bytes)
        my_ix = 1;
        while my_bytes(my_ix) ~= 0
          my_ix = my_ix + 1;
        end
        out = char(my_bytes(1:my_ix - 1));
      end
      function out = take_byte(n)
        if nargin < 1; n = 1; end
        n = double(n);
        out = data(ix:ix + n - 1);
        ix = ix + n;
      end
      function out = take_int(n)
        if nargin < 1; n = 1; end
        n = double(n);
        out = get_int(data(ix:ix + (4*n) - 1));
        ix = ix + 4*n;
      end
      function out = take_int64(n)
        if nargin < 1; n = 1; end
        n = double(n);
        out = get_int64(data(ix:ix+(8*n)-1));
        ix = ix + 8*n;
      end
      function out = take_timeval(n)
        if sectionFormat == 1
          out = take_int(n);
        else
          out = take_int64(n);
        end
      end

      % Header
      h.magic = data(ix:ix+4-1);
      h.magic_char = char(h.magic);
      ix = ix + 4;
      format_id_byte = take_byte;
      h.format_id = char(format_id_byte);
      h.reserved = data(ix:ix+15-1);
      ix = ix + 15;
      h.counts_vals = take_int(6);
      counts_vals = h.counts_vals;
      h.n_ttisgmt = counts_vals(1);
      h.n_ttisstd = counts_vals(2);
      h.n_leap = counts_vals(3);
      h.n_time = counts_vals(4);
      h.n_type = counts_vals(5);
      h.n_char = counts_vals(6);
      
      % Body
      transitions = take_timeval(h.n_time);
      time_types = take_byte(h.n_time);
      ttinfos = struct('gmtoff',int32([]), 'isdst',uint8([]), 'abbrind',uint8([]));
      function out = take_ttinfo()
        ttinfos.gmtoff(end+1) = take_int;
        ttinfos.isdst(end+1) = take_byte;
        ttinfos.abbrind(end+1) = take_byte;
      end
      for i = 1:h.n_type
        take_ttinfo;
      end
      %TODO: read tz abbreviation bytes
      % It's not clearly documented, but following the ttinfo section are a
      % series of null-terminated strings. There's no length indicator for them,
      % so we have to scan for the null after the last string.
      abbrs = {};
      if ~isempty(ttinfos.abbrind)
        last_abbrind = max(ttinfos.abbrind);
        ix_end = ix + double(last_abbrind);
        while data(ix_end) ~= 0
          ix_end = ix_end + 1;
        end
        abbr_section = data(ix:ix_end);
        for i = 1:numel(ttinfos.abbrind)
          abbrs{i} = get_null_terminated_string(abbr_section(ttinfos.abbrind(i)+1:end));
        end
        ix = ix_end + 1;
      end
      ttinfos.abbr = abbrs;
      if sectionFormat == 1
        leap_times = repmat(uint32(0), [h.n_leap 1]);
      else
        leap_times = repmat(uint64(0), [h.n_leap 1]);
      end
      leap_second_totals = repmat(uint32(0), [h.n_leap 1]);
      for i = 1:h.n_leap
        leap_times(i) = take_timeval(1);
        leap_second_totals(i) = take_int(1);
      end
      is_std = take_byte(h.n_ttisstd);
      is_gmt = take_byte(h.n_ttisgmt);

      out.header = h;
      out.transitions = transitions;
      out.time_types = time_types;
      out.ttinfos = ttinfos;
      out.leap_times = leap_times;
      out.leap_second_totals = leap_second_totals;
      out.is_std = is_std;
      out.is_gmt = is_gmt;      
      nBytesRead = ix - 1;
    end
  end

  
  methods (Static)
    function out = defaultPath()
      if ispc
        % Use the zoneinfo database bundled with Chrono
        this_dir = fileparts(mfilename('fullpath'));
        out = fullfile(this_dir, 'resources', 'zoneinfo');
      else
        out = '/usr/share/zoneinfo';
      end
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

function out = slurpBinaryFile(file)
  [fid,msg] = fopen(file, 'r');
  if fid == -1
    error('Could not open file %s: %s', file, msg);
  end
  cleanup.fid = onCleanup(@() fclose(fid));
  out = fread(fid, Inf, 'uint8=>uint8');
  out = out';  
end

function out = findFiles(dirPath)
  %FINDFILES Recursively find files under a directory
  out = findFilesStep(dirPath, '');
end

function out = findFilesStep(dirPath, pathPrefix)
  found = {};
  d = mydir(dirPath);
  for i = 1:numel(d)
    f = d(i);
    if f.isdir
      found = [found findFilesStep(fullfile(dirPath, f.name), fullfile(pathPrefix, f.name))];
    else
      found{end+1} = fullfile(pathPrefix, f.name);
    end
  end
  out = found;
end

function out = mydir(folder)
  d = dir(folder);
  names = {d.name};
  out = d;
  out(ismember(names, {'.','..'})) = [];
end
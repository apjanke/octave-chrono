function out = hours(x)
  %HOURS Duration in hours
  %
  % If input is numeric, returns a @duration array that is that many hours long.
  %
  % If input is a duration, converts the duration to a number of hours.
  if isnumeric(x)
    out = duration.ofDays(x / 24);
  elseif isa(x, 'duration')
    out = x.days * 24;
  else
    error('Invalid input: expected numeric or duration; got %s', class(x));
  end
end

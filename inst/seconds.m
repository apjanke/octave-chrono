function out = seconds(x)
  %SECONDS Duration in seconds
  %
  % If input is numeric, returns a @duration array that is that many seconds long.
  %
  % If input is a duration, converts the duration to a number of seconds.
  if isnumeric(x)
    out = duration.ofDays(x / (24 * 60 * 60));
  elseif isa(x, 'duration')
    out = x.days * (24 * 60 * 60);
  else
    error('Invalid input: expected numeric or duration; got %s', class(x));
  end
end

function out = minutes(x)
  %MINUTES Duration in minutes
  %
  % If input is numeric, returns a @duration array that is that many minutes long.
  %
  % If input is a duration, converts the duration to a number of minutes.
  if isnumeric(x)
    out = duration.ofDays(x / (24 * 60));
  elseif isa(x, 'duration')
    out = x.days * (24 * 60);
  else
    error('Invalid input: expected numeric or duration; got %s', class(x));
  end
end

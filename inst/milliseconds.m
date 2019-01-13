function out = milliseconds(x)
  %MILLISECONDS Duration in milliseconds
  %
  % If input is numeric, returns a @duration array that is that many milliseconds long.
  %
  % If input is a duration, converts the duration to a number of milliseconds.
  if isnumeric(x)
    out = duration.ofDays(x / (24 * 60 * 60 * 1000));
  elseif isa(x, 'duration')
    out = x.days * (24 * 60 * 60 * 1000);
  else
    error('Invalid input: expected numeric or duration; got %s', class(x));
  end
end

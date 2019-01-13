function out = days(x)
  %DAYS duration in days
  %
  % out = days(x)
  %
  % If x is numeric, then out is a duration array in units of fixed-length 24-hour
  % days.
  %
  % If x is a duration, then returns a double array indicating the number of
  % days that duration is.
  if isnumeric(x)
    out = duration.ofDays(x);
  elseif isa(x, 'duration')
    out = duration.days;
  else
    error('Invalid input: expected numeric or duration; got %s', class(x));    
  end
end

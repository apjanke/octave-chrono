function out = calmonths(x)
  %CALMONTHS Calendar duration in months
  if ~isnumeric(x)
    error('Input must be numeric');
  end
  out = calendarDuration(0, x, 0);  
end

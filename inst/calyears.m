function out = calyears (x)
  %CALYEARS Calendar duration in years
  if ~isnumeric (x)
    error ('Input must be numeric');
  endif
  out = calendarDuration (x, 0, 0);
endfunction

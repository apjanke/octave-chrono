function out = years(x)
  %YEARS Duration in years
  %
  % If input is numeric, returns a @duration array in units of fixed-length 
  % years of 365.2425 days each.
  %
  % If input is a duration, converts the duration to a number of fixed-length
  % years as double.
  %
  % Note: years creates fixed-length years, which is probably not what you want.
  % To create a duration of calendar years (which account for actual leap days),
  % use calyears.
  if isnumeric(x)
    out = duration.ofDays(365.2425 * x);
  elseif isa(x, 'duration')
    out = x.days / 365.2425;
  else
    error('Invalid input: expected numeric or duration; got %s', class(x));
  end
end

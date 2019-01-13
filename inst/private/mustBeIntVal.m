function mustBeIntVal(x)
  if any(any(fix(x) ~= x))
    error('Input %s must be an integer value', inputname(1));
  end
end

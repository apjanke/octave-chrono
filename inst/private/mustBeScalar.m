function mustBeScalar(x)
  if ~isscalar(x)
    error('Input %s must be scalar', inputname(1));
  end
end

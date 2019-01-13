function out = NaT(sz)
  %NAT Not-a-Time
  %
  % Creates an array of datetimes with the value NaT.
  if nargin == 0
    out = datetime.NaT;
  else
    out = repmat(datetime.NaT, sz);
  end
end

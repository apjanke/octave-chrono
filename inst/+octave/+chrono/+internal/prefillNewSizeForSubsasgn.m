function out = prefillNewSizeForSubsasgn(x, ixRef, fillVal)
  sz = size(x);
  if isequal(ixRef, ':')
    out = x;
  elseif isscalar(ixRef)
    ix = ixRef{1};
    if max(ix) > numel(x)
      if ~isvector(x)
        error('Invalid resizing operation using out-of-bounds linear indexing on a non-vector input');
      endif
      out = x;
      out(max(ix)) = fillVal;
      out(numel(x)+1:end) = fillVal;
    endif
  else
    ixs = ixRef;
    newSz = NaN([1 ndims(x)]);
    for i = 1:numel(ixs)
      newSz = max(size(x, i), max(ixs{i}));
    endfor
    if isequal(sz, newSz)
      out = x;
    else
      out = NaN(newSz);
      oldRange = cell(1, ndims(x));
      for i = 1:numel(oldRange)
        oldRange{i} = 1:size(x,i);
      endfor
      out(oldRange{:}) = x;
    end
  endif
endfunction

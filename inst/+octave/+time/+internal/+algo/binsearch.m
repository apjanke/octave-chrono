function [tf,loc] = binsearch(needles, haystack)
  %BINSEARCH Binary search
  %
  % [tf,loc] = binsearch(needles, haystack)
  %
  % Searches for needles in haystack. Needles and haystack must both be doubles.
  % Haystack must be a sorted vector. (The sortedness is not checked, for speed:
  % if it is not sorted, you will just get wrong answers instead of raising an
  % error.
  %
  % This does the same thing as ismember(), but is faster, with an additional
  % restriction that the array to search through must be sorted.
  %
  % Returns arrays the same size as needles. tf is a logical array indicating
  % whether each element was found. loc is an array of indexes, either where it
  % was found, or if not found, -1 * the index of the element where it should be
  % inserted; that is, the index of the first element larger than it, or one past
  % the end of the array if it is larger than all the elements in the haystack.
  if ~isvector(haystack) && ~isempty(haystack)
    error('haystack must be a vector or empty');
  end
  if ~isequal(class(needles), class(haystack))
    error('needles and haystack must be same type; got %s and %s', ...
      class(needles), class(haystack));
  end
  if isnumeric(needles)
    if iscomplex(needles) || iscomplex(haystack)
      error('complex values are not supported');
    end
    loc = double(binsearch_oct(needles, haystack));
  else
    % TODO: Native Octave implementation for these.
    error('Non-numeric types are unimplemented (got type %s).', class(needles));
  end
  tf = loc > 0;
end

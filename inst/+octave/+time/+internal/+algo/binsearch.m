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
  if ~isa(needles, 'double')
    error('needles must be a double');
  end
  if ~isa(haystack, 'double')
    error('haystack must be a double');
  end
  if ~isvector(haystack) && ~isempty(haystack)
    error('haystack must be a vector or empty');
  end
  loc = double(binsearch_oct(needles, haystack));
  tf = loc > 0;
end

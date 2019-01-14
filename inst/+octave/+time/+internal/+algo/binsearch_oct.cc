#include <octave/oct.h>
#include <iostream>

// Inputs:
//  1: target values (needles)
//  2: search array (haystack); must be a sorted vector
// Returns:
//  1: Indexes: positive if found, negative if not found. 1-based.

template <class T>
octave_idx_type *binsearch (const T vals[], octave_idx_type vals_len, const T arr[], octave_idx_type len) {
  octave_idx_type *out = new octave_idx_type[vals_len];
  for (octave_idx_type i = 0; i < vals_len; i++) {
    T val = vals[i];
    octave_idx_type low = 0;
    octave_idx_type high = len - 1;
    int found = 0;
    while (low <= high) {
      octave_idx_type mid = (low + high) / 2;
      if (arr[mid] > val)
        high = mid - 1;
      else if (arr[mid] < val)
        low = mid + 1;
      else {
        found = 1;
        out[i] = mid + 1; // found
        break;
      }
    }
    if (!found)
      out[i] = -1 * (low + 1); // not found - not sure this is correct
  }
  return out;
}

DEFUN_DLD (binsearch_oct, args, nargout,
           "Vectorized binary search")
{
  int nargin = args.length ();
  if (nargin != 2)
    return octave_value_list ();  // TODO: raise Octave error

  // I don't know how to do type detection in oct files. Assume inputs are doubles.
  NDArray vals = args(0).array_value ();
  NDArray arr = args(1).array_value ();
  octave_idx_type *indexes = binsearch(vals.fortran_vec (), vals.numel (), 
    arr.fortran_vec (), arr.numel ());
  NDArray out (vals.dims ());
  octave_idx_type n = vals.numel ();
  for (octave_idx_type i = 0; i < n; i++) {
    out(i) = indexes[i];
  }
  delete [] indexes;
  return octave_value (out);
}


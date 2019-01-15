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
      else if (arr[mid] == val) {
        found = 1;
        out[i] = mid + 1; // found
        break;
      } else {
        std::cout << "Total ordering violation: neither <, >, nor == was true. "
          << "vals[" << i << "] = " << val << ", arr[" << mid << "] = " << arr[mid]
          << "\n";
        // TODO: Raise Octave error.
        break;
      }
    }
    if (!found)
      out[i] = -1 * (low + 1); // not found
  }
  return out;
}

DEFUN_DLD (__oct_time_binsearch__, args, nargout,
           "Vectorized binary search")
{
  int nargin = args.length ();
  if (nargin != 2) {
    std::cout << "Error: Invalid number of arguments. Expected 2; got "
      << nargin << "\n";
    return octave_value_list ();  // TODO: raise Octave error
  }
  
  octave_value vals = args(0);
  octave_value arr = args(1);
  builtin_type_t vals_type = vals.builtin_type ();
  builtin_type_t arr_type = vals.builtin_type ();
  if (vals_type != arr_type) {
    std::cout << "Error: inputs must be same type; got types " << vals_type <<
      " and " << arr_type << "\n";
    return octave_value_list ();
  }
  octave_idx_type *indexes;
  switch (vals_type) {
    case btyp_double:
      indexes = binsearch(vals.array_value ().fortran_vec (), vals.numel (), 
        arr.array_value ().fortran_vec (), arr.numel ());
      break;
    case btyp_float:
      indexes = binsearch(vals.float_array_value ().fortran_vec (), vals.numel (), 
        arr.float_array_value ().fortran_vec (), arr.numel ());
      break;
    case btyp_int8:
      indexes = binsearch(vals.int8_array_value ().fortran_vec (), vals.numel (), 
        arr.int8_array_value ().fortran_vec (), arr.numel ());
      break;
    case btyp_int16:
      indexes = binsearch(vals.int16_array_value ().fortran_vec (), vals.numel (), 
        arr.int16_array_value ().fortran_vec (), arr.numel ());
      break;
    case btyp_int32:
      indexes = binsearch(vals.int32_array_value ().fortran_vec (), vals.numel (), 
        arr.int32_array_value ().fortran_vec (), arr.numel ());
      break;
    case btyp_uint8:
      indexes = binsearch(vals.uint8_array_value ().fortran_vec (), vals.numel (), 
        arr.uint8_array_value ().fortran_vec (), arr.numel ());
      break;
    case btyp_uint16:
      indexes = binsearch(vals.uint16_array_value ().fortran_vec (), vals.numel (), 
        arr.uint16_array_value ().fortran_vec (), arr.numel ());
      break;
    case btyp_uint32:
      indexes = binsearch(vals.uint32_array_value ().fortran_vec (), vals.numel (), 
        arr.uint32_array_value ().fortran_vec (), arr.numel ());
      break;
    case btyp_uint64:
      indexes = binsearch(vals.uint64_array_value ().fortran_vec (), vals.numel (), 
        arr.uint64_array_value ().fortran_vec (), arr.numel ());
      break;
    default:
      std:: cout << "Error: unsupported data type: " << vals_type << "\n";
      return octave_value_list (); // TODO: raise Octave error
  }

  NDArray out (vals.dims ());
  octave_idx_type n = vals.numel ();
  for (octave_idx_type i = 0; i < n; i++) {
    out(i) = indexes[i];
  }
  delete [] indexes;
  return octave_value (out);
}


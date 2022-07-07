function compute_percentile, array, PERCENTILE=percentile
  sorted = array[sort(array)]
  p = percentile/100.0
  d = size(sorted, /dimensions)
  index = round( p*d )
  return, sorted[index]
end
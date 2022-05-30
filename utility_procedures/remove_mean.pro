function remove_mean, im

out  = FLTARR(size(im, /dimensions))
sizes = size(im)
for i=0,sizes[0] do begin
  out[i, *, *] = im[i,*,*] - mean(im[i,*,*])
endfor

return, out

end
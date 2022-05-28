function remove_mean, im

out  = FLTARR(size(im, /dimensions))
sizes = size(im)
for i=0,sizes[0] do begin
  out[i, *, *] = im[i,*,*] - mean(im[i,*,*])
endfor

return, out


matrix_MS_0 = make_array(size_MS[2], size_MS[3], size_MS[1], /DOUBLE, VALUE = 0)
for i = 0,size_MS[2]-1 do matrix_MS_0[i,*,*] = image_MS[*,i,*] - mean(image_MS[*,i,*])
help, matrix_MS_0
end
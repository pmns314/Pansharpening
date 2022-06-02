function remove_mean, im
sizes = size(im)

if (sizes[0] eq 2) then begin
  out = im - mean(im) 
endif else begin
  out  = FLTARR(size(im, /dimensions))
  for i=0,sizes[1]-1 do begin
    out[i, *, *] = im[i,*,*] - mean(im[i,*,*])
  endfor
endelse
return, out

end
; +
; Utility function for smoothing an image with a gaussian filter with a 
; frequency cut at the inverse of the ratio passed as input and with Nyquist gain 
; at 0.3
; 
; :Uses: gaussian_smoothing(im, ratio)
; 
; :Params:
;   im : in, required, type=uintarr
;         The Panchromatic image to smooth
;         
;   ratio: in, required, type=int
;         The ratio needed for the cutoff frequency calculation
;         
; :Returns:
;           The output smoothed image
; 
; 
; :Author: Paolo Mansi, Alessia Carbone, Nina Brolich
; -

function gaussian_smoothing, im, ratio

  GNyq = .3
  N = 41
  fcut = 1./ratio
  st_dev = sqrt((N*(fcut/2))^2/(-2*alog(GNyq)))
  return, gauss_smooth(im, st_dev, WIDTH=N, /EDGE_Truncate)


end 
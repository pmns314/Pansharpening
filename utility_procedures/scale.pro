; +
; Utility procedure for scaling an image
;
; :Uses: scale, im
; 
; :Params:      
;   im : in, required, type=fltarr
;        The image to be saved
;
; :Returns:
;           The scaled Image
; 
; :Authors: Paolo Mansi, Alessia Carbone, Nina Brolich
; - 
function scale, im
  return, 255 * ((im - min(im))/(max(im)-min(im)))
end
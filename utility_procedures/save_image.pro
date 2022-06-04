; +
; Utility procedure for saving an image in a double format
;
; :Uses: SAVE_IMAGE, filename, image_to_save
; 
; :Params:
;   filename : in, required, type=string
;              The filename of the file
;              
;   image_to_save : in, required, type=fltarr
;                   The image to be saved
;
; 
; :Authors: Paolo Mansi, Alessia Carbone, Nina Brolich
; - 
pro save_image, filename, im
  file_delete, filename, /ALLOW_NONEXISTENT
  WRITE_tiff,filename,im, /double
end
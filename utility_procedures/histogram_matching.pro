; +
; Utility function for histogram mathing the PAN image passed as input to the matrix passed as
; second input
;
; :Uses:  histogram_matching(Pan, I_L)
; 
; :Params:
;   Pan : in, required, type=uintarr
;         The panchromatic image 
;   I_L : in, required, type=fltarr
;         The image target of the histogram matching
;  
;  :Returns:
;           The histogram matched image
; 
;
; :Authors: Paolo Mansi, Alessia Carbone, Nina Brolich
; -

function histogram_matching,Pan, I_L
  sigma_P = stddev(Pan)
  mu_P = mean(Pan)
  sigma_I = stddev(I_L)
  mu_I = mean(I_L)
  P_i = (Pan - mu_P) * (sigma_I/sigma_P) + mu_I
  return, P_i
end
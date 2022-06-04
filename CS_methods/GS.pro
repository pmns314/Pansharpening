; +
;   GS fuses the upsampled MultiSpectral (MS) and PANchromatic (PAN) images by 
;           exploiting the Gram-Schmidt (GS) transformation.
;  
;  I_L = mean(MS)
;  P_i = Histmatch(PAN, I_L)
;  outk = MSk + cov(MSk, I_L)/var(I_L) * (P_i - I_L)
;  
;  
; :Uses: GS, PAN, MS, I_GS 
; 
; :Params:
;   PAN : in, required, type=uintarr
;         The Panchromatic image
;         
;   MS : in, required, type=uintarr
;         The multispectral image upscaled at PAN dimensions
;         
;   MS : out, required, type=fltarr
;        The output Pansharpened image with GS transformation
; 
; 
; :Authors: Paolo Mansi, Alessia Carbone, Nina Brolich
; -

pro GS, PAN, MS, I_GS 

; ---------  Initialisation workspace ---------------------------
  PAN = double(PAN)
  MS = double(MS)
  sizes = size(MS, /dimensions)
  channels = sizes[0]
  MS_no_mean = remove_mean(MS) ; Mean Removal

; ---------  I_L Calculation ------------------------------------
  I_L = mean(MS, Dimension=1) 
  I_L_no_mean = remove_mean(I_L)

; ---------  P_i Calculation ------------------------------------
  P_i = histogram_matching(PAN, I_L_no_mean)


; --------  Coefficients Gk  ------------------------------------
  coeff  = FLTARR(channels)
  for i=0,channels-1 do coeff[i,*,*] =$
     correlate(I_L_no_mean, MS_no_mean[i,*,*], /COVARIANCE)/ $
     variance(I_L_no_mean)

; --------  Fusion  ---------------------------------------------
  delta = P_i - I_L_no_mean 
  
  details = fltarr(sizes)
  for i=0, channels-1 do details[i,*,*]= coeff[i]*delta
  
  I_GS = MS + details
  
  ; Normalization Fused Data
  for i=0, channels-1 do I_GS[i,*,*] =I_GS[i,*,*] - mean(I_GS[i,*,*])+mean(MS[i,*,*])

end
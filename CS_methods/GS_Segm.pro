; +
; 
;  GS_Segm fuses the upsampled MultiSpectral (MS) and PANchromatic (PAN) images by 
;  exploiting the segmentation-based version of the Gram-Schmidt algorithm.
;
;
; :Uses: gs_segm, PAN, MS, I_LR_input, S, I_GS_Segm
;
; :Params:
;   PAN : in, required, type=uintarr
;         The Panchromatic image
;
;   MS : in, required, type=uintarr
;        The multispectral image upscaled at PAN dimensions
;
;   I_LR_input : in, required, type=uintarr
;                The Low Resolution version of PAN 
;   
;   S : in, required, type=uintarr
;       The segmented image
;      
;   I_GS_Segm : out, required, type=fltarr
;               The output Pansharpened image with GSA based on segmentation
;
;
; :Authors: Paolo Mansi, Alessia Carbone, Nina Brolich
; -

pro gs_segm, PAN, I_MS, I_LR_input, S, I_GS_Segm

; ---------- Initialisation Workspace -------------------------
  I_MS = double(I_MS)
  PAN = double(PAN)
  
  size_I_MS = size(I_MS, /dimensions)
  channels = size_I_MS[0]
  
  X = REFORM(PAN, 1, size_I_MS[1], size_I_MS[2])
  temp = fltarr(size_I_MS)
  for i=0,channels-1 do temp[i,*,*] = X
  I_PAN = temp
 
  I_LR_input = double(I_LR_input)
 
  size_I_LR = size(I_LR_input)
  
  ; Adjust dimensions
  ; Single band images are transformed in multiband images by 
  ; replication of the band for each channel
  IF size_I_LR[0] EQ 2 THEN BEGIN 
    X = REFORM(I_LR_input, 1, size_I_MS[1], size_I_MS[2])
    temp = fltarr(size_I_MS)
    for i=0,channels-1 do temp[i,*,*] = X
    I_LR_input = temp
  ENDIF
  
  size_I_PAN = size(I_PAN)
  size_I_LR = size(I_LR_input)
  IF size_I_LR[1] NE size_I_PAN[1] THEN BEGIN
    PRINT, 'I_LP should have the same number of bands as PAN'
  ENDIF
  
  ; --------------- Calculation Injection Matrix D ------------------
  DetailsHRPan = I_PAN - I_LR_input
  
  ; --------------- Calculation Coefficients Gk ---------------------
  Coeff = fltarr(size_I_MS)
  labels = S[UNIQ(S, SORT(S))]
  
  ; Calculation coefficients for each band
  FOR ii = 0, size_I_MS[0]-1 DO BEGIN
    MS_Band_before = I_MS[ii, *, *]
    size_MS_Band = size(MS_Band_before, /dimensions)
    MS_Band = REFORM(MS_Band_before, size_MS_Band[1], size_MS_Band[2])
    
    I_LR_Band_before = I_LR_input[ii, *, *]
    size_I_LR_Band = size(I_LR_Band_before, /dimensions)
    I_LR_Band = REFORM(I_LR_Band_before, size_I_LR_Band[1], size_I_LR_Band[2])
    
    Coeff_Band = fltarr(size(I_LR_Band, /dimensions))
    
    ; Calculation Coefficient related to each partition 
    FOR il=0, (size(labels, /dimensions))[0]-1 DO BEGIN
      IDX  = S EQ labels[il]
      c = CORRELATE(I_LR_Band[idx], MS_Band[idx], /covariance)
      Coeff_Band[where(idx)] = c / VARIANCE(I_LR_BAND[idx])
    ENDFOR
    
    Coeff[ii, *, *] = Coeff_Band
  ENDFOR
 
; ------------------- Fusion ------------------------------------
  I_GS_Segm = Coeff * DetailsHRPan + I_MS

END
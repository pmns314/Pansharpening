; +
;   Brovey data fusion with optional haze correction
; 
; Brovey:
;         I = Media(MS)
;         D = PAN - I
;         G = MS/ I
;         out = MS + D * G --> out = MS * PAN / I
;
; Brovey with Haze Correction:
;         I = Media(MS-L)
;         D = PAN - I
;         G = MS/ I
;         out = MS-L + D * G --> out = (MS-L) * PAN / I
;         
;         
; :Uses: Brovey, PAN, MS, BT, RATIO=4, /HAZE
; 
; :Params:
;   PAN : in, required, type=uintarr
;         The Panchromatic image
;         
;   MS : in, required, type=uintarr
;         The multispectral image upscaled at PAN dimensions
;              
;   BT : out, required, type=fltarr
;        The output Pansharpened image with brovey transform
; 
; 
;  :Keywords:
;     RATIO: in, type=int
;            The Ratio of scaling of the MS in relation to the PAN
;     
;     HAZE:  in
;            Set this keyword if Haze correction must be performed
; 
; :Authors: Paolo Mansi, Alessia Carbone, Nina Brolich
; -

pro Brovey, PAN, MS, BT, RATIO=ratio, HAZE=haze

; --------- Initialisation workspace -------------------------
MS = float(MS)
PAN = float(PAN)
sizes = size(PAN, /dimensions)
sizes_MS = size(MS, /dimensions)
channels = sizes_MS[0]
if not KEYWORD_SET(RATIO) then ratio=4


;-----  Haze Correction --------------------------------------
L = fltarr(sizes_MS)
if KEYWORD_SET(HAZE) then begin
  l_k = [0.95*cgPercentiles(MS[0,*,*], Percentiles=.01),$
    0.45*cgPercentiles(MS[1,*,*], Percentiles=.01),$
    0.40*cgPercentiles(MS[2,*,*], Percentiles=.01),$
    0.05*cgPercentiles(MS[3,*,*], Percentiles=.01)]
  
  for i=0,3 do L[i,*,*] = replicate(l_k[i], [1, sizes])
endif

; -------- I_L Calculation ------------------------------------------------------
  ; 1) Generate a Smoothed version of PAN
  PAN_smooth = gaussian_smoothing(PAN, ratio)

  ; 2) Coefficients generated by minimizing MSE between smoothed PAN and MS
  num_elements = sizes[0] * sizes[1]
  PAN_flatten = reform(PAN_smooth, 1, num_elements)
  MS_flatten = reform(MS, channels, num_elements)
  w_k = LA_LEAST_SQUARES(MS_flatten, PAN_flatten)
  
  ; 3) I_L = Average Mean of MS scaled by coefficients w
  W = fltarr(sizes_MS)
  for i=0,channels-1 do W[i,*,*] = replicate(w_k[i], [1, sizes])
  I_L = total((MS-L) * W, 1) ;
  
; ---------- P_i Calculation: --------------------------
  ; Histogram Matching di P su I_L
  P_i = histogram_matching(PAN, I_L)

; --------- Fusion -------------------------
; MS with Haze Correction
I_MS_L = MS - L;

D = P_I / I_L
D = reform(D, 1, 512, 512)

BT = fltarr(sizes_MS)
for i = 0,channels-1 do BT[i,*,*] = I_MS_L[i,*,*] * D
BT = BT + L

end

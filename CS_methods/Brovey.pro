pro Brovey, PAN, MS, BT, RATIO=ratio, HAZE=haze
; Brovey:
;         I = Media(MS)
;         D = PAN - I
;         G = MS/ I
;         out = MS + D * G --> out = MS * PAN / I

; Brovey with Haze Correction:
;         I = Media(MS)
;         D = PAN - I
;         G = MS/ I
;         out = MS + D * G --> out = MS * PAN / I

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

; -------- Calcolo di I_L ------------------------------------------------------
  ; 1) Ottenere PAN Smoothed con filtro gaussiano a frequenza di taglio 0.3
  PAN_smooth = gaussian_smoothing(PAN, ratio)

  ; 2) Calcolo coefficienti w_k come minimizzazione MSE PAN e PAN_GAUSS
  num_elements = sizes[0] * sizes[1]
  PAN_flatten = reform(PAN_smooth, 1, num_elements)
  MS_flatten = reform(MS, channels, num_elements)
  w_k = LA_LEAST_SQUARES(MS_flatten, PAN_flatten)
  
  ; 3) Media Pesata di MS con pesi w_k
  W = fltarr(sizes_MS)
  for i=0,channels-1 do W[i,*,*] = replicate(w_k[i], [1, sizes])
  
  
  I_L = total((MS-L) * W, 1) ;
  
; ----------  Calcolo di P_i: --------------------------
  ; Histogram Matching di P su I_L
  P_i = histogram_matching(PAN, Pan_smooth, I_L)



; --------- Fusion -------------------------
I_MS_L = MS - L;


D = P_I / I_L
D = reform(D, 1, 512, 512)

BT = fltarr(sizes_MS)
for i = 0,channels-1 do BT[i,*,*] = I_MS_L[i,*,*] * D
BT = BT + L

end

; Gram Schmidt 
; 
; ; Load Images
PAN = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\PAN.tif')
PAN = double(PAN)
MS = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\MS.tif')
MS = double(MS)
GroundTruth = read_image('.\PAirMax\GE_Lond_Urb\RR\GT.tif')
sizes = size(MS, /dimensions)
channels = sizes[0]

;  I_L = mean(MS)
;  P_i = Histmatch(PAN, I_L)
; outk = MSk + cov(MSk, I_L)/var(I_L) * (P_i - I_L)

; Rimozione media
MS_no_mean = remove_mean(MS) ; Correct

; Calcolo I_L
  I_L = mean(MS, Dimension=1) ; CORRECT
  I_L_no_mean = I_L - mean(I_L) ; Correct


; Calcolo P_i
  P_i = histogram_matching(PAN, PAN, I_L_no_mean) ; Correct


; Calcolo coefficienti 
coeff  = FLTARR(channels)
for i=0,channels-1 do coeff[i,*,*] =$
   correlate(I_L_no_mean, MS_no_mean[i,*,*], /COVARIANCE)/ $
   variance(I_L_no_mean)


; ???
delta = P_i - I_L_no_mean ; Correct
save_image, ".\output\delta.tif", delta

details = fltarr(sizes)
for i=0, channels-1 do $
   details[i,*,*]= coeff[i]*delta
save_image, ".\output\details.tif", details

new_MS = MS + details
save_image, ".\output\new_MS.tif", new_MS
for i=0, channels-1 do $
  new_MS[i,*,*] =scale(new_MS[i,*,*] - mean(new_MS[i,*,*])+mean(MS[i,*,*]))


;Write the array to the file. This file will have the png format.
WRITE_tiff,".\output\GS.tif",NEW_MS, /double
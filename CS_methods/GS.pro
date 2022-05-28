; Gram Schmidt 
; 
; ; Load Images
PAN = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\PAN.tif')
PAN = float(PAN)
MS = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\MS.tif')
MS = float(MS)
GroundTruth = read_image('.\PAirMax\GE_Lond_Urb\RR\GT.tif')
sizes = size(MS)
channels = sizes[0]

;  I_L = mean(MS)
;  P_i = Histmatch(PAN, I_L)
; outk = MSk + cov(MSk, I_L)/var(I_L) * (P_i - I_L)

; Rimozione media
MS_no_mean = remove_mean(MS)

; Calcolo I_L
  I_L = mean(MS, Dimension=1)
  I_L_no_mean = remove_mean(I_L)

; Calcolo P_i
  P_i = histogram_matching(PAN, PAN, I_L_no_mean)
  
; Calcolo coefficienti 
coeff  = FLTARR(channels+1)
for i=0,channels do coeff[i,*,*] =$
   correlate(I_L_no_mean, MS_no_mean[i,*,*], /COVARIANCE)/ $
   variance(I_L_no_mean)
  
; ???
delta = PAN - I_L_no_mean
delta = reform(delta, 1, 512, 512)
deltam = [delta, delta, delta, delta]





;Write the array to the file. This file will have the png format.
;WRITE_tiff,".\output\GS.tif",NEW_MS
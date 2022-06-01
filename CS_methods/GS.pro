pro GS, PAN, MS, I_GS 

; Gram Schmidt 
; 

PAN = double(PAN)
MS = double(MS)
sizes = size(MS, /dimensions)
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
coeff  = FLTARR(channels)
for i=0,channels-1 do coeff[i,*,*] =$
   correlate(I_L_no_mean, MS_no_mean[i,*,*], /COVARIANCE)/ $
   variance(I_L_no_mean)

; Fusion
delta = P_i - I_L_no_mean 

details = fltarr(sizes)
for i=0, channels-1 do details[i,*,*]= coeff[i]*delta

I_GS = MS + details

; Normalization Fused Data
for i=0, channels-1 do I_GS[i,*,*] =I_GS[i,*,*] - mean(I_GS[i,*,*])+mean(MS[i,*,*])

end

cd, 'C:\Users\pmans\Documents\Magistrale\Remote Sensing\Progetto\PAirMax\GE_Lond_Urb\RR'


; Load Images
PAN = read_TIFF('PAN.tif')
PAN = float(PAN)
MS = read_TIFF('MS.tif', R, G, B, channels=[0,1,2,3])
MS = float(MS)
GroundTruth = read_image('GT.tif')

cd, 'C:\Users\pmans\Documents\Magistrale\Remote Sensing\Esercizi\Pansharpen'

; Brovey:
;         I = Media(MS)
;         D = PAN - I
;         G = MS/ I
;         out = MS + D * G --> out = MS * PAN / I

R = MS(0,*,*)
G = MS(1,*,*)
B = MS(2,*,*)
NIR = MS(3,*,*)
sizes = size(PAN, /dimensions)
ratio = 4

; Calcolo di I_L
  ; 1) Ottenere PAN Smoothed con filtro gaussiano
  PAN_smooth = gauss_smooth(PAN, 3.3027, KERNEL=kernel, WIDTH=41, /EDGE_MIRROR)
  
  PAN_smooth2= convol(PAN, kernel, /Edge_Mirror)
  ; 2) Calcolo coefficienti w_k come minimizzazione MSE PAN e PAN_GAUSS
  num_elements = sizes[0] * sizes[1]
  PAN_flatten = reform(PAN_smooth, 1, num_elements)
  MS_flatten = reform(MS, 4, num_elements)
  w_k = LA_LEAST_SQUARES(MS_flatten, PAN_flatten)
  print, w_k
  ; 3) Media Pesata di MS con pesi w_k
  W_r = replicate(w_k[0], [1, sizes])
  W_g = replicate(w_k[1], [1, sizes])
  W_b = replicate(w_k[2], [1, sizes])
  W_nir = replicate(w_k[3], [1, sizes])
  W = [W_r, W_g, W_b, W_nir]
  I_L = total(MS * W, 1)
  
; Calcolo di P_i:
  ; Histogram Matching di P su I_L
  sigma_P = stddev(PAN_SMOOTH)
  mu_P = mean(PAN_SMOOTH)
  sigma_I = stddev(I_L)
  mu_I = mean(I_L)
  P_i = (PAN - mu_P) * (sigma_I/sigma_P) + mu_I


D = P_I / I_L
D = reform(D, 1, 512, 512)
NEW_MS = [scale(R*D), scale(G*D), scale(B*D), scale(NIR*D)]

;Construct the full path with filename.
fwrite=DIALOG_PICKFILE() 
 ;Write the array to the file. This file will have the png format.
WRITE_tiff,fwrite,NEW_MS


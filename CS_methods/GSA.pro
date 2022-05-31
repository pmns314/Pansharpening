cd, 'C:\Users\carbo\OneDrive\Desktop\Università\Magistrale\Secondo anno\Secondo Semestre\Remote Sensing\Progetto\Toolbox and Datasets\PAirMax\GE_Lond_Urb\RR'

; Read the images
;  image_MS:     MS image upsampled at PAN scale
;  image_MS_LR:  MS original image
;  image_PAN:    PAN image
imageLR = read_image('MS.tif')
imageLR_LP = read_image('MS_LR.tif')
imageHR = read_image('PAN.tif')

; Each image has 4 channels (red, green, blue and nir) and a certain spatial resolution (size_X[1]*size_X[2])
imageLR = float(image_MS)
imageLR_LP = float(image_MS_LR)
imageHR = float(image_PAN)

size_MS = size(imageLR, /DIMENSIONS)
size_MS_LR = size(imageLR_LP, /DIMENSIONS)
size_PAN = size(imageHR, /DIMENSIONS)

channels = 4

;; APPLY THE REDUCED RESOLUTION ASSESSMENT PROTOCOL

; Remove means from the images 
imageLR0 = make_array(size_MS, /FLOAT, VALUE = 0)
imageLR_LP0 = make_array(size_MS_LR, /FLOAT, VALUE = 0)
imageHR0 = make_array(size_PAN, /FLOAT, VALUE = 0)
for i = 0,channels-1 do imageLR0[i,*,*] = imageLR[i,*,*] - mean(imageLR[i,*,*])
for i = 0,channels-1 do imageLR_LP0[i,*,*] = imageLR_LP[i,*,*] - mean(imageLR_LP[i,*,*])
imageHR0 = imageHR - mean(imageHR)

; Use a low pass filter based on the wavelet transform for the PAN image and downsample it by ratio
ratio = 4
WT = wtn(imageHR0, ratio, /OVERWRITE)
imageHR0 = wtn(WT, ratio, /INVERSE, /OVERWRITE)
imageHR0 = congrid(imageHR0, size_PAN[0]/ratio, size_PAN[1]/ratio, /INTERP)
size_HR0 = size(imageHR0, /DIMENSIONS)

; Compute alpha coefficients
one_matrix = make_array(size_MS_LR[1], size_MS_LR[2], /FLOAT, VALUE = 1)
concatenation = make_array(channels+1, size_MS_LR[1],size_MS_LR[2], /FLOAT, VALUE = 0)
for i=0,channels-1 do concatenation[i,*,*] = imageLR_LP0[i,*,*]
concatenation[channels,*,*] = one_matrix[*,*]
alpha = make_array(1, 1, channels+1, /FLOAT, VALUE = 0)
IHc = imageHR0[*]
size_conc = size(concatenation, /DIMENSIONS)
ILRc = reform(concatenation, [size_conc[0], size_conc[1]*size_conc[2]])
alpha[0,0,*] = la_least_squares(ILRc, IHc)

; Compute intensity
one_matrix = make_array(size_MS[1], size_MS[2], /FLOAT, VALUE=1)
concatenation = make_array(size_MS[1], size_MS[2], channels+1, /FLOAT, VALUE = 0)
for i=0,channels-1 do concatenation[*,*,i] = imageLR0[i,*,*]
concatenation[*,*,channels] = one_matrix[*,*]
new_alpha = make_array(size_MS[1], size_MS[2], channels+1, /FLOAT, VALUE=0)
for i=0,channels do new_alpha[*,*,i]=alpha[0,0,i]
I = total(concatenation * new_alpha, 3)

; Remove mean from I
I0 = I - mean(I)

; Coefficients
coeff = make_array(channels+1, /FLOAT, VALUE=1)
for i=0,channels-1 do coeff[i+1] = correlate(I0, imageLR0[i,*,*], /COVARIANCE)/variance(I0)

imageHR = imageHR - mean(imageHR)

;; Detail Extraction
delta = imageHR - I0
size_delta = size(delta)
new_delta = make_array(channels+1, size_delta[1]*size_delta[2], /FLOAT, VALUE=0)
for i=0, channels do new_delta[i,*] = delta[*]

;; Fusion
size_I0 = size(I0, /DIMENSIONS)
V = make_array(channels+1, size_I0[0]*size_I0[1], /FLOAT, VALUE=0)
V[0,*]=I0[*]
for i=0,channels-1 do V[i+1,*]=(imageLR0[i,*,*])[*]
gm = make_array(size(V, /DIMENSIONS), /FLOAT, VALUE=0)
for i=0,channels do gm[i,*] = coeff[i] * make_array(size_MS[1]*size_MS[2], /FLOAT, VALUE=1)

V_hat = V + (new_delta*gm)
size_vhat = size(V_hat)

;; Reshape fusion result
I_fus_GSA = make_array(size_MS[0], size_MS[1], size_MS[2], /FLOAT, VALUE = 0)
for i=0,channels-1 do I_fus_GSA[i,*,*]=reform(V_hat[i+1,*],[size_MS[1], size_MS[2]])
h = make_array(size_MS[0], size_MS[1], size_MS[2], /FLOAT, VALUE = 0)
for i=0,channels-1 do h[i,*,*] = I_Fus_GSA[i,*,*]
for i=0,channels-1 do I_Fus_GSA[i,*,*] = h[i,*,*] - mean(h[i,*,*]) + mean(imageLR[i,*,*])

;; SAVE PANSHARPENED IMAGE
;R = I_Fus_GSA[0,*,*]
;G = I_Fus_GSA[1,*,*]
;B = I_Fus_GSA[2,*,*]
;N = I_Fus_GSA[3,*,*]
;red = 255 * ((R - min(R))/(max(R)-min(R)))
;green = 255 * ((G - min(G))/(max(G)-min(G)))
;blue = 255 * ((B - min(B))/(max(B)-min(B)))
;nir = 255 * ((N - min(N))/(max(N)-min(N)))
;I_Fus_GSA[0,*,*] = red
;I_Fus_GSA[1,*,*] = green 
;I_Fus_GSA[2,*,*] = blue
;I_Fus_GSA[3,*,*] = nir
write_tiff, 'C:\Users\carbo\OneDrive\Desktop\Università\Magistrale\Secondo anno\Secondo Semestre\Remote Sensing\Progetto\Pansharpening\output\GSA.tif', I_Fus_GSA
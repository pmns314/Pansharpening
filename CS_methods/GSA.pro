cd, 'C:\Users\carbo\OneDrive\Desktop\Università\Magistrale\Secondo anno\Secondo Semestre\Remote Sensing\Progetto\Toolbox and Datasets\PAirMax\GE_Lond_Urb\FR'

; Read the following images
;  image_MS:     MS image upsampled at PAN scale
;  image_MS_LR:  MS image
;  image_PAN:    PAN image
image_MS = read_image('MS.tif')
image_MS_LR = read_image('MS_LR.tif')
image_PAN = read_image('PAN.tif')

; Type conversion of the read images UINT -> DOUBLE
image_MS = double(image_MS)
image_MS_LR = double(image_MS_LR)
image_PAN = double(image_PAN)

; Convert images in matrixes
size_MS = size(image_MS)
size_MS_LR = size(image_MS_LR)
size_PAN = size(image_PAN)

; Remove means from MS 
matrix_MS_0 = make_array(size_MS[2], size_MS[3], size_MS[1], /DOUBLE, VALUE = 0)
for i = 0,size_MS[2]-1 do matrix_MS_0[i,*,*] = image_MS[*,i,*] - mean(image_MS[*,i,*])
help, matrix_MS_0

; Remove means from MS_LR 
matrix_MS_LR_0 = make_array(size_MS_LR[2], size_MS_LR[3], size_MS_LR[1], /DOUBLE, VALUE = 0)
for i = 0,size_MS_LR[2]-1 do matrix_MS_LR_0[i,*,*] = image_MS_LR[*,i,*] - mean(image_MS_LR[*,i,*])
help, matrix_MS_LR_0

; Remove means from PAN 
matrix_PAN_0 = image_PAN - mean(image_PAN)
help, matrix_PAN_0

; Create a low pass filter for PAN image and apply it to the image
kernelSize = [size_PAN[1], size_PAN[2]]
print, kernelSize
kernel = replicate(double(1./(kernelSize[0]*kernelSize[1])), kernelSize[0], kernelSize[1])
matrix_PAN_0 = convol(matrix_PAN_0, kernel, /CENTER, /EDGE_TRUNCATE)
print, matrix_PAN_0

; Compute alpha coefficients
one_matrix = make_array(size_MS_LR[2], size_MS_LR[3], /DOUBLE, VALUE=1)
matrix_MS_LR_0 = [[[matrix_MS_LR_0]],[[one_matrix]]]
help, matrix_MS_LR_0
alpha = make_array(1, 1, size_MS_LR[2], /DOUBLE, VALUE = 0)
help, alpha

IHc = reform(matrix_PAN_0, [size_PAN[4], 1])
ILRc = reform(matrix_MS_LR_0, [size_MS_LR[2]*size_MS_LR[3], size_MS_LR[1]])
alpha(1,1,*) = ILRc.\IHc

; Compute intensity
one_matrix_2 = make_array(size_1[1], size_1[2], /DOUBLE, VALUE=1)
matrix_MS_0 = [[[matrix_MS_0]],[[one_matrix_2]]]
;I = sum(cat(3,imageLR0,ones(size(I_MS,1),size(I_MS,2))) .* repmat(alpha,[size(I_MS,1) size(I_MS,2) 1]),3); 

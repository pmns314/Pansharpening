; +
; gen_LP generates the Low Resolution version of the PAN image required for the calculation of the
; segmentation-based version of the Gram-Schmidt algorithm
;
; :Uses: genLP, PAN, MS, MS_LR, output
; 
; :Params:
;   PAN : in, required, type=uintarr
;         The Panchromatic image
;         
;   MS : in, required, type=uintarr
;         The multispectral image upscaled at PAN dimensions
;         
;   MS_LR : in, required, type=uintarr
;         The original multispectral image
;         
;   output : out, required, type=fltarr
;         The output Low resolution image
; 
; 
; :Authors: Paolo Mansi, Alessia Carbone, Nina Brolich
; -


pro genLP, PAN, MS, MS_LR, output, RATIO=ratio

if not KEYWORD_SET(RATIO) then ratio=4

; Generate Smoothed PAN and Downsample it to a specific ratio
PAN_LP = gaussian_smoothing(PAN, ratio)
sizes_PAN = size(PAN, /dimensions)
PAN_LP2 = rebin(PAN_LP, sizes_PAN/ratio, /SAMPLE);


; Estimation Weights
sizes = size(PAN, /dimensions)
num_elements = sizes_PAN[0] *1/ratio* sizes_PAN[1] * 1/ratio
sizes_MS = size(MS, /dimensions)
channels = sizes_MS[0]
PAN_LR_flatten = reform(PAN_LP2, 1, num_elements)
MS_LR_flatten = reform(MS_LR, channels, num_elements)

MS_LR_Exp = make_array(channels+1, num_elements, value=1.)
for i=0, channels-1 do MS_LR_Exp[i, *,*] = MS_LR_flatten[i, *,*]

num_elements = sizes[0] * sizes[1]
MS_flatten = reform(MS, channels, num_elements)

w_k = LA_LEAST_SQUARES(MS_LR_Exp, PAN_LR_flatten)

; Transform vector coefficients into a matrix
alpha = fltarr(channels+1, num_elements)
for i=0,channels do alpha[i,*] = replicate(w_k[i], 1, num_elements)

; Multiplies the MS in input by the coefficients and averages along the bands to generate the
; LP image
ones = replicate(1., 1, num_elements)
output = total([MS_flatten, ones] * alpha, 1)
output = reform(output, sizes_PAN)
end
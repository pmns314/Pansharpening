
pro genLP, PAN, MS, MS_LR, output
; Generate LowPass PAN Downsampled
ratio = 4
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

alpha = fltarr(channels+1, num_elements)
for i=0,channels do alpha[i,*] = replicate(w_k[i], 1, num_elements)

ones = replicate(1., 1, num_elements)
output = total([MS_flatten, ones] * alpha, 1)
output = reform(output, sizes_PAN)
end
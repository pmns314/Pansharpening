
pro genLP, PAN, MS, MS_LR, output
; Generate LowPass PAN Downsampled
ratio = 4
PAN_LP = gaussian_smoothing(PAN, ratio)
PAN_LP2 = rebin(PAN_LP, 128, 128, /SAMPLE);


; Estimation Weights
sizes = size(PAN, /dimensions)
num_elements = sizes[0] * sizes[1] * 1/16

PAN_LR_flatten = reform(PAN_LP2, 1, num_elements)
MS_LR_flatten = reform(MS_LR, 4, num_elements)

MS_LR_Exp = make_array(5, num_elements, value=1.)
for i=0, 3 do MS_LR_Exp[i, *,*] = MS_LR_flatten[i, *,*]

num_elements = sizes[0] * sizes[1]
MS_flatten = reform(MS, 4, num_elements)

w_k = LA_LEAST_SQUARES(MS_LR_Exp, PAN_LR_flatten)

alpha = fltarr(5, num_elements)
for i=0,4 do alpha[i,*] = replicate(w_k[i], 1, num_elements)

ones = replicate(1., 1, num_elements)
output = total([MS_flatten, ones] * alpha, 1)
output = reform(output, 512, 512)
end
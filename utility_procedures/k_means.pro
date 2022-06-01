; kmeanPaolo
pro k_means, I_MS, segm, N_SEGM=n_segm

if not KEYWORD_SET(N_SEGM) then n_segm=5

I_MS = double(I_MS)

size_I_MS = size(I_MS, /dimensions)
F1 = fltarr(size_I_MS)
channels = size_I_MS[0]
num_elements = size_I_MS[1] * size_I_MS[2]

FOR ibands = 0, channels-1 DO BEGIN
  a = I_MS[ibands, *, *]
  max_value = max(a)
  F1[ibands, *, *] = a/max_value
ENDFOR

F2 = reform(F1, channels, num_elements)

weights = CLUST_WTS(F2, N_CLUSTERS = n_segm)
IDX = CLUSTER(F2, weights, N_CLUSTERS = n_segm)
segm = reform(IDX, size_I_MS[1], size_I_MS[2])

end
; +
; Utility procedure for segmenting an image using the k-means algorithm
;
; :Uses: k_means, I_MS, segm, N_SEGM=n_segm
; 
; :Params:
;   I_MS : in, required, type=uintarr
;         The multispectral image to segment
;   segm : out, required, type=fltarr
;         The output segmented image
; 
; :Keywords:
;   N_SEGM : in, type=int
;           The number of partitions of the segmentation. 
;           If missing, 5 is assumed
; 
; :Author: Paolo Mansi, Alessia Carbone, Nina Brolich
; -
pro k_means, I_MS, segm, N_SEGM=n_segm

; ------------- Initialisation vairables --------------
if not KEYWORD_SET(N_SEGM) then n_segm=5

I_MS = double(I_MS)

size_I_MS = size(I_MS, /dimensions)
F1 = fltarr(size_I_MS)
channels = size_I_MS[0]
num_elements = size_I_MS[1] * size_I_MS[2]

;--------- Normalisation values --------------------- 
FOR ibands = 0, channels-1 DO BEGIN
  a = I_MS[ibands, *, *]
  max_value = max(a)
  F1[ibands, *, *] = a/max_value
ENDFOR

F2 = reform(F1, channels, num_elements)

;---------- K Means Algorithm Application ----------
weights = CLUST_WTS(F2, N_CLUSTERS = n_segm)
IDX = CLUSTER(F2, weights, N_CLUSTERS = n_segm)
segm = reform(IDX, size_I_MS[1], size_I_MS[2])

end
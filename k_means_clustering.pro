;!EXCEPT = 0
PRO k_means_clustering, I_MS, n_segm
  I_MS = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\MS.tif')
  n_segm = 100
  
  ;fname=".\output\I_MS.txt"
  ;  OPENW,1,fname
  ;  PRINTF,1, I_MS
  ;  CLOSE,1
  
  
  ;F1 = zeros(size(I_MS,1)*size(I_MS,2),size(I_MS,3))
  size_I_MS = size(I_MS)
  size_3 = size_I_MS[1]
  size_2 = size_I_MS[2]
  size_1 = size_I_MS[3]
  F1 = MAKE_ARRAY(size_3,size_1 * size_2, /UINT, VALUE = 0)
  ;F2 = MAKE_ARRAY(size_3,size_1 * size_2, /UINT, VALUE = 0)
  ;for ibands = 1 :size(I_MS,3)
  FOR ibands = 0, size_3-1 DO BEGIN
    ;a = I_MS(:,:,ibands)
    I_MS_TRANS = I_MS
    a = I_MS_TRANS[ibands, *, *]
    a = transpose(a)
    ;fname=".\output\a.txt"
    ;OPENW,1,fname
    ;PRINTF,1, a
    ;CLOSE,1
    max_value = max(a)
    a_star = a[*]
    FOR idx = 0L, 262143 DO BEGIN
      a_idx = a_star[idx]
      IF 2*a_idx GE max_value THEN BEGIN
        F1[ibands, idx] = 1
        ;PRINT,F1(ibands, idx)
      ENDIF
      ;F2[ibands, idx] = a_idx
    ENDFOR
  ENDFOR
  ;PRINT, COUNTER
  ;fname=".\output\array.txt"
  ;OPENW,1,fname
  ;PRINTF,1, F1
  ;CLOSE,1
  ;IDX = kmeans(F1,n_segm);
  ;IDX = CLUSTER(F1, n_segm)
  ;F2 are seeds, so as a start estimate, we'll just use the first commun, every size/n value
  ;step = size_1 * size_2 / n_segm
  ;start = 0
  ;FOR i = 0, n_segm DO BEGIN
  ;  F2[0, i*step] = start
  ;  start = start + 1
  ;ENDFOR
  ;IDX = IMSL_K_MEANS(F1, F2, COUNTS_CLUSTER=n_segm)
  F1 = transpose(F1)
  PRINT, "vor idx"
  weights = CLUST_WTS(F1, N_CLUSTERS = n_segm)
  IDX = CLUSTER(F1, weights, N_CLUSTERS = n_segm)
  
  fname=".\output\idx.txt"
  OPENW,1,fname
  PRINTF,1, IDX
  CLOSE,1
  PRINT, "nach idx"
  ;S = reshape(IDX,[size(I_MS,1) size(I_MS,2)]);
  S = REFORM(IDX, [size_1,size_2])
  fname=".\output\S.txt"
  OPENW,1,fname
  PRINTF,1, S
  CLOSE,1
  ;WRITE_tiff,".\output\MS.tif",RESULT
  ;return, RESULT
END
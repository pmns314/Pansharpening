PRO k_means_clustering, I_MS, n_segm
  I_MS = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\MS.tif')
  I_MS = double(I_MS)
  n_segm = 10
  
  ;F1 = zeros(size(I_MS,1)*size(I_MS,2),size(I_MS,3))
  size_I_MS = size(I_MS, /dimensions)
  channels = size_I_MS[0]
  size_1 = size_I_MS[1]
  size_2 = size_I_MS[2]
  F1 = fltarr(channels, size_1, size_2)
  FOR ibands = 0, channels-1 DO BEGIN
    ;a = I_MS(:,:,ibands)
    a = I_MS[ibands, *, *]
    ;F1(:,ibands) = a(:)/max(a(:));
    max_value = max(a)
    F1[ibands, *, *] = a/max_value
  ENDFOR
  
  F2 = REFORM(F1, channels, size_1*size_2)
  
  ;IDX = kmeans(F1,n_segm);
  weights = CLUST_WTS(F2, N_CLUSTERS = n_segm)
  IDX = CLUSTER(F2, weights, N_CLUSTERS = n_segm)
 
  ;S = reshape(IDX,[size(I_MS,1) size(I_MS,2)]);
  S = REFORM(IDX, [size_1,size_2])
END

base = widget_auto_base(title = 'Brovey Transform')
wl = widget_slabel(base, prompt = 'Function: Brovey')
sb = widget_base(base, /row, /frame)
wp = widget_param(sb, prompt = 'Exponent', dt = 5, uvalue = 'value', /auto)

sb = widget_base(base, /row, /frame)
wf = widget_outfm(sb, uvalue = 'outf', /auto)
result = auto_wid_mng(base)
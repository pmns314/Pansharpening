FUNCTION gs_segm, I_MS, PAN, I_LR_input, S
  ;I_MS = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\MS.tif')
  ;I_PAN = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\PAN.tif')
  ;I_LR_input = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\MS_LR.tif')
  
  ;I_MS = double(I_MS);
  I_MS = double(I_MS)
  PAN = double(PAN)
  
  ;I_PAN = repmat(double(I_PAN), [1, 1, size(I_MS,3)]);
  size_I_MS = size(I_MS, /dimensions)
  channels = size_I_MS[0]
  
  X = REFORM(I_LR_input, 1, size_I_MS[1], size_I_MS[2])
  temp = fltarr(size_I_MS)
  for i=0,channels-1 do temp[i,*,*] = X
  I_PAN = temp
  

  
  ;I_LR_input = double(I_LR_input);
  I_LR_input = double(I_LR_input)
  
  ;if size(I_LR_input, 3) == 1
  size_I_LR = size(I_LR_input)
  IF size_I_LR[0] EQ 2 THEN BEGIN ;if the image has 1 channel, it means it has only two dimensions
  
    ;I_LR_input = repmat(I_LR_input, [1, 1, size(I_MS,3)]);
    X = REFORM(I_LR_input, 1, size_I_MS[1], size_I_MS[2])
    temp = fltarr(size_I_MS)
    for i=0,channels-1 do temp[i,*,*] = X
    I_LR_input = temp
    
  ENDIF
  
  ;if size(I_LR_input, 3) ~= size(I_PAN, 3)
  size_I_PAN = size(I_PAN)
  size_I_LR = size(I_LR_input)
  IF size_I_LR[1] NE size_I_PAN[1] THEN BEGIN
  
    ;error('I_LP should have the same number of bands as PAN');
    PRINT, 'I_LP should have the same number of bands as PAN'
    
  ENDIF
  
  ;DetailsHRPan = I_PAN - I_LR_input;
  DetailsHRPan = I_PAN - I_LR_input
  
  ;Coeff = zeros(size(I_MS));
  Coeff = fltarr(size_I_MS)
  
  ;labels = unique(S);
  ;TODO comment in just for test purposes
  labels = S[UNIQ(S, SORT(S))]
  ;labels = [1,2,3,4,5,6,7,8,9,0]
  
  ;for ii = 1: size(I_MS,3)
  FOR ii = 0, size_I_MS[0]-1 DO BEGIN
  
    ;MS_Band = squeeze(I_MS(:,:,ii));
    MS_Band_before = I_MS[ii, *, *]
    size_MS_Band = size(MS_Band_before, /dimensions)
    MS_Band = REFORM(MS_Band_before, size_MS_Band[1], size_MS_Band[2])
    
    ;I_LR_Band = squeeze(I_LR_input(:,:,ii));
    I_LR_Band_before = I_LR_input[ii, *, *]
    size_I_LR_Band = size(I_LR_Band_before, /dimensions)
    I_LR_Band = REFORM(I_LR_Band_before, size_I_LR_Band[1], size_I_LR_Band[2])
    
    ;Coeff_Band = zeros(size(I_LR_Band));
    Coeff_Band = fltarr(size(I_LR_Band, /dimensions))
    
    ;for il=1:length(labels)
    FOR il=0, (size(labels, /dimensions))[0]-1 DO BEGIN
    
      ;idx = S==labels(il);
      IDX  = S EQ labels[il]
    
      ;c = cov(I_LR_Band(idx),MS_Band(idx));
      c = CORRELATE(I_LR_Band[idx], MS_Band[idx], /covariance)
    
      ;Coeff_Band(idx) = c(1,2)/var(I_LR_Band(idx));
      Coeff_Band[where(idx)] = c / VARIANCE(I_LR_BAND[idx])
    ENDFOR
    
    ;Coeff(:,:,ii) = Coeff_Band;
    Coeff[ii, *, *] = Coeff_Band
  ENDFOR
  
  ;PanSharpenedImage = Coeff .* DetailsHRPan + I_MS;
  PanSharpenedImage = Coeff * DetailsHRPan + I_MS
  
  RETURN, PanSharpenedImage
END
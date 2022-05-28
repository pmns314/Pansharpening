; Gram Schmidt 
; 
; ; Load Images
PAN = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\PAN.tif')
PAN = float(PAN)
MS = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\MS.tif')
MS = float(MS)
GroundTruth = read_image('.\PAirMax\GE_Lond_Urb\RR\GT.tif')

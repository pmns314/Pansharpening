; Main Script
; 
 ; Load Images
PAN = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\PAN.tif')
MS = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\MS.tif')

GroundTruth = read_image('.\PAirMax\GE_Lond_Urb\RR\GT.tif')


GS, PAN, MS, I_GS


save_image,".\output\GS.tif",I_GS
; Main Script
; 
 ; Load Images
PAN = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\PAN.tif')
MS = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\MS.tif')

GroundTruth = read_image('.\PAirMax\GE_Lond_Urb\RR\GT.tif')

Brovey, PAN, MS, I_BT, RATIO=4
Brovey, PAN, MS, I_BT_H, RATIO=4, /HAZE
GS, PAN, MS, I_GS

k_means,MS, segmented, N_SEGM=6


save_image,".\output\GS.tif",I_GS
save_image,".\output\BT.tif",I_BT
save_image,".\output\BT_H.tif",I_BT_H
save_image,".\output\segm.tif",segmented
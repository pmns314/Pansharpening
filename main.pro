; Main Script
; 
 ; Load Images
print, "Loading Image Files"
PAN = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\PAN.tif')
MS = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\MS.tif')
MS_LR = read_TIFF('.\PAirMax\GE_Lond_Urb\RR\MS_LR.tif')

GroundTruth = read_image('.\PAirMax\GE_Lond_Urb\RR\GT.tif')

print, "Brovey PanSharpening"
Brovey, PAN, MS, I_BT, RATIO=4
print, "Brovey PanSharpening with Haze Correction"
Brovey, PAN, MS, I_BT_H, RATIO=4, /HAZE
print, "Gram Schmidt PanSharpening"
GS, PAN, MS, I_GS

print, "Adaptive Gram Schmidt PanSharpening with Segmentation"
k_means,MS, segmented, N_SEGM=6
genLP, PAN, MS, MS_LR, I_LR_input
I_GS_segm = gs_segm(MS, PAN, I_LR_input, segmented)

print, "Saving images"
save_image,".\output\GS.tif",I_GS
save_image,".\output\BT.tif",I_BT
save_image,".\output\BT_H.tif",I_BT_H
save_image,".\output\segm.tif",segmented
save_image,".\output\GS_Segm.tif",I_GS_segm
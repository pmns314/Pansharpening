; Main Script
; 
 ; Load Images
folder = 'GE_Lond_Urb'
print, "Loading Image Files: " + folder
PAN = read_TIFF('.\PAirMax\'+folder+'\RR\PAN.tif')
MS = read_TIFF('.\PAirMax\'+folder+'\RR\MS.tif')
MS_LR = read_TIFF('.\PAirMax\'+folder+'\RR\MS_LR.tif')

GroundTruth = read_TIFF('.\PAirMax\'+folder+'\RR\GT.tif')

print, "Brovey PanSharpening"
Brovey, PAN, MS, I_BT, RATIO=4
print, "Brovey PanSharpening with Haze Correction"
Brovey, PAN, MS, I_BT_H, RATIO=4, /HAZE

print, "Gram Schmidt PanSharpening"
GS, PAN, MS, I_GS

print, "Adaptive Gram Schmidt PanSharpening"
GSA, PAN, MS, MS_LR, I_GSA

print, "Adaptive Gram Schmidt PanSharpening with Segmentation"
k_means,MS, segmented, N_SEGM=5
save_image,".\output\segm.tif",segmented

genLP, PAN, MS, MS_LR, I_LR_input
save_image,".\output\genLP.tif",I_LR_input

I_GS_segm = gs_segm(MS, PAN, I_LR_input, segmented)


print, "Saving images"
save_image,".\output\GS.tif",I_GS
save_image,".\output\BT.tif",I_BT
save_image,".\output\BT_H.tif",I_BT_H
save_image, ".\output\GSA.tif", I_GSA
save_image,".\output\GS_Segm.tif",I_GS_segm
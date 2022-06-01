clc, close all
I_GT = double(imread(strcat('C:\Users\pmans\Documents\Magistrale\Remote Sensing\Progetto\Pansharpening\PAirMax\GE_Lond_Urb\RR\GT.tif'), 'tif'));
I_PAN = double(imread(strcat('C:\Users\pmans\Documents\Magistrale\Remote Sensing\Progetto\Pansharpening\PAirMax\GE_Lond_Urb\RR\PAN.tif'), 'tif'));
I_MS = double(imread(strcat('C:\Users\pmans\Documents\Magistrale\Remote Sensing\Progetto\Pansharpening\PAirMax\GE_Lond_Urb\RR\MS.tif'), 'tif'));
I_MS_LR = double(imread(strcat('C:\Users\pmans\Documents\Magistrale\Remote Sensing\Progetto\Pansharpening\PAirMax\GE_Lond_Urb\RR\MS_LR.tif'), 'tif'));
I_GT = double(I_GT);
algorithms= ["BT", "GS", "GS_Segm"]
addpath([pwd,'/Tools']);
addpath([pwd,'/BT-H']);
addpath([pwd,'/GS']);

for alg=algorithms 
    
switch(alg)
    case "BT"
        I_matlab = BroveyRegHazeMin(I_MS,I_PAN,ratio);
    case 'GS'
        I_matlab = GS(I_MS,I_PAN);
    case 'GSA'
        I_matlab = GSA(I_MS,I_PAN,I_MS_LR,ratio);
    case 'GS_Segm'
        PS_algorithm = 'GSA'; % Pansharpening algorithm 
        n_segm = 5; 
        I_matlab = GS_Segm(I_MS,I_PAN,gen_LP_image(PS_algorithm,I_MS,I_PAN, ...
            I_MS_LR,ratio,sensor),k_means_clustering(I_MS,n_segm));
end
[A1, A2, A3, A4, A5] = ...
        indexes_evaluation(I_matlab,I_GT,ratio,L,Qblocks_size,...
        flag_cut_bounds,dim_cut,thvalues);
    
    filename = strcat(alg,'.tif');
    myMS = imread(strcat('C:\Users\pmans\Documents\Magistrale\Remote Sensing\Progetto\Pansharpening\output\',filename));
    
    [B1, B2, B3, B4, B5] = ...
        indexes_evaluation(myMS,I_GT,ratio,L,Qblocks_size,...
        flag_cut_bounds,dim_cut,thvalues);
    disp(strcat(['Indexes of '], alg))
    indices = [A1, A2, A3, A4, A5;B1, B2, B3, B4, B5]
    figure()
    subplot(1,2,1)
    IMN = viewimage(I_matlab(:,:,1:3));
    subplot(1,2,2)
    IMN = viewimage(myMS(:,:,1:3));
    title(alg)
end
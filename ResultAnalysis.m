clc, clear, close all
%% Load Images
folder = 'W4_Mexi_Nat';
I_GT = double(imread(strcat('.\PAirMax\',folder,'\RR\GT.tif')));
I_PAN = double(imread(strcat('.\PAirMax\',folder,'\RR\PAN.tif')));
I_MS = double(imread(strcat('.\PAirMax\',folder,'\RR\MS.tif')));
I_MS_LR = double(imread(strcat('.\PAirMax\',folder,'\RR\MS_LR.tif')));
I_GT = double(I_GT);
algorithms= ["BT_H", "GS", "GSA", "GS_Segm"]




%% Initialisation path and variables
ratio = 4;
L=11;
Qblocks_size = 32;
flag_cut_bounds = 1;
dim_cut = 11;
thvalues = 0;
sensor = 'none';
p = path();
pathparts = strsplit(p, ';');
id_path = cellfun(@(s) contains(s, "Toolbox for Distribution"), pathparts);
dir_path = pathparts(id_path);
userdir=pwd;
cd(dir_path{1})

addpath(strcat(pwd, "\Tools"), '-end')
addpath(strcat(pwd, "\BT-H"), '-end')
addpath(strcat(pwd, "\GS"), '-end')
addpath(strcat(pwd, "\Quality_Indices"), '-end')




for alg=algorithms 
    
switch(alg)
    case "BT_H"
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
    disp(strcat('Indexes of ', alg))
    indices = [A1, A2, A3, A4, A5;B1, B2, B3, B4, B5]
    figure()
    subplot(1,2,1)
    IMN = viewimage(I_matlab(:,:,1:3));
    subplot(1,2,2)
    IMN = viewimage(myMS(:,:,1:3));
    title(alg)
end

cd(userdir)

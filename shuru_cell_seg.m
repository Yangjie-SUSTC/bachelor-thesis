close all
clear
clc
path='D:\lab_data\4_29\3M_KCl\'; 
fluo='FLUO_1';
bf='BF_1';
datapath=[path,fluo,'\data.mat']; 
load (datapath);
bfpath=[path,bf,'\data.mat']; 
load (bfpath);
i=1;
%%
FLUO=CFLUO_double(:,:,end);
BF=CBF_double(:,:,end);
if i==0
    mask=BF_cell_seg(FLUO,BF,[path,fluo,'\label\'],1);
else
    mask=cell_seg(FLUO,BF,[path,fluo,'\label\'],1);
end
maskpath=[path,fluo,'\label\mask'];
save(maskpath,'mask')

[stasticResult,imaData]=getFLUOinfo(datapath,[maskpath,'.mat']);
save([path,fluo,'\label\stasticResult'],'stasticResult')
save([path,fluo,'\label\imaData'],'imaData')

clc
close all


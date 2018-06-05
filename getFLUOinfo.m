function [stasticResult,imaData]=getFLUOinfo(FLUOpath,maskpath)
clc
%%%
%This functio used to get the bias, mean intensity , var intensity of full
%cell and each single cell in FLUO image series of each frame.
%%%
%%
load (FLUOpath);
CFLUO_double=CBF_double;
CBF_double=[];
%mask=cell_seg(CFLUO_double(:,:,1),1);
load (maskpath);
stasticResult.creat=0;
imaData.creat=0;
for i=1:size(CFLUO_double,3)
    disp(i)
    oframe=CFLUO_double(:,:,i);
    frame=oframe;
    frame(oframe<0)=nan;
    %frame = histeq(oframe/max(max(oframe)))*255;
    %fgimg=mask.fg.*frame;
    %bgimg=mask.bg.*frame;
    fg=frame(mask.fg==1);
    bg=frame(mask.bg==1);
    fg(isnan(fg))=[];
    bg(isnan(fg))=[];
    ave.fg=mean(fg);
    ave.bg=mean(bg);
    mvar.fg=std(fg);
    mvar.bg=std(bg);
    bias.fg=std(fg)/mean(fg);
    bias.bg=std(bg)/mean(bg);
    
    
    timg={};
    tave=[];
    tstd=[];
    for k=1:mask.cellNum
        array=(mask.singleCell==k).*frame;
        array (all(array == 0, 2),:) = []; %全零行设为空，即可去掉 
        array (:,all(array == 0, 1)) = []; %全零行设为空，即可去掉 
        img=array(array>0);
        timg=[timg,array];
        tave=[tave,mean(img)];
        tstd=[tstd,std(img)];
        %imavalue=[imavalue,img];
    end
    imaDatas.sigleCell=timg;
    Cell.ave=tave;
    Cell.std=tstd;
    Cell.bias=tstd./tave;
    
    ave.cell=mean(tave);
    mvar.cell=mean(tstd);
    bias.cell=mean(Cell.bias);
    ima.ave=ave;
    ima.mvar=mvar;
    ima.bias=bias;
    ima.Cell=Cell; 
    SNR.ima=20*log10((ima.ave.fg)/ima.ave.bg);% full image fg/bg SNR
    SNR.cell=20*log10((tave)/ima.ave.bg);
    ima.SNR=SNR;
    stasticResult=setfield(stasticResult,['img_',int2str(i)],ima);
    imaDatas.fg=fg;
    imaDatas.bg=bg;
    imaData=setfield(imaData,['img_',int2str(i)],imaDatas);
    %%
   
  

    
    
    

end
stasticResult=rmfield(stasticResult,'creat');
imaData=rmfield(imaData,'creat');
end
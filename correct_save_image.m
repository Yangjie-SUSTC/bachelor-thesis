%%%
% ima corect, Cima=ima-mean(BG)-
%%%
close all
clear
clc

%%
path='H:\graduation\oridata\6_2_cuimie';
savepath='H:\graduation\data\6_2_cuimie';
%property='long_excited';
%DF_name='DF';
%FF_name='fluoflat';
%BG_name=FF_name;
%fullfile(path),'*.tif')


 sub_filefolder=get_subfilefolder(path);
for i=13:length(sub_filefolder)
    sub_sub_filefolder=get_subfilefolder(sub_filefolder{i});
    data.bg.bf=[];
    data.flat.bf=[];
     data.bg.fluo=[];
    data.flat.fluo=[];
    [BF_set,FLUO_set,data]=classify(sub_sub_filefolder,data);
    startbf=0;
    path=BF_set;
    for j=1:length(BF_set)
        savedata(BF_set{j},startbf,data,0);
         %savedata(FLUO_set{j},startbf,data,1);
    end
    for j=1:length(FLUO_set)
        %savedata(BF_set{j},startbf,data,0);
         savedata(FLUO_set{j},startbf,data,1);
    end
    
         
     
end   
%%
function mvanue=savedata(spath,startbf,data,flag)
       if flag==0
           mark='bf';
       else
           mark='fluo';
       end


        SF=dir(fullfile(fullfile(spath),'*.tif'));
        count=0;
        mvanue=[];
        len=length(SF);
        while startbf<len
            CBF_double=[];
            [BF_series,startbf,nameset]=read_ima(SF,startbf);
            count=count+1;
            for k=1:size(BF_series,3)
                bg=eval(['data.bg.',mark]);
                flat=eval(['data.flat.',mark]);
                 CBF_double(:,:,k)=figsave(BF_series(:,:,k),bg,flat,[spath,'\',nameset{k}(1:end-3),'png'],flag);%num2str(50*(count-1)+k),'.png'],flag);
            end
            
         %figsave(CBF_double(:,:,bfk+1),[],[],[BF_set{j},'\mean.png'],0);
         
             
                save([replace(spath,'oridata','data'),['\data',num2str(count)]],'CBF_double');   
        
         if isempty(mvanue)
             size_mvalue=0;
             mvanue=mean(CBF_double,3);
             size_mvalue=size(CBF_double,3)+size_mvalue;
         else 
            mvanue=(sum(CBF_double,3)+mvanue*size_mvalue)/(size_mvalue+size(CBF_double,3));
            size_mvalue=size(CBF_double,3)+size_mvalue;
         end
        end
        %CBF_double(:,:,size(CBF_double,3)+1)=mvanue;
            save([replace(spath,'oridata','data'),'\mean'],'mvanue');
      


end
%%
function ima=figsave(ima,bg,flat,figpath,flag)
figpath=replace(figpath,'oridata','data');
if ~isempty(bg)
    if ~isempty(flat)
    flat=floor(flat);
    flat(flat==0)=1;
   flat=flat/max(max(flat));
   
    %ima=(ima-bg)./flat;
    ima=ima./flat;
    %ima = histeq(ima);%%%%
    
    end
end
tima=ima;
if flag==0 % histeq BF no FLUO
    
    temp=ima/(max(max(ima)));
    tima=255*(temp-min(min(temp)))/(max(max(temp))-min(min(temp)));
end
imwrite(uint8(tima),figpath) ;
end


function sub_filefolder=get_subfilefolder(path)
All_content=dir(fullfile(path));
name_cell={All_content.name};
filefolder_set=name_cell([All_content.isdir]==1);
sub_filefolder=filefolder_set(3:end);% get all subfile folder
for i=1:length(sub_filefolder)
    temp={All_content.folder};
    sub_filefolder{i}=[temp{i},'\',sub_filefolder{i}];
end
end

function [BF_set,FLUO_set,data]=classify(sub_sub_filefolder,data)
BF_set={};
BG={};
FLAT={};
FLUO_set={};

for j= 1:length(sub_sub_filefolder)
    path=sub_sub_filefolder{j};
    figpath=replace(path,'oridata','data');
    if ~exist(figpath)
        mkdir(figpath)
    end
   
   if regexp(path, 'BG_')  
        if regexp(path, 'BF')
            mvanue=savedata(path,0,data,0);
            data.bg.bf=mvanue;
        
        else
             mvanue=savedata(path,0,data,1);
            data.bg.fluo=mvanue;
          
        end
     elseif regexp(path, 'FLAT_')  
        if regexp(path, 'BF')
            mvanue=savedata(path,0,data,0);
            data.flat.bf=mvanue;
       
        else
            mvanue=savedata(path,0,data,1);
            data.flat.fluo=mvanue;
          
               
        end
   
   elseif regexp(path, 'BF_') %%%%%%%%%%%%%%%%%%%%% BF_mark
        BF_set=[BF_set,path];
        
    elseif regexp(path, 'FLUO_') 
        FLUO_set=[FLUO_set,path];
        
        
        
    end
       
       
end
end

function [ima,k,nameset]=read_ima(SF,k)
len=length(SF);
for j =1:min(50,len-k)
    nameset{j}=SF(k+j).name;
    name=[SF(k+j).folder,'\',SF(k+j).name]
    ori_ima=double(rgb2gray(imread(name)));
    ima(:,:,j)=ori_ima(55:2000,:,:);
end 
k=k+j;
end


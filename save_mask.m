close all
clear
clc
groupset={'cuimie1','cuimie2','cuimie3','cuimie4'};
%groupset={'5' '10' '30' '50' '200' '400'};
leng=[3,5,5,5];
for i=1:length(groupset)
     path=['H:\graduation\data\cuimie\',groupset{i},'\'];
     %path=['H:\graduation\data\KCl\',groupset{i},'\'];
     temp=dir(fullfile(path,'FLUO_*'));
     %temp=dir(fullfile(path,'*_*'));
    fluoset={temp.name};
    
    for no=1:length(fluoset)
        fluo=fluoset{no};
         load ([path,fluo,'\','mean']);
         mask=cell_seg(mvanue,[],[path,fluo,'\label\'],1);

       

        
        %bf=['BF_', int2str(no)];
        FLUO=[];
         temp=dir(fullfile([path,fluo,'\'],'data*'));
         matset={temp.name};
        
        for kk=1:length(matset)
        datapath=[path,fluo,'\',matset{kk}]; 
        load (datapath);
        FLUO=cat(3,FLUO,CBF_double);
        CBF_double=[];
        end
%         bfpath=[path,bf,'\data.mat']; 
%         load (bfpath);

        %%
        
        %FLUO=FLUO(:,:,end-1);
        %BF=CBF_double(:,:,end);
        
            %mask=BF_cell_seg(FLUO,BF,[path,fluo,'\label\'],1);
        
        
           
        
        %save([path,fluo,'\label\mask'],'mask')
       maskpath=[path,fluo,'\label\mask'];
        save(maskpath,'mask')
        
        %maskpath=[path,fluo,'\label\mask'];
      count=1;
  for kk=1:length(matset)
        datapath=[path,fluo,'\',matset{kk}]; 
         [stasticResult,imaData]=getFLUOinfo(datapath,[maskpath,'.mat']);
        save([path,fluo,'\label\stasticResult',num2str(count)],'stasticResult')
        save([path,fluo,'\label\imaData',num2str(count)],'imaData')
                clc
        close all
        count=count+1;
   end
       
    end
end



function plot_cell_imaresult(path,prop,varname)
groupset={'0','1','2','3','4'};
npos=[0,1,2,3,4]+0.6*0.3;
%%
%path='D:\lab_data\4_29_exciting_intensity\';
color={'b','g','k'};
sym={'b+','g+','k+'};
ord=[1,2,3];
h=figure();
fgsetset=[];
colsizeset=[];
matname=prop.matname;%'stasticResult';
peoperty=prop.peoperty;%'SNR.cell';%Cell.bias   SNR.cell
ylab=prop.ylab;%'SNR/db';%Normalizes deviation SNR/db
xlab=prop.xlab;
fname=prop.fname;%'SNR_cell';%cell_bias SNR_cell
 for ik=1:3
    k=ord(ik);
    pathset=setpath(path,matname,k);
    fgset=[];
    colsize=[];
    ncolsize=[];
    for i =1:length(pathset)
        dpath=pathset{i};
        load(dpath)
        load(replace(dpath,matname,'mask'))
        img=fieldnames(eval(matname));% all images
        oridata=eval([matname,'.',img{end}]);
        %if length(eval([matname,'.',img{end},'.',peoperty]))>20
        imavalue=[];
        imacell=[];
        for k1=1:mask.cellNum
            array=(mask.singleCell==k1);
            array (all(array == 0, 2),:) = []; %全零行设为空，即可去掉 
            array (:,all(array == 0, 1)) = []; %全零行设为空，即可去掉 
            timg=array.*oridata.sigleCell{k1};
            timg=timg(array>0);
            imavalue=[imavalue,timg.'];
            [imacell,ncolsize]=append(imacell,ncolsize,timg);
         end
        
        bg=oridata.bg;
        fg=oridata.fg;
        imaResults.SNR.cell=20*log10(imavalue/nanmean(bg));
        imaResults.ave.cell = imavalue; 
        imaResults.Cell.bias = nanstd(imacell)./nanmean(imacell); 
        imaResults.SNR.ima = 20*log10(fg/nanmean(bg));
        imaResults.ave.fg =fg ; 
        imaResults.bias.fg =abs(fg-nanmean(fg))/nanmean(fg);  
        SNRset=eval(['imaResults.',peoperty]);
        [fgset,colsize]=append(fgset,colsize,SNRset);

    end
    pos=[0,1,2,3,4]+0.6*0.3*(k-1);
    width=0.6*0.3*colsize/max(colsize);
    plot(pos,nanmean(fgset),color{k})
    hold on
    boxplot(fgset,'widths',width,'Symbol',sym{k},'Colors',color{k},'positions',pos,'Labels',{'Control','1' '2' '3' '4' },'OutlierSize',2)
    hold on 
   
    fgsetset=[fgsetset;fgset];
    colsizeset=[colsizeset;colsize];
    
    
 end
 
 
 if strcmp(ylab,'Fluorescent intensity')
     loc='NorthWest';
 else
     loc='NorthEast' ;
 end
 legend('G1 mean','G2 mean','G3 mean','Location',loc);
 xlabel(xlab)
 ylabel(ylab)
 set(gca,'Xtick',npos);
 set(gca,'Xticklabel',groupset);
 set(gca,'Fontname','times new Roman','fontsize',12);
 %ylim([min(min(fgsetset)),1.05*max(max(fgsetset))]);
 ax=gca;
ti = ax.TightInset;
set(gca,'position',[ti(1),ti(2),1-1.1*ti(1),1-1.1*ti(2)])
%set(gcf,'PaperUnits','normalized','PaperType','<custom>','PaperPosition',[-0.1,-0.05,1.2,1.125],'PaperOrientation','landscape')
print(['H:\my_thesis\figures\',varname,'\3_',fname,'_box'],'-depsc','-r600','-painters')
saveas(gca,['D:\lab_data\4_29_exciting_intensity\fig\ima\3_',fname,'_box.fig'])


figure()
colsize=sum(colsizeset);
width=0.8*colsize/max(colsize);
boxplot(fgsetset,'widths',width,'Labels',{'Control','1' '2' '3' '4' },'OutlierSize',2,'positions',pos)
hold on
plot(pos,nanmean(fgsetset),'r-')
hold on
plot(pos,nanmean(fgsetset),'b*')
xlabel(xlab)
ylabel(ylab)
%ylim([min(min(fgsetset)),1.05*max(max(fgsetset))]);
  if strcmp(ylab,'Fluorescent intensity')
     loc='NorthWest';
 else
     loc='NorthEast' ;
  end
legend('mean','Location',loc)
set(gca,'Xtick',npos);
set(gca,'Xticklabel',groupset);
set(gca,'Fontname','times new Roman','fontsize',12);  
ax = gca;
ti = ax.TightInset;
set(gca,'position',[ti(1),ti(2),1-1.1*ti(1),1-1.1*ti(2)])
print(['H:\my_thesis\figures\',varname,'\3full_',fname,'_box'],'-depsc','-r600','-painters')
saveas(gca,['D:\lab_data\4_29_exciting_intensity\fig\ima\3full_',fname,'_box.fig'])
%end
end
%%
function [set,colsize]=append(set,colsize,vector)
colsize=[colsize,length(vector)];
vector=reshape(vector,[length(vector),1]);
if size(set,1)>length(vector)
    vector(length(vector)+1:size(set,1))=nan;
elseif size(set,1)<length(vector)
    temp=nan(length(vector)-size(set,1),size(set,2));
    set=[set;temp] ;
end
 set=[set,vector];

end

function pathset=setpath(path,matname,k)

for i=0:4
    %for no=1:3
         tpath=[path,int2str(i),'\FLUO_',int2str(k),'\label\',matname,'.mat'];
         pathset{i+1}=tpath;
         
        
    %end
end


end

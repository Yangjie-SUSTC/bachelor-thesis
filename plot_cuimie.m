function[] =plot_cuimie(info)

color={'b','g','k','m','r'};% for repeat time
sym={'b+','g+','k+','m+','r+'};
[FLUO,stdv]=getfulldata(info);
cuit=[];





for i=1:size(FLUO,1)
    inten=[];
    temp=FLUO(i,:);
    for j=1:length(temp)
        wave=temp{j};
        if length(wave)>0
            inten(j,:)=wave/wave(1);
            stop(j,i)=get_stop(wave/wave(1));
            start(j,i)=wave(1);
        end
    end
    in(i,:)=mean(inten);
    time(i,:)=[0:length(inten)-1]*info.step;
    %errorbar(time(i,:),in(i,:),in(i,:)-min(inten),max(inten)-in(i,:))
    errorbar(time(i,:),in(i,:),std(inten),'linewidth',0.05,'Color',color{i})
       
    hold on
    
    
    
end
for i=1:size(FLUO,1)
    plot(time(i,:),in(i,:),'linewidth',2.5,'Color',color{i})
end
save([info.datapath,info.varname,'\ref','_',replace(info.peoperty,'.','_')],'in')

leg={'1','2','3','4'};
info.loc='northeast';
info.fname='fLuo';
info.xlim=[0,max(time(1,:))*1.05];
info.xlab='Time / s';
info.ylab='I/I_0';
setaxe(gca,info,3,leg)

info.fname='initial';
info.ylab='Fluorescent intensity';
pltbar([1,2,3,4],start,info,0)

info.fname='half_life';
info.ylab='Half-life / s';

pltbar([1,2,3,4],stop*info.step,info,1)


end
%%
function pltbar(x,sig,info,flag)
close all
figure()
info.xlim=[0.5,4.5];
 sig(sig==0)=nan;
 my=nanmean(sig);
 bar(x,my,'r')
 hold on
  errorbar(x,my,nanstd(sig),'k.','linewidth',2.5)
  hold on
 if flag==1
  for i=1:length(my)
    if my(i)>130
        str{i}='>130';
    else
        str{i}=num2str(my(i));
    end
  end
 else
     str=num2cell(my);
 end

        
 
text(x-0.3,my+nanstd(sig)+15,str,'fontsize',15)
  
info.xlab='Exciting intensity';
ttt=max(my+nanstd(sig)+20)+20
set(gca,'ylim',[0,ttt]);
setaxe(gca,info,1,[])

end
%%
function stop=get_stop(wave)
kk=1;
count=0;
while count<5 && kk<=length(wave)
    
    if wave(kk)<0.5
        count=count+1;
    else
        count=0;
    end
    kk=kk+1;          
end
stop=kk-count-2;
    

end
%%
function setaxe(axe,info,cuit,leg)


axe.XLabel.String=info.xlabel;
axe.YLabel.String=info.ylab;
 %set(axe,'Xtick',info.xpos);
 %set(axe,'XTickLabel',info.xtickbel);
 set(axe,'Fontname','times new Roman','fontsize',info.fontsize);
 
if ~isempty(leg)
set(gcf,'outerposition',get(0,'screensize'));
h=legend(leg,'Location',info.loc );
set(h,'FontSize',30) 
 set(axe,'Fontname','times new Roman','fontsize',30);
end
 %ylim([min(min(data)),1.005*max(max(data))]);
 %xlim([min(min(xdata))-0.5*info.halfwidth*info.step,max(max(xdata))+0.5*info.halfwidth*info.step]);
 xlim(info.xlim)
ti = axe.TightInset;
set(gca,'position',[ti(1),ti(2),1-1.1*ti(1),1-1.1*ti(2)])

ppath=[info.figpath,info.varname];
if ~exist(ppath)
    mkdir(ppath);
end

print([ppath,'\',info.fname,'_',replace(info.peoperty,'.','_')],'-depsc','-r600','-painters')
ppath=[info.datapath,info.varname,'\fig'];
if ~exist(ppath)
    mkdir(ppath);
end
saveas(axe,[ppath,'\3_',info.fname,'_box.fig'])

end



%%

function[FLUO,std]=getfulldata(info)

for i=1:length(info.group)% get into group folder
    group=info.group{i};
    FLUOset=get_FLUOset(group,info);
    for j=1:length(FLUOset)
        repeat=FLUOset{j};
        matset=dir(fullfile(fullfile(info.datapath,...
        info.varname,group,repeat,'label'),[info.matname,'*','.mat']));
        matset={matset.name};
        [SNRset,varset]=readdata(matset,info,group,repeat);
        FLUO{i,j}=SNRset;
        std{i,j}=varset;  
    end % finish one group
   
end  

end
 %% 
 function [SNRset,varset]=readdata(matset,info,group,repeat)
SNRset=[];
varset=[];
count=1;
flag=1;
flagcount=0;
while flag==1 && count<=length(matset)

matname=[info.matname,num2str(count),'.mat']

fullmatpath=fullfile(info.datapath,...
info.varname,group,repeat,'label',matname);
load(fullmatpath)
img=fieldnames(eval(info.matname));
   
    for jimg=1:size(img)
        select=img{jimg};
        SNR=eval([info.matname,'.',select,'.',info.peoperty]);
        SNR=reshape(SNR,length(SNR),1);
        SNRset=[SNRset;SNR];% each mat is one column
        bias=eval([info.matname,'.',select,'.',info.bias]);
        bias=reshape(bias,length(bias),1);
        varset=[varset;bias.*SNR];% each mat is one column
    end
% finish one fragment
if count==1
    std=nanmean(SNR);
end

if nanmean(SNR)<0.707*std
    flagcount= flagcount+1;
    if flagcount==3
        flag=0;
    end
else
    flagcount=0;
end
count=count+1;
end
 end
%%
function FLUOset=get_FLUOset(group,info)
a=fullfile(info.datapath,info.varname,group);
temp=dir(fullfile(a,'FLUO_*'));
FLUOset={temp.name};
end

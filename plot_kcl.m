function[] =plot_kcl(info)
close all
ord=[5,5,5;
    5,5,5;
    5,5,5;
    5,5,5;
    5,5,5;
    5,5,5];

color={'b','g','k','m','r','y'};% for repeat time
sym={'b+','g+','k+','m+','r+','y+'};
[FLUO,stdv]=getfulldata(info);
cuit=[];

st=5;
et=15;



for i=1:size(FLUO,1)
    inten=[];
    temp=FLUO(i,:);
    load([info.datapath,info.varname,'\ref','_',replace(info.peoperty,'.','_'),'.mat'])
    for j=1:length(temp)
        wave=temp{j};
        if length(wave)>0
            inten(j,:)=wave.'./(in(2,:)*wave(1));
            stop(j,i)=get_stop(wave/wave(1),ord(i,j));
            ttemp=inten(j,:);
            start(j,i)=min(ttemp(st:et));
            startpos(j,i)=find(ttemp==start(j,i));
        end
    end
    mein(:,i)=(mean(inten,1)).';
    time(:,i)=([0:length(inten)-1]*info.step).';
    %errorbar(time(i,:),in(i,:),in(i,:)-min(inten),max(inten)-in(i,:))
    if size(inten,1)==1
        s(:,i)=0*zeros(size(inten));
        else
        s(:,i)=std(inten);
    end   
end


%%


info.fname='max';
info.ylab='I/I_0';
info.xlab='ln(K^+)';
for kk=1:length(info.group)
    x(kk)=str2num(info.group{kk});
end
my=pltbar(log(x),start,info,0)
close all
%%
for i=1:size(FLUO,1)
    errorbar(time(:,i),mein(:,i),s(:,i),'linewidth',0.05,'Color',color{i}) 
    hold on
end
for i=1:size(FLUO,1)
    plot(time(:,i),mein(:,i),'linewidth',2.5,'Color',color{i})
    hold on
end

yt=[0.6:0.1:1.2];
xt=time(st:et,1);
plot(time(st,1)*ones(size(yt)),yt,'r--','linewidth',1.5);
hold on
plot(xt,0.6*ones(size(xt)),'r--','linewidth',1.5);
hold on
plot(xt,1.2*ones(size(xt)),'r--','linewidth',1.5);
hold on
plot(time(et,1)*ones(size(yt)),yt,'r--','linewidth',1.5);
save([info.datapath,info.varname,'\cor','_',replace(info.peoperty,'.','_')],'mein')
save([info.datapath,info.varname,'\cortime','_',replace(info.peoperty,'.','_')],'time')
save([info.datapath,info.varname,'\corstd','_',replace(info.peoperty,'.','_')],'s')

leg=info.group;
info.loc='northeast';
info.fname='fLuo';
info.xlim=[0,max(time(:,1))*1.05];
info.xlab='Time / s';
setaxe(gca,info,cuit,leg)

close all
for i=1:size(FLUO,1)
    errorbar(time(st:et,i),mein(st:et,i),s(st:et,i),'linewidth',0.05,'Color',color{i}) 
    hold on
end
for i=1:size(FLUO,1)
    ts=time(st:et,i);
    ys=mein(st:et,i);
    plot(ts,ys,'linewidth',2.5,'Color',color{i})
%     hold on
%     plot(ts(find(ys==my(i))),my(i),'*','linewidth',20,'Color',color{i})
end

save([info.datapath,info.varname,'\cor_loc','_',replace(info.peoperty,'.','_')],'mein')
save([info.datapath,info.varname,'\cortime_loc','_',replace(info.peoperty,'.','_')],'time')
save([info.datapath,info.varname,'\corstd_loc','_',replace(info.peoperty,'.','_')],'s')
 
leg=info.group;
info.loc='northeast';
info.fname='fLuo_local';
info.xlim=[min(time(st:et,1))*0.95,max(time(st:et,1))*1.05];
info.xlab='Time / s';
setaxe(gca,info,4,leg)














% info.fname='ord';
% pltbar(log(x)),stop*info.step,info,1)


end
%%
function my=pltbar(x,sig,info,flag)
close all

figure()
info.xlim=[-5 405];
 sig(sig==0)=nan;
 my=nanmean(sig);
 dott=sig;
 dott=[sig;my];
 save([info.datapath,info.varname,'\cor_dot','_',replace(info.peoperty,'.','_')],'dott')
 
 plot(x,my,'k','linewidth',2.5)
 hold on
  errorbar(x,my,nanstd(sig),'k','linewidth',1.5)
  hold on
 
for i=1:length(my)
    temp=sig(:,i);
    for j=1:length(temp)
        plot(x(i),temp(j),'*','linewidth',5)
        hold on
    end

end
y(1)=min(sig(:,1));
y(2)=max(sig(:,2));
y(3)=mean(sig(:,3));
y(4)=min(sig(:,4));
y(5)=mean(sig(:,5));
y(6)=max(sig(:,6));

x=x.';
X=repmat(x,size(y,1),1);
y=reshape(y,size(X));
X=[ones(size(y)),X]
[b,bint,r,rint,stats]=regress(y,X)

y=x*b(2)+b(1);
plot(x,y,'r','linewidth',3)
str=sprintf(['y = ',num2str(b(2)),'*x',' + ',num2str(b(1)),'\n','R^2 = ',num2str(stats(1)),'\nP = ',num2str(stats(3))])
text(3.2,0.72,str,'fontsize',15)
%rcoplot(r,rint)

        
 
% text(x-0.2,my+nanstd(sig)+7,str)
%   
% info.xlab='ln(K^+)';

 info.xlim=[min(x)*0.95,max(x)*1.05];
setaxe(gca,info,1,[])

end
%%
function stop=get_stop(wave,ord)
 stop=wave(ord) ;
end
%%
function setaxe(axe,info,cuit,leg)


axe.XLabel.String=info.xlab;
axe.YLabel.String=info.ylab;
 %set(axe,'Xtick',info.xpos);
 %set(axe,'XTickLabel',info.xtickbel);
 set(axe,'Fontname','times new Roman','fontsize',info.fontsize);
 %ylim([min(min(data)),1.005*max(max(data))]);
 %xlim([min(min(xdata))-0.5*info.halfwidth*info.step,max(max(xdata))+0.5*info.halfwidth*info.step]);
if ~isempty(leg)
set(gcf,'outerposition',get(0,'screensize'));
h=legend(leg,'Location',info.loc );
set(h,'FontSize',30) 
 set(axe,'Fontname','times new Roman','fontsize',30);
end

if cuit==4
set(gcf,'outerposition',get(0,'screensize'));
h=legend(leg,'Location',info.loc );
set(h,'FontSize',50) 
 set(axe,'Fontname','times new Roman','fontsize',50);
end

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
temp=dir(fullfile(a,'*_*'));
FLUOset={temp.name};
end

function plot_score(SNRsetset,matsize,Biasetset,info)
SNRset=SNRsetset./nanmean(SNRsetset(:,1));
Biaset=Biasetset./nanmean(Biasetset(:,1));
scoreset=log((SNRset.*Biaset).^2);
effset=scoreset.*(ones(size(scoreset,1),1)*info.efd);


info.fname='score';
info.ylab='Score';
plotscore(scoreset,matsize,info)

info.fname='ROI';
info.ylab='OIR';
plotscore(effset,matsize,info)

end


function plotscore(scoreset,matsize,info)
color={'b','g','k','m','r'};% for repeat time
sym={'b+','g+','k+','m+','r+'};
for j=1:size(matsize,2)% get into group folder
    st=1;
    for i=1:size(matsize,1)
        len=matsize(i,j);
        en=st+len-1;
       score=scoreset(st:en,j);
       
       st=en+1;
       temp=nanmean(score);
       median_repeatset(j,i)=temp;
       
        plot(info.poset(j,i),temp,color{i})
        hold on
        boxplot(score,'widths',info.thrwidthset(j,i),'Symbol',sym{i},...
        'Colors',color{i},'positions',info.poset(j,i),'OutlierSize',2)
        hold on   
    end
end
       
drawline(info.poset,median_repeatset,color)
for cu=1:size(info.poset,2)
    leg{cu}=['Group ',num2str(cu)];
end
setaxe(gca,info,scoreset,leg,info.poset)
%h1=figure('name',['mean',info.peoperty]);
figure()
plot(info.xpos,nanmean(scoreset),'r-')
hold on
plot(info.xpos,nanmean(scoreset),'b*')
hold on
boxplot(scoreset,'widths',info.width,'positions',info.xpos,'OutlierSize',2)
hold on 
setaxe(gca,info,scoreset,'mean',info.xpos)
end


%%
function drawline(poset,median_repeatset,color)
for kk=1:size(poset,2)
    x=poset(:,kk);
    y=median_repeatset(:,kk);
    plot(x,y,color{kk});
    hold on
end
end




%%

function  setaxe(axe,info,data,leg,xdata)
if strcmp(info.ylab,'Fluorescent intensity')
     loc='NorthWest';
 else
     loc='NorthEast' ;
 end
legend(leg,'Location',loc )
axe.XLabel.String=info.xlabel;
axe.YLabel.String=info.ylab;
 set(axe,'Xtick',info.xpos);
 set(axe,'XTickLabel',info.xtickbel);
 set(axe,'Fontname','times new Roman','fontsize',info.fontsize);
 ylim([min(min(data)),1.005*max(max(data))]);
 xlim([min(min(xdata))-0.5*info.halfwidth*info.step,max(max(xdata))+0.5*info.halfwidth*info.step]);
ti = axe.TightInset;
set(gca,'position',[ti(1),ti(2),1-1.1*ti(1),1-1.1*ti(2)])
ppath=[info.figpath,info.varname];
if ~exist(ppath)
    mkdir(ppath);
end
print([ppath,'\3_',info.fname,'_box'],'-depsc','-r600','-painters')
ppath=[info.datapath,info.varname,'\fig'];
if ~exist(ppath)
    mkdir(ppath);
end
saveas(axe,[ppath,'\3_',info.fname,'_box.fig'])

end


























































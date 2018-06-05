
clear
close all
clc
%%
info.varname='kcl';

info.group={'5' '10' '30' '50' '200' '400'};
info.xpos=[1,2,3,4];
info.xtickbel={'1','2','3','4'};
info.xlabel=('Time / s');
info.efd=log(info.xpos);
info.dt=0.5*ones(1,length(info.group));
%%
%{
info.varname='4_23time';
info.group={'0min','5min','10min','20min','30min','45min','90min'};
info.xpos=[0,5,10,20,30,45,50];
info.xtickbel={'0','5','10','20','30','45','50'};
info.xlabel=('Incubation time / min');
temp=log(info.xpos(2:length(info.xpos)));
temp=1./temp;
temp=[0,temp];
info.efd=temp;
%}
%%
info.datapath='H:\graduation\data\';
info.figpath='H:\graduation\thesis\figures\';
info.fontsize=20;
info.step=1.316;
info.halfwidth=0.8;
%%
proset={'ave.cell','ave.fg'};%
bias={'bias.cell','bias.fg'};

matname='stasticResult';
fnameset={'cell_intensity','intensity'};
ylabset={'I/I_0','I/I_0'};
for i =1:length(proset)
    peoperty=proset{i};
    ylab=ylabset{i};
    fname=fnameset{i};
    info.matname=matname;%'stasticResult';
    info.peoperty=peoperty;%'SNR.cell';%Cell.bias   SNR.cell
    info.ylab=ylab;%'SNR/db';%Normalizes deviation SNR/db
    info.fname=fname;%'SNR_cell';%cell_bias SNR_cell
    info.bias=bias{i};
%plot_fg_staresult(path,peoperty,fname,'Normalized deviation')
plot_kcl(info);
close all
end
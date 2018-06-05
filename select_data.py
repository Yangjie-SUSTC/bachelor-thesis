# -*- coding: utf-8 -*-
"""
Created on Tue Apr 24 06:28:09 2018

@author: Yangjie
"""
import pandas as pd
import os
import copy as cp
import matplotlib.pyplot as plt  
import numpy as np
#from matplotlib import rc
#rc('font',**{'family':'serif','serif':['Palatino']})
#rc('text', usetex=True)


class baseinfo:
     def __init__(self,resultdir,resultname,figpath,refdir,refname):
         self.resultdir=resultdir
         self.resultname=resultname
         self.figdir=figpath
         self.refdir=refdir
         self.refname=refname
         

class plotfig:
    def __init__(self,select,plotinfo,base):
        self.xlabel=plotinfo[0]
        self.ylabel=plotinfo[1]
        self.title=plotinfo[2]
        self.figdir=base.figdir
        self.resultname=base.resultname
        self.resultdir=base.resultdir
        self.refdir=base.refdir
        self.refname=base.refname
        self.select=select
        self.data=self.readata(self.resultdir, self.resultname)
        self.ref=self.readata(self.refdir, self.refname)
        
    def newd(self):
        self.data=self.readata(self.resultdir, self.resultname)
        self.ref=self.readata(self.refdir, self.refname)
        
    
    def box(self):
        #self.data=self.readata(self.select)
        font1 = {'family' : 'Times New Roman',  
                 'weight' : 'normal',  
                 'size'   : 14,  
} 
         # plt.plot(self.data.T)
        #plt.grid(True)
        #%plt.setp(ax,xticklabels=['1st','2nd'])
        x=list(np.log(self.data.columns))
        x[0]=x[1]-[x[2]-x[1]]
        refx=list(np.log(self.ref.columns))
        refx[0]=refx[1]-[refx[2]-refx[1]]
        lab=[]
        for i in self.data.columns:
            lab.append('{:g}'.format(i))
        
        fig=plt.figure(num=self.title,figsize=(10,6), dpi=200)
        #plt.plot(x,self.data.T)#np.mean(self.data,axis=0))
        plt.plot(x,np.mean(self.data,axis=0))
        plt.plot(refx,self.ref.T)
        plt.boxplot(self.data.T,labels=lab,autorange=True,showfliers=False, positions=np.array(x))
        plt.xlabel(self.xlabel,font1)
        plt.ylabel(self.ylabel,font1)
        plt.legend(['Incubation - digestion','Digestion - incubation'],loc='best',prop=font1)
        #plt.xticks(self.data.columns)
        #plt.title(self.title)
        #plt.show()
        fig.savefig (os.path.join(self.figdir, self.title+'.pdf'),bbox_inches='tight')
        
        
        

            

    def readata(self,resultdir, resultname):
        
        
        plate=os.path.join(resultdir, resultname)  
        result=pd.read_excel(plate)
        rslice=result[(result['class']==self.select[0])&(result['part']==self.select[1])]
        fresult=rslice[[self.select[2],'con']]
        conset=set(fresult['con'])
        conset=list(conset)
        conset.sort()
        final=pd.DataFrame([])
        for con in conset:
            temp= fresult[fresult['con']==con]
            temp=temp[self.select[2]]
            temp.name=con
            frames=[final,temp]
            final=pd.concat(frames,axis=1)
            
            
            '''
        str='_'
        resultname=str.join(select)
        resultname=resultname+'.xlsx'
        final.to_excel(os.path.join(self.figdir, self.resultname))
        '''
        
        return  final





resultname ='digest_then_fuyu'#'fuyu_then_digest'################# set here
refname ='fuyu_then_digest'
redir='H:\\graduation\\data\\4-16-FCM_concentration\\result\\'
fdir ='H:\\graduation\\thesis\\figures\\FCM_result\\'
resultdir=redir+resultname
refdir=redir+refname

figdir=fdir#+resultname
resultname=resultname+'.xlsx'
refname=refname+'.xlsx'




base=baseinfo(resultdir,resultname,figdir,refdir,refname)

class_set=['favor','back']
part_set=['signal','noise']
vset=['FITC-H_ave','FITC-A_ave','FITC-H_std','FITC-A_std']

'''
for i in class_set:
    for j in part_set:
        for k in vset:
            select=[i,j,k]
            readata(select,figdir,resultname)
            
 '''
 
 
 
 
select=['favor','signal','FITC-H_ave']
plotinfo=['DiBAC'+r'$_4(3)$'+ ' concnetration '+r'$(\mu\mathrm{mol} / L)$','Fluorescent intensity','name']
favsig=plotfig(select,plotinfo,base)
favsig.title='favsig_inensity'
favsig.box()

select=['back','signal','FITC-H_ave']
backsig=cp.deepcopy(favsig)
backsig.select=select;
backsig.newd()
#'''
###############  remove exception dot##############
tem=backsig.data[0];
tem=np.mean(tem.drop(0))
backsig.data[0][0]=tem
###############  remove exception dot##############
#'''
backsig.title='backsig_inetnsity'
backsig.box()


std=cp.deepcopy(favsig)
std.select=['favor','signal','FITC-H_std']
std.newd()
#'''
###############  remove exception dot##############
tem=std.data[0];
tem=np.mean(tem.drop(0))
std.data[0][0]=tem
tem=std.data[0.025];
tem=np.mean(tem.drop(3))
std.data[0.025][3]=tem
###############  remove exception dot##############
#'''

std.title='std';
std.ylabel='Normalized deviation'
std.box()



snr=20*np.log10(favsig.data/backsig.data)
snref=20*np.log10(favsig.ref/backsig.ref)
SNR=cp.deepcopy(favsig)
SNR.data=snr;
SNR.ref=snref;
SNR.title='SNR';
SNR.ylabel='SNR / dB'
SNR.box()


Bias=cp.deepcopy(favsig)
Bias.data=std.data/favsig.data
'''
tem=Bias.data[0.025];
tem=np.mean(tem.drop(3))
Bias.data[0.025][3]=tem
'''
Bias.ref=std.ref/favsig.ref
#tem=cp.deepcopy(Bias);
#tem.data.drop(tem.data.index[[3]],inplace=True)
Bias.title='bias';
Bias.ylabel='Normalized deviation'
Bias.box()


score=SNR.data.div(SNR.data[0],axis=0)*Bias.data.div(Bias.data[0],axis=0)
score=np.log(score)
scoref=SNR.ref.div(SNR.ref[0],axis=0)*Bias.ref.div(Bias.ref[0],axis=0)
scoref=np.log(scoref)

SCORE=cp.deepcopy(favsig)

SCORE.data=score;
SCORE.ref=scoref;
SCORE.title='Score';
SCORE.ylabel='Score'
SCORE.box()


eff=cp.deepcopy(SCORE)
temp=1/SCORE.data.columns[1:];
temp=np.log(temp)
temp=temp.insert(0,SCORE.data.columns[0]) # get 1/concentration
eff.data=eff.data.mul(list(temp),axis=1) 

temp=1/SCORE.ref.columns[1:];
temp=np.log(temp)
temp=temp.insert(0,SCORE.ref.columns[0])
eff.ref=eff.ref.mul(list(temp),axis=1) 

eff.title='efficency';
eff.ylabel='ROI'
eff.box()
#score=score.loc[1:4]


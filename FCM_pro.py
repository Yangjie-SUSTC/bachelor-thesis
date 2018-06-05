import os
from matplotlib.colors import LogNorm
from scipy.stats import gaussian_kde
import FlowCytometryTools
from FlowCytometryTools import FCMeasurement
from pylab import *
import matplotlib.pyplot as plt  
from mpl_toolkits.mplot3d import Axes3D
import shutil
import csv  
import xlrd 
import pandas as pd

class fcmplot:
    def __init__(self,data,figpath,mark):
      
        data=data.dropna(axis=0,how='any')
        t=np.where(data==inf)
        data=data.drop(data.index[t[0]])
        t=np.where(data==0)
        data=data.drop(data.index[t[0]])
        self.data=data
        #print(self.data)
        self.figpath=figpath
        self.mark=mark
        if 'density'not in self.data.columns:
            x=self.data['FSC-H'].dropna();
            y=self.data['SSC-H'].dropna();
            xy = np.vstack([x,y])
            z = gaussian_kde(xy)(xy)
            self.data['density']=z;
            
        
    def set_axi_lim(self,x,y,ax):
        
        
        xmin=min(x)
       
        
        xmax=max(x)
        ymin=min(y)
        ymax=max(y)
        cdf=hist(x,int(size(x)/5)+1,normed=1,histtype='bar',facecolor='pink',alpha=0.75,cumulative=True,rwidth=0.8)  
        temp=cdf[1][find(cdf[0]>0.05)]
        if len(temp)>0:
            xmin=max(temp[0],min(x))
        temp=cdf[1][find(cdf[0]<0.95)]
        if len(temp)>0:
            xmax=min(temp[-1] ,max(x))
        cdf=hist(y,int(size(y)/5)+1,normed=1,histtype='bar',facecolor='pink',alpha=0.75,cumulative=True,rwidth=0.8)  
        temp=cdf[1][find(cdf[0]>0.05)]
        if len(temp)>0:
            ymin=max(temp[0],min(y))
        temp=cdf[1][find(cdf[0]<0.95)]
        if len(temp)>0:
            ymax=min(temp[-1] ,max(y))
        plt.axis([xmin,xmax,ymin,ymax])
        #ax=plt.gca()  
        #xx=np.logspace(log10(xmin),log10(xmax) , num=4, endpoint=True, base=10.0, dtype=int)
        #yy=np.logspace(log10(ymin),log10(ymax) , num=4, endpoint=True, base=10.0, dtype=int)
        xx=np.linspace(xmin,xmax,4)
        yy=np.linspace(ymin,ymax,4)
        ax.set_xticks(xx)  
        ax.set_xticklabels(xx)  
        ax.set_yticks(yy)  
        ax.set_yticklabels(yy)  

        
    
    def scatter(self,xname,yname,note):
        
        font = {'family' : 'serif',  
        'color'  : 'black',  
        'weight' : 'normal',  
        'size'   : 12,  
        }
        x=self.data[xname].dropna()
        y=self.data[yname].dropna()
        z=self.data['density']
        #cmap = matplotlib.cm.jet 
        
        axe=plt.gca()
        plt.xlabel(xname,fontdict=font)
        plt.ylabel(yname,fontdict=font)
        cm = plt.cm.get_cmap('RdYlBu') 
        aa=plt.scatter(x,y,c=z, alpha=1, marker='o',s=1,cmap=cm)
        #axe.set_yscale('log')
        #axe.set_xscale('log')
        self.set_axi_lim(x,y,axe)
        #plt.axis([0,2e6,0,4e5])
        title=note+'_'+xname+'-'+yname+'_scatter'
         
        plt.colorbar(aa)
        #plt.title(title) 
        fig = plt.gcf()
        print(title)
        plt.show()
        fig.savefig (os.path.join(self.figpath, title+'.pdf'),bbox_inches='tight')
    
    def rmdlet(self):
        FSC_w=self.data['FSC-A']/self.data['FSC-H']
        #fig,(ax0,ax1) = plt.subplots(nrows=2,figsize=(9,6)) 
        pdf=hist(FSC_w,int(size(FSC_w)/10)+1,normed=1,histtype='bar',facecolor='yellowgreen',alpha=0.75)  
        cdf=hist(FSC_w,int(size(FSC_w)/10)+1,normed=1,histtype='bar',facecolor='pink',alpha=0.75,cumulative=True,rwidth=0.8)  
                #plt.show()
        temp=sorted(pdf[0])
        index1=find(pdf[0]>0.1*mean(temp[-20:]))# larger taht 0.1 max percent
        index2=find((cdf[0]>0.05) & (cdf[0]< 0.90))
        findex=set(index1)&set(index2)
        findex=sort(list(findex))
        index1=find(FSC_w>pdf[1][findex[0]]);
        index2=find(FSC_w<pdf[1][findex[-1]]);
        findex=set(index1)&set(index2)
        
        self.data=self.data.iloc[list(findex)]
        self.scatter('FSC-H','SSC-H','Singlet')
        
        
    def kmeans(self):
        from sklearn.cluster import KMeans  
        x=self.data[['SSC-H','FSC-H']]
        ax=array(x)
        #print(np.where(ax==0))
        ax=log10(ax)
        
        
        clf = KMeans(n_clusters=2)    
        y_pred = clf.fit_predict(ax)          
        live_label=sum(y_pred)>0.5*size(y_pred)
        
        p0=self.data.loc[x.index[y_pred==int(~live_label)]]
        p1=self.data.loc[x.index[y_pred==int(live_label)]]
        signal = fcmplot(p1,self.figpath,self.mark)
        signal.scatter('FSC-H','SSC-H','Favor')
        back = fcmplot(p0,self.figpath,self.mark)
        #print(back.data)
        back.scatter('FSC-H','SSC-H','Background')
        return signal,back
    
    def gussianfit(self,name,note):
        data=self.data[name]
        k=max(data)
        his=hist(data,int(size(data)/10)+1,color='black')
        temp=array(his[1])
        ndata_value=(temp[:-1] + temp[1:])/2
        from scipy import optimize  
        x=ndata_value/k
        y=his[0];
        def gaussian(x,a1,mu1,sig1):#,a2,mu2,sig2):  
            return a1/(sqrt(2*pi)*sig1)*np.exp(-np.power(x - mu1, 2) / (2 * np.power(sig1, 2)))#+\
           #a2/(sqrt(2*pi)*sig2)*np.exp(-np.power(x - mu2, 2) / (2 * np.power(sig2, 2)))
        popt, pcov = optimize.curve_fit(gaussian,x,y,maxfev = 180000000,bounds=([0,min(x),0],[100,max(x),10000]))
        #smu=max(popt[4],popt[1])
        smu=popt[1]
        ssig=abs(popt[find(popt==smu)+1])
        
        findex=find( (data.values<(smu+2*ssig)*k)&(data.values>(smu-2*ssig)*k))
        findex=data.index[findex]
        pdata=data.loc[findex]
        
        if k not in pdata:
            pdata.loc['add']=k
            
        his=hist(pdata,int(size(data)/10)+1,color='green')
        
        plt.plot(x*k,y,'b-',label='Data',linewidth=2)  

        fy=gaussian(x*k,*(popt*k))
        plt.plot(x*k,fy,'r-',label='Gussian fitted',linewidth=2)  
        
        plt.xlabel(name)
        plt.ylabel('Count')
        title=note+'_'+name+'_pdf'
        print(title)
        plt.legend()  
        fig = plt.gcf()
        plt.show()#************************************
        fig.savefig (os.path.join(self.figpath, title+'.pdf'),bbox_inches='tight')
        
        return findex
        
    def classify(self,oname):
        if oname=='favor':
            nameset=['SSC-H','SSC-A','FSC-H','FSC-A']
        else:
            nameset=['FSC-H','FSC-A']
        ind1=set(self.data.index)
        for name in nameset:
            temp=set(self.gussianfit(name,oname))
            ind1=temp & ind1
        self.signal=fcmplot(self.data.loc[ind1],self.figpath,self.mark)
        self.noise=fcmplot(self.data.loc[set(self.data.index)-ind1],self.figpath,self.mark)
        self.signal.scatter('FSC-H','SSC-H',oname+' signal')
        self.noise.scatter('FSC-H','SSC-H',oname+' noise')
    
def fcmana(datafile,figpath,mark):
    import re
    # datafile = '[insert path to your own fcs file]' 

    # Load data
    tsample = FCMeasurement(ID=mark,datafile=datafile)
    data=tsample.data.dropna(axis=0,how='any') 
    f1 = fcmplot(data,figpath,mark)
    
    f1.scatter('FSC-H','SSC-H','full cell')
    favor,back=f1.kmeans()
    favor.rmdlet()# only sigle let
    objset=['favor','back']
    proset=['signal','noise']
    result=pd.DataFrame([])
    for obj in objset:
        eval(obj).classify(obj)
        for pro in proset:
            clo=obj+'.'+pro
            x=eval(clo).data
            Number=size(x)
            mean = np.mean(x)
            std_deviation = np.std(x)
            a=np.hstack((mean[['FITC-H','FITC-A']].values,std_deviation[['FITC-H','FITC-A']].values,Number))
            a=a.reshape((1,5))
            b=re.split('_',mark)
            if size(b)==2:
                nuo=b[1]
            else:
                nuo=str(0);
            frame=pd.DataFrame(a,index=[nuo],columns=['FITC-H_ave','FITC-A_ave','FITC-H_std','FITC-A_std','size'])  
            frame['class']=obj;
            frame['part']=pro;
            frame['con']=b[0]
        
            frames=[result,frame]
            result=pd.concat(frames)       
            #print(result)
    return result
    

def fcm_config(datadir,configdir,platename,prename,figdir):
    import re
    isExists=os.path.exists(figdir)
    if isExists:
        shutil.rmtree(figdir)

    os.mkdir(figdir)
    
    plate=os.path.join(configdir, platename)  
    config = pd.read_excel(plate)  #读excel  
    print(config)
    result=pd.DataFrame([])

    for ind in config.index:
        for col in config.columns:
            tube=ind+str(col)
            mark=config.loc[ind][col]
            if  not isnan(mark):
                mark=str(mark)  #get concentration
                name=prename+tube+'.fcs'
                datafile=os.path.join(datadir, name) 
                print(name)
                figpath=os.path.join(figdir, mark)
                isExists=os.path.exists(figpath)
                if isExists:
                    pat=mark+'_'
                    order=1
                    for filename in os.listdir(figdir):
                        if pat in filename:
                            temp=re.split('_',filename)
                            if temp[0]==mark:
                                temp=temp[1]
                                print('temp----------')
                                print(filename)
                                print(temp)
                                print(order)
                                order=max(
                                        int(temp)+1,order)
                                         
                    #os.mkdir(figpath+'_'+str(order))
                    mark=mark+'_'+str(order)
                print(mark)
                print('mark*************')
                figpath=os.path.join(figdir, mark)
                os.mkdir(figpath)
                
                frame=fcmana(datafile,figpath,mark)
                frames=[result,frame]
                result=pd.concat(frames) 
            
                print(result)
    return result

datadir = 'H:\\graduation\\oridata\\FCM_concentration'
#figdir='H:\\graduation\\data\\4-16-FCM_concentration\\digest_then_fuyu' 

figdir='H:\\graduation\\data\\4-16-FCM_concentration\\result'#write  excel data path

for i in [1,2]:
    
    if i==1:
    
        platename='plate.xlsx'
        prename='02-Tube-'
        resultname='digest_then_fuyu'
        figdir=figdir+ '\\'+resultname 
        resultname=resultname+'.xlsx'
    else:
        platename='plate_12.xlsx'
        prename=''
        resultname='fuyu_then_digest'
        figdir=figdir+ '\\'+resultname  
        resultname=resultname+'.xlsx'
    configdir=datadir 
    fcm_result=fcm_config(datadir,configdir,platename,prename,figdir)
    fcm_result.to_excel(os.path.join(figdir, resultname))


        
        
        
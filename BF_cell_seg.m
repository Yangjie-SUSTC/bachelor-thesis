function ima_str=BF_cell_seg(varargin)

path=varargin{3}; 


%img_str=get_cell_mask(varargin);



%%
%function ima_str=get_cell_mask(varargin)
oriImage=[varargin{2}];
BFima=[varargin{1}];
flag=0;
if length(varargin)>3
    flag=1;
    if ~exist(path)
    mkdir(path)
    end
end
close all
Image=uint8(oriImage);
bw = imbinarize(Image,'adaptive','ForegroundPolarity','dark');
%bw=~bw;
thresh = multithresh(Image,3);
seg_I = imquantize(Image,thresh);
bw2 = label2rgb(seg_I);
temp=seg_I>2;
mul_bw=temp.*bw;
se = strel('disk',10);
mul_bw=imclose(mul_bw,se);
large_connect=remove_dot(mul_bw);



ima_str.ima=Image;
ima_str.fg=large_connect;
tbg=(seg_I<2);
ima_str.bg=tbg;
ima_str=get_sigle_cell(ima_str,path,flag);
if flag==1  
    figlabel(ima_str,'BF_lable',path);
    temp=ima_str;
    temp.ima=uint8(BFima);
    imaa=figlabel(temp,'FLUO_lable',path);
    figure('name','original');
    subplot(221)
    imshow(imaa);  
    title('original')
    subplot(222)
    imshow(bw );  
    title('binary')
    subplot(223)
    imshow(bw2  );  
    title('foru part')
    subplot(224)
    imshow(large_connect);  
    title('fg')
    
    
    savefig(Image,'original',path);
    savefig(bw,'binary',path);
    savefig(bw2,'classification',path);
    savefig(large_connect,'fg',path);
    
end

end
%end

%%
function Ima=figlabel(ima_str,name,path)
contour = bwperim(ima_str.fg);
    [y,x]=find(contour==1);
    contour = bwperim(ima_str.singleCell);
    [y1,x1]=find(contour==1);
    contour = bwperim(ima_str.bg);
    [y2,x2]=find(contour==1);
    h=figure();
    imshow(ima_str.ima);
    hold on
    plot(x,y,'ro','MarkerSize',0.5)
    hold on
    plot(x1,y1,'go','MarkerSize',0.5)
    hold on
    plot(x2,y2,'bo','MarkerSize',0.5)
    gfframe=getframe(gca);
    savefig(gfframe.cdata,name,path);
    Ima=gfframe.cdata;
    close (h)

end
%%
function connect=remove_dot(ima)
    [M,num] = bwlabel(ima,8);
    S = regionprops(M, 'Area'); 
    area=[S.Area];
    area=sort(area);
    T1=floor(area(end-min(20,length(area)-1)));
    T2=floor(0.0025*size(ima,1)*size(ima,2));
    T=max([T2,T1,floor(0.1*median(area))]);
    connect = bwareaopen(M,T,8);


end

%% get siglet cell and label eacn cell 
function img_str=get_sigle_cell(img_str,path,flag)
    
    se = strel('disk',5);
    fushi= imerode(img_str.fg,se);
  
    single_cell = imclearborder(fushi,6) ;
    connect1=remove_dot(single_cell);
    
    [M,num] = bwlabel(connect1,8);
    S = regionprops(M, 'Area'); 
    area=[S.Area];
    area=sort(area);
   
    temp = bwareaopen(connect1,floor(1.4*median(area)),8);
    connect=connect1-temp;
    [M1,num] = bwlabel(connect,8);
    S = regionprops(M1, 'Area');                       
    marea=[S.Area];
   
    M1=imfill(M1,'holes');
    bw2 = label2rgb(M1);

  
    img_str.singleCell=M1;
    img_str.cellNum=num;
  
    if flag==1
        figure('name','late process');
        subplot(222)
        imshow(single_cell);  
        title('remove board')
        subplot(221)
        imshow(fushi);  
        title('erode')
        subplot(223)
        imshow(connect1);  
        title('remove dot')
        subplot(224)
        imshow(bw2);  
        title('single cell')
        savefig(single_cell,'remove_board',path);
        savefig(fushi,'erode',path);
        savefig(connect1,'remove_dot',path);
        savefig(bw2,'single_cell',path);
    end
    
end
%% 
function []=savefig(fig,name,path)



imwrite(fig,[path,name,'.png'])
end


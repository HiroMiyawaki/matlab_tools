clear
dataDir= '/Volumes/RAID_HDD/data/OCU/HR0016/2017-06-22_18-01-54/';
videoFileName='2017-06-22 18-02-02.151.m4v';

fStr=6;
maskSmooth=5;
maskThreshold=1.5; %z-score
alpha=0.7;
rangeXY=50;
clear template tempSize prevXY


%%
vr=VideoReader([dataDir videoFileName]);
for ite=1:fStr    
    temp=double(vr.readFrame);
end
image(temp/256)
axis equal
[x,y]=ginput(2);
xRange=ceil(min(x)):floor(max(x));
yRange=ceil(min(y)):floor(max(y));

image(temp(yRange,xRange,:)/256)
axis equal

[x,y]=ginput(2)
tempXY{1}=[ceil(min(x)),floor(max(x)),ceil(min(y)),floor(max(y))];

[x,y]=ginput(2)
tempXY{2}=[ceil(min(x)),floor(max(x)),ceil(min(y)),floor(max(y))];

%%
vr=VideoReader([dataDir videoFileName]);
for ite=1:fStr    
    temp=double(vr.readFrame);
end
cnt=0;
meanImg=zeros(length(yRange),length(xRange),3);
% sqMeanImg=zeros(vr.Height,vr.Width,3);
while hasFrame(vr)
    temp=double(vr.readFrame);
    meanImg=meanImg+temp(yRange,xRange,:);
%     sqMeanImg=sqMeanImg+temp.^2;
    cnt=cnt+1;
end

meanImg=meanImg/cnt;
% sqMeanImg=sqMeanImg/cnt;


nFrame=cnt+fStr;
%%
vr=VideoReader([dataDir videoFileName]);
for ite=1:fStr    
    temp=double(vr.readFrame);
end
cnt=0;

for ite=1:fStr    
    temp=double(vr.readFrame);
end
cnt=0;
sqMeanImg=zeros(size(meanImg));
while hasFrame(vr)
    temp=double(vr.readFrame);
    temp=temp(yRange,xRange,:)-meanImg;
    sqMeanImg=sqMeanImg+temp.^2;
    cnt=cnt+1;
end

dev=sqrt(squeeze(mean(mean(sqMeanImg/cnt,1),2)));

%%
vr=VideoReader([dataDir videoFileName]);

for ite=1:fStr    
    temp=double(vr.readFrame);
end


mask=[];
maskSmoothSize=5;
maskSmooth=zeros(maskSmoothSize);
for x=1:maskSmoothSize
    for y=1:maskSmoothSize
        maskSmooth(x,y)=((x-0.5-maskSmoothSize/2)^2+(y-0.5-maskSmoothSize/2)^2)<(maskSmoothSize/2)^2;
    end
end


%%        
clear ratPos
clear tempHist;
matInnProd=@(x,y) (x(:)'*y(:));
matCos=@(x,y) matInnProd(x,y)/sqrt(matInnProd(x,x))/sqrt(matInnProd(y,y));

param.tempXY=tempXY;
param.maskThreshold=maskThreshold;
param.maskSmoothSize=maskSmoothSize;
param.maskSmooth=maskSmooth;
param.alpha=alpha;
param.rangeXY=rangeXY;
param.fStr=fStr;
param.videoFile=[vr.Path '/' vr.Name];
param.xRange=xRange;
param.yRange=yRange;

param.madeby=mfilename;

%%
nextFrame=temp(yRange,xRange,:)-meanImg;
for idx=1:3
    mask(:,:,idx)=abs(nextFrame(:,:,idx))>dev(idx)*maskThreshold;
    mask(:,:,idx)=conv2(mask(:,:,idx),maskSmooth,'same')==sum(maskSmooth(:));
    mask(:,:,idx)=conv2(mask(:,:,idx),maskSmooth,'same')>0;
end
nextFrame=nextFrame.*mask;

for n=1:length(tempXY)
    template{n}=nextFrame(tempXY{n}(3):tempXY{n}(4),tempXY{n}(1):tempXY{n}(2),:);
    tempSize{n}=[size(template{n},1),size(template{n},2)];
    prevXY{n}=tempXY{n}([1,3]);    
end
originalTemplate=template;


for n=1:length(tempXY)
    ratPos{n}=zeros(nFrame,2);
    tempHistory{n}=zeros([size(template{n}),nFrame]);
    for idx=1:fStr
        ratPos{n}(idx,:)=tempXY{n}([1,3]);
        tempHistory{n}(:,:,:,idx)=template{n};
    end
end
%%
nRow=2;
nCol=7;
col=hsv(length(template));

frm=fStr;
while hasFrame(vr)
    frm=frm+1;
    origImage=double(vr.readFrame);
    nextFrame=origImage(yRange,xRange,:)-meanImg;
    for idx=1:3
        mask(:,:,idx)=abs(nextFrame(:,:,idx))>dev(idx)*1.5;
        mask(:,:,idx)=conv2(mask(:,:,idx),maskSmooth,'same')==sum(maskSmooth(:));
        mask(:,:,idx)=conv2(mask(:,:,idx),maskSmooth,'same')>0;
    end

    nextFrame=nextFrame.*mask;

    for n=1:length(template)
        maxSim=-inf;
        maxSimXY=[0,0];

        for y=max([1,ratPos{n}(frm-1,2)-rangeXY]):min([ratPos{n}(frm-1,2)+rangeXY,size(nextFrame,1)-tempSize{n}(1)+1])
            for x=max([1,ratPos{n}(frm-1,1)-rangeXY]):min([ratPos{n}(frm-1,1)+rangeXY,size(nextFrame,2)-tempSize{n}(2)+1])

                tempSim=matCos(nextFrame(y+(0:tempSize{n}(1)-1),x+(0:tempSize{n}(2)-1),:),template{n});
                if tempSim>maxSim
                    maxSim=tempSim;
                    maxSimXY=[x,y];
                end
            end
        end
        template{n}=alpha*nextFrame(maxSimXY(2)+(0:tempSize{n}(1)-1),maxSimXY(1)+(0:tempSize{n}(2)-1),:)+(1-alpha)*template{n};
        tempHistory{n}(:,:,:,frm)=template{n};
        ratPos{n}(frm,:)=maxSimXY;
        prevXY{n}=maxSimXY;
    end
    
    plotpos=mod(frm-fStr-1,nCol*nRow);
    subplot2((length(template)+1)*nRow,nCol,...
              1+(1+length(template))*floor(plotpos/nCol),mod(plotpos,nCol)+1)
%     image(video(5:370,90:450,frm))
%     imagesc(90:450,5:370,nextFrame(5:370,90:450))
    image(origImage(yRange,xRange,:)/256*3)

    axis equal
    axis off
    for n=1:length(template)
        rectangle('position',[ratPos{n}(frm,1),ratPos{n}(frm,2),tempSize{n}(2),tempSize{n}(1)],'edgeColor',col(n,:),'lineWidth',3);
    end
    title(frm)
    
    
    for n=1:length(template)
    subplot2((length(template)+1)*nRow,nCol,...
              1+n+(1+length(template))*floor(plotpos/nCol),mod(plotpos,nCol)+1)
        imagesc(template{n}/256*3)
%         colormap(gray)
        axis equal
        axis off    
    end
%     if mod(plotpos,15)==14
     drawnow
%     end
        
end
%%
save([vr.Path '/posDetectionCol.mat'],'-v7.3','ratPos','tempHistory','originalTemplate','param')

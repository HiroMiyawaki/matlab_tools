% vr=VideoReader([dataDir '2017-06-22 18-02-02.151.m4v']);
% cnt=0;
% while hasFrame(vr)
%     fr=vr.readFrame;
%     cnt=cnt+1;
%     video(:,:,cnt)=(max(fr,[],3)+min(fr,[],3))/2;
% end


% 
% %%
% meanImg=zeros(size(video,1),size(video,2));
% for x=1:size(video,1)
%     display([num2str(x) '/' num2str(size(video,1))])
%     for y=1:size(video,2)    
%         meanImg(x,y)=mean(double(video(x,y,:)));
%     end
% end
% imagesc(meanImg)
% colormap(gray)
% axis equal
% %%
% fStr=6;
% 
% clear tempXY
% clf
% 
% % mask=abs(double(video(:,:,fStr))-meanImg)>5;
% % imagesc((double(video(:,:,fStr))-meanImg).*mask )
% imagesc((double(video(:,:,fStr))-meanImg) )
% colormap(gray)
% axis equal
% 
% [x,y]=ginput(2)
% tempXY{1}=[ceil(min(x)),floor(max(x)),ceil(min(y)),floor(max(y))];
% 
% [x,y]=ginput(2)
% tempXY{2}=[ceil(min(x)),floor(max(x)),ceil(min(y)),floor(max(y))];


vr=VideoReader([dataDir '2017-06-22 18-02-02.151.m4v']);
meanImg=zeros(vr.Height,vr.Width,3);
cnt=0;
while hasFrame(vr)
    meanImg=meanImg+double(vr.readFrame);
    cnt=cnt+1;
end

meanImg=meanImg/cnt;

image(meanImg/256)
%%
clear template tempSize prevXY

maskSmooth=5;
alpha=0.7;
rangeXY=30;

mask=abs(double(video(:,:,fStr))-meanImg)>5;
mask=conv2(double(mask),ones(maskSmooth),'same')>maskSmooth^2*0.8;
mask=conv2(double(mask),ones(maskSmooth),'same')>1;
nextFrame=(double(video(:,:,fStr))-meanImg).*mask;
for n=1:length(tempXY)
    template{n}=nextFrame(tempXY{n}(3):tempXY{n}(4),tempXY{n}(1):tempXY{n}(2));
    tempSize{n}=size(template{n});
    prevXY{n}=tempXY{n}([1,3]);    
end
originalTemplate=template;


matInnProd=@(x,y) (x(:)'*y(:));
matCos=@(x,y) matInnProd(x,y)/sqrt(matInnProd(x,x))/sqrt(matInnProd(y,y));

param.tempXY=tempXY;
param.maskSmooth=maskSmooth;
param.alpha=alpha;
param.rangeXY=rangeXY;
param.fStr=fStr;
param.videoFile=[vr.Path '/' vr.Name];
param.madeby=mfilename;




clear ratPos
clear tempHist;
for n=1:length(tempXY)
    ratPos{n}=zeros(size(video,3),2);
    tempHistory{n}=zeros([size(template{n}),size(video,3)]);
    for idx=1:fStr
        ratPos{n}(idx,:)=tempXY{n}([1,3]);
        tempHistory{n}(:,:,idx)=template{n};
    end
end
nRow=2;
nCol=7;
col=hsv(length(template));



for frm=fStr:(1+size(video,3)-fStr);
    
    if mod(frm,500)==0 || frm==fStr
        display([datestr(now) ' frame ' num2str(frm) '/' num2str(size(video,3))])
    end
    mask=abs(double(video(:,:,frm))-meanImg)>5;
    mask=conv2(double(mask),ones(maskSmooth),'same')>maskSmooth^2*0.8;
    mask=conv2(double(mask),ones(maskSmooth),'same')>1;
    
    nextFrame=(double(video(:,:,frm))-meanImg).*mask;
    
    for n=1:length(template)
        maxSim=-inf;
        maxSimXY=[0,0];

        for y=max([1,ratPos{n}(frm-1,2)-rangeXY]):min([ratPos{n}(frm-1,2)+rangeXY,size(video,1)-tempSize{n}(1)+1])
            for x=max([1,ratPos{n}(frm-1,1)-rangeXY]):min([ratPos{n}(frm-1,1)+rangeXY,size(video,2)-tempSize{n}(2)+1])

                tempSim=matCos(nextFrame(y+(0:tempSize{n}(1)-1),x+(0:tempSize{n}(2)-1)),template{n});
                if tempSim>maxSim
                    maxSim=tempSim;
                    maxSimXY=[x,y];
                end
            end
        end
        template{n}=alpha*nextFrame(maxSimXY(2)+(0:tempSize{n}(1)-1),maxSimXY(1)+(0:tempSize{n}(2)-1))+(1-alpha)*template{n};
        tempHistory{n}(:,:,frm)=template{n};
        ratPos{n}(frm,:)=maxSimXY;
        prevXY{n}=maxSimXY;
    end
    
    plotpos=mod(frm-fStr-1,nCol*nRow);
    subplot2((length(template)+1)*nRow,nCol,...
              1+(1+length(template))*floor(plotpos/nCol),mod(plotpos,nCol)+1)
%     image(video(5:370,90:450,frm))
%     imagesc(90:450,5:370,nextFrame(5:370,90:450))
    imagesc(90:450,5:370,video(5:370,90:450,frm))

    axis equal
    axis off
    for n=1:length(template)
        rectangle('position',[ratPos{n}(frm,1),ratPos{n}(frm,2),tempSize{n}(2),tempSize{n}(1)],'edgeColor',col(n,:),'lineWidth',3);
    end
    title(frm)
    
    
    for n=1:length(template)
    subplot2((length(template)+1)*nRow,nCol,...
              1+n+(1+length(template))*floor(plotpos/nCol),mod(plotpos,nCol)+1)
        imagesc(template{n})
        colormap(gray)
        axis equal
        axis off    
    end
%     if mod(plotpos,15)==14
     drawnow
%     end
        
end

save([vr.Path '/posDetection.mat'],'-v7.3','ratPos','tempHistory','originalTemplate','param')



%%
    
for frm=1:size(video,3)    
    mask=abs(double(video(:,:,frm))-meanImg)>5;
    mask=conv2(double(mask),ones(maskSmooth),'same')>maskSmooth^2*0.8;
    mask=conv2(double(mask),ones(maskSmooth),'same')>1;
    imagesc(90:450,5:370,(double(video(5:370,90:450,frm))-meanImg(5:370,90:450)).*double(mask(5:370,90:450)))

    axis equal
    axis off
    for n=1:length(template)
        rectangle('position',[ratPos{n}(frm,1),ratPos{n}(frm,2),tempSize{n}(2),tempSize{n}(1)],'edgeColor',col(n,:),'lineWidth',3);
    end
    colormap(gray)
    title(frm)
%     pause(1/120)
    drawnow
end



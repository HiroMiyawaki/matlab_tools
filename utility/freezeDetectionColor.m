function freezeDetectionColor(videofile,imageRange,threshold,tOffset)

close all
nBaseFrame=2500;%100 sec

smoothSD=2;
nErosion=2;
nDilation=1;
erosionCore=[0,0,1,0,0;
    0,1,1,1,0;
    1,1,1,1,1;
    0,1,1,1,0;
    0,0,1,0,0];

dilationCore=[0,0,1,0,0;
    0,1,1,1,0;
    1,1,1,1,1;
    0,1,1,1,0;
    0,0,1,0,0];

sizeThreshold=50;

vr=VideoReader(videofile);

if ~exist('tOffset','var')
    tOffset=0;
end

%%
mu = [0 0];
Sigma = smoothSD*eye(2);
x1 = -3*smoothSD:3*smoothSD; x2 = -3*smoothSD:3*smoothSD;
[X1,X2] = meshgrid(x1,x2);
smoothigCore = mvnpdf([X1(:) X2(:)],mu,Sigma);
smoothigCore = reshape(smoothigCore,length(x2),length(x1));

%%

if exist('imageRange','var')
    rangeset=true;
    xRange=imageRange(1:2);
    yRange=imageRange(3:4);
else
    rangeset=false;
end
%%
fr=readFrame(vr);
while ~rangeset
    close all
    fh=figure('position',[200,1000,1280,960]);
    image(fr);
    axis equal
    set(gca,'clim',[0,255]);
    colormap(gray);
    title('Select area to show')
    [y,x]=ginput(2);
    xRange=[floor(min(x)),ceil(max(x))];
    yRange=[floor(min(y)),ceil(max(y))];
    imageRange=[xRange,yRange];

    image(fr(xRange(1):xRange(2),yRange(1):yRange(2),:));
    axis equal
    figure(fh);
    ans=input('Is the selected area OK? (Y or N): ','s');
    if strcmpi(ans,'y')
        rangeset=true;
    end
end


%%
baseVideo=zeros(diff(imageRange(1:2))+1,diff(imageRange(3:4))+1,3,nBaseFrame);

disp([datestr(now) ' loading base image of ' videofile])

vr.CurrentTime=tOffset; %not to use exposur fluctation at the begginign of v

for idx=1:nBaseFrame
    if vr.hasFrame
        fr=double(readFrame(vr));
        for n=1:3
            fr(:,:,n)=conv2(fr(:,:,n),smoothigCore,'same');
        end
        baseVideo(:,:,:,idx)=fr(imageRange(1):imageRange(2),imageRange(3):imageRange(4),:);
    else
        baseVideo(:,:,:,idx:end)=[];
        break
    end
end

baseImg=mean(baseVideo,4);

close all
fh=figure();
% image(fr(imageRange(1):imageRange(2),imageRange(3):imageRange(4),:));
image(baseImg/255)
axis equal
figure(fh);
pause(3)
close all

temp=baseVideo-repmat(baseImg,1,1,1,size(baseVideo,4));
temp=sum(temp.^2,3).^0.5;

baseDev=std(temp(:));

%%
vr.CurrentTime=0;
idx=0;
%%
if ~exist('threshold','var')
    threshold=baseDev*3;
end
% colormap(gray);
axis equal

sCoreSize=(size(smoothigCore,1)+1)/2;

xRange=imageRange(1)-sCoreSize:imageRange(2)+sCoreSize;
yRange=imageRange(3)-sCoreSize:imageRange(4)+sCoreSize;





prev=zeros(diff(imageRange(1:2))+1,diff(imageRange(3:4))+1);

nFrame=round(vr.Duration*vr.FrameRate);
change=nan(1,nFrame);
area=nan(1,nFrame);

progStep=0.05;
prog=progStep;

disp([datestr(now) ' start processing'])

% goNext=vr.hasFrame;
try
    while vr.hasFrame
        idx=idx+1;
        
        if idx/nFrame>prog
            disp([datestr(now) ' ' num2str(prog*100) '% done'])
            prog=prog+progStep;
        end
        

        orig=vr.readFrame;
        fr=zeros(length(xRange),length(yRange),3);
        for n=1:3
            fr(:,:,n)=conv2(double(orig(xRange,yRange,n)),smoothigCore,'same');
        end
        fr=fr(sCoreSize+1:end-sCoreSize,sCoreSize+1:end-sCoreSize,:);
        
        bi=ones(size(fr,1),size(fr,2));
        bi(sum((fr-baseImg).^2,3).^0.5 <threshold)=0;
        
        for n=1:nDilation 
            bi=conv2(bi,dilationCore,'same')>0;
        end
        for n=1:nErosion
            bi=conv2(bi,erosionCore,'same')>sum(erosionCore(:))-1;
        end
        
        iso=zeros(size(bi));
        curIdx=0;
        marge=[];
        for n=2:size(bi,1)-1
            for m=2:size(bi,2)-1
                if(bi(n,m)==1)
                    if iso(n-1,m)==0
                        if iso(n,m-1)==0
                            curIdx=curIdx+1;
                            iso(n,m)=curIdx;
                        else
                            iso(n,m)=iso(n,m-1);
                        end
                    else
                        iso(n,m)=iso(n-1,m);
                        if iso(n,m-1)~=0 && (iso(n,m-1)~=iso(n-1,m))
                            marge(end+1,:)=sort([iso(n,m-1),iso(n-1,m)]);
                        end
                    end
                end
            end
        end
        
        while ~isempty(marge)
            %         imagesc(iso)
            %         pause(1)
            
            margeSeed=min(marge(:,1));
            margeTarget=unique(marge(marge(:,1)==margeSeed,2));
            
            for ii=1:length(margeTarget)
                n=margeTarget(ii);
                iso(iso==n)=margeSeed;
                marge(marge(:,1)==margeSeed &marge(:,2)==n,:)=[];
                marge(marge==n)=margeSeed;
            end
        end
        
        islands=unique(iso(iso>0));
        
        di=zeros(size(bi));
        if ~isempty(islands)
            for n=1:length(islands)
                if sum(iso(:)==islands(n))>sizeThreshold
                    di(iso==islands(n))=1;
                end
            end
        end
        
        
        moved=xor(prev,di);
        
        prev=di;
        
        change(idx)=sum(moved(:));
        area(idx)=sum(di(:));
        
        
        
        %     goNext=vr.hasFrame;
        %
        %
%             subplot(2,2,1)
%             image(fr/255)
%             colormap(gca,gray)
%             clim=get(gca,'clim');
%         
%             subplot(2,2,2)
%             temp=[];
%             for n=1:3
%                 temp2=fr(:,:,n)/2;
%                 if n<3
%                     temp2(bi==1)=temp2(bi==1)+128;
%                 else
% %                     temp2(bi==1)=255;
%                 end
%                 temp(:,:,n)=temp2;
%             end
%             
%             image(temp/255)
%             colormap(gca,gray)
%             set(gca,'clim',clim)
%         
%             subplot(2,2,3)
%             imagesc(di)
%         
%             subplot(2,2,4)
%             imagesc(moved)
%             title(sum(moved(:)))
%         
%             drawnow
    end
    
    disp(['whole video was processed (' num2str(idx) ' frames'])
    
catch
    disp(['process ended at frame ' num2str(idx)])
end
lastFrame=idx;
%%
clf
smoothCh=medfilt1(change,5);
logCh=log10(smoothCh+1);
logCh(isnan(logCh)|isinf(logCh))=[];

r=zeros(1,1000);
for idx= 1:length(r)
    t=log10(idx+1);
    r(idx)=sum(logCh<t)*sum(logCh>=t)*(mean(logCh(logCh<t))-mean(logCh(logCh>=t)))^2;
end
[~,moveThreshold]=max(r);

% hist(logCh,100)
% hold on
% ax=fixAxis;
% plot(log10(thresh+1)*[1,1],ax(3:4),'r-')

% plot(change)
% ax=fixAxis;
% hold on
% plot(ax(1:2),thresh*[1,1])
%%

fz=(smoothCh<moveThreshold)&(area>0);

onset=find(diff(fz)==1)+1;
offset=find(diff(fz)==-1);

if offset(1)<onset(1); onset=[1,onset]; end
if offset(end)<onset(end); offset(end+1)=lastFrame; end

freeze=removeTransient([onset',offset'],1,5*vr.FrameRate);

%%
% clf
% plot(fz'/25,500*[1,1]')
% hold on
% plot((1:length(change))/25,change)
% ax=fixAxis;
% plot(ax(1:2),thresh*[1,1],'k-')

%%

ext=findstr(videofile,'.');
saveFileCore=[videofile(1:ext(end)-1) '_freeze'];
saveFileName=[saveFileCore '.mat'];

if exist(saveFileName,'file')
    
    backupName=[saveFileCore '-backup.mat']
    idx=0;
    while exist(backupName,'file')
        idx=idx+1;
        backupName=[saveFileCore '-backup' num2str(idx) '.mat'];
    end
    disp(['Previous results was backed up as ' backupName])
    unix(['mv ' saveFileName ' ' backupName]);
end

param.videofile=videofile;
param.imageRange=imageRange;
param.frameRate=vr.FrameRate;
param.threshold=threshold;
param.moveThreshold=moveThreshold;

param.smoothSD=smoothSD;
param.nErosion=nErosion;
param.nDilation=nDilation;
param.erosionCore=erosionCore;
param.dilationCore=dilationCore;
param.nBaseFrame=nBaseFrame;
param.sizeThreshold=sizeThreshold;
param.nProcessFrame=lastFrame;
param.madeby=mfilename;

save(saveFileName,'freeze','change','area','param','-v7.3');
disp([datestr(now) 'Results saved in ' saveFileName])


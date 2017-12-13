% videoFolderList={};
% videofileList={};
% for n=1
%     switch n
%         case 1
%             dataDirRoot='~/data/OCU/eyelid_behavior/HR0021/';
%     end
%     temp=dir([dataDirRoot '*mp4']);
%     videoFolderList={videoFolderList{:},temp.folder};
%     videofileList={videofileList{:},temp.name};
% end
% 
% ledName={'running','tone1','tone2','shock','blinker'};
% 
% for idx=1:length(videofileList)
%     vr=VideoReader(fullfile(videoFolderList{idx},videofileList{idx}));
%     fr=readFrame(vr);
%     close all
%     fh=figure('position',[200,1000,1280,960]);
%     imagesc(fr(:,:,1));
%     axis equal
%     set(gca,'clim',[0,255]);
%     colormap(gray);
%     
%     for n=1:length(ledName)
%         title(['Select ' ledName{n}])
%         [y,x]=ginput(2);
%         xRange=[floor(min(x)),ceil(max(x))];
%         yRange=[floor(min(y)),ceil(max(y))];
%         imageRange(idx).(ledName{n})=[xRange,yRange];
%     end
% end
%%

for idx=1:length(videofileList)
    videofile=fullfile(videoFolderList{idx},videofileList{idx});

    vr=VideoReader(videofile);

    nFrame=round(vr.Duration*vr.FrameRate);
    
    clear led
    for n=1:length(ledName)
        tempRange=imageRange(idx).(ledName{n});
        led.(ledName{n})=nan(diff(tempRange(1:2))+1,diff(tempRange(3:4))+1,nFrame);
    end
    
    progStep=0.05;
    prog=progStep;

    disp([datestr(now) ' start processing of ' videofileList{idx}])
    frameIdx=0;
    try
        while vr.hasFrame
            frameIdx=frameIdx+1;
            if frameIdx/nFrame>prog
                disp(['    ' datestr(now) ' ' num2str(prog*100) '% done'])
                prog=prog+progStep;
            end
            
            fr=vr.readFrame;
            
            for n=1:length(ledName)
                tempRange=imageRange(idx).(ledName{n});
                tempImg=double(fr(tempRange(1):tempRange(2),tempRange(3):tempRange(4),:));
                tempImg=max(tempImg,[],3)+min(tempImg,[],3);
                led.(ledName{n})(:,:,frameIdx)=tempImg;
                
%                 subplot2(length(ledName),10,n,mod(frameIdx-1,10)+1)
%                 imagesc(tempImg)
%                 set(gca,'clim',[0,512])
%                 axis equal
%                 colormap(gray)
%                 title(mean(tempImg(:)))
            end
%             drawnow
        end
        disp(['    ' datestr(now) ' whole video was processed (' num2str(frameIdx) ' frames'])
    
    catch
        disp(['    ' datestr(now) ' process ended at frame ' num2str(frameIdx)])
    end
    param.madebb=mfilename;
    param.imageRange=imageRange(idx);
    param.videoDir=vr.Path;
    param.videoName=vr.Name;
    param.fps=vr.FrameRate;
    
    ext=findstr(videofile,'.');
    saveFileCore=[videofile(1:ext(end)-1) '_ledImage'];
    saveFileName=[saveFileCore '.mat'];
    idx=0;

    while exist(saveFileName,'file')
        idx=idx+1;
        saveFileName=[saveFileCore '-' num2str(idx) '.mat'];
    end    
    
    save(saveFileName,'led','param','-v7.3')
    
end    




    
    
    
    
    
    

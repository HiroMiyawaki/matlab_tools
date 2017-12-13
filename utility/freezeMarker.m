function [freezeFrames,imageRange]=freezeMarker(videoFile,freezeFrames,imageRange)
% videofile=['~/data/OCU/eyelid_behavior/' 'HR0019/' 'HR0019_2017-07-14-132646-0000' '.mp4'];
% freezeMarker(videofile)

close all
vr=VideoReader(videoFile);

if ~exist('freezeFrames','var')||isempty(freezeFrames)
    freezeFrames=zeros(1,vr.Duration*vr.FrameRate+1);
end
%%


if exist('imageRange','var')
    rangeset=true;
    xRange=imageRange(1:2);
    yRange=imageRange(3:4);
else
    rangeset=false;
end
%%
while ~rangeset
    close all
    fh=figure('position',[200,1000,1280,960]);
    fr=readFrame(vr);
    imagesc(fr(:,:,1));
    axis equal
    set(gca,'clim',[0,255]);
    colormap(gray);
    title('Select area to show')
    [y,x]=ginput(2);
    xRange=[floor(min(x)),ceil(max(x))];
    yRange=[floor(min(y)),ceil(max(y))];
    imageRange=[xRange,yRange];

    imagesc(fr(xRange(1):xRange(2),yRange(1):yRange(2),1));
    axis equal
    set(gca,'clim',[0,255]);
    colormap(gray);
    figure(fh);
    ans=input('Is the selected area OK? (Y or N): ','s');
    if strcmpi(ans,'y')
        rangeset=true;
    end
end
%%
vr.CurrentTime=0;
nFrame=round(vr.Duration*vr.FrameRate)+1;
video=zeros(diff(yRange)+1,diff(xRange)+1,nFrame,'int8');
idx=0;
disp([datestr(now) ' ' 'start loading ' videoFile])
time=zeros(1,nFrame);
progStep=0.1;
prog=progStep;
frameExist=vr.hasFrame;
while frameExist
    try
        fr=vr.readFrame;
    catch
        vr.CurrentTime=vr.CurrentTime+1/vr.FrameRate;
        fr=zeros(size(fr));
    end
    idx=idx+1;
    video(:,:,idx)=fr(yRange(1):yRange(2),xRange(1):xRange(2),1);
    if(idx/nFrame>prog)
        disp([datestr(now) ' ' num2str(prog*100) '% loaded']);
        prog=prog+progStep;
    end
    time(idx)=vr.CurrentTime;   
    
    try
        frameExist=vr.hasFrame;
    catch
        if vr.Duration<vr.CurrentTime
            frameExist=false;
        else
            frameExist=true;
        end
    end
end
disp([datestr(now) ' ' 'finished loading!']);

if time(end)==0
    time(end)=[];
    video(:,:,end)=[];
end
%%
going=1;
idx=0;
nFrame=size(video,3);
close all
fh=figure('position',[200,1000,1280,960]);
subplot('position',[0.8,0.25,0.15,0.7])
xlim([0,1]);
ylim([0,1]);
axis off
text(0,1,{
    'f: flip Freeze/moving'
    'e: end analyses'
    'b/B: back 10 sec/1 frame'
    's/S: skip 10 sec/1 frame'
    'p: pause/play'
    'a/A: accelerate'
    'd/D: deaccelerate'
    'r: reset speed' 
    %'r: reverse'
    },...
    'horizontalAlign','left','verticalAlign','top')
        
while 1
    %if going ~=0
    %if vr.hasFrame
        idx=idx+going;
        
        if idx>nFrame
            idx=nFrame;
             if going>0
                going=0;
            end
       elseif idx<=0
            idx=1;
            if going<0
                going=0;
            end
        end
        
        %fr=readFrame(vr);
        % %imagesc(fr(:,:,1));
        %imagesc(fr(xRange(1):xRange(2),yRange(1):yRange(2),1));
        subplot('position',[0.05,0.25,0.7,0.7])

        imagesc(video(:,:,idx));
        axis equal
        set(gca,'clim',[0,255]);
        colormap(gray);
        text(0,0,{['t=' num2str(time(idx))],['(' num2str(idx) ')' ]},'color','r','verticalAlign','top','fontsize',18)

        if going>0
            title(['Play (' num2str(going) 'frames/step)'])
        elseif going==0
            title('Pause')
        elseif going <0
            title(['Reverse (' num2str(-going) 'frames/step)'])
        end
        
        subplot('position',[0.05,0.05,0.7,0.15])
        hold off
        %showRange=[max([0,(vr.CurrentTime-10)]),min([vr.CurrentTime+10,vr.Duration])];
        %showTime=showRange(1):1/vr.FrameRate:showRange(2);
        %showIdx=round(showTime*vr.FrameRate+1);
        %plot(showTime,freezeFrames(showIdx))
        showIdx=max([1,idx-10*vr.FrameRate]):min([idx+10*vr.FrameRate,nFrame]);
        plot(time(showIdx),freezeFrames(showIdx),'b-');
        hold on
        %plot(vr.CurrentTime*[1,1],[-0.2,1.2])
        plot(time(idx)*[1,1],[-0.2,1.2],'r-')
        xlim(time(idx)+[-10,10])
        ylim([-0.2,1.2])
        title(['total ' num2str(time(end)) 's'])
        drawnow
    %end
    figure(fh);    
    switch fh.CurrentCharacter
        case 'B'
            %vr.CurrentTime=vr.CurrentTime-2/vr.FrameRate;
            idx=idx-2;
        case 'b'
            %vr.CurrentTime=vr.CurrentTime-10;
            idx=idx-10*vr.FrameRate;
        case 'S'
            %vr.CurrentTime=vr.CurrentTime+1/vr.FrameRate;
            idx=idx+1;
        case 's'
            %vr.CurrentTime=vr.CurrentTime+10;
            idx=idx+10*vr.FrameRate;
        case 'p'
            if going==0
                going=1;
            else
                going=0;
            end
            figure(fh);    
        case 'a'
            going=going+1;                        
        case 'd'
            going=going-1; 
        case 'A'
            going=going+10;                        
        case 'D'
            going=going-10; 
        case 'r'
            %going=-1;
            going=1;
        case 'e'
            break; 
        case 'f'
            %idx=round(vr.CurrentTime*vr.FrameRate+1);
            state=mod(freezeFrames(idx)+1,2);
            next=find(freezeFrames(idx:end)==state,1,'first');
            if isempty(next)
                next=length(freezeFrames); 
            else
                next=next+idx;
            end
            freezeFrames(idx:next)=state;
    end
    figure(fh);    
    fh.CurrentCharacter=' ';
end
close(fh)

ext=findstr(videoFile,'.');
saveFileCore=[videoFile(1:ext(end)-1) '_freeze'];
saveFileName=[saveFileCore '.mat'];
idx=0;

while exist(saveFileName,'file')
    idx=idx+1;
    saveFileName=[saveFileCore '-' num2str(idx) '.mat'];
end


madeby=mfilename;

save(saveFileName,'videoFile','imageRange','freezeFrames','time','madeby','-v7.3');
disp([datestr(now) 'Results saved in ' saveFileName])




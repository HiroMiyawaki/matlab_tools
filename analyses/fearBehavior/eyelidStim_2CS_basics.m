clear

videoFolderList={};
videofileList={};
for n=1:3
    switch n
        case 1
            dataDirRoot='~/data/OCU/eyelid_2CS/HR0025/';
        case 2
            dataDirRoot='~/data/OCU/eyelid_2CS/HR0026/';
        case 3
            dataDirRoot='~/data/OCU/eyelid_2CS/HR0027/';
        otherwise
            continue
    end
    temp=dir([dataDirRoot '*mp4']);
    videoFolderList={videoFolderList{:},temp.folder};
    videofileList={videofileList{:},temp.name};
end

%%
 analysesDataIdx=length(videofileList);
%   analysesDataIdx=[];

%%
imageRange={};
ledRange={};
for idx=analysesDataIdx
    
    nameCore=videofileList{idx}(1:end-4);
    dataDirRoot=videoFolderList{idx};
    if exist([dataDirRoot '/' nameCore '_freeze.mat'])
        prevData=load([dataDirRoot '/' nameCore '_freeze.mat']);
        imageRange{idx}=prevData.param.imageRange;
        prevData=load([dataDirRoot '/' nameCore '_ledBlink.mat']);
        ledRange{idx}=prevData.param.imageRange;
    else
        
        vr=VideoReader(fullfile(videoFolderList{idx},videofileList{idx}));
        temp=zeros(vr.Height,vr.Width,3,vr.FrameRate*10);
        for n=1:size(temp,4)
            temp(:,:,:,n)=readFrame(vr);
        end
        close all
        fh=figure('position',[200,1000,1280,960]);
        imagesc(mean(temp,4)/255);
        axis equal
        set(gca,'clim',[0,255]);
        colormap(gray);
        title('Select area to show')
        [y,x]=ginput(2);
        xRange=[floor(min(x)),ceil(max(x))];
        yRange=[floor(min(y)),ceil(max(y))];
        imageRange{idx}=[xRange,yRange];
        rectangle('position',[yRange(1),xRange(1),diff(yRange),diff(xRange)],'EdgeColor','b')
        
        title('Select LED area')
        ledPos=[];
        for n=1:5
            [y,x]=ginput(2);
            xRange=[floor(min(x)),ceil(max(x))];
            yRange=[floor(min(y)),ceil(max(y))];
            ledPos(n,:)=[xRange,yRange];
            rectangle('position',[yRange(1),xRange(1),diff(yRange),diff(xRange)],'EdgeColor','r')
            drawnow;
        end
        ledRange{idx}=ledPos;
    end
end



%%
for idx=analysesDataIdx
    freezeDetectionColor(fullfile(videoFolderList{idx},videofileList{idx}),imageRange{idx},100)
    ledReadFromColorVideo(fullfile(videoFolderList{idx},videofileList{idx}),ledRange{idx})
end

%%
clear
close all
ratNameList={'Rat HR0025','Rat HR0026','Rat HR0027'};
BehTypeList={'Conditioning','Cue & Extinction' 'Retention of Extinction'};

doAppend='';
savePdfName='~/data/OCU/eyelid_2CS/summary_each.ps'
for n=1:3
    figH=initFig4Nature(2);
    switch n
        case 1
            dataDirRoot='~/data/OCU/eyelid_2CS/HR0025/';
        case 2
            dataDirRoot='~/data/OCU/eyelid_2CS/HR0026/';
        case 3
            dataDirRoot='~/data/OCU/eyelid_2CS/HR0027/';
        otherwise
            continue
    end
    temp=dir([dataDirRoot '*mp4']);
    videofileList={temp.name};
    
    for fIdx=1:length(videofileList)
        nameCore=videofileList{fIdx}(1:end-4);
        freeze=load([dataDirRoot nameCore '_freeze.mat']);
        ledEvt=load([dataDirRoot nameCore '_ledBlink.mat']);
        clear event
        evtName={'clock','experiment','CS_puls','CS_minus','shock'};
        for ledIdx=1:size(ledEvt.ledVal,1)
%             [cnt,bin]=hist(ledEvt.ledVal(ledIdx,:),100);
%             [peaks,index]=findpeaks(cnt);
%             [~,id]=sort(peaks,'descend');
%             threshold=mean(bin(index(id(1:2))));
            r=zeros(1,255);
            val=ledEvt.ledVal(ledIdx,:);
            for idx= 1:length(r)                
                r(idx)=sum(val<idx)*sum(val>=idx)*(mean(val(val<idx))-mean(val(val>=idx)))^2;
            end
            [~,threshold]=max(r);


            event.(evtName{ledIdx})=hmSchmittTrigger(ledEvt.ledVal(ledIdx,:),threshold,threshold,ledEvt.ledVal(ledIdx,1)>threshold);
        end
        
        if fIdx>1
            event.shock=[];
        end
        
        frameOffset=event.experiment(1);
        if n<3&& fIdx==1
        evt=sortrows([event.CS_puls,1*ones(size(event.CS_puls,1),1);
            event.CS_minus,2*ones(size(event.CS_minus,1),1);
            event.CS_puls(:,1)+50*ledEvt.param.frameRate,event.CS_puls(:,1)+52*ledEvt.param.frameRate,3*ones(size(event.CS_puls,1),1)]);
        else
        evt=sortrows([event.CS_puls,1*ones(size(event.CS_puls,1),1);
            event.CS_minus,2*ones(size(event.CS_minus,1),1);
            event.shock,3*ones(size(event.shock,1),1)]);
        end
        evt(:,1:2)=evt(:,1:2)-frameOffset;
        evt(:,1:2)=evt(:,1:2)/ledEvt.param.frameRate;
        
        col=[0,0.7,0;0,0,1;1,0,0,];
        
        
        t=((event.experiment(1):event.experiment(2))-frameOffset)/ledEvt.param.frameRate/60;
        movement=freeze.change(event.experiment(1):event.experiment(2));
        movement=medfilt1(movement,3);
        logMv=log10(movement+1);
        logMv(isnan(logMv)|isinf(logMv))=[];
        
        r=zeros(1,1000);
        for idx= 1:length(r)
            logTh=log10(idx+1);
            r(idx)=sum(logMv<logTh)*sum(logMv>=logTh)*(mean(logMv(logMv<logTh))-mean(logMv(logMv>=logTh)))^2;
        end
        [~,moveThreshold]=max(r);
        
        moveThreshold=moveThreshold+20;
        
        fz=(movement<moveThreshold);
        
        onset=find(diff(fz)==1)+1;
        offset=find(diff(fz)==-1);
        
        if offset(1)<onset(1); onset=[1,onset]; end
        if offset(end)<onset(end); offset(end+1)=diff(event.experiment); end
        
        frz=removeTransient([onset',offset'],1,5*freeze.param.frameRate);
        frz=(frz+event.experiment(1)-frameOffset)/freeze.param.frameRate/60;
        
        %         frz=(freeze.freeze)/freeze.param.frameRate/60;
        
        [cnt,bin]=hist(movement,1000);
        yRange(1)=0;
        yRange(2)=bin(find(cumsum(cnt)/sum(cnt)>0.99,1,'first'));
        
        for rep=1:(4-2*(fIdx>2))
            subplot(12,1,5*(fIdx-1)+rep)
            for evtIdx=1:size(evt,1)
                rectangle('position',[evt(evtIdx,1)/60,0,diff(evt(evtIdx,1:2))/60,yRange(2)],...
                    'linestyle','none','facecolor',col(evt(evtIdx,3),:))
            end
            hold on
            
            plot(t,movement,'-','color',(fIdx-1)/3*[1,1,1],'linewidth',0.1)
            plot(t([1,end]),freeze.param.moveThreshold*[1,1],'y-')
            ylim(yRange)
            
            for frzIdx=1:size(frz,1)
                rectangle('position',[frz(frzIdx,1),yRange(2)*0.9,diff(frz(frzIdx,:)),yRange(2)*0.1],...
                    'linestyle','none','facecolor',[1,0.8,0])
            end
            
            xlim((rep-1)*15+[0,15])
            ax=fixAxis;
            if rep==1
                title(BehTypeList{fIdx})
                if fIdx==1
                   text2(-0.05,1.1,ratNameList{n},ax,{'fontsize',14,'verticalAlign','bottom','horizontalAlign','left'})
                end                
            end
            ylabel({'Movement' '(Pic/Frame)'})
        end
        xlabel('Time (min)')
        
        
        
    end
    addScriptName(mfilename)
    print(savePdfName,'-dpsc','-painters',doAppend)
    doAppend='-append';
    
end

%%







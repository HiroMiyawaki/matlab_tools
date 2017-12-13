clear

saveDir='~/data/OCU/eyelid_behavior/'
showDur=2000;
close all
fh=initFig4Nature(2);

for animalIdx=1:3
    
    switch animalIdx
        case 1
            dataDir='~/data/OCU/eyelid_behavior/HR0019/';
            sampleRate=20e3;
            ttlDataList={'2017-07-14_08-11-59-ttlEvent.mat','2017-07-14_13-26-53-ttlEvent.mat'};
            freezeDataList={'HR0019_2017-07-14-081152-0000_freeze.mat','HR0019_2017-07-14-132646-0000_freeze.mat'};
            
            sesName={'Baseline','Cue retention'};
            evtName={'CS+ (12KHz)','CS- (4KHz)','Shock'};
            behName={'Base (Square)','Retention (Circle)'};
            ratName='0019';
        case 2
            dataDir='~/data/OCU/eyelid_behavior/HR0020/';
            sampleRate=20e3;
            ttlDataList={'2017-07-18_08-03-10-ttlEvent.mat','2017-07-18_13-22-36-ttlEvent.mat'};
            freezeDataList={'HR0020_2017-07-18-080318-0000_freeze.mat','HR0020_2017-07-18-132244-0000_freeze.mat'};
            sesName={'Baseline','Cue retention'};
            evtName={'CS+ (12KHz)','CS- (4KHz)','Shock'}
            behName={'Base (Circle)','Retention (Square)'};
            ratName='0020';
        case 3
            dataDir='~/data/OCU/eyelid_behavior/HR0021/';
            sampleRate=20e3;
            ttlDataList={'2017-07-20_08-07-02-ttlEvent.mat','2017-07-20_13-13-04-ttlEvent.mat'};
            freezeDataList={'HR0021_2017-07-20-080712-0000_freeze.mat','HR0021_2017-07-20-131313-0000_freeze.mat'};
            sesName={'Baseline','Cue retention'};
            evtName={'CS+ (4KHz)','CS- (12KHz)','Shock'};
            behName={'Base (Square)','Retention (Circle)'} ;           
            ratName='0021';
    end
    
    for behSes=1:length(ttlDataList)
        
        ttlData=ttlDataList{behSes};
        freezeData=freezeDataList{behSes};
        
        freeze=load([dataDir freezeData]);
        ttl=load([dataDir ttlData]);
        nFrame=freeze.param.nProcessFrame;
        if animalIdx==1 && behSes==1
            t=ttl.ttlEvent.cameraShutter(:,1)/sampleRate;
        else
            t=ttl.ttlEvent.cameraTrigger(1:nFrame,1)/sampleRate;
        end
        t(t>t(1)+showDur)=[];
        move=freeze.change(1:length(t));
        
        evt=[];
        evtList={'tone1','tone2','shockTrigger'};
        for idx=1:length(evtList)
            evt=[evt;ttl.ttlEvent.(evtList{idx})/sampleRate,idx*ones(size(ttl.ttlEvent.(evtList{idx}),1),1)];
        end
        
        evt(:,1:2)=evt(:,1:2)-t(1);
        t=t-t(1);
        
        evt(evt(:,2)>t(end),:)=[];
        evt=sortrows(evt);
        
        [cnt,bin]=hist(move,1000);
        yMax=round(bin(find(cumsum(cnt)/sum(cnt)>0.99,1,'first')));
        
        col=[0,0.8,0;
            0,0.3,1;
            1,0,0]
        subplot2(8,1,3*(animalIdx-1)+behSes,1)
        for idx=1:size(evt,1)
            rectangle('position',[evt(idx,1),0,diff(evt(idx,1:2)),yMax],...
                'lineStyle','none','faceColor',col(evt(idx,3),:))
        end
        
        ylim([0,yMax])
        hold on
        lineCol=[0.5*[1,1,1];
                    0,0,0];
        plot(t,move,'-','linewidth',0.25,'color',lineCol(behSes,:))
        plot(t([1,end]),freeze.param.moveThreshold*[1,1],'y-')
        title(['Rat' ratName ' ' sesName{behSes}])
        xlabel('Time (sec)')
        ylabel('Movement (px/frame)')
        ax=fixAxis;
        legend=[];
        if behSes==1
            for idx=1:length(evtName)
                legend=[legend,'\color[rgb]{' num2str(col(idx,:)) '}' evtName{idx} '  '];
            end
            for idx=1:length(behName)
                legend=[legend,'\color[rgb]{' num2str(lineCol(idx,:)) '}' behName{idx}  '  '];
            end
            text2(1,1,legend,ax,{'horizontalAlign','right','verticalAlign','bottom'})
        end
    end
end
addScriptName(mfilename);
print(fh,[saveDir 'eyelidStim_summary1.pdf'],'-dpdf')

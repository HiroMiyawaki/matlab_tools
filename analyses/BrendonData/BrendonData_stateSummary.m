clear
clc

rootDir='~/data/Brendon/';
coreName='Brendon';

dList=dir(rootDir);

dList={dList([dList.isdir]).name};

dList(strcmp(dList,'.') | strcmp(dList,'..') )=[];
%%
close all
nRaw=8;
psFileName=fullfile(rootDir, 'state_in_WSRestrictedIntervals.ps');
doAppend='';
for dIdx=1:length(dList)
    
    if mod(dIdx,nRaw)==1
        if dIdx~=1
            addScriptName(mfilename)
            print(fh,psFileName,doAppend,'-painters','-dpsc')
            doAppend='-append';
        end
        fh=initFig4Nature(2);
    end
    subplot(nRaw,1,mod(dIdx-1,nRaw)+1)
    
    dataName=dList{dIdx};

    nameCore=['~/data/Brendon/' dataName '/' dataName];

    state=load([nameCore '_WSRestrictedIntervals.mat'])

    stateList=fieldnames(state);
    stateList(~contains(stateList,'TimePairFormat'))=[];
    
    col.REMEpisodeTimePairFormat=[1,0,0];
    col.REMTimePairFormat=[0.7,0,0];
    col.SWSEpisodeTimePairFormat=[0,0.8,0];
    col.SWSPacketTimePairFormat=[0,1,0];
    col.MATimePairFormat=[0.8,0.8,0];
    col.WakeInterruptionTimePairFormat=[0,0,0];
    col.WakeTimePairFormat=[1,0,1];
    col.SleepTimePairFormat=[0,0,1];
    col.WakeSleepTimePairFormat=0.5*[1,1,1;0,0,0];
    
    idx.WakeSleepTimePairFormat=8;
    idx.WakeTimePairFormat=7;
    idx.SleepTimePairFormat=6;
    idx.REMEpisodeTimePairFormat=5;
    idx.SWSEpisodeTimePairFormat=4;
    idx.REMTimePairFormat=3;
    idx.WakeInterruptionTimePairFormat=2;
    idx.MATimePairFormat=1;
    idx.SWSPacketTimePairFormat=0;
    
    list=[];
    colList=[];
    yLabelText={};
    for sIdx=1:length(stateList)
        stateName=stateList{sIdx};
        
        if strcmpi(stateName,'WakeSleepTimePairFormat')
            for cnt=1:length(state.(stateName))
                list=[list;[state.(stateName){cnt},idx.WakeSleepTimePairFormat*[1;1],idx.WakeSleepTimePairFormat+[0;1]]];
            end
            colList(idx.(stateName)+(1:2),:)=col.(stateName);
        else 
            list=[list;[state.(stateName),idx.(stateName)*ones(size(state.(stateName),1),2)]];
            colList(idx.(stateName)+1,:)=col.(stateName);
        end
%             yLabelText{idx.(stateName)+1}=
    end

    for lIdx=1:size(list,1)
        rectangle('position',[list(lIdx,1),list(lIdx,3),diff(list(lIdx,1:2)),1],'facecolor',colList(list(lIdx,4)+1,:),'edgecolor','none')
    end
    ylim([0,length(stateList)])
    set(gca,'YTick',(1:length(yLabelText))-0.5,'YTickLabel','')
    for sIdx=1:length(stateList)
        stateName=stateList{sIdx};
        text(0,idx.(stateName)+0.5,stateName(1:end-length('TimePairFormat')),...
            'color',col.(stateName)(1,:),'horizontalAlign','right');
    end
    
    title(dataName,'Interpreter','none')
    xlabel('Time (s)')
    


end
if mod(dIdx,nRaw)~=0
    addScriptName(mfilename)
    print(fh,psFileName,doAppend,'-painters','-dpsc')
end
ps2pdf(psFileName,'remove',true)
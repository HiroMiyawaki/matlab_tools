% for dIdx=1:length(dList)
dIdx=0;
%% 
 dIdx=dIdx+1;

clf
    dataName=dList{dIdx};

    nameCore=['~/data/Brendon/' dataName '/' dataName];
    

    load([nameCore '_WSRestrictedIntervals.mat'])

%     temp=load([nameCore '-states.mat'])
    temp=load([nameCore '.SleepState.states.mat'])

%     idx=find(diff(temp.states)~=0);
%     
%     state=[[1,idx+1]',[idx,length(temp.states)]']
%    
%     state=[state,temp.states(1,state(:,1))'];  
state=[];
    sNames=fieldnames(temp.SleepState.ints);
    for idx=1:length(sNames)
        sName=sNames{idx};
        if contains(sName,'state')
            target=temp.SleepState.ints.(sName);
            
            if contains(sName,'NREM')
                sIdx=3;
            elseif contains(sName,'REM')
                sIdx=5;
                
            elseif contains(sName,'WAKE')
                sIdx=1;
            elseif contains(sName,'MA')
                sIdx=2;
            else
                continue
            end
            sName
            state=[state;[target,sIdx*ones(size(target,1),1)]];
        end
    end
    
    state=sortrows(state);

    temp=mergePeriod(REMEpisodeTimePairFormat+0.5*[-1,1],SleepTimePairFormat+0.5*[-1,1]);
    
    episodes=sortrows([REMEpisodeTimePairFormat,5*ones(size(REMEpisodeTimePairFormat,1),1);...
                    SWSEpisodeTimePairFormat,3*ones(size(SWSEpisodeTimePairFormat,1),1);...
                    WakeTimePairFormat,1*ones(size(WakeTimePairFormat,1),1);...
                    SleepTimePairFormat,6*ones(size(SleepTimePairFormat,1),1)]);

%     temp1=mergePeriod(SleepTimePairFormat+0.5*[-1,1], SWSPacketTimePairFormat+0.5*[-1,1]);
%     temp2=mergePeriod(SleepTimePairFormat+0.5*[-1,1], MATimePairFormat+0.5*[-1,1]);
%     temp3=mergePeriod(SleepTimePairFormat+0.5*[-1,1], WakeInterruptionTimePairFormat+0.5*[-1,1]);

    packets=sortrows([SWSPacketTimePairFormat,3*ones(size(SWSPacketTimePairFormat,1),1);...
                    MATimePairFormat,2*ones(size(MATimePairFormat,1),1);...
                    WakeInterruptionTimePairFormat,4*ones(size(WakeInterruptionTimePairFormat,1),1);...
                    REMEpisodeTimePairFormat,5*ones(size(REMEpisodeTimePairFormat,1),1);...
                    WakeTimePairFormat,1*ones(size(WakeTimePairFormat,1),1)]);                    
% 1 - wake
% 2- microarousal
% 3- NREM
% 4- unused (Intermediate sleep if you see it, basically NREM)
% 5- REM

    xRange=[
    min([state(state(:,3)~=0&state(:,3)~=2,1);packets(packets(:,3)~=2&packets(:,3)~=4,1)])-100
    max([state(state(:,3)~=0&state(:,3)~=2,1);packets(packets(:,3)~=2&packets(:,3)~=4,1)])+100];

    col=[hsv(5);0,0,0];
    subplot(3,1,1)
    for idx=1:size(state,1)
        if state(idx,3)~=0
        rectangle('position',[state(idx,1),state(idx,3),diff(state(idx,1:2)),1],...
            'edgecolor','none','facecolor',col(state(idx,3),:))
        end
    end
    xlim(xRange)
     ylim([1,7])
   title(dataName)
    subplot(3,1,3)
    for idx=1:size(episodes,1)
        if episodes(idx,3)~=0
        rectangle('position',[episodes(idx,1),episodes(idx,3),diff(episodes(idx,1:2)),1],...
            'edgecolor','none','facecolor',col(episodes(idx,3),:))
        end
    end 
    xlim(xRange)
    ylim([1,7])
       
    subplot(3,1,2)
    for idx=1:size(packets,1)
        if packets(idx,3)~=0
        rectangle('position',[packets(idx,1),packets(idx,3),diff(packets(idx,1:2)),1],...
            'edgecolor','none','facecolor',col(packets(idx,3),:))
        end
    end  
    xlim(xRange)
     ylim([1,7])
 
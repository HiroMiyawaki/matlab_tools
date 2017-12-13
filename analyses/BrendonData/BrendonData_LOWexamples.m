clear
clc

rootDir='~/data/Brendon/';
coreName='Brendon';

dList=dir(rootDir);

dList={dList([dList.isdir]).name};

dList(strcmp(dList,'.') | strcmp(dList,'..') )=[];

% %%
% close all
% FrameSize=300;
% cnt=0;
% nRow=8;
% fh=initFig4Nature(2);
% doAppend='';
% psFileName=[rootDir 'LOW-allList.ps'];
% 
% for dIdx=1:length(dList)
%     dataName=dList{dIdx};
%     nameCore=['~/data/Brendon/' dataName '/' dataName];
%     
%     disp([datestr(now),' start ' dataName '(' num2str(dIdx) '/' num2str(length(dList)) ')'])
%     
%     spec=load([nameCore '-fineEegSpec.mat']);
%     
%     state=load([nameCore '_WSRestrictedIntervals.mat']);
%     
%     load([nameCore '-low.mat']);
%     
%     temp=log(spec.Pxx(:));
%     clim=mean(temp)+std(temp)*[-1,3];
%     
%     for sIdx=1:length(state.WakeSleepTimePairFormat)
%         
%         tRange=state.WakeSleepTimePairFormat{sIdx}(2,:);
%         tRange=tRange+[-50,50];
%         
%         tBorders=tRange(1):FrameSize:tRange(2);
%         tBorders=[tBorders(1:end-1);tBorders(2:end)]';
%         
%         for tIdx=1:size(tBorders,1)
%             
%             cnt=mod(cnt,nRow)+1;
%             
%             subplot(nRow,1,cnt)
%             imagescXY(spec.t(spec.t>tBorders(tIdx,1)&spec.t<tBorders(tIdx,2)),spec.f,log(spec.Pxx(spec.t>tBorders(tIdx,1)&spec.t<tBorders(tIdx,2),:)));
%             colormap(jet)
%             set(gca,'clim',clim)
%             
%             for bType=1:5
%                 
%                 switch bType
%                     case 3
%                         temp=state.REMEpisodeTimePairFormat;
%                         col=[1,0,0];
%                         pos=1;
%                     case 1
%                         temp=state.SWSPacketTimePairFormat;
%                         col=[0,0,1];
%                         pos=1;
%                     case 2
%                         temp=state.MATimePairFormat;
%                         col=[1,0.8,0];
%                         pos=1;
%                     case 4
%                         temp=state.WakeTimePairFormat;
%                         col=[0,0,0];
%                         pos=1;
%                         
%                     case 5
%                         temp=low;
%                         col=[0.8,0,1];
%                         pos=1.1;
%                 end
%                 
%                 temp(temp(:,2)<tBorders(tIdx,1),:)=[];
%                 temp(temp(:,1)>tBorders(tIdx,2),:)=[];
%                 if ~isempty(temp) && temp(1,1)<tBorders(tIdx,1); temp(1,1)=tBorders(tIdx,1); end
%                 if ~isempty(temp) && temp(end,2)>tBorders(tIdx,2); temp(end,2)=tBorders(tIdx,2); end
%                 
%                 for n=1:size(temp,1)
%                     rectangle('position',[temp(n,1),[1-pos,pos]*spec.f([1,end]),diff(temp(n,:)),diff(spec.f([1,end]))/10],'facecolor',col,'edgecolor','none')
%                 end
%                 
%                 ylim([spec.f(1),[-0.2,1.2]*spec.f([1,end])])
%                 box off
%                 title(dataName,'interpreter','none')
%                 
%             end
%             
%             if cnt==nRow
%                 addScriptName(mfilename);
%                 print(fh,psFileName,'-dpsc','-painters',doAppend)
%                 doAppend='-append';
%             end
%             
%         end
%     end
% end
% 
% if cnt==nRow
%     addScriptName(mfilename);
%     print(fh,psFileName,'-dpsc','-painters',doAppend)
%     doAppend='-append';
% end
% 
% ps2pdf(psFileName,'remove',true)


%%
close all
fh=initFig4Nature(2);

nExample=5;
nRow=4*nExample;
dur=600;
for cnt=1:nExample;

    switch cnt
        case 1
%             dataName='Templeton_032415';
%             tRange=7000+[0,dur];
%             clim=[7.75,10.5];
            dataName='BWRat20_101013';
            tRange=9100+[0,dur];
            clim=[6.5,10];
            
        case 2
%             dataName='Splinter_020515';
%             tRange=8600+[0,dur];
%             clim=[6,10]; 
            dataName='BWRat21_121813';
            tRange=3400+[0,dur];
            clim=[7.5,11];
        case 3
            dataName='Dino_061914_ACC';
            tRange=11750+[0,dur];
            clim=[7,10.5];
        case 4
            dataName='20140528_565um';
            tRange=8000+[0,dur];
            clim=[8.75,12.25];
        case 5
            dataName='BWRat21_121813';
            tRange=12900+[0,dur];
            clim=[7,11];
            

        otherwise
            continue
    end
    
nameCore=['~/data/Brendon/' dataName '/' dataName];

spec=load([nameCore '-fineEegSpec.mat']);
state=load([nameCore '_WSRestrictedIntervals.mat']);
load([nameCore '-low.mat']);
load([nameCore    '_EMGCorr.mat'])




subplot(nRow,1,4*cnt-[3,2])
imagescXY(spec.t(spec.t>tRange(1)&spec.t<tRange(2)),spec.f,log(spec.Pxx(spec.t>tRange(1)&spec.t<tRange(2),:)));
colormap(jet)
set(gca,'clim',clim)

for bType=1:5
    
    switch bType
        case 3
            temp=state.REMEpisodeTimePairFormat;
            col=[1,0,0];
            pos=1;
        case 1
            temp=state.SWSPacketTimePairFormat;
            col=[0,0,1];
            pos=1;
        case 2
            temp=state.MATimePairFormat;
            col=[1,0.8,0];
            pos=1;
        case 4
            temp=state.WakeTimePairFormat;
            col=[0,0,0];
            pos=1;
            
        case 5
            temp=low;
            col=[0.8,0,1];
            pos=1.1;
    end
    
    temp(temp(:,2)<tRange(1),:)=[];
    temp(temp(:,1)>tRange(2),:)=[];
    if ~isempty(temp) && temp(1,1)<tRange(1); temp(1,1)=tRange(1); end
    if ~isempty(temp) && temp(end,2)>tRange(2); temp(end,2)=tRange(2); end
    
    for n=1:size(temp,1)
        rectangle('position',[temp(n,1),[1-pos,pos]*spec.f([1,end]),diff(temp(n,:)),diff(spec.f([1,end]))/10],'facecolor',col,'edgecolor','none')
    end
    
    ylim([spec.f(1),[-0.2,1.2]*spec.f([1,end])])
end
box off
ylabel('Freq  (Hz)')
title(dataName,'interpreter','none')
ax=fixAxis;
subplot(nRow,1,4*cnt-1)
temp=EMGCorr(EMGCorr(:,1)>tRange(1)&EMGCorr(:,1)<tRange(2),:);
plot(temp(:,1),temp(:,2),'k-')
box off
xlim(ax(1:2))
ylim([-0.2,1])
ylabel('Corr EMG')
xlabel('Time (s)')
end
addScriptName(mfilename)
print(fh,[rootDir 'LOW_examples.pdf'],'-dpdf','-painters')
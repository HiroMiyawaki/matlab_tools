clear
% baseDir='/Volumes/RAID_HDD/sleep/pooled/';
% baseDir='~/data/sleep/pooled/';
baseDir='~/data/sleep/pooled_withCohEMG/';
coreName='sleep';

varList={'basics'
    'behavior'
    ...'ripple'
    ...'spindle'
    ...'hpcSpindlePhase'
    ...'ctxSpindlePhase'
    ...'HL'
    ...'HLwavelet'
    ...'HLfine'
    ...'onOff'
    ...'hpcSWA'
    ...'pfcSWA'
    ...'recStart'
    ...'position'
    ...'speed'
    ...'spectrum'
    'spikes'
    ...'modulatedCell'
    ...thetaPhase'
    ...'pfcEeg'
    ...'emg'
    ...'firing'
    ...'eventRate'
    ...'stableSleep'
    ...'stableWake'
    'stateChange20s'
    ...'trisecFiring'
    ...'binnedFiring'
    ...'thetaBand'
    ...'sleepPeriod'
    ...'recStart'
    ...'deltaBand'
    ...'thetaBand'
    ...'pairCorr'
    ...'pairCorrHIGH'
    }';

for varName=varList
    load([baseDir coreName '-' varName{1} '.mat'])
end

% HL=HLfine;
dList=fieldnames(basics);
%%
tBinSize=1e6;

dIdx=1;
dName=dList{dIdx};

idx=stateChange.(dName).rem2nrem;

temp=median(diff(behavior.(dName).list(idx(:,1),1:2),1,2));
[~,sIdxList(1)]=min(abs(diff(behavior.(dName).list(idx(:,1),1:2),1,2)-temp));
dist.adaptive=[];
dist.pilot=[];
dist.cnt=[];

for sIdx=1:size(idx,1)
    tRange=behavior.(dName).list(idx(sIdx,1),1:2);
    
    tBin=-flip(-tRange(2)-tBinSize/2:tBinSize:-tRange(1)+tBinSize/2);
    
    spk=spikes.(dName)([spikes.(dName).quality]==1 & cellfun(@all,{spikes.(dName).isStable}));
    [~,order]=sort(cellfun(@length,{spk.time}));
    spk=spk(order);
    
    clear cnt pilot adaptive
    raster=[];
    for cIdx=1:length(spk);
        
        subSpk=spk(cIdx).time(spk(cIdx).time>tRange(1)&spk(cIdx).time<tRange(2));
        raster=[raster;subSpk',cIdx*ones(size(subSpk'))];
        temp=hist(subSpk,tBin);
        cnt(cIdx,:)=temp(2:end-1);
        
        
        milCnt=hist(subSpk,tBin(1)+tBinSize/2-1e3/2:1e3:tBin(end)-tBinSize/2+1e3/2);
        
        smoothSD=1000;
        smoothCore=normpdf(-3*smoothSD:3*smoothSD,0,smoothSD);
        temp=conv(milCnt,smoothCore,'same');
        
        winWidth=smoothSD./sqrt(temp/geomean(temp(temp>0)));
        
        pilot(cIdx,:)=sum(reshape(temp(2:end-1),1000,[]));
        
        temp=zeros(size(milCnt));
        
        for n=find(milCnt>0)
            temp=temp+ milCnt(n) * normpdf(1:size(milCnt,2),n,winWidth(n));
        end
        
        adaptive(cIdx,:)=sum(reshape(temp(2:end-1),1000,[]));
        
    end
    tBin=tBin(2:end-1)/1e6;
    raster(:,1)=raster(:,1)/1e6;
    raster(raster(:,1)<tBin(1),:)=[];
    raster(raster(:,1)>tBin(end),:)=[];
    
    dist.adaptive=[dist.adaptive;mean(adaptive(:,(-floor(size(tBin,2)/10):0)+end),2)];
    dist.pilot=[dist.pilot;mean(pilot(:,(-floor(size(tBin,2)/10):0)+end),2)];
    dist.cnt=[dist.cnt;mean(cnt(:,(-floor(size(tBin,2)/10):0)+end),2)];
end


%%
sum(dist.cnt==0)
sum(dist.pilot(:)==0)
sum(dist.adaptive==0)


%%


col=jet(length(spk));

set(groot,'defaultAxesColorOrder',col)
ax(1)=subplot(4,1,1);
scatter(raster(:,1)-tBin(1),raster(:,2),1,col(raster(:,2),:))
xlabel('Time (sec)')
ylabel('Cell')
box off

ax(2)=subplot(4,1,2);
plot(tBin-tBin(1),cnt')
title(sprintf('Spike count (%d sec bin)',tBinSize/1e6))
xlabel('Time (sec)')
ylabel('Spike count/sec')
box off

ax(3)=subplot(4,1,3);
plot(tBin-tBin(1),pilot')
title(sprintf('Pilot estimation (smoothing SD=%d sec)',smoothSD/1e3))
xlabel('Time (sec)')
ylabel('Spike density')
box off

ax(4)=subplot(4,1,4);
plot(tBin-tBin(1),adaptive')
title('Adaptive estimation')
xlabel('Time (sec)')
ylabel('Spike density')
box off

linkaxes(ax,'x')



clear
baseDir='~/data/sleep/pooled/';
coreName='sleep';

varList={'basics'
    'behavior'
    'ripple'
    ...'spindle'
    ...'hpcSpindlePhase'
    ...'ctxSpindlePhase'
    ...'HL'
    'HLfine'
    ...'HLbySpike'
    ...'onOff'
    ...'hpcSWA'
    ...'pfcSWA'
    ...'recStart'
    ...'position'
    ...'speed'
    ...'spectrum'
    ...'slowSilent'
    ...'spikes'
    ...'modulatedCell'
    ...thetaPhase'
    ...'pfcEeg'
    ...'emg'
    ...'firing'
    ...'eventFiring'
    ...'LowModulation'
    ...'eventRate'
    'stableSleep'
    ...'stableWake'
    'stateChange'
    ...'LowModulation'
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

dList=fieldnames(basics);
HL=HLfine;

%%
typeList={'short','middle','long'};
for tIdx=1:length(typeList);
    nextState.(typeList{tIdx})=[0,0,0];
end
for dIdx=1:length(dList)
    dName=dList{dIdx};
    display([datestr(now) '  ' dName])
    
    nrem=behavior.(dName).list(stateChange.(dName).nrem,1:2);
    
    
    temp=mergePeriod(nrem,HL.(dName).low,behavior.(dName).time(1),behavior.(dName).time(2));
    low=temp{2,2};
    
    low=removeTransient(low,HLfine.(dName).param.minIEI*1e6,HLfine.(dName).param.minDur*1e6);
    
    
    lowDurRank=tiedrank(diff(low,1,2))/size(low,1);
    
    
    for tIdx=1:length(typeList);
        subLow=low(lowDurRank>(tIdx-1)/length(typeList) & ...
            lowDurRank<=(tIdx)/length(typeList),:);
        for lIdx=1:size(subLow,1)
            nextIdx=find(behavior.(dName).list(:,1)>=subLow(lIdx,2),1,'first');
            
            if behavior.(dName).list(nextIdx,1)==subLow(lIdx,2)
                nextType=behavior.(dName).list(nextIdx,3);
            else
                nextType=1;
            end
            if nextType==4; nextType=3; end
            nextState.(typeList{tIdx})(nextType)=nextState.(typeList{tIdx})(nextType)+1;
        end
    end
end
%%
for tIdx=1:length(typeList);
    temp=nextState.(typeList{tIdx})(3)/sum(nextState.(typeList{tIdx}))*100;
    display([typeList{tIdx} ':' num2str(temp,3) '%'])    
end








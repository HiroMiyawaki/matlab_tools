clear
% baseDir='~/data/sleep/pooled/';
baseDir='~/data/sleep/pooled_withCohEMG/';
coreName='sleep';

varList={'basics'
    'behavior'
    'detailedBehavior'
    'MA'
    ...'ripple'
    ...'spindle'
    ...'hpcSpindlePhase'
    ...'ctxSpindlePhase'
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
    'firing'
    ...'eventRate'
    ...'eventFiring'
    ...'stableSleep'
    ...'stableWake'
    'stateChange'
    ...'firing1secBin'
    ...'trisecFiring'
    ...'trisecEvent'
    ...'binnedFiring'
    ...'thetaBand'
    ...'recStart'
    ...'deltaBand'
    ...'thetaBand'
    }';

for varName=varList
    load([baseDir coreName '-' varName{1} '.mat'])
end
dList=fieldnames(basics);
%HL=HLfine;

%%
FRinSlidingWindow=struct;
% if FileExists([baseDir coreName '-' 'FRinSlidingWindow' '.mat'])
%     load([baseDir coreName '-' 'FRinSlidingWindow' '.mat'])
% end

for dIdx=1:length(dList);
    dName=dList{dIdx};
    
    if isfield(FRinSlidingWindow,dName)
        display([datestr(now) ' ' dName ' is already done.'])
        continue
    end
    
    lfp=matfile([basics.(dName).filename '-fineEegSpec.mat']);
    
    windowWidth=2^round(log2(1*basics.(dName).lfpSampleRate))/basics.(dName).lfpSampleRate;
    onset=lfp.t;
    
    onset(onset<behavior.(dName).time(1))=[];
    onset(onset+windowWidth*1e6>behavior.(dName).time(2))=[];
    
    offset=onset+windowWidth*1e6;
    
    
    
    unit.pyr=spikes.(dName)(ismember([spikes.(dName).quality],[1:3]) & [spikes.(dName).isoDist]>15);
    unit.inh=spikes.(dName)(ismember([spikes.(dName).quality],[8]) & [spikes.(dName).isoDist]>15);
    unit.mult=spikes.(dName)(ismember([spikes.(dName).quality],[1:3,8]) & [spikes.(dName).isoDist]<=15);
    
    subsetRange=0:3600:length(onset);
    if subsetRange(end)<length(onset); subsetRange(end+1)=length(onset); end
    
    subsetRange=[subsetRange(1:end-1)+1
        subsetRange(2:end)]';
    
    unitTypeList=fieldnames(unit);
    
    unitCnt=0;
    totUnit=length(unit.pyr)+length(unit.inh)+length(unit.mult);
    
    for unitTypeIdx=1:length(unitTypeList)
        unitType=unitTypeList{unitTypeIdx};
        
        for unitIdx=1:length(unit.(unitType));
            display([datestr(now) ' ' dName  ': processing unit ' num2str(unitCnt+1) '/' num2str(totUnit)])
            spk=unit.(unitType)(unitIdx).time;
            rate=nan*ones(size(onset'));
            for subIdx=1:size(subsetRange,1)
                tRange=[onset(subsetRange(subIdx,1)),offset(subsetRange(subIdx,2))];
                fst=find(spk>=tRange(1),1,'first');
                lst=find(spk<=tRange(2),1,'last');
                subSpk=spk(fst:lst);
                
                for idx=subsetRange(subIdx,1):subsetRange(subIdx,2)
                    rate(idx)=sum(subSpk>=onset(idx)&subSpk<offset(idx))/windowWidth;
                end
            end
            unitCnt=unitCnt+1;
            
            FRinSlidingWindow.(dName).rate(unitCnt,:)=rate;
            FRinSlidingWindow.(dName).percent(unitCnt,:)=...
                rate/unit.(unitType)(unitIdx).meanF*100;
            FRinSlidingWindow.(dName).z(unitCnt,:)=...
                (rate-unit.(unitType)(unitIdx).meanF)*unit.(unitType)(unitIdx).stdF;
            FRinSlidingWindow.(dName).cellType(unitCnt,1)=unitTypeIdx;
            FRinSlidingWindow.(dName).id(unitCnt,:)=unit.(unitType)(unitIdx).id;
        end
    end
    FRinSlidingWindow.(dName).cellTypeList=unitTypeList;
    
    %%
    behList=[];
    display([datestr(now) ' ' dName  ': getting behavior type'])
    for behType=1:6
        
        switch behType
            case 1
                idxGrp=1;
                behName='nrem';
            case 2
                idxGrp=2;
                behName='low';
            case 3
                idxGrp=3;
                behName='rem';
            case 4
                idxGrp=[4,5];
                behName='ma';
            case 5
                idxGrp=[6,7];
                behName='quiet';
            case 6
                idxGrp=8;
                behName='active';
        end
        behId=detailedBehavior.(dName).list(ismember(detailedBehavior.(dName).list(:,3),idxGrp),1:2);
        behId=removeTransient(behId,eps,eps);
        
        behList=[behList;[behId,behType*ones(size(behId,1),1)]];
        behNameList{behType}=behName;
    end
    behList=sortrows(behList,1);
    
    
    behId=nan*zeros(1,length(onset)-1);
    for subIdx=1:size(subsetRange,1)
        timeWindow=[onset(subsetRange(subIdx,1)),offset(subsetRange(subIdx,2))];;
        
        fst=find(behList(:,2)>=timeWindow(1),1,'first');
        lst=find(behList(:,1)<=timeWindow(2),1,'last');
        subList=behList(fst:lst,:);
        
        for idx=subsetRange(subIdx,1):subsetRange(subIdx,2)
            begIdx=find(subList(:,1)<=onset(idx),1,'last');
            if isempty(begIdx); begIdx=1; end
            
            endIdx=find(subList(:,1)<=offset(idx),1,'last');
            if isempty(endIdx); endIdx=1; end
            
            if begIdx==endIdx
                behId(idx)=subList(begIdx,3);
            else
                inBin=subList(begIdx:endIdx,:);
                if inBin(1,1)<onset(idx); inBin(1,1)=onset(idx); end
                if inBin(end,2)>offset(idx); inBin(end,2)=offset(idx); end
                [~,maxIdx]=max(diff(inBin(:,1:2),1,2));
                behId(idx)=inBin(maxIdx,3);
            end
        end
    end
    
    
    FRinSlidingWindow.(dName).t=(onset+offset)/2;
    FRinSlidingWindow.(dName).behType=behId;
    FRinSlidingWindow.(dName).behTypeList=behNameList;
    
    param.windowSize=windowWidth*1e6;
    param.stepSize=median(diff(onset));
    param.madeby=mfilename;
    
    FRinSlidingWindow.(dName).param=param;
    
    
    display([datestr(now) ' ' dName ': saving to the file'])
    save([baseDir coreName '-' 'FRinSlidingWindow' '.mat'],'FRinSlidingWindow','-v7.3')
end






















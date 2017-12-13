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
    'HLfine'
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

HL=HLfine;
dList=fieldnames(basics);
%%
% dur.nrem=[];
% dur.rem=[];
% for dIdx=1:length(dList)
%     dName=dList{dIdx};
%     dur.nrem=[dur.nrem;diff(behavior.(dName).list(stateChange.(dName).nrem,1:2),1,2)];
%     dur.rem=[dur.rem;diff(behavior.(dName).list(stateChange.(dName).rem,1:2),1,2)];
% end
% mean duration: nrem=6.6 min, rem=2.1 min
nPeriod.rem=10;
nPeriod.nrem=3*nPeriod.rem;

wakeDur=60e6;
wakeNumBin=5;
wakeBinSize=wakeDur/wakeNumBin;

for dIdx=1:length(dList)
    dName=dList{dIdx};
    spk.pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));
    spk.inh=spikes.(dName)([spikes.(dName).quality]==8 & cellfun(@all,{spikes.(dName).isStable}));
    cTypeList=fieldnames(spk);
    for sIdx=1:size(behavior.(dName).list,1)
        sName=behavior.(dName).name{behavior.(dName).list(sIdx,3)};
        
        if ~isfield(nPeriod,sName)
            timeNormFR.(dName).onset.pyr{sIdx}=[];
            timeNormFR.(dName).onset.inh{sIdx}=[];
            timeNormFR.(dName).offset.pyr{sIdx}=[];
            timeNormFR.(dName).offset.inh{sIdx}=[];
            continue
        end
        
%         tBorder=behavior.(dName).list(sIdx,1)+diff(behavior.(dName).list(sIdx,1:2))/nPeriod.(sName)*(0:nPeriod.(sName));
        tBinSize=diff(behavior.(dName).list(sIdx,1:2))/nPeriod.(sName);       
        tBin=behavior.(dName).list(sIdx,1)-tBinSize/2:tBinSize:behavior.(dName).list(sIdx,2)+tBinSize/2;
        
        for cTypeIdx=1:length(cTypeList)
            cTypeName=cTypeList{cTypeIdx}; 
            clear temp
            temp=zeros(length(spk.(cTypeName)),length(tBin));
            for cIdx=1:length(spk.(cTypeName))                
%                 spkSub=spk.(cTypeName)(cIdx).time(spk.(cTypeName)(cIdx).time>tBorder(1) & spk.(cTypeName)(cIdx).time<tBorder(end));
                temp(cIdx,:)=hist(spk.(cTypeName)(cIdx).time,tBin)/tBinSize*1e6;
            end            
            timeNormFR.(dName).onset.(cTypeName){sIdx}=temp(:,2:end-1);
            timeNormFR.(dName).offset.(cTypeName){sIdx}=temp(:,2:end-1);
        end
    end
    timeNormFR.(dName).param.nBin=nPeriod;
    
    wakeIdx.onset=sort([stateChange.(dName).nrem2quiet(:,2);stateChange.(dName).rem2quiet(:,2)]);
    wakeIdx.offset=stateChange.(dName).quiet2nrem(:,1);
    edgeTypeList=fieldnames(wakeIdx);
    for edgeIdx=1:length(edgeTypeList)
        edgeType=edgeTypeList{edgeIdx};
        for wIdx=1:length(wakeIdx.(edgeType))           
            if strcmpi(edgeType,'offset')
                fstIdx=find(behavior.(dName).list(:,2)>behavior.(dName).list(wakeIdx.offset(wIdx),2)-wakeDur,1,'first');
                if all(behavior.(dName).list(fstIdx:wakeIdx.offset(wIdx),3)>2)
                    wakePeriod=behavior.(dName).list(wakeIdx.offset(wIdx),2)+[-wakeDur,0];      
                else
                    continue
                end
            elseif strcmpi(edgeType,'onset')
                lstIdx=find(behavior.(dName).list(:,1)<behavior.(dName).list(wakeIdx.onset(wIdx),1)+wakeDur,1,'last');
                if all(behavior.(dName).list(wakeIdx.onset(wIdx):lstIdx,3)>2)
                    wakePeriod=behavior.(dName).list(wakeIdx.onset(wIdx),1)+[0,wakeDur];
                else
                    continue
                end
            else
                continue
            end
            tBinSize=wakeBinSize;
            tBin=wakePeriod(1)-tBinSize/2:tBinSize:wakePeriod(2)+tBinSize/2;

            for cTypeIdx=1:length(cTypeList)
                cTypeName=cTypeList{cTypeIdx}; 
                clear temp
                temp=zeros(length(spk.(cTypeName)),length(tBin));
                for cIdx=1:length(spk.(cTypeName))                
    %                 spkSub=spk.(cTypeName)(cIdx).time(spk.(cTypeName)(cIdx).time>tBorder(1) & spk.(cTypeName)(cIdx).time<tBorder(end));
                    temp(cIdx,:)=hist(spk.(cTypeName)(cIdx).time,tBin)/tBinSize*1e6;
                end            
                timeNormFR.(dName).(edgeType).(cTypeName){wakeIdx.(edgeType)(wIdx)}=temp(:,2:end-1);
            end
        end
    end
    timeNormFR.(dName).param.nBin.quiet=wakeNumBin;
    timeNormFR.(dName).param.wakeMinDur=wakeDur;
    timeNormFR.(dName).param.madeby=mfilename;

end


varList={'timeNormFR'};
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end















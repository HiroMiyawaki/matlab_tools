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
nDiv=5;

dur.nrem=[];
dur.rem=[];
for dIdx=1:length(dList)
    dName=dList{dIdx};
    dur.nrem=[dur.nrem;diff(behavior.(dName).list(stateChange.(dName).nrem,1:2),1,2)];
    dur.rem=[dur.rem;diff(behavior.(dName).list(stateChange.(dName).rem,1:2),1,2)];
end

nremRemRatio=round(mean(dur.nrem)/mean(dur.rem));

nPeriod.nrem=6*nremRemRatio;
nPeriod.rem=nPeriod.nrem;

bTypeList={'nrem','rem'};

for bIdx=1:length(bTypeList)
    bName=bTypeList{bIdx};
    for divIdx=1:(nDiv+1)
        fr.(bName){divIdx}=[];
    end
    nEpoch.(bName)=0;
        
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        targetIdx=stateChange.(dName).(bName);

        spk.pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));
        spk.inh=spikes.(dName)([spikes.(dName).quality]==8 & cellfun(@all,{spikes.(dName).isStable}));

        for nIdx=1:length(targetIdx)
            nEpoch.(bName)=nEpoch.(bName)+1;
            tRange=behavior.(dName).list(targetIdx(nIdx),1:2);
            clear temp
            
            tBinSize=diff(tRange)/nPeriod.(bName);
            tBin=tRange(1)-tBinSize/2:tBinSize:tRange(2)+tBinSize/2;
            
            for uIdx=1:2
                if uIdx==1; uType='pyr'; else  uType='inh'; end                 
                temp.(uType)=zeros(length(spk.(uType)),nPeriod.(bName)+2);
                for cellIdx=1:length(spk.(uType))
                      temp.(uType)(cellIdx,:)=hist(spk.(uType)(cellIdx).time,tBin)/tBinSize*1e6;                    
%                     first=find(spk.(uType)(cellIdx).time>tRange(1),1,'first');
%                     last=find(spk.(uType)(cellIdx).time<tRange(2),1,'last');
%                     temp.(uType){cellIdx}=spk.(uType)(cellIdx).time(first:last);
%                     spk.(uType)(cellIdx).time(1:last)=[];                                
                end
                temp.(uType)(:,[1,end])=[];
            end

            ranking=ceil(tiedrank(sum(temp.pyr,2))/length(temp.pyr)*nDiv);
            
            for divIdx=1:nDiv+1
                if divIdx<nDiv+1
                    fr.(bName){divIdx}=[fr.(bName){divIdx};temp.pyr(ranking==divIdx,:)];
                else
                    fr.(bName){divIdx}=[fr.(bName){divIdx};temp.inh];
                end
            end
        end
    end

end

%%
nPeriod.rem=6;
nPeriod.nrem=nPeriod.rem*nremRemRatio;

bTypeList={'nrem2rem','rem2nrem'};

for bIdx=1:length(bTypeList)
    bName=bTypeList{bIdx};
    for divIdx=1:(nDiv+1)
        fr.(bName){divIdx}=[];
    end
    nEpoch.(bName)=0;
        
    state{1}=bName(1:findstr(bName,'2')-1);
    state{2}=bName(findstr(bName,'2')+1:end);

    rankPeriod=1:nPeriod.(state{1});
    
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        targetIdx=stateChange.(dName).(bName);

        spk.pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));
        spk.inh=spikes.(dName)([spikes.(dName).quality]==8 & cellfun(@all,{spikes.(dName).isStable}));

        for nIdx=1:size(targetIdx,1)
            nEpoch.(bName)=nEpoch.(bName)+1;
            
            tRange=behavior.(dName).list(targetIdx(nIdx,:),1:2);
            clear tBinSize tBin
            
            for stateIdx=1:2
                tBinSize(stateIdx)=diff(tRange(stateIdx,:))/nPeriod.(state{stateIdx});
                tBin{stateIdx}=tRange(stateIdx,1)-tBinSize(stateIdx)/2:tBinSize(stateIdx):tRange(stateIdx,2)+tBinSize(stateIdx)/2;
            end
            
            clear nSpk
            for uIdx=1:2
                if uIdx==1; uType='pyr'; else  uType='inh'; end                 
                nSpk.(uType)=zeros(length(spk.(uType)),sum(cellfun(@length,tBin)-2));
                for cellIdx=1:length(spk.(uType))
                    pre=hist(spk.(uType)(cellIdx).time,tBin{1});
                    post=hist(spk.(uType)(cellIdx).time,tBin{2});

                    nSpk.(uType)(cellIdx,:)=[pre(2:end-1),post(2:end-1)];                    
                end
            end

            ranking=ceil(tiedrank(sum(nSpk.pyr(:,rankPeriod),2))/length(nSpk.pyr)*nDiv);
            
            for divIdx=1:nDiv+1
                if divIdx<nDiv+1
                    preRate=nSpk.pyr(ranking==divIdx,1:nPeriod.(state{1}))/tBinSize(1)*1e6;
                    postRate=nSpk.pyr(ranking==divIdx,nPeriod.(state{1})+1:end)/tBinSize(2)*1e6;
                else
                    preRate=nSpk.inh(:,1:nPeriod.(state{1}))/tBinSize(1)*1e6;
                    postRate=nSpk.inh(:,nPeriod.(state{1})+1:end)/tBinSize(2)*1e6;
                end
                fr.(bName){divIdx}=[fr.(bName){divIdx};[preRate,postRate]];
            end
        end
    end

end

%%
bTypeList=fieldnames(fr);

close all
fh=initFig4Nature(2);
basePyrCol=rgb2hsv([1,0.4,0])

col=[hsv2rgb([basePyrCol(1)*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,1,nDiv)']);
     [0,0.6,1]];

bTypeList=fieldnames(fr);

clear dist
bType.nrem='Within NREM';
bType.rem='Within REM';
bType.nrem2rem='NREM to REM';
bType.rem2nrem='REM to NREM';

binSize=0.1;
bin=(-1+binSize/2):binSize:(1-binSize/2);

for bIdx=1:length(bTypeList)
    bName=bTypeList{bIdx};
    
    if isempty(strfind(bName,'2'))
         diffOrder=', first vs last ';
    else
         diffOrder=', last vs first ';
    end
    
    for diffType=1:2
        if diffType==1
            diffName='bins';
            
            if strcmpi(bName,'nrem')
                binToUse={1,18};
            elseif strcmpi(bName,'rem')
                binToUse={1,18};
            elseif strcmpi(bName,'nrem2rem')
                binToUse={18,19};
            elseif strcmpi(bName,'rem2nrem')
                binToUse={6,7};
            else
%                 continue
            end                
            
        else
            diffName='thirds';
            if strcmpi(bName,'nrem')
                binToUse={1:6,13:18};
            elseif strcmpi(bName,'rem')
                binToUse={1:6,13:18};
            elseif strcmpi(bName,'nrem2rem')
                binToUse={13:18,19:20};
            elseif strcmpi(bName,'rem2nrem')
                binToUse={5:6,7:12};
            else
                
            end
        end
        
        subplot2(6,4,diffType,bIdx)
        
        hold on
        for divIdx=1:length(fr.(bName))
            f1=mean(fr.(bName){divIdx}(:,binToUse{1}),2);
            f2=mean(fr.(bName){divIdx}(:,binToUse{2}),2);
            
            ng=find(f1==0 & f2==0);
            f1(ng)=[];
            f2(ng)=[];

            ci=hist((f2-f1)./(f1+f2),bin);
            plot(bin,ci,'color',col(divIdx,:))
        end
        
        title([bType.(bName), ', ' diffOrder diffName])
        ylabel('#cell')
        xlabel('CI')        
 
    end
end

addScriptName(mfilename)

print(fh,'~/Dropbox/Quantile/preliminary/TimeNormalized_CI.pdf','-dpdf')













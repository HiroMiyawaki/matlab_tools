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
    'MA'
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
        nSpk.(bName){divIdx}=[];
        duration.(bName){divIdx}=[];
    end
    nEpoch.(bName)=0;
        
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        targetIdx=stateChange.(dName).(bName);

        spk.pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));
        spk.inh=spikes.(dName)([spikes.(dName).quality]==8 & cellfun(@all,{spikes.(dName).isStable}));

        exPeriods=removeTransient(sortrows([MA.(dName).time;HL.(dName).low]),eps,eps);        
        
        for nIdx=1:length(targetIdx)
            nEpoch.(bName)=nEpoch.(bName)+1;
            tRange=behavior.(dName).list(targetIdx(nIdx),1:2);
            clear temp dur
            
            tBin=tRange(1)+diff(tRange)/nPeriod.(bName)*(0:nPeriod.(bName));            
            exSub=exPeriods(exPeriods(:,2)>tRange(1)&exPeriods(:,1)<tRange(2),:);            
           
            dur=zeros(1,nPeriod.(bName));
            for uIdx=1:2
                if uIdx==1; uType='pyr'; else  uType='inh'; end                 
                temp.(uType)=zeros(length(spk.(uType)),nPeriod.(bName));
                for tIdx=1:nPeriod.(bName)
                    exInBin=exSub(exSub(:,2)>tBin(tIdx)& exSub(:,1)<tBin(tIdx+1),:);
                    if ~isempty(exInBin)
                        if exInBin(1,1)<tBin(tIdx);exInBin(1,1)=tBin(tIdx);end
                        if exInBin(end,end)>tBin(tIdx+1);exInBin(end,end)=tBin(tIdx+1);end
                    end
                    dur(tIdx)=(diff(tBin(tIdx+(0:1)))-sum(diff(exInBin,1,2)))/1e6;

                    for cellIdx=1:length(spk.(uType))
                        subSpk=spk.(uType)(cellIdx).time(spk.(uType)(cellIdx).time>tBin(tIdx)&spk.(uType)(cellIdx).time<tBin(tIdx+1));
                        for exIdx=1:size(exInBin,1)
                            subSpk(subSpk>exInBin(exIdx,1)&subSpk<exInBin(exIdx,2))=[];
                        end
                        temp.(uType)(cellIdx,tIdx)=length(subSpk);                        
                    end                      
                end
            end

            ranking=ceil(tiedrank(sum(temp.pyr,2))/length(temp.pyr)*nDiv);
            
            for divIdx=1:nDiv+1
                if divIdx<nDiv+1
                    nSpk.(bName){divIdx}=[nSpk.(bName){divIdx};temp.pyr(ranking==divIdx,:)];
                    duration.(bName){divIdx}=[duration.(bName){divIdx};repmat(dur,sum(ranking==divIdx),1)];
                else
                    nSpk.(bName){divIdx}=[nSpk.(bName){divIdx};temp.inh];
                    duration.(bName){divIdx}=[duration.(bName){divIdx};repmat(dur,size(temp.inh,1),1)];
                end
            end
        end
    end
    
    for divIdx=1:nDiv+1
          fr.(bName){divIdx}=nSpk.(bName){divIdx}./ duration.(bName){divIdx};
    end

end

%%
nPeriod.rem=6;
nPeriod.nrem=nPeriod.rem*nremRemRatio;

bTypeList={'nrem2rem','rem2nrem'};

for bIdx=1:length(bTypeList)
    bName=bTypeList{bIdx};
    for divIdx=1:(nDiv+1)
        nSpk.(bName){divIdx}=[];
        duration.(bName){divIdx}=[];
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

        exPeriods=removeTransient(sortrows([MA.(dName).time;HL.(dName).low]),eps,eps);        
        
        
        for nIdx=1:size(targetIdx,1)
            nEpoch.(bName)=nEpoch.(bName)+1;
            
            tRange=behavior.(dName).list(targetIdx(nIdx,:),1:2);
            clear tBin
            
            tBin=tRange(1,1);
            
            for stateIdx=1:2
                tBin=[tBin,tRange(stateIdx,1)+diff(tRange(stateIdx,:))/nPeriod.(state{stateIdx})*(1:nPeriod.(state{stateIdx}))];
            end
            exSub=exPeriods(exPeriods(:,2)>tRange(1)&exPeriods(:,1)<tRange(end),:);            
            
            dur=zeros(1,length(tBin)-1);
            for uIdx=1:2
                if uIdx==1; uType='pyr'; else  uType='inh'; end                 
                temp.(uType)=zeros(length(spk.(uType)),length(tBin)-1);
                for tIdx=1:length(tBin)-1
                    exInBin=exSub(exSub(:,2)>tBin(tIdx)& exSub(:,1)<tBin(tIdx+1),:);
                    if ~isempty(exInBin)
                        if exInBin(1,1)<tBin(tIdx);exInBin(1,1)=tBin(tIdx);end
                        if exInBin(end,end)>tBin(tIdx+1);exInBin(end,end)=tBin(tIdx+1);end
                    end
                    dur(tIdx)=(diff(tBin(tIdx+(0:1)))-sum(diff(exInBin,1,2)))/1e6;

                    for cellIdx=1:length(spk.(uType))
                        subSpk=spk.(uType)(cellIdx).time(spk.(uType)(cellIdx).time>tBin(tIdx)&spk.(uType)(cellIdx).time<tBin(tIdx+1));
                        for exIdx=1:size(exInBin,1)
                            subSpk(subSpk>exInBin(exIdx,1)&subSpk<exInBin(exIdx,2))=[];
                        end
                        temp.(uType)(cellIdx,tIdx)=length(subSpk);                        
                    end                      
                end
            end

            ranking=ceil(tiedrank(sum(temp.pyr,2))/length(temp.pyr)*nDiv);
            
            for divIdx=1:nDiv+1
                if divIdx<nDiv+1
                    nSpk.(bName){divIdx}=[nSpk.(bName){divIdx};temp.pyr(ranking==divIdx,:)];
                    duration.(bName){divIdx}=[duration.(bName){divIdx};repmat(dur,sum(ranking==divIdx),1)];
                else
                    nSpk.(bName){divIdx}=[nSpk.(bName){divIdx};temp.inh];
                    duration.(bName){divIdx}=[duration.(bName){divIdx};repmat(dur,size(temp.inh,1),1)];
                end
            end
        end
    end
    
    for divIdx=1:nDiv+1
          fr.(bName){divIdx}=nSpk.(bName){divIdx}./ duration.(bName){divIdx};
    end

end

%%
nShuffle=50;
clear shuffle

bTypeList=fieldnames(fr);

for bIdx=1:length(bTypeList)
    bName=bTypeList{bIdx};
    for divIdx=1:length(fr.(bName))
        shuffle.(bName){divIdx}=zeros(nShuffle,size(fr.(bName){divIdx},2));
        for ite=1:nShuffle
            nCell=size(fr.(bName){divIdx},1);
            idx=zeros(nCell,size(fr.(bName){divIdx},2));

            for n=1:size(idx,1)
                idx(n,:)=(randperm(size(fr.(bName){divIdx},2))-1)*nCell+n;
            end
            shuffle.(bName){divIdx}(ite,:)=nanmean(fr.(bName){divIdx}(idx),1);
        end
    end
end

%%
close all
basePyrCol=rgb2hsv([1,0.4,0])

col=[hsv2rgb([basePyrCol(1)*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,1,nDiv)']);
     [0,0.6,1]];

fh=initFig4Nature(2);

qName={'Pyr lowest fifth','Pyr 4th fifth','Pyr middle fifth','Pyr 2nd fifth','Pyr highest fifth','Inh'};

bType.nrem='Within NREM';
bType.rem='Within REM';
bType.nrem2rem='NREM to REM';
bType.rem2nrem='REM to NREM';

for bIdx=1:length(bTypeList)
    bName=bTypeList{bIdx};
    
    for divIdx=1:nDiv+1

    subplot2(nDiv+1,4,divIdx,bIdx)

    frac=shuffle.(bName){divIdx}/nanmean(shuffle.(bName){divIdx}(:))*100;

    hold on
    
    nBin=size(fr.(bName){divIdx},2);            
    
    errorbar(1:nBin,nanmean(frac,1),nanstd(frac,1,1),'k-')
    plot(1:nBin,nanmean(fr.(bName){divIdx},1)/nanmean(fr.(bName){divIdx}(:))*100,'color',col(divIdx,:))
    title([bType.(bName) ' - ' qName{divIdx}])
    ax=fixAxis;
    if strcmpi(bName,'nrem2rem')
        plot(nPeriod.nrem*[1,1],ax(3:4),'-','color',0.5*[1,1,1])
    elseif strcmpi(bName,'rem2nrem')
        plot(nPeriod.rem*[1,1],ax(3:4),'-','color',0.5*[1,1,1])
    end
    
    
            set(gca,'xtick',[])
        xlabel(['Normalized time'])
        ylabel('FR (%)')

    
    end
end
    
addScriptName(mfilename);

print(fh,'~/Dropbox/Quantile/preliminary/TimeNormalized_woLowMa.pdf','-dpdf')


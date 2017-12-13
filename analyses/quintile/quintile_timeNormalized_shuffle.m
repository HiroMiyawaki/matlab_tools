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

close all
fh=initFig4Nature(2);
basePyrCol=rgb2hsv([1,0.4,0])

col=[hsv2rgb([basePyrCol(1)*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,1,nDiv)']);
     [0,0.6,1]];

bTypeList=fieldnames(fr);

bin=-3:0.1:2;
clear dist
nExample=2;
for bIdx=1:length(bTypeList)
    bName=bTypeList{bIdx};
    for divIdx=1:length(fr.(bName))
        dist.(bName).first{1}(divIdx,:)=hist(log10(fr.(bName){divIdx}(fr.(bName){divIdx}(:,1)>0,1)),bin);
        dist.(bName).last{1}(divIdx,:)=hist(log10(fr.(bName){divIdx}(fr.(bName){divIdx}(:,end)>0,end)),bin);
        
        for ite=1:nExample
            nCell=size(fr.(bName){divIdx},1);
            idx=zeros(nCell,size(fr.(bName){divIdx},2));

            for n=1:size(idx,1)
                idx(n,:)=(randperm(size(fr.(bName){divIdx},2))-1)*nCell+n;
            end
            temp=fr.(bName){divIdx}(idx);
            dist.(bName).first{ite+1}(divIdx,:)=hist(log10(temp(temp(:,1)>0,1)),bin);
            dist.(bName).last{ite+1}(divIdx,:)=hist(log10(temp(temp(:,end)>0,end)),bin);
        end
    end
end
    
bType.nrem='Within NREM';
bType.rem='Within REM';
bType.nrem2rem='NREM to REM';
bType.rem2nrem='REM to NREM';

for bIdx=1:length(bTypeList)
    bName=bTypeList{bIdx};
    for epochType=1:2
        if epochType==1
            binName='first';
        else
            binName='last';
        end
            
        for ite=1:nExample+1
            if ite==1; titleText='real'; else titleText=['example' num2str(ite-1)]; end
            titleText=[bType.(bName) '-' titleText '-' binName ' bin'];

            subplot2(2*(nExample+1),length(bTypeList),ite+(nExample+1)*(epochType-1),bIdx)
            hold on
            for divIdx=1:6
                plot(bin,dist.(bName).(binName){ite}(divIdx,:),'color',col(divIdx,:))
            end
            title(titleText)
            box off
            set(gca,'xtick',-2:2:2,'xticklabel',[0.001,0,100])
            xlim([-3,2])
            xlabel('FR (Hz)')
            ylabel('# cell')
            
        end
    end
end

addScriptName(mfilename)

print(fh,'~/Dropbox/Quantile/preliminary/TimeNormalized_shuffling_distExamples.pdf','-dpdf')



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
            shuffle.(bName){divIdx}(ite,:)=mean(fr.(bName){divIdx}(idx),1);
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

    frac=shuffle.(bName){divIdx}/mean(shuffle.(bName){divIdx}(:))*100;

    hold on
    
    nBin=size(fr.(bName){divIdx},2);            
    
    errorbar(1:nBin,mean(frac,1),std(frac,1,1),'k-')
    plot(1:nBin,mean(fr.(bName){divIdx},1)/mean(fr.(bName){divIdx}(:))*100,'color',col(divIdx,:))
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

print(fh,'~/Dropbox/Quantile/preliminary/TimeNormalized_shuffling.pdf','-dpdf')


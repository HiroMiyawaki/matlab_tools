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
close all
basePyrCol=rgb2hsv([1,0.4,0])

col=[hsv2rgb([basePyrCol(1)*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,1,nDiv)']);
     [0,0.6,1]];

fh=initFig4Nature(2);

qName={'Pyr lowest fifth','Pyr 4th fifth','Pyr middle fifth','Pyr 2nd fifth','Pyr highest fifth','Inh'};

for bIdx=1:length(bTypeList)
    bName=bTypeList{bIdx};

    subplot(nDiv+3,5,3*(bIdx-1)+[1,2,6,7])
    meanFR=cellfun(@mean,fr.(bName),'uniformOutput',false);
    steFR=cellfun(@ste,fr.(bName),'uniformOutput',false);
    
    hold on
    xVal={};
    yVal={};
    eVal={};
    for divIdx=1:nDiv+1
        fill([1:nPeriod.(bName),nPeriod.(bName):-1:1]-1,...
                [meanFR{divIdx}+steFR{divIdx},...
                 fliplr(meanFR{divIdx}-steFR{divIdx})],col(divIdx,:),...
            'facealpha',0.3,'linestyle','none')
        plot(0:nPeriod.(bName)-1,meanFR{divIdx},'-','color',col(divIdx,:))
        xVal{divIdx}=0:nPeriod.(bName)-1;
        yVal{divIdx}=meanFR{divIdx};
        eVal{divIdx}=steFR{divIdx};
    end
    set(gca,'yscale','log')
    xlim([0,nPeriod.(bName)-1])
    ylim(10.^[-1.5,1.2])
    set(gca,'xtick',[])
    xlabel(['Normalized time in ' upper(bName)])
    ylabel('FR (Hz)')

    clear param
    param.epoch=nEpoch.(bName);
    param.n=cellfun(@length,fr.(bName));
    param.cellType=qName;
    param.madeby=mfilename;
    saveGraph('quantile20s2',['f' num2str(bIdx) 'a'],...
            'line',...
            xVal,... %x
            yVal,... %y
            eVal,... %error 
            col,... %color
            get(gca),... %info
            get(get(gca,'xlabel'),'string'),... %xlabel
            get(get(gca,'ylabel'),'string'),... %ylabel
            get(get(gca,'title'),'string'),... %title,
            param,... %legend
            mfilename)             
        
    
    

    subplot2(nDiv+3,5,3,3*(bIdx-1)+1)
    plot(0:nPeriod.(bName)-1,mean(cat(1,fr.(bName){1:nDiv})),'k-')
    xlim([0,nPeriod.(bName)-1])
    box off
    set(gca,'xtick',[])
    xlabel(['Normalized time in ' upper(bName)])
    ylabel('FR (Hz)')
    title('All Pyr')


    clear param
    param.epoch=nEpoch.(bName);
    param.n=sum(cellfun(@length,fr.(bName)(1:nDiv)));
    param.cellType='pyr';
    param.madeby=mfilename;

    saveGraph('quantile20s2',['f' num2str(bIdx) 'b'],...
            'line',...
            0:nPeriod.(bName)-1,... %x
            mean(cat(1,fr.(bName){1:nDiv})),... %y
            ste(cat(1,fr.(bName){1:nDiv})),... %error 
            [0,0,0],... %color
            get(gca),... %info
            get(get(gca,'xlabel'),'string'),... %xlabel
            get(get(gca,'ylabel'),'string'),... %ylabel
            get(get(gca,'title'),'string'),... %title,
            param,... %legend
            mfilename)      
    
    for divIdx=1:nDiv+1
        if divIdx==nDiv+1
            subplot2(nDiv+3,5,4,3*(bIdx-1)+1)
        else
            subplot2(nDiv+3,5,nDiv+1-divIdx+2,3*(bIdx-1)+2)
        end
        hold on
        fill([1:nPeriod.(bName),nPeriod.(bName):-1:1]-1,...
                [meanFR{divIdx}+steFR{divIdx},...
                 fliplr(meanFR{divIdx}-steFR{divIdx})],col(divIdx,:),...
            'facealpha',0.3,'linestyle','none')
        plot(0:nPeriod.(bName)-1,meanFR{divIdx},'-','color',col(divIdx,:))
        xlim([0,nPeriod.(bName)-1])
        box off
        set(gca,'xtick',[])
        xlabel(['Normalized time in ' upper(bName)])
        ylabel('FR (Hz)')
        

        title(qName{divIdx})

    end

end    
    
addScriptName(mfilename);

% print(fh,'~/Dropbox/Quantile/preliminary/TimeNormalized_withinEpochs_20s.pdf','-dpdf')


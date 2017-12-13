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

    rankPeriod=round(nPeriod.(state{1})*2/3+1):nPeriod.(state{1});
    
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
basePyrCol=rgb2hsv([1,0.4,0])

col=[hsv2rgb([basePyrCol(1)*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,1,nDiv)']);
     [0,0.6,1]];

colBorder=0.7*[1,1,1];
 
fh=initFig4Nature(2);

qName={'Pyr lowest fifth','Pyr 4th fifth','Pyr middle fifth','Pyr 2nd fifth','Pyr highest fifth','Inh'};

xText.nrem2rem={'Normalized time' 'in NREM/REM sequence'};
xText.rem2nrem={'Normalized time' 'in REM/NREM sequence'};

for bIdx=1:length(bTypeList)
    bName=bTypeList{bIdx};

    subplot(nDiv+3,5,3*(bIdx-1)+[1,2,6,7])
    meanFR=cellfun(@mean,fr.(bName),'uniformOutput',false);
    steFR=cellfun(@ste,fr.(bName),'uniformOutput',false);

    state{1}=bName(1:findstr(bName,'2')-1);
    state{2}=bName(findstr(bName,'2')+1:end);
    rankPeriod=round(nPeriod.(state{1})*2/3+1):nPeriod.(state{1});
    
    
    nPeriodTotal=nPeriod.(state{1})+nPeriod.(state{2});
    
    hold on
    xVal={};
    yVal={};
    eVal={};
    for divIdx=1:nDiv+1
        fill([1:nPeriodTotal,nPeriodTotal:-1:1]-1,...
                [meanFR{divIdx}+steFR{divIdx},...
                 fliplr(meanFR{divIdx}-steFR{divIdx})],col(divIdx,:),...
            'facealpha',0.3,'linestyle','none')
        plot(0:nPeriodTotal-1,meanFR{divIdx},'-','color',col(divIdx,:))
        xVal{divIdx}=0:nPeriodTotal-1;
        yVal{divIdx}=meanFR{divIdx};
        eVal{divIdx}=steFR{divIdx};
    end
    set(gca,'yscale','log')
    xlim([0,nPeriodTotal-1])
    ylim(10.^[-1.5,1.2])
    set(gca,'xtick',[])
    xlabel(xText.(bName))
    ylabel('FR (Hz)')
    ax=fixAxis;
    hold on
    plot(nPeriod.(state{1})-0.5*[1,1],ax(3:4),'-','color',colBorder)

    clear param
    param.epoch=nEpoch.(bName);
    param.n=cellfun(@length,fr.(bName));
    param.cellType=qName;
    param.stateName=state;
    param.nBin=[nPeriod.(state{1}),nPeriod.(state{2})];
    param.rankPeriod=rankPeriod;
    param.madeby=mfilename;
    saveGraph('quantile20s2',['f' num2str(bIdx+2) 'a3rd'],...
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
    plot(0:nPeriodTotal-1,mean(cat(1,fr.(bName){1:nDiv})),'k-')
    xlim([0,nPeriodTotal-1])
    box off
    set(gca,'xtick',[])
    xlabel(xText.(bName))
    ylabel('FR (Hz)')
    title('All Pyr')
    ax=fixAxis;
    hold on
    plot(nPeriod.(state{1})-0.5*[1,1],ax(3:4),'-','color',colBorder)



    clear param
    param.epoch=nEpoch.(bName);
    param.n=sum(cellfun(@length,fr.(bName)(1:nDiv)));
    param.cellType='pyr';
    param.stateName=state;
    param.nBin=[nPeriod.(state{1}),nPeriod.(state{2})];
    param.rankPeriod=rankPeriod;
    param.madeby=mfilename;

    saveGraph('quantile20s2',['f' alphabet(bIdx) '23rd'],...
            'line',...
            0:nPeriodTotal-1,... %x
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
        fill([1:nPeriodTotal,nPeriodTotal:-1:1]-1,...
                [meanFR{divIdx}+steFR{divIdx},...
                 fliplr(meanFR{divIdx}-steFR{divIdx})],col(divIdx,:),...
            'facealpha',0.3,'linestyle','none')
        plot(0:nPeriodTotal-1,meanFR{divIdx},'-','color',col(divIdx,:))
        xlim([0,nPeriodTotal-1])
        box off
        set(gca,'xtick',[])
        xlabel(xText.(bName))
        ylabel('FR (Hz)')
        ax=fixAxis;
        hold on
        plot(nPeriod.(state{1})-0.5*[1,1],ax(3:4),'-','color',colBorder)
        

        title(qName{divIdx})

    end

end    
    
addScriptName(mfilename);

print(fh,'~/Dropbox/Quantile/preliminary/TimeNormalized_transition_thirds.pdf','-dpdf')


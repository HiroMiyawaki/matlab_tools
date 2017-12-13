%%
clear
% baseDir='/Volumes/RAID_HDD/sleep/pooled/';
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
    'firing'
    ...'eventRate'
    ...'stableSleep'
    ...'stableWake'
    'stateChange20s'
    'trisecFiring'
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

ci=@(x) diff(x,1,2)./sum(x,2);
dlog=@(x) log10(x(:,2)./x(:,1));
                            
nDiv=1;
nShuffle=2000;
nPeriods=3;

clear shuffle realData

for n=1:nDiv
    for ite=1:nShuffle
        shuffle.ci{ite,n}=[];
        shuffle.dLog{ite,n}=[];
    end
    shuffle.example{n}=[];
    realData.ci{n}=[];
    realData.dLog{n}=[];
    realData.fr{n}=[];
end
realData.nEpoch=0;

highDurThreshold=2e6;
for dIdx=1:length(dList)
    dName=dList{dIdx};
    display([datestr(now) ' - ' dName])
    
    inh=spikes.(dName)([spikes.(dName).quality]==8 & cellfun(@all,{spikes.(dName).isStable}));
    if isempty(inh)
        continue
    end
    nrem=behavior.(dName).list(stateChange.(dName).nrem,1:2);
    for idx=1:size(nrem,1)
        display(['    ' datestr(now) ' ' num2str(idx) '/' num2str(size(nrem,1)) ' of ' dName])
        
        for n=1:2
            if n==1
                nremTime{n}=nrem(idx,1)+diff(nrem(idx,:))/nPeriods*[0,1];
            else
                nremTime{n}=nrem(idx,1)+diff(nrem(idx,:))/nPeriods*[nPeriods-1,nPeriods];
            end
            low{n}=HL.(dName).low(HL.(dName).low(:,2)>nremTime{n}(1)&HL.(dName).low(:,1)<nremTime{n}(2),:);
            if ~isempty(low{n})
                if low{n}(1,1)<nremTime{n}(1);low{n}(1,1)=nremTime{n}(1); end
                if low{n}(end,2)>nremTime{n}(2);low{n}(end,2)=nremTime{n}(2); end
            end
        end
        
        clear firingRate
        clear tempFR
        for cIdx=1:length(inh);
            spkSub=inh(cIdx).time(inh(cIdx).time>nremTime{1}(1)& inh(cIdx).time<nremTime{2}(2));
            
            spkNrem(1)=sum(spkSub<nremTime{1}(2));
            spkNrem(2)=sum(spkSub>nremTime{2}(1));
            for n=1:2
                spkLow(n)=sum(isInRange(low{n},spkSub));
            end
            durNrem=cellfun(@diff,nremTime)/1e6;
            durLow=cellfun(@(x) sum(diff(x,1,2)),low)/1e6;
            
            tempFR(cIdx,:)=(spkNrem-spkLow)./(durNrem-durLow);
        end
        
        tempFR(any(tempFR==0,2),:)=[];
        ranking=tiedrank(tempFR(:,1))/size(tempFR,1);

        for n=1:nDiv
            realData.ci{n}=[realData.ci{n};...
                ci(tempFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];
            realData.dLog{n}=[realData.dLog{n};...
                dlog(tempFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];
            realData.fr{n}=[realData.fr{n};...
                tempFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:)];
        end

        realData.nEpoch=realData.nEpoch+1;
        for ite=1:nShuffle
            shuffleIdx=rand(size(tempFR,1),1)>0.5;
            shuffleIdx=repmat(1:size(tempFR,1),2,1)'+[shuffleIdx,1-shuffleIdx]*size(tempFR,1);
            shuffleFR=tempFR(shuffleIdx);
            ranking=tiedrank(shuffleFR(:,1))/size(shuffleFR,1);

            for n=1:nDiv
                shuffle.ci{ite,n}=[shuffle.ci{ite,n};...
                    ci(shuffleFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];
                shuffle.dLog{ite,n}=[shuffle.dLog{ite,n};...
                    dlog(shuffleFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];

                if ite==nShuffle
                    shuffle.example{n}=[shuffle.example{n};...
                        shuffleFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:)];
                end

            end
        end
    end

end
    


%%

measureList={'ci','dLog'};

    
    for mIdx=1:length(measureList)
        measureType=measureList{mIdx};
        
        for n=1:nDiv
            nPoint=length(realData.(measureType){n});
            pointToUse=ceil(nPoint/10);
            
            subMed=[];
            for ite=1:nShuffle
                temp=realData.(measureType){n}(randperm(nPoint,pointToUse));
                
                subMed(ite)=nanmedian(temp(~isinf(temp)));
            end
            
            subMed=sort(subMed);
            frChange.real.(measureType).medianCI(:,n)=subMed([floor(nShuffle*0.025),ceil(nShuffle*0.975)])';
        end
        
        for statTypeIdx=1:2
            if statTypeIdx==1
                statType='mean';
                statFun=@nanmean;
            else
                statType='median';
                statFun=@nanmedian;
            end
            
            frChange.real.(measureType).(statType)=...
                cellfun(@(x) statFun(x(~isinf(x))),realData.(measureType));
            
            temp=sort(cellfun(@(x) statFun(x(~isinf(x))),shuffle.(measureType)));
            
            clear p
            for n=1:nDiv
                lowerBond=find(temp(:,n)<frChange.real.(measureType).(statType)(n),1,'last');
                if isempty(lowerBond)
                    lowerBond=0;
                end
                
                
                upperBond=find(temp(:,n)>frChange.real.(measureType).(statType)(n),1,'first');
                if isempty(upperBond)
                    upperBond=nShuffle;
                end
                p(n)=1-max([(nShuffle/2-lowerBond)/nShuffle*2,(upperBond-nShuffle/2)/nShuffle*2]);
            end
            frChange.shuffle.(measureType).(statType).p=p;
            frChange.shuffle.(measureType).(statType).interval=temp([floor(nShuffle*0.025),ceil(nShuffle*0.975)],:);
            frChange.shuffle.(measureType).(statType).mean=mean(temp,1);
            
        end
        
        
        statType='ste';
        statFun=@nanste;
        
        frChange.real.(measureType).(statType)=...
            cellfun(@(x) statFun(x(~isinf(x))),realData.(measureType));
    end



%%
close all
fh=initFig4JNeuro(2);
set(fh,'defaultLineMarkerSize',4)
nCol=4;
nRaw=7;
col=hsv2rgb([2/3*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,0.5,nDiv)'])

mu = [0 0];
Sigma = [1 0; 0 1];
smoothCoreBin = -3:3; smoothCoreBin = -3:3;
[smoothCoreBin,smoothCoreBin] = meshgrid(smoothCoreBin,smoothCoreBin);
smoothCore = mvnpdf([smoothCoreBin(:) smoothCoreBin(:)],mu,Sigma);
smoothCore = reshape(smoothCore,length(smoothCoreBin),length(smoothCoreBin));
smoothCore=smoothCore/sum(sum(smoothCore));

col=hsv2rgb([5/12*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');


densityRange=-2:1;
logXrange=(densityRange([1,end]));
logYrange=(densityRange([1,end]));
xbin=linspace(logXrange(1),logXrange(2),50);
ybin=linspace(logYrange(1),logYrange(2),50);

densityLabel={'10^{-2}','10^{-1}','10^{0}','10^{1}'};

% tNameList={'nrem2rem','rem2nrem'};


    
    subplot2(nRaw,nCol,1,1)
    temp=[];
    hold on
    clear xVal yVal
    for n=1:nDiv
        xVal{n}=realData.fr{n}(:,1);
        yVal{n}=realData.fr{n}(:,2);
        plot(xVal{n},yVal{n},'.','color',col(n,:));
        temp=[temp;realData.fr{n}];
    end
    xlim(10.^[-3,2])
    ylim(10.^[-3,2])
    xlabel({'Firing rate in' 'first 1/3 (Hz)'})
    ylabel({'Firing rate in' 'last 1/3 (Hz)'})
    set(gca,'xscale','log','yscale','log')
    set(gca,'xtick',10.^(-2:2:2),'ytick',10.^(-2:2:2))
    plotIdentityLine(gca,{'color','black'})
    box off
    title('Non-REM excluding LOW')
    fixAxis;
    clear param
    param.nCell=cellfun(@length,xVal)
    param.nEpoch=realData.nEpoch;
    saveGraph('quantile20s5',['b1' 'Inh'],...
        'scatter',...
        xVal,... %x
        yVal,... %y
        [],... %error
        col,... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename)
    
    subplot2(nRaw,nCol,1,2)
    temp(any(temp==0,2),:)=[];
    densMap=hist2(log10(temp),xbin,ybin);
    densMap=conv2(densMap,smoothCore);
    densMap=densMap/sum(sum(densMap))*100;
    imagescXY(logXrange,logYrange,densMap)
    colormap(gca,jet)
    set(gca,'xtick',densityRange,'xticklabel',densityLabel)
    set(gca,'ytick',densityRange,'yticklabel',densityLabel)
    xlabel({'Firing rate in' 'first 1/3 (Hz)'})
    ylabel({'Firing rate in' 'last 1/3 (Hz)'})
    
    plotIdentityLine(gca,{'color','black'})
    plotIdentityLine(gca,{'color',0.99*[1,1,1]})
    box off
    title('Non-REM excluding LOW')
    fixAxis;
    clear param
    param.nCell=cellfun(@length,xVal)
    param.nEpoch=realData.nEpoch;
    param.smoothCoreSize=size(smoothCore);
    param.smoothCoreSD=1;
    saveGraph('quantile20s5',['b2' 'Inh'],...
        'spectrum',...
        [logXrange,logYrange],... %x
        densMap,... %y
        [],... %error
        col,... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename)
    
    subplot2(nRaw,nCol,1,3)
    temp=[];
    hold on
    for n=1:nDiv
        plot(shuffle.example{n}(:,1),...
            shuffle.example{n}(:,2),'.','color',col(n,:));
        temp=[temp;shuffle.example{n}];
    end
    
    xlim(10.^[-3,2])
    ylim(10.^[-3,2])
    xlabel({'Firing rate in' 'first 1/3 (Hz)'})
    ylabel({'Firing rate in' 'last 1/3 (Hz)'})
    set(gca,'xscale','log','yscale','log')
    set(gca,'xtick',10.^(-2:2:2),'ytick',10.^(-2:2:2))
    plotIdentityLine(gca,{'color','black'})
    box off
    title('Example of shuffling')
    fixAxis;
    
    subplot2(nRaw,nCol,1,4)
    temp(any(temp==0,2),:)=[];
    densMap=hist2(log10(temp),xbin,ybin);
    densMap=conv2(densMap,smoothCore);
    imagescXY(densMap)
    colormap(gca,jet)
    xlabel({'Firing rate in' 'first 1/3 (Hz)'})
    ylabel({'Firing rate in' 'last 1/3 (Hz)'})
    plotIdentityLine(gca,{'color',0.99*[1,1,1]})
    box off
    title('Example of shuffling')
    fixAxis;

%%
measureNameList={'Change index','\Deltalog_{10}(Hz)'};

    
    for mIdx=1:length(measureList)
        measureType=measureList{mIdx};
        measureName=measureNameList{mIdx};
        
        subplot2(nRaw,nCol,2,2*(mIdx-1)+1)
        hold on
        for n=1:nDiv
            plot(n*[1,1],frChange.real.(measureType).mean(n)+frChange.real.(measureType).ste(n)*[-1,1],...
                'color',col(n,:))
            bar(n,frChange.real.(measureType).mean(n),'linestyle','none','faceColor',col(n,:))
        end
        xlim([0.5,nDiv+0.5])
        fill([1:nDiv,nDiv:-1:1],[frChange.shuffle.(measureType).mean.interval(1,:),...
            fliplr(frChange.shuffle.(measureType).mean.interval(2,:))],hsv2rgb([0,0.75,0.75]),...
            'faceAlpha',0.5,'lineStyle','none')
        xlabel('Quintile')
        ylabel(measureName)
        title('Mean')
        clear param
        param.confInt=frChange.shuffle.(measureType).mean.interval;
        param.p=frChange.shuffle.(measureType).mean.p;
        
        saveGraph('quantile20s5',['b3' alphabet(mIdx) 'Inh'],...
            'multiColorBar',...
            1:nDiv,... %x
            frChange.real.(measureType).mean,... %y
            frChange.real.(measureType).ste,... %error
            col,... %color
            get(gca),... %info
            get(get(gca,'xlabel'),'string'),... %xlabel
            get(get(gca,'ylabel'),'string'),... %ylabel
            get(get(gca,'title'),'string'),... %title,
            param,... %legend
            mfilename)
        
        
        
        subplot2(nRaw,nCol,3,2*(mIdx-1)+1)
        hold on
        for n=1:nDiv
            plot(n*[1,1],...
                frChange.real.(measureType).mean(n)+...
                frChange.real.(measureType).ste(n)*[-1,1]-...
                frChange.shuffle.(measureType).mean.mean(n),...
                'color',col(n,:))
            bar(n,frChange.real.(measureType).mean(n)-...
                frChange.shuffle.(measureType).mean.mean(n),'linestyle','none','faceColor',col(n,:))
        end
        xlim([0.5,nDiv+0.5])
        fill([1:nDiv,nDiv:-1:1],...
            [frChange.shuffle.(measureType).mean.interval(1,:)-frChange.shuffle.(measureType).mean.mean,...
            fliplr(frChange.shuffle.(measureType).mean.interval(2,:)-frChange.shuffle.(measureType).mean.mean)]...
            ,hsv2rgb([0,0.75,0.75]),...
            'faceAlpha',0.5,'lineStyle','none')
        xlabel('Quintile')
        ylabel(['Deflection index'])
        title('Mean')
        
        clear param
        param.confInt=frChange.shuffle.(measureType).mean.interval-[1;1]*frChange.shuffle.(measureType).mean.mean;
        param.p=frChange.shuffle.(measureType).mean.p;
        param.measure=measureName;
        
        saveGraph('quantile20s5',['b4' alphabet(mIdx) 'Inh'],...
            'multiColorBar',...
            1:nDiv,... %x
            frChange.real.(measureType).mean-frChange.shuffle.(measureType).mean.mean,... %y
            frChange.real.(measureType).ste,... %error
            col,... %color
            get(gca),... %info
            get(get(gca,'xlabel'),'string'),... %xlabel
            get(get(gca,'ylabel'),'string'),... %ylabel
            get(get(gca,'title'),'string'),... %title,
            param,... %legend
            mfilename)
        
        
        subplot2(nRaw,nCol,2,2*(mIdx-1)+2)
        
        hold on
        for n=1:nDiv
            plot(n*[1,1],frChange.real.(measureType).medianCI(:,n)',...
                'color',col(n,:))
            bar(n,frChange.real.(measureType).median(n),'linestyle','none','faceColor',col(n,:))
        end
        xlim([0.5,nDiv+0.5])
        fill([1:nDiv,nDiv:-1:1],[frChange.shuffle.(measureType).median.interval(1,:),...
            fliplr(frChange.shuffle.(measureType).median.interval(2,:))],hsv2rgb([0,0.75,0.75]),...
            'faceAlpha',0.5,'lineStyle','none')
        xlabel('Quintile')
        ylabel(measureType)
        title('Median')
        
        
        subplot2(nRaw,nCol,3,2*(mIdx-1)+2)
        
        hold on
        for n=1:nDiv
            plot(n*[1,1],frChange.real.(measureType).medianCI(:,n)'-frChange.shuffle.(measureType).median.mean(n),...
                'color',col(n,:))
            bar(n,frChange.real.(measureType).median(n)-frChange.shuffle.(measureType).median.mean(n),'linestyle','none','faceColor',col(n,:))
        end
        xlim([0.5,nDiv+0.5])
        fill([1:nDiv,nDiv:-1:1],[frChange.shuffle.(measureType).median.interval(1,:)-frChange.shuffle.(measureType).median.mean,...
            fliplr(frChange.shuffle.(measureType).median.interval(2,:)-frChange.shuffle.(measureType).median.mean)],hsv2rgb([0,0.75,0.75]),...
            'faceAlpha',0.5,'lineStyle','none')
        xlabel('Quintile')
        ylabel(['Deflection of ' measureType])
        title('Median')
        
    end

ax=fixAxis;
addScriptName;

subplot2(nRaw,nCol,3,1)
hold on
ax=fixAxis;
text2(0,-1,{
    ['Red bands indcates 95% confidence interval estimated by shuffling (' num2str(nShuffle) ' times)']
    ['Error bars indicates STE for mean and 95% confidence interval for median estimated by subsampling (' num2str(nShuffle) ' times)']},ax,...
    {'horizontalALign','left','verticalALign','top','fontsize',7});

%%
% print(fh,'~/Dropbox/Quantile/preliminary/excludeLOW_20s.pdf','-dpdf')





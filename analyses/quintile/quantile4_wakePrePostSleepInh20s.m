%%
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
    'stableSleep20s'
    ...'stableWake'
    'stateChange20s'
    ...'trisecFiring'
    ...'trisecEvent'
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

windowSize=1*60e6;
for dIdx=1:length(dList)
    dName=dList{dIdx};
    
    inh=spikes.(dName)([spikes.(dName).quality]==8 & cellfun(@all,{spikes.(dName).isStable}));
    
    if isempty(inh)
        continue
    end
    
    for idx=1:size(stableSleep.(dName).time,1)
        
        befIdx=find(behavior.(dName).list(:,2)>stableSleep.(dName).time(idx,1)-windowSize&...
             behavior.(dName).list(:,1)<stableSleep.(dName).time(idx,1));

        aftIdx=find(behavior.(dName).list(:,2)>stableSleep.(dName).time(idx,2)&...
             behavior.(dName).list(:,1)<stableSleep.(dName).time(idx,2)+windowSize);
        
        if any(behavior.(dName).list([befIdx;aftIdx],3)<3)
            continue
        end
        
        clear tempFR
        for timeType=1:2
            if timeType==1
                tRange=stableSleep.(dName).time(idx,1)-[windowSize,0];
            else
                tRange=stableSleep.(dName).time(idx,2)+[0,windowSize];
            end
            
            for cIdx=1:length(inh)
                tempFR(cIdx,timeType)=sum(inh(cIdx).time>tRange(1)&inh(cIdx).time<tRange(2))/(windowSize/1e6);
            end
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

%

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

col=hsv2rgb([0*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');


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
    xlabel({'Firing rate in' 'min preceding sleep (Hz)'})
    ylabel({'Firing rate in' 'min following sleep (Hz)'})
    set(gca,'xscale','log','yscale','log')
    set(gca,'xtick',10.^(-2:2:2),'ytick',10.^(-2:2:2))
    plotIdentityLine(gca,{'color','black'})
    box off
    title('Wake before vs after sleep')
    fixAxis;
    clear param
    param.n=cellfun(@length,xVal)
    saveGraph('quantile20s4',['i1' 'Inh'],...
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
    xlabel({'Firing rate in' 'min preceding sleep (Hz)'})
    ylabel({'Firing rate in' 'min following sleep (Hz)'})
    
    plotIdentityLine(gca,{'color','black'})
    plotIdentityLine(gca,{'color',0.99*[1,1,1]})
    box off
    title('Wake before vs after sleep')
    fixAxis;
    clear param
    param.smothCoreSize=size(smoothCore);
    param.smotCorehSD=1;
    saveGraph('quantile20s4',['i2' 'Inh'],...
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
    xlabel({'Firing rate in' 'min preceding sleep (Hz)'})
    ylabel({'Firing rate in' 'min following sleep (Hz)'})
    set(gca,'xscale','log','yscale','log')
    set(gca,'xtick',10.^(-2:2:2),'ytick',10.^(-2:2:2))
    plotIdentityLine(gca,{'color','black'})
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
    xlabel({'Firing rate in' 'min preceding sleep (Hz)'})
    ylabel({'Firing rate in' 'min following sleep (Hz)'})
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
        
        saveGraph('quantile20s4',['i3' alphabet(mIdx) 'Inh'],...
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
        
        saveGraph('quantile20s4',['i4' alphabet(mIdx) 'Inh'],...
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
text2(1,-0.5,['made with ' mfilename '.m'],ax,...
    {'horizontalALign','right','verticalALign','top','fontsize',4,'interpreter','none'});

subplot2(nRaw,nCol,4,1)
temp=cat(1,realData.fr{:});
temp(any(temp==0,2),:)=[];
temp=log10(temp);
bin=-3:0.1:2;
distCol(1,:)=0.5*[1,1,1];
distCol(2,:)=0*[1,1,1];
hold on
clear xVal yVal
for n=1:2
    yVal{n}=hist(temp(:,n),bin)/size(temp,1)*100;
    xVal{n}=bin;
    plot(xVal{n},yVal{n},'color',distCol(n,:))
end

xlabel('Fring rate (log_{10} Hz)');
ylabel('% of cells')
xTickPos=-2:1:1;
xTickLabel={'10^{-2}','10^{-1}','10^{0}','10^{1}'};
xlim([-2.5,1.3]);
set(gca,'xtick',xTickPos,'xticklabel',xTickLabel)    
    
param.n=size(temp,1);
param.stateName={'First min','Last min'};
saveGraph('quantile20s4',['e9' 'Inh'],...
        'line',...
        xVal,... %x
        yVal,... %y
        [],... %error 
        distCol,... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename)      

hold on
ax=fixAxis;
text2(0,-1,{
    ['Red bands indcates 95% confidence interval estimated by shuffling (' num2str(nShuffle) ' times)']
    ['Error bars indicates STE for mean and 95% confidence interval for median estimated by subsampling (' num2str(nShuffle) ' times)']},ax,...
    {'horizontalALign','left','verticalALign','top','fontsize',7});

%%
% print(fh,'~/Dropbox/Quantile/preliminary/changeInStableWaking_20s.pdf','-dpdf')













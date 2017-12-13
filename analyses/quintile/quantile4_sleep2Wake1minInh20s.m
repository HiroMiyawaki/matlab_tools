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
    ...'stableSleep'
    ...'stableWake'
    'stateChange20s'
    'trisecFiring'
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

tNameList={'quiet2nrem','nrem2quiet','rem2quiet'};

wakeDur=1*60e6;

for tIdx=1:length(tNameList)
    tName=tNameList{tIdx};
    for n=1:nDiv
        for ite=1:nShuffle
            shuffle.(tName).ci{ite,n}=[];
            shuffle.(tName).dLog{ite,n}=[];
        end
        shuffle.(tName).example{n}=[];
        realData.(tName).ci{n}=[];
        realData.(tName).dLog{n}=[];
        realData.(tName).fr{n}=[];
    end
    
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        target=stateChange.(dName).(tName);
        
        inh=spikes.(dName)([spikes.(dName).quality]==8& cellfun(@all, {spikes.(dName).isStable}));
        
        if isempty(inh)
            continue
        end

        for idx=1:size(target,1)
            
            if behavior.(dName).list(target(idx,1),3)==3
                fstIdx=find(behavior.(dName).list(:,2)>behavior.(dName).list(target(idx,1),2)-wakeDur,1,'first');
                if all(behavior.(dName).list(fstIdx:target(idx,1),3)>2)
                    wakePeriod=behavior.(dName).list(target(idx,1),2)+[-wakeDur,0];
                else
                    continue
                end
            else
                lstIdx=find(behavior.(dName).list(:,2)<behavior.(dName).list(target(idx,2),1)+wakeDur,1,'last');
                if all(behavior.(dName).list(target(idx,2):lstIdx,3)>2)
                    wakePeriod=behavior.(dName).list(target(idx,2),1)+[0,wakeDur];
                else
                    continue
                end
            end
            
            wakeFr=[];
            for cIdx=1:length(inh)
                wakeFr(cIdx)=sum(inh(cIdx).time>wakePeriod(1) &  inh(cIdx).time<wakePeriod(2))/(wakeDur/1e6);
            end
            
            if behavior.(dName).list(target(idx,1),3)==3
                tempFR=[wakeFr',...
                    trisecFiring.(dName).inh.rate{target(idx,2)}(:,1)];
            else
                tempFR=[trisecFiring.(dName).inh.rate{target(idx,1)}(:,3),...
                    wakeFr'];
            end
            
            ranking=tiedrank(tempFR(:,1))/size(tempFR,1);
            
            for n=1:nDiv
                realData.(tName).ci{n}=[realData.(tName).ci{n};...
                    ci(tempFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];
                realData.(tName).dLog{n}=[realData.(tName).dLog{n};...
                    dlog(tempFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];
                realData.(tName).fr{n}=[realData.(tName).fr{n};...
                    tempFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:)];
            end
            
            
            for ite=1:nShuffle
                shuffleIdx=rand(size(tempFR,1),1)>0.5;
                shuffleIdx=repmat(1:size(tempFR,1),2,1)'+[shuffleIdx,1-shuffleIdx]*size(tempFR,1);
                shuffleFR=tempFR(shuffleIdx);
                ranking=tiedrank(shuffleFR(:,1))/size(shuffleFR,1);
                
                for n=1:nDiv
                    shuffle.(tName).ci{ite,n}=[shuffle.(tName).ci{ite,n};...
                        ci(shuffleFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];
                    shuffle.(tName).dLog{ite,n}=[shuffle.(tName).dLog{ite,n};...
                        dlog(shuffleFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];
                    
                    if ite==nShuffle
                        shuffle.(tName).example{n}=[shuffle.(tName).example{n};...
                            shuffleFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:)];
                    end
                    
                end
            end
            
        end
        
    end
    
end

%%

measureList={'ci','dLog'};

for tIdx=1:length(tNameList)
    tName=tNameList{tIdx};
    
    for mIdx=1:length(measureList)
        measureType=measureList{mIdx};

        for n=1:nDiv
            nPoint=length(realData.(tName).(measureType){n});
            pointToUse=ceil(nPoint/10);
            
            subMed=[];
            for ite=1:nShuffle
                temp=realData.(tName).(measureType){n}(randperm(nPoint,pointToUse));
                
                subMed(ite)=nanmedian(temp(~isinf(temp)));
            end
            
            subMed=sort(subMed);
            frChange.(tName).real.(measureType).medianCI(:,n)=subMed([floor(nShuffle*0.025),ceil(nShuffle*0.975)])';
        end
        
        for statTypeIdx=1:2
            if statTypeIdx==1
                statType='mean';
                statFun=@nanmean;
            else
                statType='median';
                statFun=@nanmedian;
            end

            frChange.(tName).real.(measureType).(statType)=...
                cellfun(@(x) statFun(x(~isinf(x))),realData.(tName).(measureType));

            temp=sort(cellfun(@(x) statFun(x(~isinf(x))),shuffle.(tName).(measureType)));
            
            clear p
            for n=1:nDiv
                lowerBond=find(temp(:,n)<frChange.(tName).real.(measureType).(statType)(n),1,'last');
                if isempty(lowerBond)
                    lowerBond=0;
                end
                
                                    
                upperBond=find(temp(:,n)>frChange.(tName).real.(measureType).(statType)(n),1,'first');
                if isempty(upperBond)
                    upperBond=nShuffle;
                end
                p(n)=1-max([(nShuffle/2-lowerBond)/nShuffle*2,(upperBond-nShuffle/2)/nShuffle*2]);            
            end
            frChange.(tName).shuffle.(measureType).(statType).p=p;
            frChange.(tName).shuffle.(measureType).(statType).interval=temp([floor(nShuffle*0.025),ceil(nShuffle*0.975)],:);
            frChange.(tName).shuffle.(measureType).(statType).mean=mean(temp,1);
            
        end
                

        statType='ste';
        statFun=@nanste;
        
        frChange.(tName).real.(measureType).(statType)=...
            cellfun(@(x) statFun(x(~isinf(x))),realData.(tName).(measureType));
    end
end


%%
close all
fh=initFig4JNeuro(2);
set(fh,'defaultLineMarkerSize',4)
nCol=4;
nRaw=9;
col=hsv2rgb([2/3*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,0.5,nDiv)'])

mu = [0 0];
Sigma = [1 0; 0 1];
smoothCoreBin = -3:3; smoothCoreBin = -3:3;
[smoothCoreBin,smoothCoreBin] = meshgrid(smoothCoreBin,smoothCoreBin);
smoothCore = mvnpdf([smoothCoreBin(:) smoothCoreBin(:)],mu,Sigma);
smoothCore = reshape(smoothCore,length(smoothCoreBin),length(smoothCoreBin));
smoothCore=smoothCore/sum(sum(smoothCore));

colNrem=hsv2rgb([2/3*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colRem=hsv2rgb([5/6*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colWake=hsv2rgb([0*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');


densityRange=-2:1;
logXrange=(densityRange([1,end]));
logYrange=(densityRange([1,end]));
xbin=linspace(logXrange(1),logXrange(2),50);
ybin=linspace(logYrange(1),logYrange(2),50);

densityLabel={'10^{-2}','10^{-1}','10^{0}','10^{1}'};

% tNameList={'nrem2rem','rem2nrem'};
% tNameList={'quiet2nrem','rem2quiet','nrem2quiet'};

dispTname{1}={'Resting wake','non-REM'};
dispTname{2}={'Non-REM','wake'};
dispTname{3}={'REM','wake'};

xLabelText{1}='last min of wake';
xLabelText{2}='last 1/3 of non-REM';
xLabelText{3}='last 1/3 of REM';

yLabelText{1}='first 1/3 of non-REM';
yLabelText{2}='first min of wake';
yLabelText{3}='first min of wake';

for tIdx=1:length(tNameList)
    tName=tNameList{tIdx};
    if tIdx==1
        col=colWake;
    elseif tIdx==2
        col=colNrem;
    else
        col=colRem;
    end
    firstState=dispTname{tIdx}{1};
    lastState=dispTname{tIdx}{2};
    
    subplot2(nRaw,nCol,3*(tIdx-1)+1,1)
    temp=[];
    hold on
    clear xVal yVal
    for n=1:nDiv
        xVal{n}=realData.(tName).fr{n}(:,1);
        yVal{n}=realData.(tName).fr{n}(:,2);
        plot(xVal{n},yVal{n},'.','color',col(n,:));
        temp=[temp;realData.(tName).fr{n}];
    end
    xlim(10.^[-3,2])
    ylim(10.^[-3,2])
    xlabel({'Firing rate in' [xLabelText{tIdx} ' (Hz)']})
    ylabel({'Firing rate in' [yLabelText{tIdx}  ' (Hz)']})
    set(gca,'xscale','log','yscale','log')
    set(gca,'xtick',10.^(-2:2:2),'ytick',10.^(-2:2:2))
    plotIdentityLine(gca,{'color','black'})
    box off
    title([firstState ' to ' lastState])
    fixAxis;
    clear param
    param.n=cellfun(@length,xVal)
    saveGraph('quantile20s4',[alphabet(5+tIdx) '1' 'Inh'],...
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
    
    subplot2(nRaw,nCol,3*(tIdx-1)+1,2)
    temp(any(temp==0,2),:)=[];
    densMap=hist2(log10(temp),xbin,ybin);
    densMap=conv2(densMap,smoothCore);
    imagescXY(logXrange,logYrange,densMap)    
    colormap(gca,jet)
    set(gca,'xtick',densityRange,'xticklabel',densityLabel)
    set(gca,'ytick',densityRange,'yticklabel',densityLabel)
    xlabel({'Firing rate in' [xLabelText{tIdx} ' (Hz)']})
    ylabel({'Firing rate in' [yLabelText{tIdx}  ' (Hz)']})

    plotIdentityLine(gca,{'color','black'})
    plotIdentityLine(gca,{'color',0.99*[1,1,1]})
    box off
    title([firstState ' to ' lastState])
    fixAxis;
    clear param
    param.smothCoreSize=size(smoothCore);
    param.smotCorehSD=1;
    saveGraph('quantile20s4',[alphabet(5+tIdx) '2' 'Inh'],...
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
    
    subplot2(nRaw,nCol,3*(tIdx-1)+1,3)
    temp=[];
    hold on
    for n=1:nDiv
        plot(shuffle.(tName).example{n}(:,1),...
            shuffle.(tName).example{n}(:,2),'.','color',col(n,:));
        temp=[temp;shuffle.(tName).example{n}];
    end
    
    xlim(10.^[-3,2])
    ylim(10.^[-3,2])
    xlabel({'Firing rate in' [xLabelText{tIdx} ' (Hz)']})
    ylabel({'Firing rate in' [yLabelText{tIdx}  ' (Hz)']})
    set(gca,'xscale','log','yscale','log')
    set(gca,'xtick',10.^(-2:2:2),'ytick',10.^(-2:2:2))
    plotIdentityLine(gca,{'color','black'})
    plotIdentityLine(gca,{'color','black'})
    box off
    title('Example of shuffling')
    fixAxis;
    
    subplot2(nRaw,nCol,3*(tIdx-1)+1,4)
    temp(any(temp==0,2),:)=[];
    densMap=hist2(log10(temp),xbin,ybin);
    densMap=conv2(densMap,smoothCore);
    imagescXY(densMap)
    colormap(gca,jet)
    set(gca,'xtick',densityRange,'xticklabel',densityLabel)
    set(gca,'ytick',densityRange,'yticklabel',densityLabel)
    xlabel({'Firing rate in' [xLabelText{tIdx} ' (Hz)']})
    ylabel({'Firing rate in' [yLabelText{tIdx}  ' (Hz)']})
    plotIdentityLine(gca,{'color',0.99*[1,1,1]})
    box off
    title('Example of shuffling')
    fixAxis;
end
%%
measureNameList={'Change index','\Deltalog_{10}(Hz)'};
for tIdx=1:length(tNameList)
    tName=tNameList{tIdx};
    
    if tIdx==1
        col=colWake;
    elseif tIdx==2
        col=colNrem;
    else
        col=colRem;
    end
    firstState=dispTname{tIdx}{1};
    lastState=dispTname{tIdx}{2};
        
    for mIdx=1:length(measureList)
        measureType=measureList{mIdx};
        measureName=measureNameList{mIdx};

        subplot2(nRaw,nCol,3*(tIdx-1)+2,2*(mIdx-1)+1)    
        hold on
        for n=1:nDiv
            plot(n*[1,1],frChange.(tName).real.(measureType).mean(n)+frChange.(tName).real.(measureType).ste(n)*[-1,1],...
                'color',col(n,:))
            bar(n,frChange.(tName).real.(measureType).mean(n),'linestyle','none','faceColor',col(n,:))        
        end
        xlim([0.5,nDiv+0.5])
        fill([1:nDiv,nDiv:-1:1],[frChange.(tName).shuffle.(measureType).mean.interval(1,:),...
            fliplr(frChange.(tName).shuffle.(measureType).mean.interval(2,:))],hsv2rgb([0,0.75,0.75]),...
            'faceAlpha',0.5,'lineStyle','none')
        xlabel('Quintile')
        ylabel(measureName)
        title('Mean')
        clear param
        param.confInt=frChange.(tName).shuffle.(measureType).mean.interval;
        param.p=frChange.(tName).shuffle.(measureType).mean.p;
        
        saveGraph('quantile20s4',[alphabet(5+tIdx) '3' alphabet(mIdx) 'Inh'],...
            'multiColorBar',...
            1:nDiv,... %x
            frChange.(tName).real.(measureType).mean,... %y
            frChange.(tName).real.(measureType).ste,... %error 
            col,... %color
            get(gca),... %info
            get(get(gca,'xlabel'),'string'),... %xlabel
            get(get(gca,'ylabel'),'string'),... %ylabel
            get(get(gca,'title'),'string'),... %title,
            param,... %legend
            mfilename)

        
        
        subplot2(nRaw,nCol,3*(tIdx-1)+3,2*(mIdx-1)+1)    
        hold on
        for n=1:nDiv
            plot(n*[1,1],...
                frChange.(tName).real.(measureType).mean(n)+...
                frChange.(tName).real.(measureType).ste(n)*[-1,1]-...
                frChange.(tName).shuffle.(measureType).mean.mean(n),...
                'color',col(n,:))
            bar(n,frChange.(tName).real.(measureType).mean(n)-...
                frChange.(tName).shuffle.(measureType).mean.mean(n),'linestyle','none','faceColor',col(n,:))        
        end
        xlim([0.5,nDiv+0.5])
        fill([1:nDiv,nDiv:-1:1],...
            [frChange.(tName).shuffle.(measureType).mean.interval(1,:)-frChange.(tName).shuffle.(measureType).mean.mean,...
            fliplr(frChange.(tName).shuffle.(measureType).mean.interval(2,:)-frChange.(tName).shuffle.(measureType).mean.mean)]...
            ,hsv2rgb([0,0.75,0.75]),...
            'faceAlpha',0.5,'lineStyle','none')
        xlabel('Quintile')
        ylabel(['Deflection index'])
        title('Mean')

        clear param
        param.confInt=frChange.(tName).shuffle.(measureType).mean.interval-[1;1]*frChange.(tName).shuffle.(measureType).mean.mean;
        param.p=frChange.(tName).shuffle.(measureType).mean.p;
        param.measure=measureName;
        
         saveGraph('quantile20s4',[alphabet(5+tIdx) '4' alphabet(mIdx) 'Inh'],...
            'multiColorBar',...
            1:nDiv,... %x
            frChange.(tName).real.(measureType).mean-frChange.(tName).shuffle.(measureType).mean.mean,... %y
            frChange.(tName).real.(measureType).ste,... %error 
            col,... %color
            get(gca),... %info
            get(get(gca,'xlabel'),'string'),... %xlabel
            get(get(gca,'ylabel'),'string'),... %ylabel
            get(get(gca,'title'),'string'),... %title,
            param,... %legend
            mfilename)       
        
        
        subplot2(nRaw,nCol,3*(tIdx-1)+2,2*(mIdx-1)+2)
    
        hold on
        for n=1:nDiv
            plot(n*[1,1],frChange.(tName).real.(measureType).medianCI(:,n)',...
                'color',col(n,:))
            bar(n,frChange.(tName).real.(measureType).median(n),'linestyle','none','faceColor',col(n,:))        
        end
        xlim([0.5,nDiv+0.5])
        fill([1:nDiv,nDiv:-1:1],[frChange.(tName).shuffle.(measureType).median.interval(1,:),...
            fliplr(frChange.(tName).shuffle.(measureType).median.interval(2,:))],hsv2rgb([0,0.75,0.75]),...
            'faceAlpha',0.5,'lineStyle','none')
        xlabel('Quintile')
        ylabel(measureType)
        title('Median')    


        subplot2(nRaw,nCol,3*(tIdx-1)+3,2*(mIdx-1)+2)
    
        hold on
        for n=1:nDiv
            plot(n*[1,1],frChange.(tName).real.(measureType).medianCI(:,n)'-frChange.(tName).shuffle.(measureType).median.mean(n),...
                'color',col(n,:))
            bar(n,frChange.(tName).real.(measureType).median(n)-frChange.(tName).shuffle.(measureType).median.mean(n),'linestyle','none','faceColor',col(n,:))        
        end
        xlim([0.5,nDiv+0.5])
        fill([1:nDiv,nDiv:-1:1],[frChange.(tName).shuffle.(measureType).median.interval(1,:)-frChange.(tName).shuffle.(measureType).median.mean,...
            fliplr(frChange.(tName).shuffle.(measureType).median.interval(2,:)-frChange.(tName).shuffle.(measureType).median.mean)],hsv2rgb([0,0.75,0.75]),...
            'faceAlpha',0.5,'lineStyle','none')
        xlabel('Quintile')
        ylabel(['Deflection of ' measureType])
        title('Median')           
        
    end
end
    
ax=fixAxis;
text2(1,-0.5,['made with ' mfilename '.m'],ax,...
    {'horizontalALign','right','verticalALign','top','fontsize',4,'interpreter','none'});

subplot2(nRaw,nCol,6,1)
hold on
ax=fixAxis;
text2(0,-1,{
    ['Red bands indcates 95% confidence interval estimated by shuffling (' num2str(nShuffle) ' times)']
    ['Error bars indicates STE for mean and 95% confidence interval for median estimated by subsampling (' num2str(nShuffle) ' times)']},ax,...
    {'horizontalALign','left','verticalALign','top','fontsize',7});

%%
close all
fh=initFig4JNeuro(1);

bin=-3:0.05:2

% tNameList={'quiet2nrem','nrem2quiet','rem2quiet'};

for type=1:3
    tName=tNameList{type}
    switch type
        case 1
            firstName={'Last min' 'of wake'};
            lastName={'First 1/3' 'of non-REM'};
            col=[colWake(5,:);colNrem(2,:)];
        case 2
            firstName={'Last 1/3' 'of non-REM'};
            lastName={'First min' 'pf wake'};
            col=[colNrem(2,:);colWake(5,:)];
        case 3
            firstName={'Last 1/3' 'of REM'};
            lastName={'First min' 'of wake'};
            col=[colRem(2,:);colWake(5,:)];
         otherwise
            continue
    end
    
    tempFR=cat(1,realData.(tName).fr{:});
    tempFR(any(tempFR==0,2),:)=[];
    tempFR=log10(tempFR);
    
    subplot2(6,2,type,1)
    hold on
    clear xVal yVal
    for n=1:2
        yVal{n}=hist(tempFR(:,n),bin)/size(tempFR,1)*100;
        xVal{n}=bin;
        plot(xVal{n},yVal{n},'color',col(n,:))
    end
    xlabel('Firing rate (Hz)')
    set(gca,'xtick',-3:2,'xticklabel',{'10^{-3}','10^{-2}','10^{-1}','10^{-0}','10^{1}','10^{2}'})
    ylabel('% of cells')
    xlim([-2.5,1.5])
    
    param.n=size(tempFR,1);
    param.stateName={firstName,lastName};
    saveGraph('quantile20s4',['e' num2str(5+type) 'Inh'],...
        'line',...
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
    
end

    

    %%
%print(fh,'~/Dropbox/Quantile/preliminary/changeInStableWaking_20s.pdf','-dpdf')













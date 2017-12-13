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
    'stableWake20s'
    'stateChange20s'
    'trisecFiring'
    'exLowTrisecFiring'
    ...'eventFiring'
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
cellTypeList=fieldnames(trisecFiring.(dList{1}));
cellTypeList(strcmp(cellTypeList,'madeby'))=[];
measureTypeList=fieldnames(trisecFiring.(dList{1}).(cellTypeList{1}))

for dIdx=1:length(dList)
    dName=dList{dIdx};
    for idx=1:size(behavior.(dName).list,1)
        if behavior.(dName).list(idx,3)==1
            for cellTypeIdx=1:length(cellTypeList)
                cellType=cellTypeList{cellTypeIdx};
                for measureTYpeIdx=1:length(measureTypeList)
                    measureType=measureTypeList{measureTYpeIdx};
                    trisecFiring.(dName).(cellType).(measureType){idx}=...
                        exLowTrisecFiring.(dName).(cellType).(measureType){idx};
                end
            end
        end
    end
end

%%
typeList={};
clear Zscore
nShuffle=2000;
nDiv=5;

colNrem=hsv2rgb([2/3*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colRem=hsv2rgb([5/6*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colIntLow=hsv2rgb([5/12*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colLow=hsv2rgb([1/6*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colWake=hsv2rgb([0*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');

typeList={'nrem','rem','nrem2rem','rem2nrem','nrem2rem2nrem','rem2nrem2rem','quiet2nrem','nrem2quiet',...
        'rem2quiet','quiet','exLOW','interLOW','LOW'};
    
toBeCalculated=find(~cellfun(@isempty,strfind(typeList,'nrem')));
toBeCalculated(toBeCalculated==find(strcmp(typeList,'rem2nrem2rem')))=[];

labelText.nrem={'first 1/3 of non-REM','last 1/3 of non-REM'};
labelText.rem={'first 1/3 of REM','last 1/3 of REM'};
labelText.nrem2rem={'last 1/3 of non-REM','first 1/3 of REM'};
labelText.rem2nrem={'last 1/3 of REM','first 1/3 of non-REM'};
labelText.nrem2rem2nrem={'last 1/3 of non-REM_i','first 1/3 of non-REM_{i+1}'};
labelText.rem2nrem2rem={'last 1/3 of REM_i','first 1/3 of REM_{i+1}'};    
labelText.quiet2nrem={'last 1/3 of resting wake','first 1/3 of non-REM'};
labelText.nrem2quiet={'last 1/3 of non-REM','first 1/3 of resting wake'};
labelText.rem2quiet={'last 1/3 of REM','first 1/3 of resting wake'};    
labelText.quiet={'first 5 min of wake','last 5 min of wake'};
labelText.exLOW={'first 1/3 of non-REM','last 1/3 of non-REM'};
labelText.interLOW={'inter-LOW_i','inter-Low_{i+1}'};
labelText.LOW={'LOW_i','Low_{i+1}'};

titleText.nrem={'Within non-REM'};
titleText.rem={'Within REM'};
titleText.nrem2rem={'Non-REM to REM'};
titleText.rem2nrem={'REM to non-REM'};
titleText.nrem2rem2nrem={'Non-REM_i/REM/non-REM_{i+1}'};
titleText.rem2nrem2rem={'REM_i/non-REM/REM_{i+1}'};    
titleText.quiet2nrem={'Wake to non-REM'};
titleText.nrem2quiet={'Non-REM to wake'};
titleText.rem2quiet={'REM to wake'};    
titleText.quiet={'Within stable wake'};
titleText.exLOW={'Within non-REM' 'excluding LOW'};
titleText.interLOW={'inter-LOW_i/LOW/inter-Low_{i+1}'};
titleText.LOW={'LOW_i/inter-LOW/Low_{i+1}'};

color.nrem=colNrem;
color.rem=colRem;
color.nrem2rem=colNrem;
color.rem2nrem=colRem;
color.nrem2rem2nrem=colNrem;
color.rem2nrem2rem=colRem;    
color.quiet2nrem=colWake;
color.nrem2quiet=colNrem;
color.rem2quiet=colRem;    
color.quiet=colWake;
color.exLOW=colNrem;
color.interLOW=colIntLow;
color.LOW=colLow;

%%
tempTypeList={'nrem','nrem2rem','rem2nrem','nrem2rem2nrem','quiet2nrem','nrem2quiet'};

for typeIdx=1:length(tempTypeList)
    typeName=tempTypeList{typeIdx};
    
    if ~any(strcmp(typeList(toBeCalculated),typeName))
        continue
    end
        
    display([datestr(now) ' start ' typeName])
    Zscore.(typeName)=[];
    
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        display(['   ' datestr(now) ' - ' dName])
        stateIdx=stateChange.(dName).(typeName);
        if isempty(stateIdx);
            continue
        end

        temp=[];
        for n=1:size(stateIdx,2)
            temp=[temp,cat(1,trisecFiring.(dName).pyr.zscore{stateIdx(:,n)})];
        end
        
        if size(stateIdx,2)==1
            idxToUse=[1,3];
        elseif size(stateIdx,2)==2
            idxToUse=[3,4];
        elseif size(stateIdx,2)==3
            idxToUse=[3,7];
        else
            continue
        end
        
        Zscore.(typeName)=[Zscore.(typeName);temp(:,idxToUse)];
        
        
    end

end



%%
clear dZ
for calcIdx=1:length(toBeCalculated);
    typeName=typeList{toBeCalculated(calcIdx)};
    
    display([datestr(now) ' start shuffling ' typeName])

    ranking=tiedrank(Zscore.(typeName)(:,1))/size(Zscore.(typeName),1);
    tempDiff=diff(Zscore.(typeName),1,2);
    for n=1:nDiv
        temp=(tempDiff(ranking>(n-1)/nDiv & ranking<=n/nDiv));
        dZ.(typeName).mean(n)=nanmean(temp);
        dZ.(typeName).ste(n)=nanste(temp);
        dZ.(typeName).n(n)=sum(~isnan(temp));
    end
    
    
    clear shuffledMean
    
    for ite=1:nShuffle
        shuffleIdx=rand(size(Zscore.(typeName),1),1)>0.5;
        shuffleIdx=[shuffleIdx,1-shuffleIdx]*size(Zscore.(typeName),1)+repmat((1:size(Zscore.(typeName),1))',1,2);

        temp=Zscore.(typeName)(shuffleIdx);
        ranking=tiedrank(temp(:,1))/size(temp,1);
        tempDiff=diff(temp,1,2);
        for n=1:nDiv
            shuffledMean(ite,n)=nanmean(tempDiff(ranking>(n-1)/nDiv & ranking<=n/nDiv));
        end
    end
    
    shuffledMean=sort(shuffledMean);
        
    dZ.(typeName).shuffled.mean=mean(shuffledMean,1);    
    dZ.(typeName).shuffled.confInt=shuffledMean([ceil(nShuffle*0.975),floor(nShuffle*0.025)],:);
    
    for n=1:nDiv
        lowerBond=find(shuffledMean(:,n)<dZ.(typeName).mean(n),1,'last');
        if isempty(lowerBond)
            lowerBond=0;
        end
        upperBond=find(shuffledMean(:,n)>dZ.(typeName).mean(n),1,'first');
        if isempty(upperBond)
            upperBond=nShuffle;
        end
        dZ.(typeName).p(n)=1-max([(nShuffle/2-lowerBond)/nShuffle*2,(upperBond-nShuffle/2)/nShuffle*2]);          
    end
end
    
%%
close all
fh=initFig4Nature(2);
nCol=6;
nRaw=ceil(length(typeList)/2);

mu = [0 0];
Sigma = [1 0; 0 1];
smoothCoreBin = -2:2; smoothCoreBin = -3:3;
[smoothCoreBin,smoothCoreBin] = meshgrid(smoothCoreBin,smoothCoreBin);
smoothCore = mvnpdf([smoothCoreBin(:) smoothCoreBin(:)],mu,Sigma);
smoothCore = reshape(smoothCore,length(smoothCoreBin),length(smoothCoreBin));
smoothCore=smoothCore/sum(sum(smoothCore));

densityRange=-3:3;
xRange=(densityRange([1,end]));
yRange=(densityRange([1,end]));
xbin=linspace(xRange(1),xRange(2),50);
ybin=linspace(yRange(1),yRange(2),50);

for calcIdx=1:length(toBeCalculated);
    typeIdx=toBeCalculated(calcIdx);
    typeName=typeList{typeIdx};
    
    subplot2(nRaw,nCol,mod(typeIdx-1,nRaw)+1,1+3*(typeIdx>nRaw))

    densMap=hist2(Zscore.(typeName),xbin,ybin);
    densMap=densMap/size(Zscore.(typeName),1)*100;
    densMap=conv2(densMap,smoothCore);
    imagescXY(xRange,yRange,densMap);
    set(gca,'clim',[0,0.5])
    colormap(gca,jet)
    xlabel({'Firing rate in' [labelText.(typeName){1} ' (z)']})
    ylabel({'Firing rate in' [labelText.(typeName){2} ' (z)']})
    title(titleText.(typeName))

    plotIdentityLine(gca,{'color',0.999*[1,1,1]})
    clear param
    param.rawData=Zscore.(typeName);
    param.cLim=get(gca,'clim');
    
    saveGraph('quantile20s6',[alphabet(typeIdx) '2' 'exLow'],...
        'spectrum',...
        [xRange,yRange],... %x
        densMap,... %y
        [],... %error 
        [],... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename)
    
    subplot2(nRaw,nCol,mod(typeIdx-1,nRaw)+1,2+3*(typeIdx>nRaw))
    hold on
    fill([1:nDiv,nDiv:-1:1],...
        [dZ.(typeName).shuffled.confInt(1,:),fliplr(dZ.(typeName).shuffled.confInt(2,:))],...
        0.5*[1,1,1],'linestyle','none','faceAlpha',0.5)
    hold on
    for n=1:nDiv
        plot(n*[1,1],dZ.(typeName).mean(n)+dZ.(typeName).ste(n)*[2*(dZ.(typeName).mean(n)>0)-1,0],...
            '-','color',color.(typeName)(n,:))
        bar(n,dZ.(typeName).mean(n),'linestyle','none','facecolor',color.(typeName)(n,:))
    end    
    title(titleText.(typeName))
    xlabel('Quintile')
    ylabel('\DeltaFiring rate (z)')
    xlim([0,nDiv+1])

    box off

    clear param
    param.n=dZ.(typeName).n;
    param.confInt=dZ.(typeName).shuffled.confInt;
    param.shuffleMean=dZ.(typeName).shuffled.mean;
    param.p=dZ.(typeName).p;
    param.nShuffle=nShuffle;

    saveGraph('quantile20s6',[alphabet(typeIdx) '3a'  'exLow'],...
        'multiColorBar',...
        1:nDiv,... %x
        dZ.(typeName).mean,... %y
        dZ.(typeName).ste,... %error 
        color.(typeName),... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename)    
    

    
    subplot2(nRaw,nCol,mod(typeIdx-1,nRaw)+1,3+3*(typeIdx>nRaw))

       fill([1:nDiv,nDiv:-1:1],...
        [dZ.(typeName).shuffled.confInt(1,:)-dZ.(typeName).shuffled.mean,...
        fliplr(dZ.(typeName).shuffled.confInt(2,:)-dZ.(typeName).shuffled.mean)],...
        0.5*[1,1,1],'linestyle','none','faceAlpha',0.5)
     hold on
    for n=1:nDiv
        plot(n*[1,1],dZ.(typeName).mean(n)-dZ.(typeName).shuffled.mean(n)+dZ.(typeName).ste(n)*[2*(dZ.(typeName).mean(n)>dZ.(typeName).shuffled.mean(n))-1,0],...
            '-','color',color.(typeName)(n,:))
        bar(n,dZ.(typeName).mean(n)-dZ.(typeName).shuffled.mean(n),'linestyle','none','facecolor',color.(typeName)(n,:))
    end    

    title(titleText.(typeName))
    xlabel('Quintile')
    ylabel('Deflection of \DeltaZ')
    xlim([0,nDiv+1])
    box off
    
    clear param
    param.n=dZ.(typeName).n;
    param.confInt=dZ.(typeName).shuffled.confInt-[dZ.(typeName).shuffled.mean;dZ.(typeName).shuffled.mean];
    param.shuffleMean=dZ.(typeName).shuffled.mean;
    param.p=dZ.(typeName).p;
    param.nShuffle=nShuffle;
    
    for n=1:nDiv
        text(n,...
            dZ.(typeName).mean(n)-dZ.(typeName).shuffled.mean(n)+dZ.(typeName).ste(n)*(2*(dZ.(typeName).mean(n)>dZ.(typeName).shuffled.mean(n))-1),...
            getSigText(dZ.(typeName).p(n)),'horizontalAlign','center','verticalALign','top')
    end
    
    saveGraph('quantile20s6',[alphabet(typeIdx) '4a'  'exLow'],...
        'multiColorBar',...
        1:nDiv,... %x
        dZ.(typeName).mean-dZ.(typeName).shuffled.mean,... %y
        dZ.(typeName).ste,... %error 
        color.(typeName),... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename)      
    
end
        
addScriptName(mfilename)
% print(fh,'~/Dropbox/Quantile/preliminary/z-scores_20s.pdf','-dpdf')



    
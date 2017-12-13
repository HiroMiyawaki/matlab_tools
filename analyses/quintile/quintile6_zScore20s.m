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
    'firing'
    ...'eventRate'
    'stableSleep20s'
    'stableWake20s'
    'stateChange20s'
    'trisecFiring'
    'eventFiring'
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
typeList={};
clear Zscore
nShuffle=2000;
nDiv=5;

colNrem=hsv2rgb([2/3*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colRem=hsv2rgb([5/6*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colIntLow=hsv2rgb([5/12*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colLow=hsv2rgb([1/6*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colWake=hsv2rgb([0*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');

typeList={'nrem','rem','nrem2rem','rem2nrem','nrem2rem2nrem',...
         'rem2nrem2rem','quiet2nrem','nrem2quiet','rem2quiet','quiet',...
         'exLOW','interLOW','LOW','quiet2nrem1min','nrem2quiet1min',...
         'rem2quiet1min','nrem2rem2nremMean','rem2nrem2remMean','quiet2quiet'};
     
toBeCalculated=1:length(typeList);

labelText.nrem={'first 1/3 of non-REM','last 1/3 of non-REM'};
labelText.rem={'first 1/3 of REM','last 1/3 of REM'};
labelText.nrem2rem={'last 1/3 of non-REM','first 1/3 of REM'};
labelText.rem2nrem={'last 1/3 of REM','first 1/3 of non-REM'};
labelText.nrem2rem2nrem={'last 1/3 of non-REM_i','first 1/3 of non-REM_{i+1}'};
labelText.rem2nrem2rem={'last 1/3 of REM_i','first 1/3 of REM_{i+1}'};    
labelText.quiet2nrem={'last 1/3 of resting wake','first 1/3 of non-REM'};
labelText.nrem2quiet={'last 1/3 of non-REM','first 1/3 of resting wake'};
labelText.rem2quiet={'last 1/3 of REM','first 1/3 of resting wake'};    
labelText.quiet={'first min of wake','last min of wake'};
labelText.exLOW={'first 1/3 of non-REM','last 1/3 of non-REM'};
labelText.interLOW={'inter-LOW_i','inter-Low_{i+1}'};
labelText.LOW={'LOW_i','Low_{i+1}'};
labelText.quiet2nrem1min={'last min of wake', 'first 1/3 of non-REM'};
labelText.nrem2quiet1min={'last 1/3 of non-REM' , 'first min of wake'};
labelText.rem2quiet1min={'last 1/3 of REM' , 'first min of wake'};
labelText.nrem2rem2nremMean={'non-REM_i','non-REM_{i+1}'};
labelText.rem2nrem2remMean={'REM_i','first REM_{i+1}'};    
labelText.quiet2quiet={'wake_i', 'wake_{i+1}'}

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
titleText.quiet2nrem1min={'Wake to non-REM'};
titleText.nrem2quiet1min={'Non-REM to wake'};
titleText.rem2quiet1min={'REM to wake'};    
titleText.nrem2rem2nremMean={'Non-REM_i/REM/non-REM_{i+1}'};
titleText.rem2nrem2remMean={'REM_i/non-REM/REM_{i+1}'};    
titleText.quiet2quiet={'wake_i/sleep/wake_{i+1}'}

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
color.quiet2nrem1min=colWake;
color.nrem2quiet1min=colNrem;
color.rem2quiet1min=colRem;    
color.nrem2rem2nremMean=colNrem;
color.rem2nrem2remMean=colRem;    
color.quiet2quiet=colWake;

%%
tempTypeList={'nrem','rem','nrem2rem','rem2nrem','nrem2rem2nrem','rem2nrem2rem','quiet2nrem','nrem2quiet','rem2quiet'};

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
tempTypeList={'quiet'};

windowSize=1*60e6;

typeIdx=1;
typeName=tempTypeList{typeIdx};

if any(strcmp(typeList(toBeCalculated),typeName))

Zscore.(typeName)=[];
display([datestr(now) ' start ' typeName])

for dIdx=1:length(dList)
    dName=dList{dIdx};
    display(['   ' datestr(now) ' - ' dName])
    
    pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));
    
    for idx=1:size(stableWake.(dName).time,1)
        
        clear subset
        for cIdx=1:length(pyr)
            subset{cIdx}=pyr(cIdx).time(...
                pyr(cIdx).time>stableWake.(dName).time(idx,1) &...
                pyr(cIdx).time<stableWake.(dName).time(idx,2));
        end
        
        tempFR=[];
        for cIdx=1:length(pyr)
            for timeType=1:2
                if timeType==1
                    tRange=stableWake.(dName).time(idx,1)+[0,windowSize];
                else
                    tRange=stableWake.(dName).time(idx,2)-[windowSize,0];
                end

                fr(timeType)=sum(subset{cIdx}>tRange(1)&subset{cIdx}<tRange(2))/(windowSize/1e6);
            end
            if any(fr~=0)
                tempFR(end+1,:)=(fr-pyr(cIdx).meanF)/pyr(cIdx).stdF;
            end
        end
        Zscore.(typeName)=[Zscore.(typeName);tempFR];
    end
end

end
%%
tempTypeList={'exLOW'};

typeIdx=1;
typeName=tempTypeList{typeIdx};

if any(strcmp(typeList(toBeCalculated),typeName))
Zscore.(typeName)=[];
nPeriods=3;

display([datestr(now) ' start ' typeName])
highDurThreshold=2e6;
for dIdx=1:length(dList)
    dName=dList{dIdx};
    display(['   ' datestr(now) ' - ' dName])
    
    pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));
    nrem=behavior.(dName).list(stateChange.(dName).nrem,1:2);
    for idx=1:size(nrem,1)        
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
        for cIdx=1:length(pyr);
            spkSub=pyr(cIdx).time(pyr(cIdx).time>nremTime{1}(1)& pyr(cIdx).time<nremTime{2}(2));
            
            spkNrem(1)=sum(spkSub<nremTime{1}(2));
            spkNrem(2)=sum(spkSub>nremTime{2}(1));
            for n=1:2
                spkLow(n)=sum(isInRange(low{n},spkSub));
            end
            durNrem=cellfun(@diff,nremTime)/1e6;
            durLow=cellfun(@(x) sum(diff(x,1,2)),low)/1e6;
            
            tempFR(cIdx,:)=((spkNrem-spkLow)./(durNrem-durLow)-pyr(cIdx).meanF)/pyr(cIdx).stdF;
        end
        tempFR(any(isnan(tempFR),2),:)=[];
        Zscore.(typeName)=[Zscore.(typeName);tempFR];

    end

end
end
%%
tempTypeList={'interLOW'};

typeIdx=1;
typeName=tempTypeList{typeIdx};
if any(strcmp(typeList(toBeCalculated),typeName))
Zscore.(typeName)=[];

highDurThreshold=2e6;

display([datestr(now) ' start ' typeName])

for dIdx=1:length(dList)
    dName=dList{dIdx};
    display(['   ' datestr(now) ' - ' dName])
    pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));
    nrem=behavior.(dName).list(stateChange.(dName).nrem,1:2);
    for idx=1:size(nrem,1)        
        clear subset
        for cIdx=1:length(pyr)
            subset{cIdx}=pyr(cIdx).time(...
                    pyr(cIdx).time>nrem(idx,1) &...
                    pyr(cIdx).time<nrem(idx,2));
        end
        
        low=HL.(dName).low(HL.(dName).low(:,2)>nrem(idx,1)&HL.(dName).low(:,1)<nrem(idx,2),:);
        
        if isempty(low);continue; end
        
        highPair{1}=[];
        highPair{2}=[];
        for lowIdx=1:size(low,1)
            if lowIdx==1
                begHigh=nrem(idx,1);
            else
                begHigh=low(lowIdx-1,2);
            end
            
            if lowIdx==size(low,1)
                endHigh=nrem(idx,2);
            else
                endHigh=low(lowIdx+1,1);
            end
            
            if low(lowIdx,1)-begHigh>highDurThreshold && ...
                endHigh-low(lowIdx,2)>highDurThreshold
                highPair{1}(end+1,:)=[begHigh,low(lowIdx,1)];
                highPair{2}(end+1,:)=[low(lowIdx,2),endHigh];            
            end
        end
        
        for highIdx=1:size(highPair{1},1)
            clear tempFR
            for timeType=1:2
                tRange=highPair{timeType}(highIdx,:);

                for cIdx=1:length(pyr)
                    fr=sum(subset{cIdx}>tRange(1)&subset{cIdx}<tRange(2))/(diff(tRange)/1e6);
                    tempFR(cIdx,timeType)=(fr-pyr(cIdx).meanF)/pyr(cIdx).stdF;
                end
            end
            
            Zscore.(typeName)=[Zscore.(typeName);tempFR];
            
        end        
    end
    
end
end
%%
tempTypeList={'LOW'};

typeIdx=1;
typeName=tempTypeList{typeIdx};
if any(strcmp(typeList(toBeCalculated),typeName))
display([datestr(now) ' start ' typeName])
Zscore.(typeName)=[];

highDurThreshold=2e6;
for dIdx=1:length(dList)
    dName=dList{dIdx};
    pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));
    nrem=behavior.(dName).list(stateChange.(dName).nrem,1:2);
    for idx=1:size(nrem,1)        
        clear subset
        for cIdx=1:length(pyr)
            subset{cIdx}=pyr(cIdx).time(...
                    pyr(cIdx).time>nrem(idx,1) &...
                    pyr(cIdx).time<nrem(idx,2));
        end
        
        low=HL.(dName).low(HL.(dName).low(:,2)>nrem(idx,1)&HL.(dName).low(:,1)<nrem(idx,2),:);
        
        if size(low,1)<2;continue; end
        
        lowPair{1}=[];
        lowPair{2}=[];
        for lowIdx=1:size(low,1)-1
            if low(lowIdx+1,1)-low(lowIdx,2)>highDurThreshold
                lowPair{1}(end+1,:)=low(lowIdx,:);
                lowPair{2}(end+1,:)=low(lowIdx+1,:);            
            end
        end
        
        for lowIdx=1:size(lowPair{1},1)
            clear tempFR
            for timeType=1:2
                tRange=lowPair{timeType}(lowIdx,:);

                for cIdx=1:length(pyr)
                    fr=sum(subset{cIdx}>tRange(1)&subset{cIdx}<tRange(2))/(diff(tRange)/1e6);
                    tempFR(cIdx,timeType)=(fr-pyr(cIdx).meanF)/pyr(cIdx).stdF;
                end
            end

            Zscore.(typeName)=[Zscore.(typeName);tempFR];

        end
        
    end
    
end
end

%%
tempTypeList={'quiet2nrem1min','nrem2quiet1min','rem2quiet1min'};
wakeDur=1*60e6;
for typeIdx=1:length(tempTypeList)
    typeName=tempTypeList{typeIdx};
    stateName=typeName(1:end-4);
    
    if ~any(strcmp(typeList(toBeCalculated),typeName))
        continue
    end
        
    display([datestr(now) ' start ' typeName])
    Zscore.(typeName)=[];
    
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        display(['   ' datestr(now) ' - ' dName])
        dName=dList{dIdx};

        target=stateChange.(dName).(stateName);        
        if isempty(target)
            continue
        end
        pyr=spikes.(dName)([spikes.(dName).quality]<4& cellfun(@all, {spikes.(dName).isStable}));
        temp=[];
        
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
            for cIdx=1:length(pyr)
                temp=sum(pyr(cIdx).time>wakePeriod(1) &  pyr(cIdx).time<wakePeriod(2))/(wakeDur/1e6);
                wakeFr(cIdx)=(temp-pyr(cIdx).meanF)/pyr(cIdx).stdF;
            end
            
            if behavior.(dName).list(target(idx,1),3)==3
                tempFR=[wakeFr',...
                    trisecFiring.(dName).pyr.zscore{target(idx,2)}(:,1)];
            else
                tempFR=[trisecFiring.(dName).pyr.zscore{target(idx,1)}(:,3),...
                    wakeFr'];
            end
        
            Zscore.(typeName)=[Zscore.(typeName);tempFR];
        end
        
        
    end

end
%%
tempTypeList={'nrem2rem2nremMean','rem2nrem2remMean'};

for typeIdx=1:length(tempTypeList)
    typeName=tempTypeList{typeIdx};
    stateName=typeName(1:end-4);
    
    if ~any(strcmp(typeList(toBeCalculated),typeName))
        continue
    end
        
    display([datestr(now) ' start ' typeName])
    Zscore.(typeName)=[];
    
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        display(['   ' datestr(now) ' - ' dName])
        stateIdx=stateChange.(dName).(stateName);
        
        if isempty(stateIdx)
            continue
        end

        temp=[];
        for n=1:size(stateIdx,1)
            temp=[temp;cat(1,firing.(dName).pyr.zscore{stateIdx(n,[1,3])})'];
        end
        
        Zscore.(typeName)=[Zscore.(typeName);temp];
        
        
    end

end
%%
tempTypeList={'quiet2quiet'};
wakeDur=1*60e6;
for typeIdx=1:length(tempTypeList)
    typeName=tempTypeList{typeIdx};
    
    if ~any(strcmp(typeList(toBeCalculated),typeName))
        continue
    end
        
    display([datestr(now) ' start ' typeName])
    Zscore.(typeName)=[];
    
    for dIdx=1:length(dList)
        dName=dList{dIdx};

        pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));

        for idx=1:size(stableSleep.(dName).time,1)

            befIdx=find(behavior.(dName).list(:,2)>stableSleep.(dName).time(idx,1)-wakeDur&...
                 behavior.(dName).list(:,1)<stableSleep.(dName).time(idx,1));

            aftIdx=find(behavior.(dName).list(:,2)>stableSleep.(dName).time(idx,2)&...
                 behavior.(dName).list(:,1)<stableSleep.(dName).time(idx,2)+wakeDur);

            if any(behavior.(dName).list([befIdx;aftIdx],3)<3)
                continue
            end

            clear tempFR
            for timeType=1:2
                if timeType==1
                    tRange=stableSleep.(dName).time(idx,1)-[wakeDur,0];
                else
                    tRange=stableSleep.(dName).time(idx,2)+[0,wakeDur];
                end

                for cIdx=1:length(pyr)
                    temp=sum(pyr(cIdx).time>tRange(1)&pyr(cIdx).time<tRange(2))/(wakeDur/1e6);
                    tempFR(cIdx,timeType)=(temp-pyr(cIdx).meanF)/pyr(cIdx).stdF;
                end
            end
        
            Zscore.(typeName)=[Zscore.(typeName);tempFR];
        end
        
        
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
        dZ.(typeName).mean(n)=mean(temp);
        dZ.(typeName).ste(n)=ste(temp);
        dZ.(typeName).n(n)=length(temp);
    end
    
    
    clear shuffledMean
    
    for ite=1:nShuffle
        shuffleIdx=rand(size(Zscore.(typeName),1),1)>0.5;
        shuffleIdx=[shuffleIdx,1-shuffleIdx]*size(Zscore.(typeName),1)+repmat((1:size(Zscore.(typeName),1))',1,2);

        temp=Zscore.(typeName)(shuffleIdx);
        ranking=tiedrank(temp(:,1))/size(temp,1);
        tempDiff=diff(temp,1,2);
        for n=1:nDiv
            shuffledMean(ite,n)=mean(tempDiff(ranking>(n-1)/nDiv & ranking<=n/nDiv));
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
    
    saveGraph('quantile20s6',[alphabet(typeIdx) '2'],...
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

    saveGraph('quantile20s6',[alphabet(typeIdx) '3a'],...
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
    
    saveGraph('quantile20s6',[alphabet(typeIdx) '4a'],...
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
%%
nDiv=5;

nCol=3;
nRaw=ceil(length(typeList)/3);
initFig4JNeuro(2)
for calcIdx=1:length(toBeCalculated);
    typeIdx=toBeCalculated(calcIdx);
    typeName=typeList{typeIdx};
    ranking=tiedrank(Zscore.(typeName)(:,1))/size(Zscore.(typeName),1);
    
    subplot2(nRaw,nCol,mod(typeIdx-1,nRaw)+1,ceil(typeIdx/nRaw))
    hold on
    xVal={};
    yVal={};
    for n=1:nDiv
        xVal{n}=Zscore.(typeName)(ranking>(n-1)/nDiv&ranking<=n/nDiv,1);
        yVal{n}=Zscore.(typeName)(ranking>(n-1)/nDiv&ranking<=n/nDiv,2);
        plot(xVal{n},yVal{n},'.','color',color.(typeName)(n,:),'markersize',1)
    end
    
    xlabel({'Firing rate in' [labelText.(typeName){1} ' (z)']})
    ylabel({'Firing rate in' [labelText.(typeName){2} ' (z)']})
    title(titleText.(typeName))

    plotIdentityLine(gca,{'color',0*[1,1,1]})
    clear param
    param.n=size(Zscore.(typeName),1);
    
    saveGraph('quantile20s6',[alphabet(typeIdx) '1'],...
        'scatter',...
        xVal,... %x
        yVal,... %y
        [],... %error 
        color.(typeName),... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename)

end
    
    
    
    

    
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

highDurThreshold=2e6;
FR.interLOW=[];
for dIdx=1:length(dList)
    dName=dList{dIdx};
    display([datestr(now) ' - ' dName])
    pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));
    nrem=behavior.(dName).list(stateChange.(dName).nrem,1:2);
    for idx=1:size(nrem,1)
        display(['    ' datestr(now) ' ' num2str(idx) '/' num2str(size(nrem,1)) 'in ' dName])
        
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
                    tempFR(cIdx,timeType)=sum(subset{cIdx}>tRange(1)&subset{cIdx}<tRange(2))/(diff(tRange)/1e6);
                end
            end

            tempFR(any(tempFR==0,2),:)=[];
            
            FR.interLOW=[FR.interLOW;tempFR];
            
        end        
    end
    
end

%%

FR.LOW=[];
highDurThreshold=2e6;
for dIdx=1:length(dList)
    dName=dList{dIdx};
    display([datestr(now) ' - ' dName])
    pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));
    nrem=behavior.(dName).list(stateChange.(dName).nrem,1:2);
    for idx=1:size(nrem,1)
        display(['    ' datestr(now) ' ' num2str(idx) '/' num2str(size(nrem,1)) 'in ' dName])
        
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
                    tempFR(cIdx,timeType)=sum(subset{cIdx}>tRange(1)&subset{cIdx}<tRange(2))/(diff(tRange)/1e6);
                end
            end

            tempFR(any(tempFR==0,2),:)=[];
            FR.LOW=[FR.LOW;tempFR];


        end
        
    end
    
end

%%

highDurThreshold=2e6;
nPeriods=3;
FR.nrem=[];
clear low
for dIdx=1:length(dList)
    dName=dList{dIdx};
    display([datestr(now) ' - ' dName])
    
    pyr=spikes.(dName)([spikes.(dName).quality]<4 & cellfun(@all,{spikes.(dName).isStable}));
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
        for cIdx=1:length(pyr);
            spkSub=pyr(cIdx).time(pyr(cIdx).time>nremTime{1}(1)& pyr(cIdx).time<nremTime{2}(2));
            
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
        FR.nrem=[FR.nrem;tempFR];

 
    end

end
    
%%
close all
fh=initFig4JNeuro(1);

bin=-3:0.05:2
col(1,:)=0*[1,1,1];
col(2,:)=0.5*[1,1,1];

for type=1:4
    switch type
        case 1
            sName='interLOW';
            firstName='Inter-LOW_i';
            lastName='Inter-LOW_{i+1}';
        case 4
            sName='LOW';
            firstName='LOW_i';
            lastName='LOW_{i+1}';
        case 2
            sName='nrem';
            firstName='First 1/3';
            lastName='Last 1/3';
        otherwise
            continue
    end
    subplot2(6,2,type,1)
    hold on
    for n=1:2
        yVal{n}=hist(log10(FR.(sName)(:,n)),bin)/size(FR.(sName),1)*100;
        xVal{n}=bin;
        plot(xVal{n},yVal{n},'color',col(n,:))
    end
    xlabel('Firing rate (Hz)')
    set(gca,'xtick',-3:2,'xticklabel',{'10^{-3}','10^{-2}','10^{-1}','10^{-0}','10^{1}','10^{2}'})
    ylabel('% of cells')
    xlim([-2.5,1.5])
    
    param.n=size(FR.(sName),1);
    param.stateName={firstName,lastName};
    saveGraph('quantile20s5',['e' num2str(type)],...
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

    
    
    
    
    
    
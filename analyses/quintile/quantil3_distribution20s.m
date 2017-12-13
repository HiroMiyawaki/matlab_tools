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
    ...'HLfine'
    ...'onOff'
    ...'hpcSWA'
    ...'pfcSWA'
    ...'recStart'
    ...'position'
    ...'speed'
    ...'spectrum'
    ...'spikes'
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

% HL=HLfine;
dList=fieldnames(basics);


%%
stateList={'nrem2rem','rem2nrem'};

for sIdx=1:length(stateList)
    sName=stateList{sIdx};
    FR.(sName)=[];
    Z.(sName)=[];
    for dIdx=1:length(dList)
        dName=dList{dIdx};        
        
        temp=[cat(1,trisecFiring.(dName).pyr.rate{stateChange.(dName).(sName)(:,1)}),...
              cat(1,trisecFiring.(dName).pyr.rate{stateChange.(dName).(sName)(:,2)})];        
        FR.(sName)=[FR.(sName);temp(:,[3,4])];                
        temp=[cat(1,trisecFiring.(dName).pyr.zscore{stateChange.(dName).(sName)(:,1)}),...
              cat(1,trisecFiring.(dName).pyr.zscore{stateChange.(dName).(sName)(:,2)})];        
        Z.(sName)=[Z.(sName);temp(:,[3,4])];                
    end
end
%%
clf

colNrem=hsv2rgb([2/3*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colRem=hsv2rgb([5/6*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');

colors.nrem2rem=[colNrem(2,:);colRem(2,:)];
colors.rem2nrem=[colRem(2,:);colNrem(2,:)];

titleText.nrem2rem='Non-REM to REM';
titleText.rem2nrem='REM to non-REM';
stateText.nrem2rem={{'Last 1/3' 'of non-REM'},{'First 1/3' 'of REM'}};
stateText.rem2nrem={{'Last 1/3' 'of REM'},{'First 1/3' 'of non-REM'}};
close all
fh=initFig4JNeuro(1);
for sIdx=1:length(stateList)*2
    subplot(6,1,sIdx)
    hold on
    sName=stateList{mod(sIdx-1,2)+1};
    if sIdx<=length(stateList)
        temp=FR.(sName)(:,[1,end]);
        temp(any(temp==0,2),:)=[];
        temp=log10(temp)
        
        bin=-2.5:0.1:1.3;
        xText='Fring rate (log_{10} Hz)';
        xTickPos=-2:1:1;
        xTickLabel={'10^{-2}','10^{-1}','10^{0}','10^{1}'};
        xRange=[-2.5,1.3];
    else
        temp=Z.(sName)(:,[1,end]);
        xText='Fring rate (z)';

        bin=-3.5:0.1:4.5;
        xTickPos=-2:2:4;
        xTickLabel=xTickPos;
        xRange=[-3,4];
    end
    
    clear xVal yVal
    col=colors.(sName);
    for n=1:2
        xVal{n}=bin;
        yVal{n}=hist(temp(:,n),bin)/length(temp)*100;
        plot(xVal{n},yVal{n},'-','color',col(n,:))
    end
    set(gca,'xtick',xTickPos,'xticklabel',xTickLabel)
    title(titleText.(sName))
    xlabel(xText)
    ylabel('% of cells')
    xlim(xRange)
    
    param.n=length(temp);
    param.stateName=stateText.(sName);
    saveGraph('quantile20s3',['e' num2str(sIdx)],...
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
stateList={'nrem2rem2nrem','rem2nrem2rem'};

for sIdx=1:length(stateList)
    sName=stateList{sIdx};
    FR.(sName)=[];
    Z.(sName)=[];
    for dIdx=1:length(dList)
        dName=dList{dIdx};        
        
        if isempty(stateChange.(dName).(sName))
            continue
        end
        
        temp=[cat(1,trisecFiring.(dName).pyr.rate{stateChange.(dName).(sName)(:,1)}),...
              cat(1,trisecFiring.(dName).pyr.rate{stateChange.(dName).(sName)(:,3)})];        
        FR.(sName)=[FR.(sName);temp(:,[3,4])];                
        temp=[cat(1,trisecFiring.(dName).pyr.zscore{stateChange.(dName).(sName)(:,1)}),...
              cat(1,trisecFiring.(dName).pyr.zscore{stateChange.(dName).(sName)(:,3)})];        
        Z.(sName)=[Z.(sName);temp(:,[3,4])];                
    end
end
%%
clf

colNrem=hsv2rgb([2/3*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colRem=hsv2rgb([5/6*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');

colors.nrem2rem2nrem=[colNrem(2,:);colRem(2,:)];
colors.rem2nrem2rem=[colRem(2,:);colNrem(2,:)];

titleText.nrem2rem2nrem='Non-REM_i/REM/non-REM_{i+1}';
titleText.rem2nrem2rem='REM_i/non-REM/REM_{i+1}';
stateText.nrem2rem2nrem={{'Last 1/3' 'of non-REM_i'},{'First 1/3' 'of non-REM_{i+1}'}};
stateText.rem2nrem2rem={{'Last 1/3' 'of REM_i'},{'First 1/3' 'of REM_{i+1}'}};
close all
fh=initFig4JNeuro(1);
for sIdx=1:length(stateList)*2
    subplot(6,1,sIdx)
    hold on
    sName=stateList{mod(sIdx-1,2)+1};
    if sIdx<=length(stateList)
        temp=FR.(sName)(:,[1,end]);
        temp(any(temp==0,2),:)=[];
        temp=log10(temp)
        
        bin=-2.5:0.1:1.3;
        xText='Fring rate (log_{10} Hz)';
        xTickPos=-2:1:1;
        xTickLabel={'10^{-2}','10^{-1}','10^{0}','10^{1}'};
        xRange=[-2.5,1.3];
    else
        temp=Z.(sName)(:,[1,end]);
        xText='Fring rate (z)';

        bin=-3.5:0.1:4.5;
        xTickPos=-2:2:4;
        xTickLabel=xTickPos;
        xRange=[-3,4];
    end
    
    clear xVal yVal
    col=colors.(sName);
    for n=1:2
        xVal{n}=bin;
        yVal{n}=hist(temp(:,n),bin)/length(temp)*100;
        plot(xVal{n},yVal{n},'-','color',col(n,:))
    end
    set(gca,'xtick',xTickPos,'xticklabel',xTickLabel)
    title(titleText.(sName))
    xlabel(xText)
    ylabel('% of cells')
    xlim(xRange)
    
    param.n=length(temp);
    param.stateName=stateText.(sName);
    saveGraph('quantile20s3',['e' num2str(4+sIdx)],...
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



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
stateList={'nrem','rem'}

for sIdx=1:length(stateList)
    sName=stateList{sIdx};
    FR.(sName)=[];
    Z.(sName)=[];
    for dIdx=1:length(dList)
        dName=dList{dIdx};        
        FR.(sName)=[FR.(sName);cat(1,trisecFiring.(dName).pyr.rate{stateChange.(dName).(sName)})];                
        Z.(sName)=[Z.(sName);cat(1,trisecFiring.(dName).pyr.zscore{stateChange.(dName).(sName)})];                
    end
end
%%
clf

colors.nrem=[0.5*[1,1,1];0*[1,1,1]]
colors.rem=[0.5*[1,1,1];0*[1,1,1]]

titleText.nrem='Non-REM';
titleText.rem='REM';
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
    saveGraph('quantile20s2',['e' num2str(sIdx)],...
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
 


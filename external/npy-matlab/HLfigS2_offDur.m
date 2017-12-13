clear
% baseDir='~/data/sleep/pooled/';
baseDir='~/data/sleep/pooled_withCohEMG/';
coreName='sleep';

varList={'basics'
    'behavior'
    'detailedBehavior'
    'MA'
    ...'ripple'
    ...'spindle'
    ...'hpcSpindlePhase'
    ...'ctxSpindlePhase'
    ...'HLfine'
    'onOff'
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
    ...'eventFiring'
    ...'stableSleep'
    ...'stableWake'
    'stateChange'
    ...'trisecFiring'
    ...'trisecEvent'
    ...'binnedFiring'
    ...'thetaBand'
    ...'recStart'
    ...'deltaBand'
    ...'thetaBand'
    }';

for varName=varList
    load([baseDir coreName '-' varName{1} '.mat'])
end
dList=fieldnames(basics);
%HL=HLfine;
%%
clear iei dur

for dIdx=1:length(dList);
    dName=dList{dIdx};

    off=onOff.(dName).off;
    on=onOff.(dName).on;
    nrem=behavior.(dName).list(stateChange.(dName).nrem,1:2);

    iei{dIdx}=[];
    dur{dIdx}=[];
    for nIdx=1:size(nrem,1)
        subset=off(off(:,1)>nrem(nIdx,1)&off(:,2)<nrem(nIdx,2),:);
        subset(subset(1:end-1,2)==subset(2:end,1),:)=[];
        iei{dIdx}=[iei{dIdx},(subset(2:end,1)-subset(1:end-1,2))'/1e3];
        
        subset=on(on(:,1)>nrem(nIdx,1)&on(:,2)<nrem(nIdx,2),:);
        dur{dIdx}=[dur{dIdx},diff(subset,1,2)'/1e3];
        
        
    end

end

%%
close all
fh=initFig4Nature(2);

for typeIdx=0:1
    switch typeIdx
        case 0
            target=iei;
            yText='IEI of OFF (ms)';
        case 1
            target=dur;
            yText='Duration of  ON (ms)';
        otherwise
            continue
    end
    
    for cutType=1:4
        switch cutType
            case 1
                minDur=-inf;
                maxDur=inf;
                titleText='All';
            case 2
                minDur=50;
                maxDur=inf;
                titleText='>50 ms';
            case 3
                minDur=-inf;
                maxDur=4000;
                titleText='<4000 ms';
            case 4
                minDur=50;
                maxDur=4000;
                titleText='> 50 ms & < 4000 ms';
            otherwise
                continue
        end
        quantileEach=cellfun(@(x) quantile(x(x>minDur&x<maxDur),3),target,'UniformOutput',false);
        quantileEach=cat(1,quantileEach{:});
        pooledTarget=[target{:}];
        quantileAll=quantile(pooledTarget(pooledTarget>minDur & pooledTarget<maxDur),3);
        pooledMean=mean(pooledTarget(pooledTarget>minDur & pooledTarget<maxDur));
        
        subplot(6,4,cutType+4*typeIdx)
        hold on
        rectangle('position',[0,quantileAll(1),length(dList)+1,diff(quantileAll([1,3]))],...
            'linestyle','none','facecolor',[1,0.8,0.8])
        plot([0,length(dList)+1],[1,1]*quantileAll(2),'r-')
        plot([0,length(dList)+1],[1,1]*pooledMean,'b-')
        
        plot([1;1]*(1:length(dList)),quantileEach(:,[1,3])','k-')
        plot(1:length(dList),quantileEach(:,2),'k.')
        title(titleText)
        ylabel(yText)
        xlabel('Session')
        xlim([0,length(dList)+1])
        ax=fixAxis;
        text2(1,1,{['\color[rgb]{1,0,0}median = ' num2str(quantileAll(2),'%.1f') ' ms']
                   ['\color[rgb]{0,0,1}mean = ' num2str(pooledMean,'%.1f') ' ms']},...
                   ax,{'horizontalAlign','right','verticalAlign','top'})
        
        if cutType==1 && typeIdx==1
            text2(0,-0.5,{'Error bars indicates upper and lower quantiles'
                'Red band and bar indicate median and quantiles of pooled data'},ax,...
                {'horizontalAlign','left','verticalAlign','top','color','k'})
        end
    end    
end

durBin=0:10:1510;
for dIdx=1:length(dList)
    subplot(7,5,15+dIdx)
    cnt=hist(dur{dIdx},durBin);
    cnt2=hist(iei{dIdx},durBin);
    bar(durBin(1:end-1),cnt(1:end-1),1,'linestyle','none')
    hold on
    plot(durBin(1:end-1),cnt2(1:end-1),'r-')
    box off
    xlim(durBin([1,end-1]))
    xlabel('Duration/IEI (ms)')
    ylabel('Count')
    title(['Session' num2str(dIdx)])
    ax=fixAxis;
end
text2(1.3,1,{'Bars: Duration of ON ','Red lines: IEI of OFF'},ax,...
    {'horizontalAlign','left','verticalAlign','top'})

addScriptName(mfilename);

print(fh,'~/Dropbox/LOW/preliminary/interOFFduration.pdf','-dpdf')


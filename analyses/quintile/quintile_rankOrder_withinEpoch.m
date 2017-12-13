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

HL=HLfine;
dList=fieldnames(basics);


%%
close all
fh=initFig4Nature(2)
nDiv=5;
for bIdx=1:2
    if bIdx==1
        bName='nrem'
    else
        bName='rem'
    end
    percentile.(bName)=[];
    rankCorr.(bName)=[];
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        targetIdx=stateChange.(dName).(bName);

        fr=trisecFiring.(dName).pyr.rate(targetIdx);

        meanRank=cellfun(@(x) tiedrank(mean(x,2))/size(x,1)*100,fr,'uniformOutput',false);
        firstRank=cellfun(@(x) tiedrank(x(:,1))/size(x,1)*100,fr,'uniformOutput',false);
        lastRank=cellfun(@(x) tiedrank(x(:,3))/size(x,1)*100,fr,'uniformOutput',false);


        percentile.(bName)=[percentile.(bName);cat(1,meanRank{:}),cat(1,firstRank{:}),cat(1,lastRank{:})];

        temp1=corr(cat(2,meanRank{:}),cat(2,firstRank{:}));
        temp2=corr(cat(2,firstRank{:}),cat(2,lastRank{:}));
        temp3=corr(cat(2,lastRank{:}),cat(2,meanRank{:}));
        rankCorr.(bName)=[rankCorr.(bName);diag(temp1),diag(temp2),diag(temp3)];
        
    end
end
corrType={'Mean vs First', 'First vs Last','Mean vs Last'};
col=eye(3);

width=30;
height=20;
margin=10;
for bIdx=1:2
    if bIdx==1
        bName='nrem'
    else
        bName='rem'
    end    
    
    subplotInMM(margin+0*(width+margin),margin+(bIdx-1)*(width+margin),width,width,true)
    [cnt,bin]=hist3(percentile.(bName)(:,1:2),[100,100]);
    imagescXY(bin{1},bin{2},cnt/sum(cnt(:))*100)
    colormap(gca,jet)
    set(gca,'clim',[0,0.1])
    xlabel('Percentile in whole epoch')
    ylabel('Percentile in first thirds')
    title(upper(bName))
    
     subplotInMM(margin+1*(width+margin),margin+(bIdx-1)*(width+margin),width,width,true)
    [cnt,bin]=hist3(percentile.(bName)(:,2:3),[100,100]);
    imagescXY(bin{1},bin{2},cnt/sum(cnt(:))*100)
    colormap(gca,jet)
    set(gca,'clim',[0,0.1])
    xlabel('Percentile in first thirds')
    ylabel('Percentile in last thirds')
    title(upper(bName))

    subplotInMM(margin+2*(width+margin),margin+(bIdx-1)*(width+margin),width,width,true)
    [cnt,bin]=hist3(percentile.(bName)(:,[1,3]),[100,100]);
    imagescXY(bin{1},bin{2},cnt/sum(cnt(:))*100)
    colormap(gca,jet)
    set(gca,'clim',[0,0.1])
    xlabel('Percentile in whole epoch')
    ylabel('Percentile in last thirds')
    title(upper(bName))
    
    subplotInMM(margin+3*(width+margin),margin+(bIdx-1)*(width+margin),width,width,true)
    hold on
    bin=0:0.01:1
    legendText={};
    for n=1:3
        plot(bin,hist(rankCorr.(bName)(:,n),bin)/size(rankCorr.(bName),1)*100,'-','color',col(n,:))
        legendText{n}=['\color[rgb]{' num2str(col(n,:)) '}' corrType{n};];
    end
    xlabel('Rank order correlation')
    ylabel('% of epochs')
    title(upper(bName))
    ax=fixAxis;
    text2(1,1,legendText,ax,{'horizontalALign','left','verticalAlign','top'})
end

subplotInMM(margin,margin+2*(width+margin),width,width,true)
hold on
bin=0:0.001:1;
legendText={};
for n=1:2
    if n==1
        bName='nrem';
    else
        bName='rem';
    end
    
    plot(bin,cumsum(hist(rankCorr.(bName)(:,2),bin)/size(rankCorr.(bName),1)*100),'-','color',col(n,:))
    legendText{n}=['\color[rgb]{' num2str(col(n,:)) '}' upper(bName);];
end
[~,p]=kstest2(rankCorr.nrem(:,2),rankCorr.rem(:,2));
legendText{end+1}=['\color[rgb]{0,0,0}p = ' num2str(p, '%.2e') ' (KS test)']
xlabel('Rank order correlation, first vs last thirds')
ylabel('Cumulative fraction of epochs')
ax=fixAxis;
text2(1,1,legendText,ax,{'horizontalALign','left','verticalAlign','top'})

addScriptName(mfilename)
print(fh,'~/Dropbox/Quantile/preliminary/rankOrder_withinEpoch','-dpdf')





clear
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
    'firing'
    ...'eventRate'
    ...'stableSleep20s'
    ...'stableWake20s'
    'stateChange20s'
    ...'trisecFiring'
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
fr=[];
nCell=5000;

for dIdx=1:length(dList)
    dName=dList{dIdx};
    
    idx=stateChange.(dName).nrem2rem2nrem;
    
    fr=[fr;
        [cat(2,firing.(dName).pyr.rate{idx(:,1)})',...
        cat(2,firing.(dName).pyr.rate{idx(:,3)})']];
    
end

idx=rand(size(fr,1),1)>0.5;
idx=[1-idx,idx]*size(fr,1)+([1;1]*(1:size(fr,1)))';
fr=fr(idx);


fr=fr(randperm(size(fr,1),nCell),:);

%%
nShuffle=2000;
nDiv=5;

close all
fh=initFig4JNeuro(2);
set(fh,'defaultLineMarkerSize',4)

ranking=tiedrank(fr(:,1))/size(fr,1);
col=hsv2rgb([0/3*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,0.5,nDiv)']);
col2=hsv2rgb([2/3*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,0.5,nDiv)']);

subplot2(5,4,1,1)
plot(10.^[-3,2],10.^[-3,2],'k-')
hold on
clear xVal yVal
for idx=1:nDiv
    xVal{idx}=fr(ranking>(idx-1)/nDiv&ranking<=idx/nDiv,1);
    yVal{idx}=fr(ranking>(idx-1)/nDiv&ranking<=idx/nDiv,2);
    plot(xVal{idx},...
        yVal{idx},'.',...
        'color',col(idx,:))
end
set(gca,'xscale','log','yscale','log')
xlim(10.^[-3,2])
ylim(10.^[-3,2])
box off
ax=fixAxis;

xlabel('FR (Hz)')
ylabel('FR (Hz)')
clear param

param.equation='Shuffled';
param.noise='Shuffled';
param.nCell=size(fr,1);

saveGraph('quantile20s1',['a' '0' 'a'],...
    'scatter',...
    xVal,... %x
    yVal,... %y
    [],... %error
    col,... %color
    get(gca),... %info
    get(get(gca,'xlabel'),'string'),... %xlabel
    get(get(gca,'ylabel'),'string'),... %ylabel
    'Shuffled',... %title,
    param,... %legend
    mfilename)

%%

for type=0:1
    
    switch type
        case 0
            idxEq=@(x) diff(x,1,2)./sum(x,2);
            measureName='MI';
        case 1
            idxEq=@(x) diff(log(x),1,2);
            measureName='D log(Hz)';
            %         case 3
            %             idxEq=@(x) diff(x,1,2)./x(:,1);
            %             measureName='\DeltaFR/FR';
    end
    
    
    
    f1=fr(:,1);
    mi=idxEq(fr);
    ranking=tiedrank(f1)/length(f1);
    
    subplot2(8,4,1,2+type)
    hold on
    clear xVal yVal
    for idx=1:nDiv
        xVal{idx}=f1(ranking>(idx-1)/nDiv&ranking<=idx/nDiv);
        yVal{idx}=mi(ranking>(idx-1)/nDiv&ranking<=idx/nDiv);
        plot(xVal{idx},...
            yVal{idx},'.',...
            'color',col(idx,:))
    end
    box off
    set(gca,'xscale','log')
    xlim(10.^[-3,2])
    %         ylim([-1,1])
    ax=fixAxis;
    
    xlabel('FR (Hz)')
    ylabel(measureName)
    
    clear param
    
    param.equation='Shuffled';
    param.noise='Shuffled';
    param.nCell=size(fr,2);
    
    saveGraph('quantile20s1',[alphabet(type+2) '0' 'a'],...
        'scatter',...
        xVal,... %x
        yVal,... %y
        [],... %error
        col,... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        'Shuffled',... %title,
        param,... %legend
        mfilename)
    
    
end


%%

for type=0:1
    
    switch type
        case 0
            idxEq=@(x) diff(x,1,2)./sum(x,2);
            measureName='MI';
            bin=-1.05:0.05:1.05
            xRange=[-1,1];
            color=col;
        case 1
            idxEq=@(x) diff(log(x),1,2);
            measureName='D log(Hz)';
            bin=-2:0.05:2;
            xRange=[-1,1];
            color=col;
            %         case 3
            %             idxEq=@(x) diff(x,1,2)./x(:,1);
            %             measureName='\DeltaFR/FR';
    end
    f1=fr(:,1);
    mi=idxEq(fr);
    ranking=tiedrank(f1)/length(f1);
    
    subplot2(8,4,2,2+type)
    hold on
    
    clear yVal xVal
    for idx=1:nDiv
        val=mi(ranking>(idx-1)/nDiv&ranking<=idx/nDiv);
        val(isinf(val))=[];
        yVal{idx}=hist(val,bin)/length(val)*100;
        plot(bin,yVal{idx},'color',color(idx,:))
        xVal{idx}=bin;
    end
    xlabel(measureName)
    ylabel('Count (%)')
    xlim(xRange)
    ax=fixAxis;
    
    
    clear param
    param.noiseType='Shuffled';
    param.equation='Shuffled';
    param.measureName=measureName;
    param.nCell=size(fr,1);
    
    saveGraph('quantile20s1',[alphabet(type+4) '0' 'a'],...
        'line',...
        xVal,... %x
        yVal,... %y
        [],... %error
        col,... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        '',... %title,
        param,... %legend
        mfilename)
    
    
end


%%

for type=0:1
    
    switch type
        case 0
            idxEq=@(x) diff(x,1,2)./sum(x,2);
            measureName='MI';
        case 1
            idxEq=@(x) diff(log(x),1,2);
            measureName='D log(Hz)';
            %         case 3
            %             idxEq=@(x) diff(x,1,2)./x(:,1);
            %             measureName='\DeltaFR/FR';
    end
    
    f1=fr(:,1);
    mi=idxEq(fr);
    ranking=tiedrank(f1)/length(f1);
    
    realMean=[];
    realMedian=[];
    realSte=[];
    clear realConf;
    for idx=1:nDiv
        val=mi(ranking>(idx-1)/nDiv&ranking<=idx/nDiv);
        val(isinf(val))=[];
        realMean(idx)=nanmean(val);
        realMedian(idx)=nanmedian(val);
        realSte(idx)=nanste(val);
        tempMean=[];
        tempMedian=[];
        nSubsample=ceil(length(val)/10);
        for rep=1:nShuffle
            subset=val(randperm(length(val),nSubsample));
            tempMean(rep)=nanmean(subset);
            tempMedian(rep)=nanmedian(subset);
        end
        tempMean=sort(tempMean);
        tempMedian=sort(tempMedian);
        
        realConf.mean(idx,:)=tempMean([floor(nShuffle*0.025),ceil(nShuffle*0.975)])
        realConf.median(idx,:)=tempMedian([floor(nShuffle*0.025),ceil(nShuffle*0.975)])
        
    end
    
    clear shuffleMean shuffleMedian
    for ite=1:nShuffle
        shuffleIdx=rand(size(fr,1),1)>0.5;
        shuffleIdx=[shuffleIdx,1-shuffleIdx];
        shuffleIdx=repmat((1:size(fr,1))',1,2)+size(fr,1)*shuffleIdx;
        
        shuffleData=fr(shuffleIdx);
        mi=idxEq(shuffleData);
        ranking=tiedrank(shuffleData(:,1))/length(shuffleData(:,1));
        for idx=1:nDiv
            temp=mi(ranking>(idx-1)/nDiv&ranking<=idx/nDiv);
            temp(isinf(temp))=[];
            shuffleMean(ite,idx)=nanmean(temp);
            shuffleMedian(ite,idx)=nanmedian(temp);
        end
    end
    
    shuffleMean=sort(shuffleMean);
    shuffleMedian=sort(shuffleMedian);
    
    shuffledRes.ConfInt.mean=shuffleMean([floor(nShuffle*0.025),ceil(nShuffle*0.975)],1:nDiv);
    shuffledRes.ConfInt.median=shuffleMedian([floor(nShuffle*0.025),ceil(nShuffle*0.975)],1:nDiv);
    
    shuffledRes.mean.mean=mean(shuffleMean);
    shuffledRes.mean.median=mean(shuffleMedian);
    
    subplot2(8,4,3,2+type)
    hold on
    for idx=1:nDiv
        bar(idx-0.1,realMean(idx),0.4,...
            'linestyle','none','faceColor',col2(idx,:))
    end
    for idx=1:nDiv
        bar(idx+0.1,realMedian(idx),0.4,...
            'linestyle','none','faceColor',col(idx,:))
    end
    xlim([0.5,nDiv+0.5])
    
    fill([1:nDiv,nDiv:-1:1],...
        [shuffleMean(floor(nShuffle*0.025),1:nDiv),shuffleMean(ceil(nShuffle*0.975),nDiv:-1:1)],...
        'b','linestyle','none','facealpha',0.5)
    fill([1:nDiv,nDiv:-1:1],...
        [shuffleMedian(floor(nShuffle*0.025),1:nDiv),shuffleMedian(ceil(nShuffle*0.975),nDiv:-1:1)],...
        'r','linestyle','none','facealpha',0.5)
    
    plot(1:nDiv,mean(shuffleMean),'b-')
    plot(1:nDiv,mean(shuffleMedian),'r-')
    ax=fixAxis;
    
    xlabel('Quintile')
    ylabel(measureName)
    
    clear param
    param.shuffle.mean=mean(shuffleMean);
    param.shuffle.confInt=shuffleMean([floor(nShuffle*0.025),ceil(nShuffle*0.975)],:);
    param.real.ste=realSte;
    param.real.confInt=realConf.mean;
    param.noiseType='Shuffled';
    param.equation='Shuffled';
    param.measureName=measureName;
    param.statName='mean';
    param.nShuffle=nShuffle;
    param.nCell=size(fr,1);
    saveGraph('quantile20s1',[alphabet(type+6) '0' 'a' '1'],...
        'bar',...
        1:nDiv,... %x
        realMean,... %y
        [],... %error
        [0,0,1],... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        'Mean',... %title,
        param,... %legend
        mfilename)
    
    clear param
    param.shuffle.mean=mean(shuffleMedian);
    param.shuffle.confInt=shuffleMedian([floor(nShuffle*0.025),ceil(nShuffle*0.975)],:);
    param.real.confInt=realConf.median;
    param.noiseType='Shuffled';
    param.equation='Shuffled';
    param.measureName=measureName;
    param.statName='median';
    param.nShuffle=nShuffle;
    param.nCell=size(fr,1);
    
    saveGraph('quantile20s1',[alphabet(type+6) '0' 'a' '2'],...
        'bar',...
        1:nDiv,... %x
        realMedian,... %y
        [],... %error
        [1,0,0],... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        'Median',... %title,
        param,... %legend
        mfilename)
    
    
end


%%

for type=0:1
    
    switch type
        case 0
            idxEq=@(x) diff(x,1,2)./sum(x,2);
            measureName='MI';
        case 1
            idxEq=@(x) diff(log(x),1,2);
            measureName='D log(Hz)';
            %         case 3
            %             idxEq=@(x) diff(x,1,2)./x(:,1);
            %             measureName='\DeltaFR/FR';
    end
    
    f1=fr(:,1);
    mi=idxEq(fr);
    ranking=tiedrank(f1)/length(f1);
    
    realMean=[];
    realMedian=[];
    realSte=[];
    clear realConf;
    for idx=1:nDiv
        val=mi(ranking>(idx-1)/nDiv&ranking<=idx/nDiv);
        val(isinf(val))=[];
        realMean(idx)=nanmean(val)-shuffledRes.mean.mean(idx);
        realMedian(idx)=nanmedian(val)-shuffledRes.mean.median(idx);
        realSte(idx)=nanste(val-shuffledRes.mean.mean(idx));
        tempMean=[];
        tempMedian=[];
        nSubsample=ceil(length(val)/10);
        for rep=1:nShuffle
            subset=val(randperm(length(val),nSubsample));
            tempMean(rep)=nanmean(subset)-shuffledRes.mean.mean(idx);
            tempMedian(rep)=nanmedian(subset)-shuffledRes.mean.median(idx);
        end
        tempMean=sort(tempMean);
        tempMedian=sort(tempMedian);
        
        realConf.mean(idx,:)=tempMean([floor(nShuffle*0.025),ceil(nShuffle*0.975)])
        realConf.median(idx,:)=tempMedian([floor(nShuffle*0.025),ceil(nShuffle*0.975)])
        
    end
    
    
    subplot2(8,4,4,2+type)
    hold on
    for idx=1:nDiv
        bar(idx-0.1,realMean(idx),0.4,...
            'linestyle','none','faceColor',col(idx,:))
    end
    for idx=1:nDiv
        bar(idx+0.1,realMedian(idx),0.4,...
            'linestyle','none','faceColor',col2(idx,:))
    end
    xlim([0.5,nDiv+0.5])
    
    fill([1:nDiv,nDiv:-1:1],...
        [shuffledRes.ConfInt.mean(1,1:nDiv)-shuffledRes.mean.mean,...
        fliplr(shuffledRes.ConfInt.mean(2,1:nDiv)-shuffledRes.mean.mean)],...
        'b','linestyle','none','facealpha',0.5)
    fill([1:nDiv,nDiv:-1:1],...
        [shuffledRes.ConfInt.median(1,1:nDiv)-shuffledRes.mean.median,...
        fliplr(shuffledRes.ConfInt.median(2,1:nDiv)-shuffledRes.mean.median)],...
        'r','linestyle','none','facealpha',0.5)
    
    ax=fixAxis;
    
    xlabel('Quintile')
    ylabel(['Def of ' measureName])
    
    clear param
    param.shuffle.mean=zeros(1,nDiv);
    param.shuffle.confInt=shuffledRes.ConfInt.mean-[1;1]*shuffledRes.mean.mean;
    param.real.ste=realSte;
    param.real.confInt=realConf.mean;
    param.noiseType='Shuffled';
    param.equation='Shuffled';
    param.measureName=measureName;
    param.statName='mean';
    param.nShuffle=nShuffle;
    param.nCell=size(fr,1);
    saveGraph('quantile20s1',[alphabet(type+8) '0' 'a' '1'],...
        'bar',...
        1:nDiv,... %x
        realMean,... %y
        [],... %error
        [0,0,1],... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        'Mean',... %title,
        param,... %legend
        mfilename)
    
    clear param
    param.shuffle.mean=zeros(1,nDiv);
    param.shuffle.confInt=shuffledRes.ConfInt.median-[1;1]*shuffledRes.mean.median;
    param.real.confInt=realConf.median;
    param.noiseType='Shuffled';
    param.equation='Shuffled';
    param.measureName=measureName;
    param.statName='median';
    param.nShuffle=nShuffle;
    param.nCell=size(fr,1);
    
    saveGraph('quantile20s1',[alphabet(type+8) '0'  'a' '2'],...
        'bar',...
        1:nDiv,... %x
        realMedian,... %y
        [],... %error
        [1,0,0],... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        'Median',... %title,
        param,... %legend
        mfilename)
    
    
end
addScriptName(mfilename)
%%
% subplot2(2*length(eqList),length(noiseList),2*length(eqList),1)
% hold on
% ax=fixAxis;
% text2(-0.2,-0.75,{'blue: mean, red: median.'
%     ['Colored band shows 95% CI estimated by shuffling (' num2str(nShuffle) ' times)']},...
%     ax,{'horizontalAlign','left','verticalAlign','top','fontsize',7})


print(fh,'~/Dropbox/Quantile/preliminary/shuffled_measures_20s.pdf','-dpdf')






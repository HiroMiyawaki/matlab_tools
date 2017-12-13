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
    'exLowTrisecFiring'
    ...'trisecEvent'
    ...'binnedFiring'
    ...'thetaBand'
    ...'sleepPeriod'
    'recStart'
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

ci=@(x) diff(x,1,2)./sum(x,2);
dlog=@(x) log10(x(:,2)./x(:,1));

nDiv=1;
nShuffle=2000;

clear shuffle realData

tNameList={'quiet2nrem','rem2nrem','nrem2quiet','nrem2rem'};

for tIdx=1:length(tNameList)
    tName=tNameList{tIdx};
    nremTime.(tName)=[];
    for n=1:nDiv
        for ite=1:nShuffle
            shuffle.(tName).ci{ite,n}=[];
            shuffle.(tName).dLog{ite,n}=[];
        end
        realData.(tName).ci{n}=[];
        realData.(tName).dLog{n}=[];
        realData.(tName).fr{n}=[];
    end
    
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        
        if isempty(trisecFiring.(dName).inh.rate{1})
            continue
        end
        
        if ~isempty(strfind(tName,'nrem2'))
            evtIdx=stateChange.(dName).(tName)(:,1);
        elseif ~isempty(strfind(tName,'2nrem'))
            evtIdx=stateChange.(dName).(tName)(:,2);
        else
            continue
        end
        target=evtIdx;
        if isempty(target)
            continue
        end
        
        for idx=1:size(target,1)
            tempFR=trisecFiring.(dName).inh.rate{target(idx,1)};
            tempFR(:,2)=[];
            
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
nCol=4;
nRaw=7;

mu = [0 0];
Sigma = [1 0; 0 1];
smoothCoreBin = -3:3; smoothCoreBin = -3:3;
[smoothCoreBin,smoothCoreBin] = meshgrid(smoothCoreBin,smoothCoreBin);
smoothCore = mvnpdf([smoothCoreBin(:) smoothCoreBin(:)],mu,Sigma);
smoothCore = reshape(smoothCore,length(smoothCoreBin),length(smoothCoreBin));
smoothCore=smoothCore/sum(sum(smoothCore));

col.nrem=hsv2rgb([2/3*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
col.rem=hsv2rgb([5/6*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
col.exLow=hsv2rgb([5/12*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
col.quiet2nrem=col.exLow;
col.rem2nrem=col.exLow;
col.nrem2quiet=col.exLow;
col.nrem2rem=col.exLow;



densityRange=-2:1;
logXrange=(densityRange([1,end]));
logYrange=(densityRange([1,end]));
xbin=linspace(logXrange(1),logXrange(2),50);
ybin=linspace(logYrange(1),logYrange(2),50);

densityLabel={'10^{-2}','10^{-1}','10^{0}','10^{1}'};

% tNameList={'nrem2rem','rem2nrem'};
xText.quiet2nrem={'FR in first 1/3' 'of non-REM (Hz)'};
yText.quiet2nrem={'FR in last 1/3' 'of non-REM (Hz)'};

xText.rem2nrem={'FR in first 1/3' 'of REM (Hz)'};
yText.rem2nrem={'FR in last 1/3' 'of non-REM (Hz)'};

xText.nrem2quiet={'FR in first 1/3' 'of non-REM (Hz)'};
yText.nrem2quiet={'FR in last 1/3' 'of non-REM (Hz)'};

xText.nrem2rem={'FR in first 1/3' 'of REM (Hz)'};
yText.nrem2rem={'FR in last 1/3' 'of non-REM (Hz)'};


titleText.rem2nrem='Following REM';
titleText.quiet2nrem='Following wake';

titleText.nrem2rem='Preceding REM';
titleText.nrem2quiet='Preceding wake';

measureNameList={'CI','\Deltalog_{10}(Hz)'};
deflectionNameList={'DI','Def. \Deltalog'};

ciRange.quiet2nrem={[-0.1,0.3],[-0.2,0.3]};
diRange.quiet2nrem={[-0.05,0.15],[-0.05,0.1]};

ciRange.rem2nrem={[-0.1,0.3],[-0.2,0.3]};
diRange.rem2nrem={[-0.05,0.15],[-0.05,0.1]};

ciRange.nrem2rem={[-0.1,0.3],[-0.2,0.3]};
diRange.nrem2rem={[-0.05,0.15],[-0.05,0.1]};

ciRange.nrem2quiet={[-0.1,0.3],[-0.2,0.3]};
diRange.nrem2quiet={[-0.05,0.15],[-0.05,0.1]};

% psFileName='~/Dropbox/Quantile/preliminary/nremBeforeAfterREM_20s.pdf';
% doAppend='';
fh=initFig4JNeuro(2);

for tIdx=1:length(tNameList)
    tName=tNameList{tIdx};
    set(fh,'defaultLineMarkerSize',4)
    
    subplot2(nRaw,nCol,1+3*floor((tIdx-1)/2),2*mod(tIdx-1,2)+1)
    temp=[];
    hold on
    clear xVal yVal
    for n=1:nDiv
        xVal{n}=realData.(tName).fr{n}(:,1);
        yVal{n}=realData.(tName).fr{n}(:,2);
        plot(xVal{n},yVal{n},'.','color',col.(tName)(n,:));
        temp=[temp;realData.(tName).fr{n}];
    end
    xlim(10.^[-3,2])
    ylim(10.^[-3,2])
    xlabel(xText.(tName))
    ylabel(yText.(tName))
    set(gca,'xscale','log','yscale','log')
    set(gca,'xtick',10.^(-2:2:2),'ytick',10.^(-2:2:2))
    plotIdentityLine(gca,{'color','black'})
    box off
    title(titleText.(tName))
    fixAxis;
    clear param
    param.n=cellfun(@length,xVal)
    saveGraph('quantile20sS2',[alphabet(tIdx+4) '1'  'Inh' 'exLow'],...
        'scatter',...
        xVal,... %x
        yVal,... %y
        [],... %error
        col.(tName),... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename)
    
    subplot2(nRaw,nCol,1+3*floor((tIdx-1)/2),2*mod(tIdx-1,2)+2)
    temp(any(temp==0,2),:)=[];
    densMap=hist2(log10(temp),xbin,ybin);
    densMap=conv2(densMap,smoothCore);
    imagescXY(logXrange,logYrange,densMap)
    colormap(gca,jet)
    set(gca,'xtick',densityRange,'xticklabel',densityLabel)
    set(gca,'ytick',densityRange,'yticklabel',densityLabel)
    xlabel(xText.(tName))
    ylabel(yText.(tName))
    
    plotIdentityLine(gca,{'color',0.99*[1,1,1]})
    box off
    title(titleText.(tName))
    fixAxis;
    clear param
    param.smothCoreSize=size(smoothCore);
    param.smotCorehSD=1;
    saveGraph('quantile20sS2',[alphabet(tIdx+4) '2'  'Inh' 'exLow'],...
        'spectrum',...
        [logXrange,logYrange],... %x
        densMap,... %y
        [],... %error
        [],... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename)
    
    
    for mIdx=1:length(measureList)
        measureType=measureList{mIdx};
        measureName=measureNameList{mIdx};
        
    subplot2(nRaw,nCol,2+3*floor((tIdx-1)/2),2*mod(tIdx-1,2)+mIdx)
        hold on
        for n=1:nDiv
            plot(n*[1,1],frChange.(tName).real.(measureType).mean(n)+frChange.(tName).real.(measureType).ste(n)*[-1,1],...
                'color',col.(tName)(n,:))
            bar(n,frChange.(tName).real.(measureType).mean(n),'linestyle','none','faceColor',col.(tName)(n,:))
        end
        xlim([0.5,nDiv+0.5])
        fill([1:nDiv,nDiv:-1:1],[frChange.(tName).shuffle.(measureType).mean.interval(1,:),...
            fliplr(frChange.(tName).shuffle.(measureType).mean.interval(2,:))],hsv2rgb([0,0.75,0.75]),...
            'faceAlpha',0.5,'lineStyle','none')
        xlabel('Quintile')
        ylabel(measureName)
        title(titleText.(tName))
        clear param
        param.confInt=frChange.(tName).shuffle.(measureType).mean.interval;
        param.shuffleMean=frChange.(tName).shuffle.(measureType).mean.mean;
        param.p=frChange.(tName).shuffle.(measureType).mean.p;
        
        ylim(ciRange.(tName){mIdx})
        
        saveGraph('quantile20sS2',[alphabet(tIdx+4) '3' alphabet(mIdx) 'Inh' 'exLow'],...
            'multiColorBar',...
            1:nDiv,... %x
            frChange.(tName).real.(measureType).mean,... %y
            frChange.(tName).real.(measureType).ste,... %error
            col.(tName),... %color
            get(gca),... %info
            get(get(gca,'xlabel'),'string'),... %xlabel
            get(get(gca,'ylabel'),'string'),... %ylabel
            get(get(gca,'title'),'string'),... %title,
            param,... %legend
            mfilename)
        
        
        
     subplot2(nRaw,nCol,3+3*floor((tIdx-1)/2),2*mod(tIdx-1,2)+mIdx)
       hold on
        for n=1:nDiv
            plot(n*[1,1],...
                frChange.(tName).real.(measureType).mean(n)+...
                frChange.(tName).real.(measureType).ste(n)*[-1,1]-...
                frChange.(tName).shuffle.(measureType).mean.mean(n),...
                'color',col.(tName)(n,:))
            bar(n,frChange.(tName).real.(measureType).mean(n)-...
                frChange.(tName).shuffle.(measureType).mean.mean(n),'linestyle','none','faceColor',col.(tName)(n,:))
        end
        xlim([0.5,nDiv+0.5])
        fill([1:nDiv,nDiv:-1:1],...
            [frChange.(tName).shuffle.(measureType).mean.interval(1,:)-frChange.(tName).shuffle.(measureType).mean.mean,...
            fliplr(frChange.(tName).shuffle.(measureType).mean.interval(2,:)-frChange.(tName).shuffle.(measureType).mean.mean)]...
            ,hsv2rgb([0,0.75,0.75]),...
            'faceAlpha',0.5,'lineStyle','none')
        xlabel('Quintile')
        ylabel(deflectionNameList{mIdx})
        title(titleText.(tName))
        ylim(diRange.(tName){mIdx})
        
        clear param
        param.confInt=frChange.(tName).shuffle.(measureType).mean.interval-[1;1]*frChange.(tName).shuffle.(measureType).mean.mean;
        param.p=frChange.(tName).shuffle.(measureType).mean.p;
        param.measure=measureName;
        
        saveGraph('quantile20sS2',[alphabet(tIdx+4) '4' alphabet(mIdx) 'Inh' 'exLow'],...
            'multiColorBar',...
            1:nDiv,... %x
            frChange.(tName).real.(measureType).mean-frChange.(tName).shuffle.(measureType).mean.mean,... %y
            frChange.(tName).real.(measureType).ste,... %error
            col.(tName),... %color
            get(gca),... %info
            get(get(gca,'xlabel'),'string'),... %xlabel
            get(get(gca,'ylabel'),'string'),... %ylabel
            get(get(gca,'title'),'string'),... %title,
            param,... %legend
            mfilename)
        
    end
end
addScriptName(mfilename)

subplot2(nRaw,nCol,2,1)
ax=fixAxis;
% text2(0,3.5,dispName.(tName),ax,{'horizontalALign','left','verticalAlign','bottom','fontsize',10})

subplot2(nRaw,nCol,6,1)
hold on
ax=fixAxis;
text2(0,-0.5,{
    ['Red bands indcates 95% confidence interval estimated by shuffling (' num2str(nShuffle) ' times)']
    ['Error bars indicates STE for mean and 95% confidence interval for median estimated by subsampling (' num2str(nShuffle) ' times)']},ax,...
    {'horizontalALign','left','verticalALign','top','fontsize',7});
% print(fh,psFileName,'-dpsc2',doAppend);
% doAppend='-append';

% print(fh,psFileName,'-dpdf');

%%
% tNameList={'quiet2nrem','rem2nrem','nrem2quiet','nrem2rem'};
% clear nremTime
% for tIdx=1:length(tNameList)
%     tName=tNameList{tIdx};
%     nremTime.(tName)=[];
%     for dIdx=1:length(dList);
%         dName=dList{dIdx};
%         evtIdx=stateChange.(dName).(tName)(:,1);
%         time=mean(behavior.(dName).list(evtIdx,1:2),2);
%         time=(time-behavior.(dName).time(1)+recStart.(dName)*[3600,60,2]'*1e6)/3600e6;
%         nremTime.(tName)=[nremTime.(tName),time'];
%     end
% end
% 
% pBorder=[9,15,21,25.5,30];
% for tIdx=1:length(tNameList)
% tName=tNameList{tIdx}
% for n=1:length(pBorder)-1
%     cnt.(tName)(n)=sum(nremTime.(tName)>pBorder(n)&nremTime.(tName)<pBorder(n+1));
% end
% end
% 
% cnt.quiet2nrem./(cnt.quiet2nrem+cnt.rem2nrem)
% cnt.nrem2quiet./(cnt.nrem2quiet+cnt.nrem2rem)






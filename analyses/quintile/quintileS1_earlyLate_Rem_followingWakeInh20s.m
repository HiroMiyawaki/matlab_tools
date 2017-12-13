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

ci=@(x) diff(x,1,2)./sum(x,2);
dlog=@(x) log10(x(:,2)./x(:,1));

nDiv=1;
nShuffle=2000;

clear shuffle realData

tNameList={'rem2nrem','rem2quiet'};
pNameList={'earlyLight','lateLight','earlyDark','lateDark'};
pBorder=[-inf,15,21,25.5,inf];

processList=1:length(tNameList);

for tIdx=processList
    tName=tNameList{tIdx};
    for pIdx=1:length(pNameList)
        pName=pNameList{pIdx};
        for n=1:nDiv
            for ite=1:nShuffle
                shuffle.(tName).(pName).ci{ite,n}=[];
                shuffle.(tName).(pName).dLog{ite,n}=[];
            end
            realData.(tName).(pName).ci{n}=[];
            realData.(tName).(pName).dLog{n}=[];
            realData.(tName).(pName).fr{n}=[];
        end
        realData.(tName).(pName).nEpoch=0;
    end
    
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        
        if isempty(stateChange.(dName).(tName))
            continue
        end
        if isempty(trisecFiring.(dName).inh.rate{1})
            continue
        end
        
        evtIdx=stateChange.(dName).(tName)(:,1);
        
        if isempty(evtIdx)
            conitnue
        end
        time=mean(behavior.(dName).list(evtIdx,1:2),2);
        time=(time-behavior.(dName).time(1)+recStart.(dName)*[3600,60,2]'*1e6)/3600e6;
        
        for pIdx=1:length(pNameList)
            pName=pNameList{pIdx};
            target=evtIdx(time>pBorder(pIdx)&time<pBorder(pIdx+1),:);
            if isempty(target)
                continue
            end
            
            for idx=1:size(target,1)
                
                if size(target,2)==1
                    tempFR=trisecFiring.(dName).inh.rate{target(idx,1)};
                    tempFR(:,2)=[];
                else
                    tempFR=[trisecFiring.(dName).inh.rate{target(idx,1)}(:,3),...
                        trisecFiring.(dName).inh.rate{target(idx,2)}(:,1)];
                end
                
                ranking=tiedrank(tempFR(:,1))/size(tempFR,1);
                
                for n=1:nDiv
                    realData.(tName).(pName).ci{n}=[realData.(tName).(pName).ci{n};...
                        ci(tempFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];
                    realData.(tName).(pName).dLog{n}=[realData.(tName).(pName).dLog{n};...
                        dlog(tempFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];
                    realData.(tName).(pName).fr{n}=[realData.(tName).(pName).fr{n};...
                        tempFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:)];
                end
                realData.(tName).(pName).nEpoch=realData.(tName).(pName).nEpoch+1;
                
                for ite=1:nShuffle
                    shuffleIdx=rand(size(tempFR,1),1)>0.5;
                    shuffleIdx=repmat(1:size(tempFR,1),2,1)'+[shuffleIdx,1-shuffleIdx]*size(tempFR,1);
                    shuffleFR=tempFR(shuffleIdx);
                    ranking=tiedrank(shuffleFR(:,1))/size(shuffleFR,1);
                    
                    for n=1:nDiv
                        shuffle.(tName).(pName).ci{ite,n}=[shuffle.(tName).(pName).ci{ite,n};...
                            ci(shuffleFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];
                        shuffle.(tName).(pName).dLog{ite,n}=[shuffle.(tName).(pName).dLog{ite,n};...
                            dlog(shuffleFR(ranking>(n-1)/nDiv & ranking<=n/nDiv,:))];
                        
                    end
                end
            end
        end
        
    end
    
end

%%

measureList={'ci','dLog'};

for tIdx=processList
    tName=tNameList{tIdx};
    for pIdx=1:length(pNameList)
        pName=pNameList{pIdx};
        for mIdx=1:length(measureList)
            measureType=measureList{mIdx};
            
            for n=1:nDiv
                nPoint=length(realData.(tName).(pName).(measureType){n});
                pointToUse=ceil(nPoint/10);
                
                subMed=[];
                for ite=1:nShuffle
                    temp=realData.(tName).(pName).(measureType){n}(randperm(nPoint,pointToUse));
                    
                    subMed(ite)=nanmedian(temp(~isinf(temp)));
                end
                
                subMed=sort(subMed);
                frChange.(tName).(pName).real.(measureType).medianCI(:,n)=subMed([floor(nShuffle*0.025),ceil(nShuffle*0.975)])';
            end
            
            for statTypeIdx=1:2
                if statTypeIdx==1
                    statType='mean';
                    statFun=@nanmean;
                else
                    statType='median';
                    statFun=@nanmedian;
                end
                
                frChange.(tName).(pName).real.(measureType).(statType)=...
                    cellfun(@(x) statFun(x(~isinf(x))),realData.(tName).(pName).(measureType));
                
                temp=sort(cellfun(@(x) statFun(x(~isinf(x))),shuffle.(tName).(pName).(measureType)));
                
                clear p
                for n=1:nDiv
                    lowerBond=find(temp(:,n)<frChange.(tName).(pName).real.(measureType).(statType)(n),1,'last');
                    if isempty(lowerBond)
                        lowerBond=0;
                    end
                    
                    
                    upperBond=find(temp(:,n)>frChange.(tName).(pName).real.(measureType).(statType)(n),1,'first');
                    if isempty(upperBond)
                        upperBond=nShuffle;
                    end
                    p(n)=1-max([(nShuffle/2-lowerBond)/nShuffle*2,(upperBond-nShuffle/2)/nShuffle*2]);
                end
                frChange.(tName).(pName).shuffle.(measureType).(statType).p=p;
                frChange.(tName).(pName).shuffle.(measureType).(statType).interval=temp([floor(nShuffle*0.025),ceil(nShuffle*0.975)],:);
                frChange.(tName).(pName).shuffle.(measureType).(statType).mean=mean(temp,1);
                
            end
            
            
            statType='ste';
            statFun=@nanste;
            
            frChange.(tName).(pName).real.(measureType).(statType)=...
                cellfun(@(x) statFun(x(~isinf(x))),realData.(tName).(pName).(measureType));
        end
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
col.rem2quiet=col.rem;
col.rem2nrem=col.rem;


densityRange=-2:1;
logXrange=(densityRange([1,end]));
logYrange=(densityRange([1,end]));
xbin=linspace(logXrange(1),logXrange(2),50);
ybin=linspace(logYrange(1),logYrange(2),50);

densityLabel={'10^{-2}','10^{-1}','10^{0}','10^{1}'};

xText.rem2nrem={'FR in first 1/3' 'of REM (Hz)'};
yText.rem2nrem={'FR in last 1/3' 'of REM (Hz)'};

xText.rem2quiet={'FR in first 1/3' 'of REM (Hz)'};
yText.rem2quiet={'FR in last 1/3' 'of REM (Hz)'};

% titleText.rem2nrem='Following REM';
% titleText.quiet2nrem='Following wake';
% 
% titleText.nrem2rem='Preceding REM';
% titleText.nrem2quiet='Preceding wake';
titleText.rem2nrem='Preceding NREM';
titleText.rem2quiet='Preceding wake';


measureNameList={'CI','\Deltalog_{10}(Hz)'};
deflectionNameList={'DI','Def. \Deltalog'};

ciRange.rem2nrem={[-0.3,0.8],[-0.3,0.8]};
diRange.rem2nrem={[-0.4,0.4],[-0.4,0.2]};

ciRange.rem2quiet={[-0.3,0.6],[-0.3,0.6]};
diRange.rem2quiet={[-0.4,0.4],[-0.4,0.2]};

dispName.rem2nrem='Within REM';
dispName.rem2quiet='Within REM';

% psFileName='~/Dropbox/Quantile/preliminary/earlyLateRem_afterWakeREM.ps';
doAppend='';

% doAppend='';
close all

for tIdx=processList
    tName=tNameList{tIdx};
    fh=initFig4JNeuro(2);
    set(fh,'defaultLineMarkerSize',4)
    
    for pIdx=1:length(pNameList)
        pName=pNameList{pIdx};
                
        subplot2(nRaw,nCol,3*floor((pIdx-1)/2)+1,1+2*(mod(pIdx-1,2)))
        temp=[];
        hold on
        clear xVal yVal
        for n=1:nDiv
            xVal{n}=realData.(tName).(pName).fr{n}(:,1);
            yVal{n}=realData.(tName).(pName).fr{n}(:,2);
            plot(xVal{n},yVal{n},'.','color',col.(tName)(n,:));
            temp=[temp;realData.(tName).(pName).fr{n}];
        end
        xlim(10.^[-3,2])
        ylim(10.^[-3,2])
        xlabel(xText.(tName))
        ylabel(yText.(tName))
        set(gca,'xscale','log','yscale','log')
        set(gca,'xtick',10.^(-2:2:2),'ytick',10.^(-2:2:2))
        plotIdentityLine(gca,{'color','black'})
        box off
            title([tName '-' pName])
        fixAxis;
        clear param
        param.nCell=cellfun(@length,xVal);
        param.nEpoch=realData.(tName).(pName).nEpoch;
        saveGraph('quantile20sS2',[alphabet(tIdx+9) '1' alphabet(pIdx) 'Inh'],...
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
        
        subplot2(nRaw,nCol,3*floor((pIdx-1)/2)+1,2+2*(mod(pIdx-1,2)))
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
            title([tName '-' pName])
        fixAxis;
        clear param
        param.nCell=cellfun(@length,xVal);
        param.nEpoch=realData.(tName).(pName).nEpoch;
        param.smoothCoreSize=size(smoothCore);
        param.smoothCoreSD=1;
        saveGraph('quantile20sS2',[alphabet(tIdx+9) '2' alphabet(pIdx) 'Inh'],...
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
            
            subplot2(nRaw,nCol,3*floor((pIdx-1)/2)+2,mIdx+2*(mod(pIdx-1,2)))
            hold on
            for n=1:nDiv
                plot(n*[1,1],frChange.(tName).(pName).real.(measureType).mean(n)+frChange.(tName).(pName).real.(measureType).ste(n)*[-1,1],...
                    'color',col.(tName)(n,:))
                bar(n,frChange.(tName).(pName).real.(measureType).mean(n),'linestyle','none','faceColor',col.(tName)(n,:))
            end
            xlim([0.5,nDiv+0.5])
            fill([1:nDiv,nDiv:-1:1],[frChange.(tName).(pName).shuffle.(measureType).mean.interval(1,:),...
                fliplr(frChange.(tName).(pName).shuffle.(measureType).mean.interval(2,:))],hsv2rgb([0,0.75,0.75]),...
                'faceAlpha',0.5,'lineStyle','none')
            xlabel('Quintile')
            ylabel(measureName)
            title([tName '-' pName])
            clear param
            param.confInt=frChange.(tName).(pName).shuffle.(measureType).mean.interval;
            param.shuffleMean=frChange.(tName).(pName).shuffle.(measureType).mean.mean;
            param.p=frChange.(tName).(pName).shuffle.(measureType).mean.p;

            ylim(ciRange.(tName){mIdx})

            saveGraph('quantile20sS2',[alphabet(tIdx+9) '3' alphabet(mIdx) num2str(pIdx) 'Inh'],...
                'multiColorBar',...
                1:nDiv,... %x
                frChange.(tName).(pName).real.(measureType).mean,... %y
                frChange.(tName).(pName).real.(measureType).ste,... %error
                col.(tName),... %color
                get(gca),... %info
                get(get(gca,'xlabel'),'string'),... %xlabel
                get(get(gca,'ylabel'),'string'),... %ylabel
                get(get(gca,'title'),'string'),... %title,
                param,... %legend
                mfilename)
            
            
            
            subplot2(nRaw,nCol,3*floor((pIdx-1)/2)+3,mIdx+2*(mod(pIdx-1,2)))
            hold on
            for n=1:nDiv
                plot(n*[1,1],...
                    frChange.(tName).(pName).real.(measureType).mean(n)+...
                    frChange.(tName).(pName).real.(measureType).ste(n)*[-1,1]-...
                    frChange.(tName).(pName).shuffle.(measureType).mean.mean(n),...
                    'color',col.(tName)(n,:))
                bar(n,frChange.(tName).(pName).real.(measureType).mean(n)-...
                    frChange.(tName).(pName).shuffle.(measureType).mean.mean(n),'linestyle','none','faceColor',col.(tName)(n,:))
            end
            xlim([0.5,nDiv+0.5])
            fill([1:nDiv,nDiv:-1:1],...
                [frChange.(tName).(pName).shuffle.(measureType).mean.interval(1,:)-frChange.(tName).(pName).shuffle.(measureType).mean.mean,...
                fliplr(frChange.(tName).(pName).shuffle.(measureType).mean.interval(2,:)-frChange.(tName).(pName).shuffle.(measureType).mean.mean)]...
                ,hsv2rgb([0,0.75,0.75]),...
                'faceAlpha',0.5,'lineStyle','none')
            xlabel('Quintile')
            ylabel(deflectionNameList{mIdx})
            title([tName '-' pName])
            ylim(diRange.(tName){mIdx})

            clear param
            param.confInt=frChange.(tName).(pName).shuffle.(measureType).mean.interval-[1;1]*frChange.(tName).(pName).shuffle.(measureType).mean.mean;
            param.p=frChange.(tName).(pName).shuffle.(measureType).mean.p;
            param.measure=measureName;
            
            saveGraph('quantile20sS2',[alphabet(tIdx+9) '4' alphabet(mIdx) num2str(pIdx) 'Inh'],...
                'multiColorBar',...
                1:nDiv,... %x
                frChange.(tName).(pName).real.(measureType).mean-frChange.(tName).(pName).shuffle.(measureType).mean.mean,... %y
                frChange.(tName).(pName).real.(measureType).ste,... %error
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
    text2(0,3.5,dispName.(tName),ax,{'horizontalALign','left','verticalAlign','bottom','fontsize',10})

    subplot2(nRaw,nCol,6,1)
    hold on
    ax=fixAxis;
    text2(0,-0.5,{
        ['Red bands indcates 95% confidence interval estimated by shuffling (' num2str(nShuffle) ' times)']
        ['Error bars indicates STE for mean and 95% confidence interval for median estimated by subsampling (' num2str(nShuffle) ' times)']},ax,...
        {'horizontalALign','left','verticalALign','top','fontsize',7});
%     print(fh,psFileName,'-dpsc2',doAppend);
    doAppend='-append';
end














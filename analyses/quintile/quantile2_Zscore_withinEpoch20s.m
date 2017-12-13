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
nDiv=5;
for ite=0
    for divIdx=1:nDiv
        frNrem{divIdx}=[];
        frRem{divIdx}=[];
    end
    
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        
        nremIdx=stateChange.(dName).nrem;
        
        for nIdx=1:length(nremIdx)
            temp=trisecFiring.(dName).pyr.zscore{nremIdx(nIdx)};
            
            if ite==0
                ranking=tiedrank(temp(:,1))/size(temp,1);
            else
                ranking=tiedrank(mean(temp,2))/size(temp,1);
            end
            
            for divIdx=1:nDiv
                
                frNrem{divIdx}=[frNrem{divIdx};temp(ranking>(divIdx-1)/nDiv & ranking<=divIdx/nDiv,:)];
            end
        end
        
        remIdx=stateChange.(dName).rem;
        
        for rIdx=1:length(remIdx)
            temp=trisecFiring.(dName).pyr.rate{remIdx(rIdx)};
            
            if ite==0
                ranking=tiedrank(temp(:,1))/size(temp,1);
            else
                ranking=tiedrank(mean(temp,2))/size(temp,1);
            end
            
            for divIdx=1:nDiv
                
                frRem{divIdx}=[frRem{divIdx};temp(ranking>(divIdx-1)/nDiv & ranking<=divIdx/nDiv,:)];
            end
        end
        
    end
end
%%
clear shuffle shuffleMI shuffleDLog

nShuffle=2000;

for sIdx=1:2
    if sIdx==1
        sName='nrem';
    else
        sName='rem';
    end
    
    for ite=1:nShuffle
        for divIdx=1:nDiv
            shuffle{divIdx}=[];
        end
        
        for dIdx=1:length(dList)
            dName=dList{dIdx};
            idxList=stateChange.(dName).(sName);
            
            for idx=1:length(idxList)
                fr=trisecFiring.(dName).pyr.zscore{idxList(idx)}(:,[1,3]);
                
                shufIdx=rand(size(fr,1),1)>0.5;
                shufIdx=[shufIdx,1-shufIdx]*size(fr,1)+[1:size(fr,1);1:size(fr,1)]';
                
                fr=fr(shufIdx);
                ranking=tiedrank(fr(:,1))/size(fr,1);
                for divIdx=1:nDiv
                    shuffle{divIdx}=...
                        [shuffle{divIdx};...
                        fr(ranking>(divIdx-1)/nDiv & ranking<=divIdx/nDiv,[1,end])];
                    
                end
            end
        end
        
        for divIdx=1:nDiv
            fr=shuffle{divIdx};
            shuffleMI.(sName)(divIdx,ite)=nanmean(diff(fr,1,2));
                        
        end
    end
    
    
    shuffleMI.(sName)=sort(shuffleMI.(sName),2);
end

%%
nCol=4;
nRaw=6;

colNrem=hsv2rgb([2/3*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colRem=hsv2rgb([5/6*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');


close all
fh=initFig4JNeuro(2);
densityRange=2*[-1,1]
for sIdx=1:2
    if sIdx==1
        sName='nrem';
        target=frNrem;
        titleText='Non-REM';
        col=colNrem;
    elseif sIdx==2
        sName='rem';
        target=frRem;
        titleText='REM';
        col=colRem;
    else
        continue
    end
    
    subplot2(nRaw,nCol,1,(sIdx-1)*2+1)
    hold on

    clear xVal yVal
    for n=1:nDiv
        xVal{n}=target{n}(:,1);
        yVal{n}=target{n}(:,end);
        plot(xVal{n},yVal{n},'.','color',col(n,:),'markersize',1)
    end
    xlim([-5,10])
    ylim([-5,10])
    xlabel({'Firing rate' 'in firest third (z)'})
    ylabel({'Firing rate' 'in last third (z)'})
%     set(gca,'xtick',-2:2:2,'ytick',-2:2:2)
    title(titleText)

    clear param
    param.n=cellfun(@length,xVal);
    
    saveGraph('quantile20s2',[alphabet(sIdx+2) '1'],...
        'scatter',...
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

    subplot2(nRaw,nCol,1,(sIdx-1)*2+2)
    
    fr=[cat(1,xVal{:}),cat(1,yVal{:})];

    logXrange=(densityRange);
    logYrange=(densityRange);
    xbin=linspace(logXrange(1),logXrange(2),50);
    ybin=linspace(logYrange(1),logYrange(2),50);
    densMap=hist2(fr,xbin,ybin);
        
    mu = [0 0];
    Sigma = [1 0; 0 1];
    smoothCoreBin = -3:3;
    [smoothCoreBin,smoothCoreBin] = meshgrid(smoothCoreBin,smoothCoreBin);
    smoothCore = mvnpdf([smoothCoreBin(:) smoothCoreBin(:)],mu,Sigma);
    smoothCore = reshape(smoothCore,length(smoothCoreBin),length(smoothCoreBin));
    smoothCore=smoothCore/sum(sum(smoothCore));

    densMap=conv2(densMap,smoothCore,'same');
    imagescXY(logXrange,logYrange,(densMap))
    colormap(gca,jet)

	plotIdentityLine(gca,{'color',0.99*[1,1,1]})
    xlabel({'Firing rate' 'in firest third (z)'})
    ylabel({'Firing rate' 'in last third (z)'})
    title(titleText)
    
    clear param
    param.nBin=[length(xbin),length(ybin)];
    param.smoothingSize=7;
    param.smoothingSD=1;
    
    saveGraph('quantile20s2',[alphabet(sIdx+2) '2'],...
        'spectrum',...
        [logXrange,logYrange],... %x
        densMap,... %y
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
for sIdx=1:2
    if sIdx==1
        sName='nrem';
        target=frNrem;
        titleText='Non-REM';
        col=colNrem;
    elseif sIdx==2
        sName='rem';
        target=frRem;
        titleText='REM';
        col=colRem;
    else
        continue
    end
    
    for measureType=1
        if measureType==1
            func=@(x) diff(x(:,[1,end]),1,2);
            measureName='\Deltaz';
            defName='Deflection of \Deltaz';
            shuffled=shuffleMI.(sName);
        else
            continue
        end
    
        for offsetType=1:2
            if offsetType==1
                offset=zeros(1,nDiv);
                yLabelText=measureName;
            elseif offsetType==2
                offset=mean(shuffled,2)';
                yLabelText=defName;
            end
        
            clear xVal yVal eVal
            xVal=1:nDiv;
            yVal=cellfun(@(x) nanmean(func(x)),target)-offset;    
            eVal=cellfun(@(x) nanste(func(x)),target);
            
            confInt=[shuffled(:,ceil(nShuffle*0.025))'-offset;shuffled(:,floor(nShuffle*0.975))'-offset];

            subplot2(nRaw,nCol,1+offsetType,measureType+2*(sIdx-1))
            hold on
            
            clear p
            for n=1:nDiv
                lowerBond=find(shuffled(n,:)<yVal(n),1,'last');
                if isempty(lowerBond)
                    lowerBond=0;
                end
                
                                    
                upperBond=find(shuffled(n,:)>yVal(n),1,'first');
                if isempty(upperBond)
                    upperBond=nShuffle;
                end
                p(n)=1-max([(nShuffle/2-lowerBond)/nShuffle*2,(upperBond-nShuffle/2)/nShuffle*2]);
            end
        
            plot([1;1]*xVal,[yVal+(2*(yVal>0)-1).*eVal;yVal],'color',col(3,:))
            bar(xVal,yVal,0.8,'linestyle','none','facecolor',col(3,:))
            
            
            fill([1:nDiv,nDiv:-1:1],...
                [confInt(1,:),fliplr(confInt(2,:))],...
                col(3,:),'linestyle','none','faceAlpha',0.5);
                        
            xlim([0.5,nDiv+0.5])
            set(gca,'xtick',1:nDiv)
            xlabel('Quantile')
            ylabel(yLabelText)
            
            clear param
            param.confInt=confInt;
            param.p=p;
            param.nShuffle=nShuffle;
            param.ShuffleMean=mean(shuffled,2)'-offset;
            
    saveGraph('quantile20s2',[alphabet(sIdx+2) num2str(2+offsetType) alphabet(measureType)],...
        'multiBar',...
        xVal,... %x
        yVal,... %y
        eVal,... %error 
        col,... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename)             
        end
     end
end
%%
ax=fixAxis;
text2(1,-0.2,['made with ' mfilename '.m'],ax,...
    {'horizontalALign','right','verticalAlign','top','fontsize',4,'interpreter','none'})

print(fh,'~/Dropbox/Quantile/preliminary/Zscore-withinEpochs_20s.pdf','-dpdf')


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
    ...'stableSleep'
    ...'stableWake'
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
nremAllFr=[];
nTriplet=0;
nNrem=0;
for dIdx=1:length(dList)
    dName=dList{dIdx};
    
    idx=stateChange.(dName).nrem2rem2nrem;

    fr=[fr;
        [cat(2,firing.(dName).pyr.rate{idx(:,1)})',...
         cat(2,firing.(dName).pyr.rate{idx(:,3)})']];
    nremAllFr=[nremAllFr;[firing.(dName).pyr.rate{stateChange.(dName).nrem}]'];
    nTriplet=nTriplet+length(stateChange.(dName).nrem2rem2nrem);
    nNrem=nNrem+length(stateChange.(dName).nrem);
end

%%
% for ite=1:2000
%     
% %     temp=fr(randperm(size(fr,1),ceil(size(fr,1)*0.1)),:);
%     temp=fr;
%     
%     idx=rand(size(temp,1),1)>0.5;
%     idx=[1-idx,idx]*size(temp,1)+([1;1]*(1:size(temp,1)))';
%     temp=temp(idx);
%     combineNoise(ite,:)=polyfit(temp(:,1),abs(diff(temp,1,2)),1);
%     
%     temp2=temp(~any(temp==0,2),:);
% %     multiNoise(ite)=nanmean(abs(diff(temp2,1,2))./temp2(:,1));
% %     multiNoise(ite)=sqrt(exp(var(diff(log(temp2),1,2))/2)-1);
% %     multiNoise(ite)=std(diff(temp2,1,2)./mean(temp2,2))/sqrt(2);
% %     addNoise(ite)=std(diff(temp,1,2))/sqrt(2);
%     multiNoise(ite)=rms(diff(temp2,1,2)./mean(temp2,2))*sqrt(2);
%     addNoise(ite)=rms(diff(temp,1,2)/2)*sqrt(2);
% 
%         
%     distMu(ite)=nanmean(temp(:,1));
%     distSigma(ite)=nanstd(temp(:,1));
% end
temp=fr;
temp(any(temp==0,2),:)=[];
addNoise=rms(diff(temp,1,2)/2)*sqrt(2);
multiNoise=rms(diff(temp,1,2)./mean(temp,2))*sqrt(2);

firing

distMu=mean(nremAllFr(:));
distSigma=std(nremAllFr(:));

% mean(combineNoise);
% std(combineNoise);
% 
% mean(multiNoise);
% std(multiNoise);
% 
% mean(addNoise);
% std(addNoise);
% 
%%
% nCell=size(fr,1);
nCell=5000;
% mu=mean(fr(:,1));
% sigma=std(fr(:,1));
mu=mean(distMu);
sigma=mean(distSigma);
nShuffle=2000;

meanDiff=mean(fr(:,2))-mean(fr(:,1));
meanRatio=mean(fr(:,2))/mean(fr(:,1));
bothChange=polyfit(fr(:,1),fr(:,2),1);

mean(fr(:,1))*meanRatio^0.5+meanDiff/2

% additiveNoiseMu=mean(addNoise);
% additiveNoiseSigma=std(addNoise);
additiveNoiseMu=0;
additiveNoiseSigma=mean(addNoise);

% multiplicativeNoiseMu=mean(multiNoise);
% multiplicativeNoiseSigma=std(multiNoise);
multiplicativeNoiseMu=1;
multiplicativeNoiseSigma=mean(multiNoise);

% bothNoiseAdditiveMu=mean(combineNoise(:,2));
% bothNoiseAdditiveSigma=std(combineNoise(:,2));
% bothNoiseMultiplicativeMu=mean(combineNoise(:,1));
% bothNoiseMultiplicativeSigma=std(combineNoise(:,2));
% bothNoiseAdditiveMu=0;
% bothNoiseAdditiveSigma=mean(combineNoise(:,2));
% bothNoiseMultiplicativeMu=1;
% bothNoiseMultiplicativeSigma=mean(combineNoise(:,1));
bothNoiseAdditiveMu=0;
bothNoiseAdditiveSigma=additiveNoiseSigma;
bothNoiseMultiplicativeMu=1;
bothNoiseMultiplicativeSigma=multiplicativeNoiseSigma;


eqList={@(x)x, @(x)x*meanRatio, @(x)x+meanDiff,  @(x)x*bothChange(1)+bothChange(2),};
eqName={'y = x',['y = ' num2str(meanRatio,3) 'x'],['y = x - ' num2str(meanDiff,3)],['y = ' num2str(bothChange(1),3) 'x +' num2str(bothChange(2),3)],};

noiseList={[0,0],[0,1],[1,0],[1,1]};
noiseName={'No noise' 'Additive noise' 'Multiplicative noise' 'Both noises'};

nDiv=5;
col=hsv2rgb([2/3*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,0.5,nDiv)']);
col2=hsv2rgb([0/3*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,0.5,nDiv)']);

f1original = lognrnd2(mu,sigma,2*nCell,1);

psFileName='~/Dropbox/Quantile/preliminary/logNormalQuantileSimlation.ps';
doAppend='';


close all
fh=initFig4JNeuro(2);
set(fh,'defaultLineMarkerSize',4)


subplot2(length(eqList)+1,length(noiseList),1,1)

plot(10.^[-3,2],10.^[-3,2],'k-')
hold on
plot(fr(:,1),fr(:,2),'r.')
set(gca,'xscale','log','yscale','log')
xlim(10.^[-3,2])
ylim(10.^[-3,2])
xlabel('FR in NREM_i (Hz)')
ylabel('FR in NREM_{i+1} (Hz)')
box off
title('NREM/REM/NREM')
ax=fixAxis;
text(10^3,10^2,{
    ['<FR_i> = ' num2str(mu,2) ', std(FR_i) = ' num2str(sigma,3)]
    ['<FR_{i+1}> - <FR_i> =' num2str(meanDiff,2) ', <FR_{i+1}>/<FR_i> =' num2str(meanRatio,3)]
    ['FR_{i+1} =' num2str(bothChange(1),2) 'FR_{i+1} + ' num2str(bothChange(2),3)]
    ''
    'Parameters of simulated data'
    [num2str(nCell) 'points distributed in log-normal (mean: ' num2str(mu,3) ', sd: ' num2str(sigma,3) ')']
    'noise was added to x and y independently'
    'F'' = [multiplicative noise] * F + [additive noise]'
    ['Additive noise: Gaussian noise, mean = ' num2str(additiveNoiseMu,3) ' sd = ' num2str(additiveNoiseSigma,3) ]
    ['Multiplicative noise: Gaussian noise mean = ' num2str(multiplicativeNoiseMu,3) ' sd = ' num2str(multiplicativeNoiseSigma,3)]
    ['Both noises: additive noise mean = ' num2str(bothNoiseAdditiveMu,3) ' sd = ' num2str(bothNoiseAdditiveSigma,3),...
                  'multiplicative noise mean = ' num2str(bothNoiseMultiplicativeMu,3) ' sd = ' num2str(bothNoiseMultiplicativeSigma,3)]
    },...
    'horizontalALign','left','verticalAlign','top','fontsize',7)


noiseMu=[0,1;
         additiveNoiseMu,1;
         0,multiplicativeNoiseMu;
         bothNoiseAdditiveMu,bothNoiseMultiplicativeMu];

noiseSigma=[0,0;
         additiveNoiseSigma,0;
         0,multiplicativeNoiseSigma;
         bothNoiseAdditiveSigma,bothNoiseMultiplicativeSigma];
     
     
for eqIdx=1:length(eqList)
    for noiseIdx=1:length(noiseList)
        
        eq=eqList{eqIdx};
        
        f2=eq(f1original);
        
        f1=f1original.*normrnd(noiseMu(noiseIdx,2),noiseSigma(noiseIdx,2),2*nCell,1)+...
            normrnd(noiseMu(noiseIdx,1),noiseSigma(noiseIdx,1),2*nCell,1);
%         f1=f1original.*lognrnd2(noiseMu(noiseIdx,2),noiseSigma(noiseIdx,2),2*nCell,1)+...
%             normrnd(noiseMu(noiseIdx,1),noiseSigma(noiseIdx,1),2*nCell,1);


        f2=f2.*normrnd(noiseMu(noiseIdx,2),noiseSigma(noiseIdx,2),2*nCell,1)+...
            normrnd(noiseMu(noiseIdx,1),noiseSigma(noiseIdx,1),2*nCell,1);
%         f2=f2.*lognrnd2(noiseMu(noiseIdx,2),noiseSigma(noiseIdx,2),2*nCell,1)+...
%             normrnd(noiseMu(noiseIdx,1),noiseSigma(noiseIdx,1),2*nCell,1);
        
        temp=[f1,f2];
        temp(any(temp<0,2),:)=[];
        
        f1=temp(1:nCell,1);
        f2=temp(1:nCell,2);
        
        ranking=tiedrank(f1)/length(f1);
        
        simData{eqIdx,noiseIdx}=[f1,f2];
        
        
        subplot2(length(eqList)+1,length(noiseList),eqIdx+1,noiseIdx)
        plot(10.^[-3,2],10.^[-3,2],'k-')
        hold on
        clear xVal yVal
        for idx=1:nDiv
            xVal{idx}=f1(ranking>(idx-1)/nDiv&ranking<=idx/nDiv);
            yVal{idx}=f2(ranking>(idx-1)/nDiv&ranking<=idx/nDiv);
            plot(xVal{idx},...
                yVal{idx},'.',...
                'color',col(idx,:))
        end
        set(gca,'xscale','log','yscale','log')
        xlim(10.^[-3,2])
        ylim(10.^[-3,2])
        box off
        ax=fixAxis;
        if eqIdx==1
            title(noiseName{noiseIdx})
        end
        if noiseIdx==1
            text(10^-5,10^-0.5,eqName{eqIdx},...
                'horizontalAlign','center','verticalAlign','middle',...
                'rotation',90,'fontsize',8,'fontweight','bold')
        end
        xlabel('FR (Hz)')
        ylabel('FR (Hz)')
        clear param
        
        param.equation=eqName{eqIdx};
        param.noise=noiseName{noiseIdx};
        param.nCell=nCell;
        
        saveGraph('quantile20s1',['a' num2str(eqIdx) alphabet(noiseIdx)],...
            'scatter',...
            xVal,... %x
            yVal,... %y
            [],... %error 
            col,... %color
            get(gca),... %info
            get(get(gca,'xlabel'),'string'),... %xlabel
            get(get(gca,'ylabel'),'string'),... %ylabel
            noiseName{noiseIdx},... %title,
            param,... %legend
            mfilename)                    
                        
        
        
    end
end
ax=fixAxis;
text(10^2,10^-5,['made with ' mfilename '.m'],...
    'fontsize',4,'horizontalALign','right','fontsize',4)

print(fh,psFileName,'-dpsc2',doAppend)
doAppend='-append';
%%
close all
fh=initFig4JNeuro(2);
set(fh,'defaultLineMarkerSize',4)
box off

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
    
subplot2(1+2*length(eqList),length(noiseList),1,2*type+1)
f1=fr(:,1);
mi=idxEq(fr);        
ranking=tiedrank(f1)/length(f1);
hold on
for idx=1:nDiv
    plot(f1(ranking>(idx-1)/nDiv&ranking<=idx/nDiv),...
        mi(ranking>(idx-1)/nDiv&ranking<=idx/nDiv),'.',...
        'color',col2(idx,:))
end 
set(gca,'xscale','log')
xlim(10.^[-3,2])
xlabel('FR (Hz)')
ylabel(measureName)
title('NREM/REM/NREM')

for eqIdx=1:length(eqList)
    for noiseIdx=1:length(noiseList)
        
        
        f1=simData{eqIdx,noiseIdx}(:,1);
        mi=idxEq(simData{eqIdx,noiseIdx});        
        ranking=tiedrank(f1)/length(f1);
        
        subplot2(1+2*length(eqList),length(noiseList),1+type*length(eqList)+eqIdx,noiseIdx)
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
        if eqIdx==1
            title(noiseName{noiseIdx})
        end
        ax=fixAxis;
        if noiseIdx==1
            text(10^-5,mean(ax(3:4)),eqName{eqIdx},...
                'horizontalAlign','center','verticalAlign','middle',...
                'rotation',90,'fontsize',8,'fontweight','bold')
        end
        xlabel('FR (Hz)')
        ylabel(measureName)
        
         clear param
        
        param.equation=eqName{eqIdx};
        param.noise=noiseName{noiseIdx};
        param.nCell=nCell;
        
        saveGraph('quantile20s1',[alphabet(type+2) num2str(eqIdx) alphabet(noiseIdx)],...
            'scatter',...
            xVal,... %x
            yVal,... %y
            [],... %error 
            col,... %color
            get(gca),... %info
            get(get(gca,'xlabel'),'string'),... %xlabel
            get(get(gca,'ylabel'),'string'),... %ylabel
            noiseName{noiseIdx},... %title,
            param,... %legend
            mfilename)                    
        
        
    end
end
end

ax=fixAxis;
text2(1,-1.2,['made with ' mfilename '.m'],ax,...
    {'fontsize',4,'horizontalALign','right'})


print(fh,psFileName,'-dpsc2',doAppend)
doAppend='-append';
%%
close all
fh=initFig4JNeuro(2);
set(fh,'defaultLineMarkerSize',4)

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
            color=col2;
%         case 3
%             idxEq=@(x) diff(x,1,2)./x(:,1);
%             measureName='\DeltaFR/FR';
    end
    for eqIdx=1:length(eqList)
        for noiseIdx=1:length(noiseList)

            f1=simData{eqIdx,noiseIdx}(:,1);
            mi=idxEq(simData{eqIdx,noiseIdx});        
            ranking=tiedrank(f1)/length(f1);

            subplot2(2*length(eqList),length(noiseList),type*length(eqList)+eqIdx,noiseIdx)
            hold on
            
            clear yVal xVal
            for idx=1:nDiv
                val=mi(ranking>(idx-1)/nDiv&ranking<=idx/nDiv);
                yVal{idx}=hist(val,bin)/length(val)*100;
                plot(bin,yVal{idx},'color',color(idx,:))
                xVal{idx}=bin;
            end  
            xlabel(measureName)
            ylabel('Count (%)')
            xlim(xRange)
            ax=fixAxis;

        if eqIdx==1
            title(noiseName{noiseIdx})
        end
        if noiseIdx==1
            text2(-0.5,0.5,eqName{eqIdx},ax,...
                {'horizontalAlign','center','verticalAlign','middle',...
                'rotation',90,'fontsize',8,'fontweight','bold'})
        end 
        

        clear param
        param.noiseType=noiseName;
        param.equation=eqName{eqIdx};
        param.measureName=measureName;
        param.nCell=nCell;
        
         saveGraph('quantile20s1',[alphabet(type+4) num2str(eqIdx) alphabet(noiseIdx)],...
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
    end
end

text2(1,-1.2,['made with ' mfilename '.m'],ax,...
    {'fontsize',4,'horizontalALign','right'})

subplot2(2*length(eqList),length(noiseList),2*length(eqList),1)
hold on
ax=fixAxis;
text2(-0.2,-0.75,{'blue: mean, red: median.' 
    ['Color shade indicates each quantile']},...
    ax,{'horizontalAlign','left','verticalAlign','top','fontsize',7})

print(fh,psFileName,'-dpsc2',doAppend)
doAppend='-append';

%%
close all
fh=initFig4JNeuro(2);
set(fh,'defaultLineMarkerSize',4)

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
for eqIdx=1:length(eqList)
    for noiseIdx=1:length(noiseList)
              
        f1=simData{eqIdx,noiseIdx}(:,1);
        mi=idxEq(simData{eqIdx,noiseIdx});        
        ranking=tiedrank(f1)/length(f1);
        
        realMean=[];
        realMedian=[];
        realSte=[];
        clear realConf;
        for idx=1:nDiv
            val=mi(ranking>(idx-1)/nDiv&ranking<=idx/nDiv);
            realMean(idx)=mean(val);
            realMedian(idx)=median(val);
            realSte(idx)=ste(val);
            tempMean=[];
            tempMedian=[];
            nSubsample=ceil(length(val)/10);
            for rep=1:nShuffle
                subset=val(randperm(length(val),nSubsample));
                tempMean(rep)=mean(subset);
                tempMedian(rep)=median(subset);
            end
            tempMean=sort(tempMean);
            tempMedian=sort(tempMedian);  
            
            realConf.mean(idx,:)=tempMean([floor(nShuffle*0.025),ceil(nShuffle*0.975)])
            realConf.median(idx,:)=tempMedian([floor(nShuffle*0.025),ceil(nShuffle*0.975)])
            
        end        

        clear shuffleMean shuffleMedian
        for ite=1:nShuffle
            shuffleIdx=rand(nCell,1)>0.5;
            shuffleIdx=[shuffleIdx,1-shuffleIdx];
            shuffleIdx=repmat((1:nCell)',1,2)+nCell*shuffleIdx;

            shuffleData=simData{eqIdx,noiseIdx}(shuffleIdx);
            mi=idxEq(shuffleData);
            ranking=tiedrank(shuffleData(:,1))/length(shuffleData(:,1));
            for idx=1:nDiv
                shuffleMean(ite,idx)=mean(mi(ranking>(idx-1)/nDiv&ranking<=idx/nDiv));
                shuffleMedian(ite,idx)=median(mi(ranking>(idx-1)/nDiv&ranking<=idx/nDiv));
            end        
        end

        shuffleMean=sort(shuffleMean);
        shuffleMedian=sort(shuffleMedian);
        
        shuffledRes.ConfInt.mean{eqIdx,noiseIdx}=shuffleMean([floor(nShuffle*0.025),ceil(nShuffle*0.975)],1:nDiv);
        shuffledRes.ConfInt.median{eqIdx,noiseIdx}=shuffleMedian([floor(nShuffle*0.025),ceil(nShuffle*0.975)],1:nDiv);
        
        shuffledRes.mean.mean{eqIdx,noiseIdx}=mean(shuffleMean);
        shuffledRes.mean.median{eqIdx,noiseIdx}=mean(shuffleMedian);
        
        subplot2(2*length(eqList),length(noiseList),type*length(eqList)+eqIdx,noiseIdx)
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
            [shuffleMean(floor(nShuffle*0.025),1:nDiv),shuffleMean(ceil(nShuffle*0.975),nDiv:-1:1)],...
            'b','linestyle','none','facealpha',0.5)
        fill([1:nDiv,nDiv:-1:1],...
            [shuffleMedian(floor(nShuffle*0.025),1:nDiv),shuffleMedian(ceil(nShuffle*0.975),nDiv:-1:1)],...
            'r','linestyle','none','facealpha',0.5)

        plot(1:nDiv,mean(shuffleMean),'b-')
        plot(1:nDiv,mean(shuffleMedian),'r-')
        ax=fixAxis;

        if eqIdx==1
            title(noiseName{noiseIdx})
        end
        if noiseIdx==1
            text2(-0.5,0.5,eqName{eqIdx},ax,...
                {'horizontalAlign','center','verticalAlign','middle',...
                'rotation',90,'fontsize',8,'fontweight','bold'})
        end
        xlabel('Quintile')
        ylabel(measureName)

        clear param
        param.shuffle.mean=mean(shuffleMean)
        param.shuffle.confInt=shuffleMean([floor(nShuffle*0.025),ceil(nShuffle*0.975)],:);
        param.real.ste=realSte;
        param.real.confInt=realConf.mean;
        param.noiseType=noiseName;
        param.equation=eqName{eqIdx};
        param.measureName=measureName;
        param.statName='mean';
        param.nShuffle=nShuffle;
        param.nCell=nCell;
         saveGraph('quantile20s1',[alphabet(type+6) num2str(eqIdx) alphabet(noiseIdx) '1'],...
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
        param.noiseType=noiseName;
        param.equation=eqName{eqIdx};
        param.measureName=measureName;
        param.statName='median';
        param.nShuffle=nShuffle;
        param.nCell=nCell;
        
         saveGraph('quantile20s1',[alphabet(type+6) num2str(eqIdx) alphabet(noiseIdx) '2'],...
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
end

end
ax=fixAxis;
text2(1,-1.2,['made with ' mfilename '.m'],ax,...
    {'fontsize',4,'horizontalALign','right'})

subplot2(2*length(eqList),length(noiseList),2*length(eqList),1)
hold on
ax=fixAxis;
text2(-0.2,-0.75,{'blue: mean, red: median.' 
    ['Colored band shows 95% CI estimated by shuffling (' num2str(nShuffle) ' times)']},...
    ax,{'horizontalAlign','left','verticalAlign','top','fontsize',7})

print(fh,psFileName,'-dpsc2',doAppend)
doAppend='-append';


%%
close all
fh=initFig4JNeuro(2);
set(fh,'defaultLineMarkerSize',4)

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
for eqIdx=1:length(eqList)
    for noiseIdx=1:length(noiseList)
              
        f1=simData{eqIdx,noiseIdx}(:,1);
        mi=idxEq(simData{eqIdx,noiseIdx});        
        ranking=tiedrank(f1)/length(f1);
        
        realMean=[];
        realMedian=[];
        realSte=[];
        clear realConf;
        for idx=1:nDiv
            val=mi(ranking>(idx-1)/nDiv&ranking<=idx/nDiv);
            realMean(idx)=mean(val)-shuffledRes.mean.mean{eqIdx,noiseIdx}(idx);
            realMedian(idx)=median(val)-shuffledRes.mean.median{eqIdx,noiseIdx}(idx);
            realSte(idx)=ste(val-shuffledRes.mean.mean{eqIdx,noiseIdx}(idx));
            tempMean=[];
            tempMedian=[];
            nSubsample=ceil(length(val)/10);
            for rep=1:nShuffle
                subset=val(randperm(length(val),nSubsample));
                tempMean(rep)=mean(subset)-shuffledRes.mean.mean{eqIdx,noiseIdx}(idx);
                tempMedian(rep)=median(subset)-shuffledRes.mean.median{eqIdx,noiseIdx}(idx);
            end
            tempMean=sort(tempMean);
            tempMedian=sort(tempMedian);  
            
            realConf.mean(idx,:)=tempMean([floor(nShuffle*0.025),ceil(nShuffle*0.975)])
            realConf.median(idx,:)=tempMedian([floor(nShuffle*0.025),ceil(nShuffle*0.975)])
            
        end        

        
        subplot2(2*length(eqList),length(noiseList),type*length(eqList)+eqIdx,noiseIdx)
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
            [shuffledRes.ConfInt.mean{eqIdx,noiseIdx}(1,1:nDiv)-shuffledRes.mean.mean{eqIdx,noiseIdx},...
             fliplr(shuffledRes.ConfInt.mean{eqIdx,noiseIdx}(2,1:nDiv)-shuffledRes.mean.mean{eqIdx,noiseIdx})],...
            'b','linestyle','none','facealpha',0.5)
        fill([1:nDiv,nDiv:-1:1],...
            [shuffledRes.ConfInt.median{eqIdx,noiseIdx}(1,1:nDiv)-shuffledRes.mean.median{eqIdx,noiseIdx},...
             fliplr(shuffledRes.ConfInt.median{eqIdx,noiseIdx}(2,1:nDiv)-shuffledRes.mean.median{eqIdx,noiseIdx})],...
            'r','linestyle','none','facealpha',0.5)

        ax=fixAxis;

        if eqIdx==1
            title(noiseName{noiseIdx})
        end
        if noiseIdx==1
            text2(-0.5,0.5,eqName{eqIdx},ax,...
                {'horizontalAlign','center','verticalAlign','middle',...
                'rotation',90,'fontsize',8,'fontweight','bold'})
        end
        xlabel('Quintile')
        ylabel(['Def of ' measureName])

        clear param
        param.shuffle.mean=zeros(1,nDiv);
        param.shuffle.confInt=shuffledRes.ConfInt.mean{eqIdx,noiseIdx}-[1;1]*shuffledRes.mean.mean{eqIdx,noiseIdx};
        param.real.ste=realSte;
        param.real.confInt=realConf.mean;
        param.noiseType=noiseName;
        param.equation=eqName{eqIdx};
        param.measureName=measureName;
        param.statName='mean';
        param.nShuffle=nShuffle;
        param.nCell=nCell;
         saveGraph('quantile20s1',[alphabet(type+8) num2str(eqIdx) alphabet(noiseIdx) '1'],...
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
        param.shuffle.confInt=shuffledRes.ConfInt.median{eqIdx,noiseIdx}-[1;1]*shuffledRes.mean.median{eqIdx,noiseIdx};
        param.real.confInt=realConf.median;
        param.noiseType=noiseName;
        param.equation=eqName{eqIdx};
        param.measureName=measureName;
        param.statName='median';
        param.nShuffle=nShuffle;
        param.nCell=nCell;
        
         saveGraph('quantile20s1',[alphabet(type+8) num2str(eqIdx) alphabet(noiseIdx) '2'],...
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
end

end
ax=fixAxis;
text2(1,-1.2,['made with ' mfilename '.m'],ax,...
    {'fontsize',4,'horizontalALign','right'})

subplot2(2*length(eqList),length(noiseList),2*length(eqList),1)
hold on
ax=fixAxis;
text2(-0.2,-0.75,{'blue: mean, red: median.' 
    ['Colored band shows 95% CI estimated by shuffling (' num2str(nShuffle) ' times)']},...
    ax,{'horizontalAlign','left','verticalAlign','top','fontsize',7})

print(fh,psFileName,'-dpsc2',doAppend)
doAppend='-append';






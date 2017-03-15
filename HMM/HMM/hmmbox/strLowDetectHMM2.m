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
    ...'eventFiring'
    ...'stableSleep'
    ...'stableWake'
    'stateChange'
    ...'firing1secBin'
    'FRinSlidingWindow'
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
showPlot=false;

if showPlot
    close all
    fh =initFig4Nature(2);
    doAppend='';
end

zSmoothSigma=1;

for dIdx=1:length(dList)
    dName=dList{dIdx};
    
    lfp=load([basics.(dName).filename '-fineEegSpec.mat']);
    
    load([basics.(dName).filename '-CheckEegParam.mat'])
    
    fst=find( lfp.t<behavior.(dName).time(1),1,'last');
    if ~isempty(fst)
        lfp.Pxx(1:fst,:)=[];
        lfp.t(1:fst)=[];
    end
    
    lst=find(lfp.t>behavior.(dName).time(2),1,'first');
    if ~isempty(lst)
        lfp.Pxx(lst:end,:)=[];
        lfp.t(lst:end)=[];
    end    
    
    %%
    behList=[];
    for behType=1:6
        
        switch behType
            case 1
                idxGrp=1;
                behName='nrem';
            case 2
                idxGrp=2;
                behName='low';
            case 3
                idxGrp=3;
                behName='rem';
            case 4
                idxGrp=[4,5];
                behName='ma';
            case 5
                idxGrp=[6,7];
                behName='quiet';
            case 6
                idxGrp=8;
                behName='active';
        end
        temp=detailedBehavior.(dName).list(ismember(detailedBehavior.(dName).list(:,3),idxGrp),1:2);
        temp=removeTransient(temp,eps,eps);
        
        behList=[behList;[temp,behType*ones(size(temp,1),1)]];
        behNameList{behType}=behName;
    end
    behList=sortrows(behList,1);
    
    
    idx=0:5000:length(FRinSlidingWindow.(dName).t);
    windowList=[idx+1;[idx(2:end),length(FRinSlidingWindow.(dName).t)]]';
    tBinSize=median(diff(FRinSlidingWindow.(dName).t));
    temp=nan*zeros(1,length(FRinSlidingWindow.(dName).t));
    for windowIdx=1:size(windowList,1)
        timeWindow=FRinSlidingWindow.(dName).t(windowList(windowIdx,:))';
        timeWindow=timeWindow+tBinSize/2*[-1,1];
        
        display([datestr(now) ' ' dName '-' 'behType' ' ' num2str(windowIdx) '/' num2str(size(windowList,1))])
        fst=find(behList(:,2)>=timeWindow(1),1,'first');
        lst=find(behList(:,1)<=timeWindow(2),1,'last');
        subList=behList(fst:lst,:);
%         if lst>2; behList(1:lst-1,:)=[]; end
        
        for idx=windowList(windowIdx,1):windowList(windowIdx,2)
            begIdx=find(subList(:,1)<=FRinSlidingWindow.(dName).t(idx)-tBinSize/2,1,'last');
            if isempty(begIdx); begIdx=1; end
            endIdx=find(subList(:,1)<=FRinSlidingWindow.(dName).t(idx)+tBinSize/2,1,'last');
            if isempty(endIdx); endIdx=1; end
            
            if begIdx==endIdx
                temp(idx)=subList(begIdx,3);
            else
                inBin=subList(begIdx:endIdx,:);
                if inBin(1,1)<FRinSlidingWindow.(dName).t(idx)-tBinSize/2; inBin(1,1)=FRinSlidingWindow.(dName).t(idx)-tBinSize/2; end
                if inBin(end,2)>FRinSlidingWindow.(dName).t(idx)+tBinSize/2; inBin(end,2)=FRinSlidingWindow.(dName).t(idx)+tBinSize/2; end
                [~,maxIdx]=max(diff(inBin(:,1:2),1,2));
                temp(idx)=inBin(maxIdx,3);
            end
        end
    end
    
    behId=temp;
    
    
    
    
    %%
    
    % [a,b]=findRange(lfp.f,[5,25]);
    [a,b]=findRange(lfp.f,[5,50]);

    tBinSize=median(diff(lfp.t)/1e6);
    xbin=0:tBinSize:4*zSmoothSigma;
    xbin=[-xbin(end:-1:2),xbin];
    gFil=normpdf(xbin,0,zSmoothSigma)*tBinSize;
    gFil=gFil/sum(gFil);
    
    subSpec=(mean(lfp.Pxx(:,a:b),2));
    
    exIdx=find(zscore(mean(subSpec,2))>30);
    while ~isempty(exIdx)
        [~,peakIdx]=max(mean(subSpec(exIdx,:),2));    
        gap=find(diff(exIdx)~=1);
        fst=gap(find(gap<peakIdx,1,'last'));
        if isempty(fst); fst=0; end
        fst=fst+1;
        lst=gap(find(gap>peakIdx,1,'first'));
        if isempty(lst);lst=length(exIdx);end
                
        baseIdx=[exIdx(fst)+(-10:-1),exIdx(lst)+(1:10)];
        baseIdx=baseIdx(baseIdx>0&baseIdx<=size(subSpec,1));
        subSpec(exIdx(fst:lst),:)=interp1(baseIdx,subSpec(baseIdx,:),exIdx(fst:lst));
        exIdx=find(zscore(mean(subSpec,2))>30);
    end
    nremIdx=find(behId<3);
    
    subPow=mean(subSpec,2);
    
    subPow=conv(subPow,gFil,'same');
    subPow=subPow(nremIdx);
    
    nStates=2;
    likelyhood=[];
    res={};
    for nTry=1:3
        [temp,thhmm,thdec] = gausshmm(subPow,nStates,1,0);
        if mean(abs(diff(temp)))<0.8 && sum(abs(diff(temp)))>10
            likelyhood(end+1)=thhmm.LLtrain;
            res{end+1}=temp;
        end
    end
    if isempty(likelyhood)
        origState=temp;        
    else
        [~,idx]=max(likelyhood);
        origState=res{idx};
    end    
    
    
    
    for n=1:nStates
        meanPow(n)=mean(subPow(origState==n));
    end
    [~,minId]=min(meanPow);
    
    theState=(origState==minId);
    
    HmmLow2.(dName).behId=behId;
    HmmLow2.(dName).behId(nremIdx)=theState+1;
    HmmLow2.(dName).behType=behNameList;
    HmmLow2.(dName).t=lfp.t;
    
    HmmLow2.(dName).param.madeby=mfilename;
    HmmLow2.(dName).param.smooth=zSmoothSigma;
    HmmLow2.(dName).param.fRange=[5,50];
    
    %%
    if showPlot
        subplot(6,5,5*mod(dIdx-1,6)+(1:3))
        
        length(subPow)
        
        imagescXY(0.1*(0:1200),lfp.f(1:80),log(lfp.Pxx(nremIdx(end-4200:end-3000),1:80)))
        
        logPow=log(pow);
        logPow(isinf(logPow))=[];
        
        set(gca,'clim',mean(logPow)+std(logPow)*[-2,3])
        colormap(gray)
        
        
        
        hold on
        plot(0.1*(0:1200),(1-theState(end-4200:end-3000))*10+35,'-c','linewidth',2)
        
        xlim([0,120])
        xlabel('Time in NREM (s)');
        ylabel('Freq (Hz)')
        title(getDispName(dName))
        
        subplot(6,5,5*mod(dIdx-1,6)+4)
        bin=7:0.1:14;
        hold on
        cnt=hist(log(subPow(theState==1)),bin)
        plot(bin,cnt,'-','color',[0.5,0.5,1])
        cnt=hist(log(subPow(theState==0)),bin)
        plot(bin,cnt,'-','color',[0.6,0,0.6])
        xlabel('log power in 5-50Hz')
        xlim([7,14])
        ylabel('Count')
        
        
        subplot(6,5,5*mod(dIdx-1,6)+5)
        meanF=mean(FRinSlidingWindow.(dName).z);
        meanF=meanF(nremIdx);
        [~,bin]=hist(meanF,500);
        hold on
        cnt=hist((meanF(theState==1)),bin)
        plot(bin,cnt,'-','color',[0.5,0.5,1])
        cnt=hist((meanF(theState==0)),bin)
        plot(bin,cnt,'-','color',[0.6,0,0.6])
        xlabel('Mean FR (z)')
        ylabel('Count')        
        axis tight
        if mod(dIdx,6)==0 || dIdx==length(dList)
            addScriptName(mfilename)
            print(fh,'~/Dropbox/LOW/preliminary/HMM_lowDetection_test2.ps','-dpsc',doAppend)
            doAppend='-append';
            clf
        end
    end
    
end

varList={'HmmLow2'};
for varName=varList
    save([baseDir coreName '-' varName{1} '.mat'],varName{1},'-v7.3')
end
% %%
% subID=behId(behId<3);
%
% for n=1:nStates
%     meanPow(n)=mean(subPow(theState==n));
% end
% [~,isLow]=min(meanPow)
%
% res=(theState==isLow)+1;
%
% sum(res(subID==1)==1)/sum(subID==1)
%
% sum(res(subID==2)==2)/sum(subID==2)
%
% sum(res(subID==2)==2)/sum(res==2)
%
% sum(res==2)/length(res)


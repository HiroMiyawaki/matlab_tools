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
showPlot=true;

if showPlot
    close all
    fh =initFig4Nature(2);
    doAppend='';
end

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
    
    
    idx=1:5000:length(lfp.t);
    windowList=[idx;[idx(2:end),length(lfp.t)]]';
    
    temp=nan*zeros(1,length(lfp.t)-1);
    for windowIdx=1:size(windowList,1)
        timeWindow=lfp.t(windowList(windowIdx,:))';
        
        display([datestr(now) ' ' dName '-' 'behType' ' ' num2str(windowIdx) '/' num2str(size(windowList,1))])
        fst=find(behList(:,2)>=timeWindow(1),1,'first');
        lst=find(behList(:,1)<=timeWindow(2),1,'last');
        subList=behList(fst:lst,:);
        if lst>2; behList(1:lst-1,:)=[]; end
        
        for idx=windowList(windowIdx,1):windowList(windowIdx,2)-1
            begIdx=find(subList(:,1)<=lfp.t(idx),1,'last');
            if isempty(begIdx); begIdx=1; end
            endIdx=find(subList(:,1)<=lfp.t(idx+1),1,'last');
            if isempty(endIdx); endIdx=1; end
            
            if begIdx==endIdx
                temp(idx)=subList(begIdx,3);
            else
                inBin=subList(begIdx:endIdx,:);
                if inBin(1,1)<lfp.t(idx); inBin(1,1)=lfp.t(idx); end
                if inBin(end,2)>lfp.t(idx+1); inBin(end,2)=lfp.t(idx+1); end
                [~,maxIdx]=max(diff(inBin(:,1:2),1,2));
                temp(idx)=inBin(maxIdx,3);
            end
        end
    end
    
    behId=temp;
    
    
    
    
    %%
    
    % [a,b]=findRange(lfp.f,[5,25]);
    [a,b]=findRange(lfp.f,[5,50]);
    
    pow=(mean(lfp.Pxx(:,a:b),2));
    
    nremIdx=find(behId<3);
    
    subPow=pow(nremIdx);
    
    if strcmpi(dName,'TedSleep2')
        exIdx=find(subPow>mean(subPow)+30*std(subPow));
        baseIdx=[exIdx(1)+(-10:-1),exIdx(end)+(1:10)];
        subPow(exIdx)=interp1(baseIdx,subPow(baseIdx),exIdx);
    end
    
    nStates=2;
    [origState,thhmm,thdec] = gausshmm(subPow,nStates,1,0);
    
    for n=1:nStates
        meanPow(n)=mean(subPow(origState==n));
    end
    [~,highId]=max(meanPow);
    
    theState=(origState==highId);
    
    HmmLow.(dName).behId=behId;
    HmmLow.(dName).behId(nremIdx)=theState+1;
    HmmLow.(dName).behType=behNameList;
    HmmLow.(dName).t=lfp.t;
    
    HmmLow.(dName).param.madeby=mfilename;
    HmmLow.(dName).param.fRange=[5,50];
    
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
        plot(0.1*(0:1200),theState(end-4200:end-3000)*10+35,'-c','linewidth',2)
        
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
            print(fh,'~/Dropbox/LOW/preliminary/HMM_lowDetection_test.ps','-dpsc',doAppend)
            doAppend='-append';
            clf
        end
    end
    
end

varList={'HmmLow'}
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


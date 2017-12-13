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
close all
fh=initFig4Nature(2);
psFileName='~/Dropbox/LOW/preliminary/5-20HzPowerInNREM_noOverlap';
doAppend='';

for dIdx=1:length(dList);
    dName=dList{dIdx};
    
%     lfp=load([basics.(dName).filename '-fineEegSpec.mat']);
    lfp=load([basics.(dName).filename '-1sSpec_noSlide.mat']);
    
    
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
    
%     zSpec=(lfp.Pxx-repmat(mean(lfp.Pxx(behId<3,:),1),size(lfp.Pxx,1),1))...
%         ./repmat(std(lfp.Pxx(behId<3,:),1,1),size(lfp.Pxx,1),1);
    nremType=behId(behId<3);
    

%     
%     zSmoothSigma=0.5;
%     tBinSize=mean(diff(lfp.t)/1e6);
%     xbin=0:tBinSize:4*zSmoothSigma;
%     xbin=[-xbin(end:-1:2),xbin];
%     gFil=normpdf(xbin,0,zSmoothSigma)*tBinSize;
%     gFil=gFil/sum(gFil);

    for bandType=1:4
        switch bandType
            case 1
                bandRange=[0,50];
                fbin=find(lfp.f>bandRange(1),1,'first'):find(lfp.f<bandRange(2),1,'last');
            case 2
                bandRange=[5,20];
                fbin=find(lfp.f>bandRange(1),1,'first'):find(lfp.f<bandRange(2),1,'last');
            case 3
                bandRange=[0,5];
                fbin=find(lfp.f>bandRange(1),1,'first'):find(lfp.f<bandRange(2),1,'last');
            case 4
                bandRange=[30,45];
                fbin=find(lfp.f>bandRange(1),1,'first'):find(lfp.f<bandRange(2),1,'last');
        end
    
        meanPow=mean((lfp.Pxx(:,fbin)),2);
        zPow=(meanPow-mean(meanPow(behId<3)))/std(meanPow(behId<3));
        
%         zPow=conv(zPow,gFil,'same');
        [~, dipP]=HartigansDipSignifTest(zPow,2000);
%         [~, modalityP]=HMslivermanTest(zPow,2000);
        
        powBin=-2:0.02:4;
        cntNrem=hist(zPow(behId==1),powBin);
        cntLow=hist(zPow(behId==2),powBin);
        
        cSmoothSigma=0.01;
        if cSmoothSigma>0
            cBin=0:0.02:cSmoothSigma*4;
            cBin=[-cBin(end:-1:2),cBin];
            cFil=normpdf(-cBin,0,cSmoothSigma);
            cFil=cFil/sum(cFil);
        end         
        cntNrem=conv(cntNrem,cFil,'same');
        cntLow=conv(cntLow,cFil,'same');
            
        subplot2(6,4,mod(dIdx-1,6)+1,bandType)
        hold on
%         plot(powBin(2:end-1),cntNrem(2:end-1)+cntLow(2:end-1),'color',0.5*[1,1,1])
%         fill(powBin,[0,cntNrem(2:end-1)+cntLow(2:end-1),0],0.7*[1,1,1],'lineStyle','none')
        bar(powBin(2:end-1),cntNrem(2:end-1)+cntLow(2:end-1),1,...
            'linestyle','none','facecolor',0.7*[1,1,1])
        plot(powBin(2:end-1),cntNrem(2:end-1),'color',[0.5,0.5,1])
        plot(powBin(2:end-1),cntLow(2:end-1),'color',[0.6,0,0.6])
        ylabel('Count')
        xlabel('Power (z)')
        title(sprintf('%d - %d Hz',bandRange))
        ax=fixAxis;
%         text2(1,1,{['Hartigan''s dip test p=' num2str(dipP,'%.3f')]
%                    ['Sliverman''s modality test p=' num2str(modalityP,'%.3f')]},ax,...
%         {'horizontalAlign','right','verticalAlign','top'})
        text2(1,1,{['Hartigan''s dip test p=' num2str(dipP,'%.3f')]
                   },ax,...
        {'horizontalAlign','right','verticalAlign','top'})
        
        if bandType==1
            text2(-0.2,1.1,getDispName(dName),ax,...
                {'horizontalAlign','left','verticalAlign','bottom','fontsize',7})
        end
        
    end
    
    if mod(dIdx,6)==0||dIdx==length(dList)
        addScriptName(mfilename)
        print(fh,[psFileName '.ps'],'-dpsc',doAppend)
        doAppend='-append';
        clf
    end
end    
    
    
    

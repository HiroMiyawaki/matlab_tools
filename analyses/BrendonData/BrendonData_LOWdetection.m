clear
clc

rootDir='~/data/Brendon/';
coreName='Brendon';

dList=dir(rootDir);

dList={dList([dList.isdir]).name};

dList(strcmp(dList,'.') | strcmp(dList,'..') )=[];
for dIdx=1:length(dList)
    
    
    
    dataName=dList{dIdx};
    nameCore=['~/data/Brendon/' dataName '/' dataName];
    
    disp([datestr(now),' start ' dataName '(' num2str(dIdx) '/' num2str(length(dList)) ')'])
    %
    % if exist([nameCore '-fineEegSpec.mat'],'file')
    %     continue
    % end
    
    load([nameCore '_BasicMetaData.mat']);
    
    state=load([nameCore '_WSRestrictedIntervals.mat']);
    
    
    ch=bmd.goodeegchannel;
    nCh=bmd.Par.nChannels;
    lfpFile=dir([nameCore '.eeg']);
    
    lfp=memmapfile(fullfile(lfpFile.folder,lfpFile.name),'format',{'int16',[nCh,floor(lfpFile.bytes/2/nCh)],'raw'});
    
    
    
    % sIdx=2%:length(state.WakeSleepTimePairFormat);
    %
    % tRange=state.WakeSleepTimePairFormat{sIdx}(2,:);
    % fRange=tRange*bmd.Par.lfpSampleRate;
    
    windowSize=1; %in sec
    stepSize=0.1; %in sec
    
    display(['    ' datestr(now),' loading the signal'])
    % eeg=single(lfp.Data.raw(ch,fRange(1):fRange(2)));
    eeg=single(lfp.Data.raw(ch,:));
    
    nFFT = 2^round(log2(2^11)); %compute nFFT according to different sampling rates
    SpecWindow = 2^round(log2(windowSize*bmd.Par.lfpSampleRate));% choose window length as power of two
    
    display(['    ' datestr(now),' whitening the signal'])
    weeg = WhitenSignal(eeg,[],1);
    display(['    ' datestr(now),' finish whitening'])
    
    nOverlap=SpecWindow-round(stepSize*bmd.Par.lfpSampleRate);
    
    display(['    ' datestr(now),' start FFT'])
    [Pxx,f,t]=mtcsglong(weeg,nFFT,bmd.Par.lfpSampleRate,SpecWindow,nOverlap,2,'linear',[],[0,330]);
    %function [yo, fo, to, phi]=mtcsglong(x,nFFT,Fs,WinLength,nOverlap,NW,Detrend,nTapers,FreqRange);
    display(['    ' datestr(now),' finish FFT'])
    % t=t+tRange(1);
    Pxx=Pxx(:,f<55);
    f=f(f<55);
    
    fMin=0;
    fMax=50;
    
    minDur=1;
    minIEI=0.5;
    cSmoothSigma=0.1;
    zSmoothSigma=0.5;
    
    
    [fst,lst]=findRange(f,[fMin,fMax]);
    freqRange=fst:lst;
    
    save([nameCore '-fineEegSpec.mat'],'t','f','Pxx')
    
    lowGammaSum=sum(Pxx(:,freqRange),2);
    % lowGamma=medfilt1(lowGamma,3);
    tBinSize=mean(diff(t));
    xbin=0:tBinSize:4*zSmoothSigma;
    xbin=[-xbin(end:-1:2),xbin];
    gFil=normpdf(xbin,0,zSmoothSigma)*tBinSize;
    lowGamma=conv(lowGammaSum,gFil,'same');
    
    nrem=state.SWSPacketTimePairFormat;
    
    timeRange=[];
    for zIdx=1:size(nrem,1)
        timeRange=[timeRange,find(t>nrem(zIdx,1)&t<nrem(zIdx,2))'];
    end
    
    LFPmean=mean(lowGamma(timeRange));
    LFPstd=std(lowGamma(timeRange));
    zGamma=(lowGamma-LFPmean)/LFPstd;
    
    
    if cSmoothSigma>0
        cBin=0:0.05:cSmoothSigma*3;
        cBin=[-cBin(end:-1:2),cBin]
        cFil=normpdf(-cBin,0,cSmoothSigma)*0.05;
    end
    
    [c,p]=hist(zGamma(timeRange),-2:0.05:4);
    c=c(2:end-1);
    p=p(2:end-1);
    if cSmoothSigma>0
        c=conv(c,cFil,'same');
    end
    
    % plot(p,c)
    
    dc=(diff(c)./diff(p));
    
    if cSmoothSigma>0
        dc=conv(dc,cFil,'same');
    end
    
    ddc=(diff(dc));
    
    if cSmoothSigma>0
        ddc=conv(ddc,cFil,'same');
    end
    
    [~,peakC.loc]=findpeaks(c);
    [~,trough.loc]=findpeaks(-ddc);
    if trough.loc(1)==1
        trough.loc(1)=[];
    end
    [~,peak.loc]=findpeaks(ddc);
    
    
    if length(peakC.loc)==1
        maxCpos=peakC.loc(1);
    else
        peakC.loc=(peakC.loc(tiedrank(c(peakC.loc))>length(peakC.loc)-2));
        
        if max(c(peakC.loc))/min(c(peakC.loc))>1.5
            [~,idx]=max(c(peakC.loc));
            maxCpos=peakC.loc(idx);
        else
            maxCpos=max(peakC.loc);
        end
    end
    
    trough.loc=trough.loc(trough.loc<maxCpos+3);
    
    
    
    l=min((trough.loc(tiedrank(ddc(trough.loc))<3)));
    
    pkPos=(find(peak.loc>l,1,'first'));
    while pkPos<length(peak.loc)-1 && diff(peak.loc(pkPos+[0,1]))<4
        if ddc(peak.loc(pkPos+1))>ddc(peak.loc(pkPos))
            pkPos=pkPos+1;
        else
            break
        end
    end
    pk=peak.loc(pkPos);
    ax=fixAxis;
    zThreshold=p(pk+1);
    
    
    zTrough=p(l+1);
    
    % clf
    % hold on
    % plotyy(p,c,p(2:end-1),ddc)
    % plot(zThreshold*[1,1],4000*[-1,1])
    % plot(zTrough*[1,1],4000*[-1,1])
    % plot(p(maxCpos)*[1,1],4000*[-1,1])
    
    
    minFrame=10;
    
    % clf
    % hold on
    % plotyy(p,c,p(2:end-1),ddc)
    % plot(zThreshold*[1,1],4000*[-1,1])
    % plot(zTrough*[1,1],4000*[-1,1])
    % plot(-2:0.01:3,hist(zGamma(tRange),-2:0.01:3))
    
    res=hmSchmittTrigger(-zGamma,-zThreshold,-zThreshold,zGamma(1)<zThreshold);
    res=removeTransient(res,eps,eps,true);
    % zTrough=Inf;
    if ~isempty(res)
        for lIndex=size(res,1):-1:1
            if min(zGamma(res(lIndex,1):res(lIndex,2)))>zTrough
                res(lIndex,:)=[];
            end
        end
        
        %     res=removeTransient(res,minFrame,minFrame,true);
        res(:,2)=res(:,2)+minFrame;
        
        for lIndex=size(res,1)-1:-1:1
            if res(lIndex,2)>=res(lIndex+1,1)
                res(lIndex,2)=res(lIndex+1,2);
                res(lIndex+1,:)=[];
            end
        end
    end
    
    if ~isempty(res)
        res(res(:,2)>length(t),:)=[];
    end
    
    low=t(res);
    param.madeby=mfilename;
    save([nameCore '-low.mat'],'low','param','-v7.3')
end
%%
BrendonData_LOWexamples

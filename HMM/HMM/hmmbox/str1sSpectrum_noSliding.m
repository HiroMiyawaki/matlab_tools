clear
% baseDir='~/data/sleep/pooled/';
baseDir='~/data/sleep/pooled_withCohEMG/';
coreName='sleep';

varList={'basics'
    ...'behavior'
    ...'detailedBehavior'
    ...'MA'
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
    ...'stateChange'
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
stepSize=1; %in s
windowSize=1; %in s

for dIdx=1:length(dList)
    dName=dList{dIdx};
    whitenFileName=[basics.(dName).filename '-1sSpec_noSlide.mat'];
    
%     if FileExists(whitenFileName)
%         display([datestr(now) ' ' dName ' is already done'])
%         continue
%     end
    display([datestr(now) ' loading ' dName])
    
    load([basics.(dName).filename '-CheckEegParam.mat'])
    ch=basics.(dName).Ch.CA1theta(CheckEegParam.ch2use(1));
    
    fh=fopen([basics.(dName).filename '.eeg']);
    fseek(fh,2*(ch-1),'bof');
    eeg=fread(fh,[1,inf],'int16',2*(basics.(dName).nChannels-1));
    fclose(fh);

    nFFT = 2^round(log2(2^9));
    specWindow = 2^round(log2(windowSize*basics.(dName).lfpSampleRate));% choose window length as power of two
    if stepSize<windowSize
         nOverlap=specWindow-round(stepSize*basics.(dName).lfpSampleRate);
    else
        nOverlap=0;
    end
    param.stepSize=stepSize; %in s
    param.windowSize=windowSize; %in s
    param.madeby=mfilename;
    param.ch=ch;

    temp=load([basics.(dName).filename '-basics.mat']);
    Periods=[];
    for ses=1:size(temp.basics.period,2)
        for per=1:size(temp.basics.period(ses).time,1);
            Periods=[Periods;temp.basics.period(ses).time(per,:)];
        end
    end    
    gap=[Periods(2:end,1)-Periods(1:end-1,2)];
    
%     if ~FileExists(nonWhitenFileName)
%         display(['   ' datestr(now) ' getting non-whitened spectrum'])
% 
%         [Pxx,f,t]=mtcsglong(eeg,nFFT,basics.(dName).lfpSampleRate,specWindow,nOverlap,2,'linear',[]);
%         Pxx(:,f>330)=[];
%         f(f>330)=[];
% 
%         t=t*1e6+Periods(1,1);
% 
%         for per = 1:size(gap,1)
%             t(t>Periods(per,2)) =  t(t>Periods(per,2)) + gap(per);
%         end
%         output=matfile(nonWhitenFileName,'writable',true);
%         output.Pxx=Pxx;
%         output.f=f;
%         output.t=t;
%         output.param=param;
%     end

    if ~FileExists(whitenFileName)
        display(['   ' datestr(now) ' getting whitened spectrum'])
        weeg = WhitenSignal(eeg,[],1);

        [Pxx,f,t]=mtcsglong(weeg,nFFT,basics.(dName).lfpSampleRate,specWindow,nOverlap,2,'linear',[]);
        Pxx(:,f>330)=[];
        f(f>330)=[];

        t=t*1e6+Periods(1,1);

        for per = 1:size(gap,1)
            t(t>Periods(per,2)) =  t(t>Periods(per,2)) + gap(per);
        end
        output=matfile(whitenFileName,'writable',true);
        output.Pxx=Pxx;
        output.f=f;
        output.t=t;
        output.param=param;
    end    
    
end

%%
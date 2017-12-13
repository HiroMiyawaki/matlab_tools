function [spindle,peakTime,peakPow]=spindleDitection(EegFileName,Ch2Use,NumCh,SampFreq,NREMperiods,EvtFileName,...
    Fband,Threshold,MinPeak,SmoothWindow,MinDuration,MinInterval,MaxInterTroughsDuration,FilOrder)

if nargin<5; NREMperiods=[]; end
if nargin<6; EvtFileName=[]; end
if nargin<7;  Fband=[9,18]; end %in Hz
if nargin<8;  Threshold=0.5; end%in SD
if nargin<9;  MinPeak=3; end%in SD
if nargin<10;  SmoothWindow=0; end%in ms
if nargin<11;  MinDuration=350; end%in ms
if nargin<12;  MinInterval=1000/Fband(1); end%in ms
if nargin<13;  MaxInterTroughsDuration=125; end%in ms
if nargin<14;  FilOrder=2048; end%in ms




%%
display(['    ' datestr(now) ':  loading eeg file'])

fh=fopen(EegFileName);
fseek(fh,2*(Ch2Use-1),'bof');
eeg=fread(fh,[1,inf],'int16',2*(NumCh-1));
fclose(fh);


%%
display(['    ' datestr(now) ':  applying bandpass filter' ])

fil=fir1(FilOrder,Fband/SampFreq*2,'bandpass');

% %check filter properties
% freqz(fil,1,5000)
spindleBand=Filter0(fil,eeg);

%%
if SmoothWindow>0
    display(['    '  datestr(now) ':  smoothing spindle band power' ])
    
    smoothen=conv(spindleBand.^2,ones(1,ceil(SampFreq*SmoothWindow/1000))/ceil(SampFreq*SmoothWindow/1000),'same');
    zSignal=zscore(smoothen);

else
    display(['    '  datestr(now) ':  performing Hilbert transform' ])
    hilSig=abs(hilbert(spindleBand));
    zSignal=zscore(hilSig);
end
%%
display(['    '  datestr(now) ':  detecting candidate periods' ])

crossThreshold=diff(zSignal>Threshold);
beg=find(crossThreshold==1);
fin=find(crossThreshold==-1);

if(beg(1)> fin(1))
    fin(1)=[];
end

if(beg(end)> fin(end))
    beg(end)=[];
end

if length(beg) ~= length(fin)
    display('!!! ERROR !!!')
    display('numbers of begginig and ending are not matched')
    return
end

if any(fin-beg<0)
    display('!!! ERROR !!!')
    display('some of detected candidates have negative durations.')
    return
end

%%
% 
% [~,n]=max(diff(sleep.rem,1,2))
% 
% b=ceil((sleep.rem(n,1)-basics.period.tsRange(1))/1e6*sampFreq+sampFreq*(-120))
% clf
% subplot(1,1,1)
% hold on
% dur=150
% plot(0:1/sampFreq:dur,  eeg(b:(b+sampFreq*dur)))
% plot(0:1/sampFreq:dur,  spindleBand(b:(b+sampFreq*dur)),'r')
% plot(0:1/sampFreq:dur,  zSignal(b:(b+sampFreq*dur))*2000-1000,'g')
% plot(0:1/sampFreq:dur,  zHil(b:(b+sampFreq*dur))*2000-1000,'y')
% plot([0,dur],Threshold*2000*[1,1]-1000,'g--')
% plot([0,dur],MinPeak*2000*[1,1]-1000,'g--')

%%
display(['    '  datestr(now) ':  checking candidates' ])

spindle=removeTransient([beg,fin],SampFreq*MinInterval/1000,SampFreq*MinDuration/1000);
badList=[];
peakPow=[];
peakTime=[];

for idx=1:size(spindle,1)
    subset=spindleBand(spindle(idx,1):spindle(idx,2));

    peaks=findpeaks(-subset);

    [peakPow(idx),peakTime(idx)]=max(zSignal(spindle(idx,1):spindle(idx,2)));
    peakTime(idx)=peakTime(idx)+spindle(idx,1)-1;
    
    if any(diff(peaks.loc)>MaxInterTroughsDuration*SampFreq/1000)
        badList=[badList,idx];
    end
end

spindle(badList,:)=[];
peakPow(badList)=[];
peakTime(badList)=[];

% spindle=spindle(badList,:)
% peakPow=peakPow(badList)
% peakTime=peakTime(badList)

spindle=spindle(peakPow>MinPeak,:);
peakTime=peakTime(peakPow>MinPeak);
peakPow=peakPow(peakPow>MinPeak);

peakTime=peakTime/SampFreq*1e6;
spindle = spindle/SampFreq*1e6;
if ~isempty(NREMperiods)
    isInNrem=isInRange(NREMperiods,peakTime);
    spindle = spindle(isInNrem,:);
    peakTime = peakTime(isInNrem);
    peakPow=peakPow(isInNrem);
end
%%
if ~isempty(EvtFileName)
    display([datestr(now) ':  making evt file' ])
    MakeEvtFile([spindle(:,1),peakTime',spindle(:,2)],EvtFileName,{'start','peak','end'},1e6);
end
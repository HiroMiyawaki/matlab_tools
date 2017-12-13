
function [SWR,HFE]=SWRdetectionHilbert(LfpSampleRate,NChannels,Filebase,Allchannels)

%lfpSampleRate=1250;
%filebase = '/Volumes/RAID_HDD/Roy/ndmFiles/Roy-20120406-maze-01/Roy-20120406-maze-01'
%nChannels = 65;
%allchannels = 1:64;

highband = 250; % bandpass filter range
lowband = 100; % (250Hz to 80Hz)

thresholdSWR = 6 ; % peak power SD threshold for ripple detection
thresholdHFE = 3 ; % peak power SD threshold for ripple detection
thresholdEvt = 1; % peak SD threshold (0 means threshold is equal to the mean)



% min_sw_period = 50 ; % minimum ripple period, 50ms ~ 5-10 cycles
minEvtperiod = 40 ; % minimum ripple period, 50ms ~ 5-10 cycles\
maxEvtperiod = 450;
% min_isw_period = 100; % minimum inter-ripple period
minIntPeriod = 5; % minimum inter-ripple period

forder = 100;  % filter order has to be even. The longer the more selective, but the operation
% will be linearly slower to the filter order. 100-125 for 1.25Hz (500 for 5 KH






fprintf('\n\n%s ripples detected started\n\n',datestr(now));

%avgfilorder = round(min_sw_period/1000*LfpSampleRate/2)*2+1 ; % should not change this. length of averaging filter
% avgfilorder = 101; % should not change this. length of averaging filter
forder = ceil(forder/2)*2; % to make sure filter order is even

firfiltb = fir1(forder,[lowband/LfpSampleRate*2,highband/LfpSampleRate*2]); 

minEvtFrame = minEvtperiod/1000*LfpSampleRate ; 
maxEvtFrame = maxEvtperiod/1000*LfpSampleRate ;
minIntFrame = minIntPeriod/1000*LfpSampleRate ;

evt=[];
for select_channel = Allchannels(1:(end));
    thresholdbuffer = readmulti([Filebase '.eeg'],NChannels,select_channel); % load .eeg trace
    filtered_data = Filter0(firfiltb,thresholdbuffer); % filtering

        
    filtered_data=filtered_data-mean(filtered_data);
    
    amp = abs(Shilbert(filtered_data)); % to power trace
    amp =(amp-mean(amp))/std(amp) ; % averaging & standardizing
    
    thresholded = amp > thresholdEvt;
    bFrame = find(diff(thresholded)>0);
    eFrame = find(diff(thresholded)<0);

    if bFrame(1)>eFrame(1);
        eFrame = eFrame(2:end);
    end

    bFrame = bFrame(1:size(eFrame,1),1);

    intervals= bFrame(2:end) - eFrame(1:(end-1));
    idx = find(intervals>=minIntFrame);
    
    bFrame=bFrame([1;idx+1],1);
    eFrame=eFrame([idx;end],1);
    
    duration = eFrame - bFrame;
    idx = find(duration>minEvtFrame & duration<maxEvtFrame);
    bFrame = bFrame(idx);
    eFrame = eFrame(idx);
    clear pFrame pValue
    for n = 1:size(bFrame,1)
        [pValue(n,1),pFrame(n,1)] = max(amp(bFrame(n,1):eFrame(n,1)));
        pFrame(n,1)= pFrame(n,1)+bFrame(n,1)-1;
    end
    
    idx=find(pValue>thresholdHFE);
    
    evt = [evt;bFrame(idx,1),pFrame(idx,1),eFrame(idx,1),pValue(idx,1)];
    
    fprintf('%s  ch%d: primary detection finished \n',datestr(now), select_channel)
end

[temp, idx] = sort(evt,1);
evt = evt(idx(:,1),:);


EVT=[];

bFrame=evt(1,1);
pFrame=evt(1,2);
eFrame=evt(1,3);
pValue=evt(1,4);
for n=2:size(evt,1)
    if evt(n,1)>eFrame
        EVT = [EVT;bFrame,pFrame,eFrame,pValue];
        bFrame=evt(n,1);
        pFrame=evt(n,2);
        eFrame=evt(n,3);
        pValue=evt(n,4);
    else
        eFrame = max(eFrame, evt(n,3));
        [pValue, temp] = max([pValue, evt(n,4)]);
        if temp ==2
            pFrame = evt(n,3);
        end
        
    end
end
EVT = [EVT;bFrame,pFrame,eFrame,pValue];

idx =find(EVT(:,4)>thresholdSWR);
SWR = EVT(idx,:);

idx = find(EVT(:,4)>thresholdHFE & EVT(:,4)<=thresholdSWR);
HFE = EVT(idx,:);


fprintf('\n%s  making Evt file is started \n',datestr(now))
MakeEvtFile(SWR(:,1:3),[Filebase '.swr.evt'],{'swr(hil)beg','swr(hil)peak','swr(hil)end'},LfpSampleRate); % make evt file for neuroscope browsing
MakeEvtFile(HFE(:,1:3),[Filebase '.hfe.evt'],{'hfe-beg','hfe-peak','hfe-end'},LfpSampleRate); % make evt file for neuroscope browsing

SWR(:,1:3)=SWR(:,1:3)*1000/LfpSampleRate;
HFE(:,1:3)=HFE(:,1:3)*1000/LfpSampleRate;


fprintf('%s ripples detected successfully!\n',datestr(now));
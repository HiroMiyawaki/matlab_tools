function [SpindleChannels,SpindlePower]=...
    BigSpindleChannels(EegFileName,CandidateChannels,NumCh,SampFreq,NREMperiods,StartFrame,EndFrame)

if ~exist('StartFrame','var')
    StartFrame=1;
end

if ~exist('EndFrame','var')
    eegInfo=dir(EegFileName);
    EndFrame=eegInfo.bytes/2/NumCh;
end

StartFrame=ceil(StartFrame);
EndFrame=floor(EndFrame);

Fband=[9,18];
FilOrder=2048;

fil=fir1(FilOrder,Fband/SampFreq*2,'bandpass');
% %check filter properties
% freqz(fil,1,5000)


NREMperiods=NREMperiods/1e6*SampFreq;
NREMperiods=NREMperiods(NREMperiods(:,2)>StartFrame&NREMperiods(:,1)<EndFrame,:);

if NREMperiods(1,1)<StartFrame
    NREMperiods(1,1)=StartFrame;
end

if NREMperiods(end,2)>EndFrame
    NREMperiods(end,2)=EndFrame;
end

NREMperiods=NREMperiods-StartFrame+1;


isInNrem=zeros(1,(EndFrame-StartFrame+1));

for idx=1:size(NREMperiods,1)
    isInNrem(ceil(NREMperiods(idx,1)):(floor(NREMperiods(idx,2))))=1;
end
    
powerList=[];

fh=fopen(EegFileName);

for Ch2Use=CandidateChannels
    
    display([datestr(now) ':  checkign power of ch' num2str(Ch2Use)])
    display(['    ' datestr(now) ':  loading eeg file'])

    fseek(fh,2*NumCh*(StartFrame-1)+2*(Ch2Use-1),'bof');

    eeg=fread(fh,[1,EndFrame-StartFrame+1],'int16',2*(NumCh-1));

    display(['    ' datestr(now) ':  applying bandpass filter' ])
    spindleBand=Filter0(fil,eeg);
    
    power=spindleBand(isInNrem==1).^2;
    powerList(end+1)=median(power);
    
end
fclose(fh)

[SpindlePower,chOrder]=sort(powerList,'descend');

SpindleChannels=CandidateChannels(chOrder);

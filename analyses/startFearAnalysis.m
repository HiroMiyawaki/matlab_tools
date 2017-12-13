clear
rootDir='~/data/Fear';
idx=0;
%%
idx=idx+1;
sessionList{idx}='magician170919';
temp={repmat({'LA'},1,32),repmat({'mPFC'},1,60),repmat({'Cortex'},1,4),...
      {'EMG'},{'ECG'},repmat({'Accelerometer1'},1,3),repmat({'Accelerometer2'},1,3),...
      {'Session','Tone1','Tone2','ShcokTrig','ShockL','ShockR','Video','Clock'}};
        %it has no OB
temp=cat(2,temp{:});
chName{idx}=temp;
ttlCh{idx}=112+(-7:0);
accelerometerCh{idx}=102:104;
detectionintervals{idx}.ttl=[5,58851.448];
detectionintervals{idx}.lfp=[0,58851.448];

temp= reshape(...
    60.^[2,1,0] * ...
    [
    2,47,37
    3,7,30
    5,49,8
    6,36,8
    9,11,40
    10,32,25
    13,6,28
    13,38,34
    ]',...
    2,[])';

videoFileList{idx}={'-01.mp4'}; %can have multiple video files
videoSession{idx}.fileIndedx=[1,1,1,1]; %index of corresponding video file
videoSession{idx}.name={'Baseline','Conditioning','CueAndExtinction','RetentionOfExtinction'};
videoSession{idx}.detectionintervals=temp;
videoSession{idx}.range={[79 397 388 657],[78 381 354 657],[84 399 387 657],[88 402 394 657]};

%%
processList=[1];

%% make files for buzFormat & basicMetaData
for idx=processList
    session=sessionList{idx};
    chList=chName{idx};


    if ~exist(fullfile(rootDir,session,[session '.AnimalMetadata.mat']),'file')
        bz_RunAnimalMetadata(fullfile(rootDir,session))
    end

    if ~exist(fullfile(rootDir,session,[session '.SessionMetadata.mat']),'file')
        bz_RunSessionMetadata(fullfile(rootDir,session))
    end

     load(fullfile(rootDir,session,[session '.SessionMetadata.mat']))

    clear basicMetaData
    
    saveFileName=fullfile(rootDir,session,[session '.basicMetaData.mat']);
    if exist(saveFileName)
        load(saveFileName)
    end
    xml=LoadParameters(fullfile(rootDir,session,[session '.xml']));


    basicMetaData.Animal.Name=SessionMetadata.AnimalMetadata.AnimalName;
    basicMetaData.Animal.Info=SessionMetadata.AnimalMetadata.Animal;

    basicMetaData.Basename=fullfile(xml.session.path,xml.session.name);


    
    if length(chList) ~= xml.nChannels
        disp(['WARNING: Channel numbers in xml are not matched with given chList'])
    end
    basicMetaData.Ch.names=chList;
    basicMetaData.Ch.ttl=ttlCh{idx};
    basicMetaData.Ch.accelerometer=accelerometerCh{idx};
    basicMetaData.Ch.emg=find(strcmpi(chList,'emg'));
    basicMetaData.Ch.ecg=find(strcmpi(chList,'ecg'));
    basicMetaData.Ch.olfactory=find(strcmpi(chList,'OB'));
    basicMetaData.nCh=xml.nChannels;
    if xml.rates.video==0
        xml.rates.video=25;
    end
    basicMetaData.SampleRates.dat=xml.rates.wideband;
    basicMetaData.SampleRates.lfp=xml.rates.lfp;
    basicMetaData.SampleRates.video=xml.rates.video;

    temp=dir([basicMetaData.Basename '.dat']);
    basicMetaData.nSample.dat=temp.bytes/xml.nChannels/2;

    temp=dir([basicMetaData.Basename '.lfp']);
    basicMetaData.nSample.lfp=temp.bytes/xml.nChannels/2;

    
    basicMetaData.detectionintervals=detectionintervals{idx};
    save(saveFileName,'basicMetaData','-v7.3')

    basicMetaData.updated = today('datetime');
    basicMetaData.generatorname=mfilename;
end

%% detect heart beats
for idx=processList
    session=sessionList{idx};
    load(fullfile(rootDir,session,[session '.basicMetaData.mat']));
    detectHeartBeat(basicMetaData);
end

%% detect ttl events
for idx=processList
    session=sessionList{idx};
    load(fullfile(rootDir,session,[session '.basicMetaData.mat']));
%     detectTTLpulses(basicMetaData,...
%         'minInterval',[10,1,1,0.1,1e-4,1e-4,10e-3,100e-3],...
%         'minDuration',[10,1,1,0.1,1e-4,1e-4,10e-3,100e-3],...
%         'detectionintervals',basicMetaData.detectionintervals.ttl,...
%         'filetype','dat');

    % behavior sessions
    detectTTLpulses(basicMetaData,...
        'chList',basicMetaData.Ch.ttl(1),...
        'minInterval',10,...
        'minDuration',10,...
        'detectionintervals',basicMetaData.detectionintervals.ttl,...
        'filetype','dat',...
        'evtFileName',[basicMetaData.Basename '.ses.evt'],...
        'saveFileName',[basicMetaData.Basename '.sessions.events.mat'],...
        'varName','sessions');    
    
    % cue 
    detectTTLpulses(basicMetaData,...
        'chList',basicMetaData.Ch.ttl(2:3),...
        'minInterval',1,...
        'minDuration',1,...
        'detectionintervals',basicMetaData.detectionintervals.ttl,...
        'filetype','dat',...
        'evtFileName',[basicMetaData.Basename '.cue.evt'],...
        'saveFileName',[basicMetaData.Basename '.cues.events.mat'],...
        'varName','cues');  
    
    % shock
    detectTTLpulses(basicMetaData,...
        'chList',basicMetaData.Ch.ttl(4:6),...
        'minInterval',[0.1,1e-4,1e-4],...
        'minDuration',[0.1,1e-4,1e-4],...
        'detectionintervals',basicMetaData.detectionintervals.ttl,...
        'filetype','dat',...
        'evtFileName',[basicMetaData.Basename '.shk.evt'],...
        'saveFileName',[basicMetaData.Basename '.shocks.events.mat'],...
        'varName','shocks');    

    %video
    detectTTLpulses(basicMetaData,...
        'chList',basicMetaData.Ch.ttl(7),...
        'minInterval',0.005,...
        'minDuration',0.005,...
        'detectionintervals',basicMetaData.detectionintervals.ttl,...
        'filetype','dat',...
        'evtFileName',[basicMetaData.Basename '.vtr.evt'],...
        'saveFileName',[basicMetaData.Basename '.videoFrames.events.mat'],...
        'varName','videoFrames');     

    %clock
    detectTTLpulses(basicMetaData,...
        'chList',basicMetaData.Ch.ttl(8),...
        'minInterval',0.1,...
        'minDuration',0.1,...
        'detectionintervals',basicMetaData.detectionintervals.ttl,...
        'filetype','dat',...
        'evtFileName',[basicMetaData.Basename '.clk.evt'],...
        'saveFileName',[basicMetaData.Basename '.clocks.events.mat'],...
        'varName','clocks');       
end


%% detect movement on video
%%
for idx=processList
    session=sessionList{idx};
    load(fullfile(rootDir,session,[session '.basicMetaData.mat']));
        
    freezeDetection2(fullfile(dataDirRoot,videofile),imageRange{idx},100,videoTimes(idx,1),videoTimes(idx,2),sessionNames{idx});
    ledReadFromVideo2(fullfile(dataDirRoot,videofile),ledRange{idx},videoTimes(idx,1),videoTimes(idx,2),sessionNames{idx});
end

%% detect movement from Accelerometer

%% get EMG envelope




function fh = CheckEegStates(Ch,FileBase,nChannels,lfpSampleRate,varargin)
%function CheckEegStates(fileinfo)
[State,AuxData] = DefaultArgs(varargin,{[],[]});

% auxil. struct for gui
global gCheckEegStates
gCheckEegStates = struct;

% basedir = pwd; 
% filename = fileinfo.name;
% 
% FileBase = [basedir '/' filename '/' filename];

%constants
UseRulesBefore = 0; % flag to switch heuristics for periods cleaning after automatic segmentation
MinLen=5; %seconds
% Par = LoadPar([FileBase '.xml']);
% if isfield(Par,'lfpSampleRate')
%     eSampleRate = Par.lfpSampleRate;
% else
%     eSampleRate = 1600;
% end
% nChannels = Par.nChannels;
Window = 1; %sec - for spectrogram calculation
% FreqRange = [1 100]; % Hz - range of freq. for the spectrogram
FreqRange = [1 25]; % Hz - range of freq. for the spectrogram

% if ~isempty(State)
%     % load segmentation results
%     if FileExists([FileBase '.sts.' State])
%         Per = load([FileBase '.sts.' State]);
%     elseif FileExists([FileBase '.states.res'])
%         Per = SelectStates(FileBase,State,eSampleRate*MinLen);
%     else
%         Per = [];
%     end       
%     if isempty(Per)
%         fprintf('No segments detected in %s state\n',State)
%         %return;
%         Per = [];
%     end
% else
    Per = [];
    State = '';
% end
Channels=[];
if isfield(Ch,'CA1theta') & ~isempty(Ch.CA1theta)
    Channels = Ch.CA1theta;
elseif isfield(Ch,'CA3theta') & ~isempty(Ch.CA3theta)
    Channels = Ch.CA3theta;
    fprintf('Warning: Using CA3 theta Channel!!\n')
else
    warning('No theta channel available!!');
end

if FileExists([FileBase '.eegseg.mat']) 
    display([datestr(now),' loading ' FileBase '.eegseg.mat'])
    load([FileBase '.eegseg.mat']); % load whitened spectrograms from EegSegmentation results
    
else
    if isempty(Channels)
    ch = inputdlg({'Enter channels to use'},'Channels',1,{'1'});
    Channels = num2str(ch{1});
    end
 
    for n=1:length(Channels)
    % now compute the spectrogram
    
    if FileExists([FileBase '.eeg'])    
        display([datestr(now),' loading ' FileBase '.eeg'])
        %     Eeg = readmulti([FileBase '.eeg'], nChannels, Channels);
        fh=fopen([FileBase '.eeg']);
    elseif FileExists([FileBase '.lfp'])    
        display([datestr(now),' loading ' FileBase '.lfp'])
        %     Eeg = readmulti([FileBase '.eeg'], nChannels, Channels);
        fh=fopen([FileBase '.lfp']);
    else
        display('either .eeg or .lfp not found')
        return
    end
    fseek(fh,2*(Channels(n)-1),'bof');
    Eeg=fread(fh,[1,inf],'int16',2*(nChannels-1));
    fclose(fh);
    
    nFFT = 2^round(log2(2^11)); %compute nFFT according to different sampling rates
    SpecWindow = 2^round(log2(Window*lfpSampleRate));% choose window length as power of two

    display([datestr(now),' whitening the signal'])    
    weeg = WhitenSignal(Eeg,[],1);
    %%%%      mtcsglong(x,nFFT,Fs,WinLength,nOverlap,NW,Detrend,nTapers,FreqRange);
    display([datestr(now),' performing FFT'])    
    [Pxx(:,:,n),f,t]=mtcsglong(weeg,nFFT,lfpSampleRate,SpecWindow,[],2,'linear',[],FreqRange);
    end
    ifsave = 1; %input('Do you want to save the spectrum? [1/0]');
    if ifsave
        display([datestr(now),' saving ' FileBase '.eegseg.mat'])
        save([FileBase '.eegseg.mat'],'Pxx','f','t','-v7.3');
    end
end

t = (t(2)-t(1))/2 +t;
   
% computer the/del ratio and detect transitions automatically - not used at
% the momnet, maybe later
%[thratio] = TDRatioAuto(Pxx,f,t,MinLen);
%[thratio, ThePeriods] = TDRatioAuto(Pxx,f,t,MinLen);

%now apply the rules to filter out junk states or make continuous periods
% to be implemented later
if UseRulesBefore
    switch State
        case 'REM'

    end
end

nAuxData = size(AuxData,1);

% fill the global structure for future use
gCheckEegStates.Channels = Channels;
gCheckEegStates.nChannels = nChannels;
gCheckEegStates.FileBase = FileBase;
gCheckEegStates.State = State;
gCheckEegStates.t = 10; %is seconds
gCheckEegStates.eFs = lfpSampleRate;
gCheckEegStates.trange = [t(1) t(end)];
gCheckEegStates.Periods = Per/lfpSampleRate; % in seconds
gCheckEegStates.Mode = 't';
gCheckEegStates.nPlots=length(Channels)+1+nAuxData;%number of plots is fixed to 3: 2 spectrograms and one zoomin trace. If changed reuiqres fixes in _aux
gCheckEegStates.lh=cell(gCheckEegStates.nPlots,1);
gCheckEegStates.Window = Window*lfpSampleRate*2;
gCheckEegStates.SelLine=[];
gCheckEegStates.cposh=cell(gCheckEegStates.nPlots,1);
gCheckEegStates.FreqRange = FreqRange;
gCheckEegStates.newl=[];
gCheckEegStates.tstep = t(2)-t(1);
gCheckEegStates.coolln = [];
gCheckEegStates.LastBut = 'normal';
gCheckEegStates.nAuxData = nAuxData;
% create and configure the figure
gCheckEegStates.figh = figure('ToolBar','none');
set(gCheckEegStates.figh, 'Position', [3 128 1276 620]); %change Postion of figure if you have low resolution
set(gCheckEegStates.figh, 'Name', 'CheckEegStates : traces');
set(gCheckEegStates.figh, 'NumberTitle', 'off');


% put the uitoolbar and uimenu definitions here .. may require rewriting
% some callbacks as actions rather then cases of actions (e.g. key
% pressing)


%now do the plots

for ii=1:length(gCheckEegStates.Channels)
    subplot(gCheckEegStates.nPlots,1,ii);
    imagesc(t,f,log(squeeze(Pxx(:,:,ii)))');axis xy; ylim([1 20]);
    hold on
    if ii==1
        title('Spectrogram'); ylabel('Frequency (Hz)');
    end
end

if nAuxData>0
    for ii=[1:nAuxData]
        subplot(gCheckEegStates.nPlots,1,ii+length(gCheckEegStates.Channels));
        DisplayAuxData(AuxData(:,ii));
        hold on
        
    end
end


%  subplot(gCheckEegStates.nPlots,1,2)
%  plot(t,thratio);axis tight;
%  set(gca,'YTick',[]);
%  hold on
%  ylabel('Theta/Delta raio'); xlabel('Seconds');

subplot(gCheckEegStates.nPlots,1,gCheckEegStates.nPlots)
CheckEegStates_aux('traces'); % plot the current eeg traces
hold on

%plots lines
if ~isempty(Per)
CheckEegStates_aux('lines');
end
% assign functions for mouse and keyboard click
set(gCheckEegStates.figh,'WindowButtonDownFcn','CheckEegStates_aux(''mouseclick'')');
set(gCheckEegStates.figh,'KeyPressFcn', 'CheckEegStates_aux(''keyboard'')');

fh = gCheckEegStates.figh;

%msave([FileBase '.states.' State],round(ThePeriods*eSampleRate));
return


function [thratio, ThePeriods] = TDRatioAuto(Pxx,f,t,MinLen)

%automatic theta periods detection just using the thetaratio
thfin = find(f>6 & f<9);
thfout = find(f<5 | (f> 12& f<25));
thratio = log(mean(squeeze(Pxx(:,thfin,1)),2))-log(mean(squeeze(Pxx(:,thfout,1)),2));

if nargout>1
    nStates =2;
    % fit gaussian mixture and to HMM - experimental version .. uses only thetaratio
    [TheState thhmm thdec] = gausshmm(thratio,{nStates,1,0});

    for i=1:nStates
        thratio_st(i) = mean(thratio(TheState==i));
    end

    [dummy TheInd] = max(thratio_st);
    InTh = (TheState==TheInd);
    DeltaT = t(2)-t(1);
    MinSeg = round(MinLen/DeltaT);

    TransTime = ThreshCross(InTh,0.5,MinSeg);
    ThePeriods = t(TransTime);
end
return

function DisplayAuxData(Data)

        nEl =  size(Data,2);
        if nEl<4 
            err=1;
        elseif ~isstr(Data{4})
            err=1;
        else
            err=0;
        end
        if err 
            warning('AuxData has to be cell array where each row is : xaxis, yaxis, data, display_func');
            close 
            return;
        end
        
        switch Data{4} %switch by functions
            case 'plot'
                plot(Data{1}, Data{3});
            case 'imagesc'
                if length(Data{1})~=size(Data{3},1) & length(Data{1})~=size(Data{3},2)
                    Data{3}=Data{3}';
                end
                    
                imagesc(Data{1},Data{2}, Data{3}');
            otherwise 
                error('wrong data display function');
        end
        


return
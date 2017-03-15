% function EegSegmentation(FileBase, Control, Overwrite, Channels, nPCA,  Window, nChannels,SignalType, GoodPeriods,Labels,FreqRange)
% performes the segmentation of the eeg by states that correspond to 
%certain power spectral features combimation
% Control = 1 for some control  (0 - Default)
% Window (in seconds) for the spectrogram calculation
% nChannels - number of channels in file, if different from .par or it is absent
% SignalType = 'eeg' (def) or 'csd'
% GoodPeriods = [beg end] by # periods in eeg sampling - selects only segments within those periods for analysis
% Labels = cell array of labels to use to cluster


function []= calcSpecP(directory,Channels,Overwrite)

% function EegSegmentation(FileBase, varargin)
% 
% DefLabels = {'SWS', 'IMM', 'REM', 'RUN' , 'AWK', 'HVS' , 'ART' ,'DES'};
% %esr = 1250;
% [Control, Overwrite, Channels, nPCA,          Window,   nChannels, SignalType, GoodPeriods, Labels,FreqRange] = DefaultArgs(varargin, ...
%     {0,         1,                 [],           5,          1,               [],      'eeg' ,[], DefLabels,[1 100]});
%  
%     
% if isempty(find(strcmp(Labels,'ART'))) & isempty(find(strcmp(Labels,'art')))
% 	Labels{end+1}= 'ART';
% end    
% save([FileBase '.statelabels.mat'],'Labels');

Window = 1; nChannels = [];  % not clear what point of Window is... Basically its in units of seconds.
if (nargin<3); Overwrite = 1;end

currentdir = pwd; 

FileBase = [directory '/' directory];
saveFn = [FileBase '.eegseg.mat'];

EegFileName = [FileBase '.eeg'];
Par = LoadPar([FileBase '.xml']);

EegFs = Par.lfpSampleRate;

% this part mostly remains from Anton
if ~FileExists(saveFn) | Overwrite% compute stuff and save
    if ~FileExists([FileBase '.par']) & ~FileExists([FileBase '.xml']) & isempty(nChannels)
        error('par file does not exist and nChannels not set');
    end
    if (FileExists([FileBase '.par']) | FileExists([FileBase '.xml'])) & isempty(nChannels)
        Par = LoadPar([FileBase]);
        nChannels = Par.nChannels;
    end
    if isempty(Channels)
        if FileExists([FileBase '.eegseg.par']);
            Channels = load([FileBase '.eegseg.par']);
            Channels = Channels+1;
        elseif FileExists([FileBase '.eeg.0']) % & ~FileExists([FileBase '.eeg'])
            EegFileName = [FileBase '.eeg.0'];
            nChannels = 1;
            Channels =1;
        else
            error('Couldnt figure out the Channels to use!!! \n');
            return
        end
    end
    
    nChanSel = length(Channels);
    
    Eeg = LoadBinary(EegFileName, Channels, nChannels);
    % compute power in segments and get stats on it
    nFFT = 2^round(log2(2^11*EegFs/1250)); %compute nFFT according to different sampling rates
    Window = 2^round(log2(Window*EegFs)); % choose window length as power of two
    
    weeg = WhitenSignal(double(Eeg),EegFs*30,1);  % remove 1/f power from the signal, to improve theta detection
    [Pxx,f,t]=mtcsglong(weeg,nFFT,EegFs,Window,[],2,'linear',[],[1 100]); % from 1 to 100 Hz
    
    GoodF = find(f<57 | f>63); 
    
    %save stuff
    
    if Overwrite | ~FileExists(saveFn) 
        save(saveFn, 'Pxx','f','t','Channels');
    end
end 


return


function out = mtptchgram_trig(Data,Trigger,Window,Params)
%function [y, f,  phi, yerr, phierr]=mtptchgram_trig(x,Res, Clu, 
%function [y, f,  phi, yerr, phierr]=mtptchgram_trig(Data, Trigger, Window, Params)
% Multitaper coherogram/spectrogram for continuous and point process
% triggered by the Trigger times and averaged
% %%%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data - is struct with fields Eeg, Res, Clu, CluSubset (last two -
% optional)
% Trigger - beginnings of the epochs to trigger, 
% Window - length of the cohero/spectro gramms (is samples, as all the
% times in the arguments); NB: Window goes left and right! by Window or
% Window(1) and Window(2) accordingly
% Params is a structure with the fields 
% nFFT = number of points of FFT to calculate (default 1024)
% Fs = sampling frequency (default 2)
% WinLength = length of moving window (default is nFFT)
% WinStep = step of the moving window (default is WinLength/2)
% NW = time bandwidth parameter (e.g. 3 or 4), default 2
% nTapers = number of data tapers kept, default 2*NW -1
% FreqRange =[Fi_beg Fi_end]
% pval - significance level for error bars
% $$$$$$$$$$$$$$$$    Output: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% y - t x f x ch x ch matrix of coherence/spectra, f - freq, t - time bin, phi - phase shift
% ch = nChannelsEeg + length(CluSubset)
% yerr: matrix nChannelsAll x nChannelsAll x 2 - lower/upper limits. Factor
% of the spectral power for lower/upper value for spectra for now (diagonal),
% offdiagonal - coherence confidence level.
% phierr = variance of the phase (theoretical)
% Original code by Partha Mitra - modified by Ken Harris
% Also containing elements from specgram.m
% and adopted for point processes, long files and phase by Anton Sirota
% Poitnt Process spectra calculation following Jarvis&Mitra,2000 and Bijan Pesaran's code

Data = mtCheckData(Data);
Params = mtCheckParams(Params);
nOverlap = Params.WinLength - Params.WinStep;
if length(Window)==1 Window =[Window Window]; end
nT = length(Data.Eeg);
Trigger = Trigger(Trigger>Window(1)+Params.WinLength & Trigger<nT-Window(2)-Params.WinLength);

ShiftsL = -fliplr([(-Params.WinLength/2+Params.WinStep):Params.WinStep:Window(1)-Params.WinLength/2])-Params.WinLength;
ShiftsR = [(Params.WinStep-Params.WinLength/2):Params.WinStep:Window(2)-Params.WinLength/2];
Shifts = [ShiftsL -Params.WinLength/2 ShiftsR];
nWins = length(Shifts);

% turn this into time, using the sample frequency


fprintf('Computing slice (out of %d) :\n',nWins);
out = struct();
out.t = (Shifts+Params.WinLength/2)/Params.Fs;
for ii=1:nWins
    myStarts = Trigger + Shifts(ii);
    fprintf('\b\b');
    fprintf('%d',ii);
% nargout
    if ~Params.CheckErr
        [out.y(ii,:,:,:), out.f, out.phi(ii,:,:,:)] = mtptchd_segs(Data.Eeg,Data.Res, Data.Clu, Params.nFFT,Params.Fs,Params.WinLength,Params.WinStep,...
            Params.NW,Params.Detrend,Params.nTapers, Params.FreqRange,Data.CluSubset,myStarts,Params.pval,Params.MinSpikes);
    else
        if ~Params.NormCoh        
        [out.y(ii,:,:,:), out.f, out.phi(ii,:,:,:), out.yerr(ii,:,:,:,:),out.phierr(ii,:,:,:) ] = ...
            mtptchd_segs(Data.Eeg,Data.Res, Data.Clu, Params.nFFT,Params.Fs,Params.WinLength,Params.WinStep,...
            Params.NW,Params.Detrend,Params.nTapers, Params.FreqRange,Data.CluSubset,myStarts,Params.pval,Params.MinSpikes);
        else        
        [out.y(ii,:,:,:), out.f, out.phi(ii,:,:,:), out.yerr(ii,:,:,:,:),out.phierr(ii,:,:,:),out.ynorm(ii,:,:,:), out.ycom(ii,:,:,:), out.phinorm(ii,:,:,:) ] = ...
            mtptchd_segs(Data.Eeg,Data.Res, Data.Clu, Params.nFFT,Params.Fs,Params.WinLength,Params.WinStep,...
            Params.NW,Params.Detrend,Params.nTapers, Params.FreqRange,Data.CluSubset,myStarts,Params.pval,Params.MinSpikes);
        end
            
    end

end

%helper function to set data fields and check things
function Data = mtCheckData(Data)
if ~isstruct(Data)
    error('Data has to be a structure, read help');
end

if ~isfield(Data,'Eeg')
    Data.Eeg = [];
end

if ~isfield(Data,'Res')
    error('this function is for spectral measures between continuous and point process - the latter is missing');
end

if ~isfield(Data,'Clu')
    Data.Clu = ones(length(Data.Res),1);
end

if isfield(Data,'CluSubset')
    myind = ismember(Data.Clu,Data.CluSubset);
    Data.Clu = Data.Clu(myind);
    Data.Res = Data.Res(myind);    
else
    Data.CluSubset = unique(Data.Clu);
end
return


% helper function to check params and set defaults
function outParams = mtCheckParams(Params)

if ~isstruct(Params)
    error('Params has to be a structure, read help');
end

outParams = struct('nFFT',2^11,'Fs',1250,'WinLength',2^10,'WinStep',2^9,'NW',2,...
    'Detrend','linear','nTapers',[], 'FreqRange',[1 100],'pval', 0.05,'MinSpikes',3,'CheckErr',0,'NormCoh',0);
fds = fieldnames(Params);

for i=1:length(fds)
    if isfield(outParams,fds{i}) 
        if ~isempty(Params.(fds{i}))
            outParams.(fds{i}) = Params.(fds{i});
        end
    else
        error('Paramer field %s is not valid',fds{i});
    end
end 

return



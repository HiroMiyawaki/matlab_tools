function ThPhase = InternThetaPh(fileinfo,overwrite,elc)
% function ThPhase = InternThetaPh(fileinfo,overwrite)


if (nargin<2);overwrite = 0;end

filename = fileinfo.name;
FileBase = [filename '/' filename];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Theta Phase and power
%% (needs: FileBase.elc, FileBase.par)
%% (output: ThPhase >> FileBase.phase)
%%

Par =LoadPar([FileBase '.par']); % either par or xml file needed
EegRate = Par.lfpSampleRate; % sampling rate of eeg file
numch = Par.nChannels;

if nargin<3
    if ~isempty(fileinfo.CA1thetach)
        elc = fileinfo.CA1thetach+1;
    elseif ~isempty(fileinfo.CA3thetach)
        elc = fileinfo.CA3thetach+1;
    elseif ~isempty(fileinfo.DGthetach)
        elc = fileinfo.DGthetach+1;
    elseif ~isempty(fileinfo.ECthetach)
        elc = fileinfo.ECthetach+1;
    else
        error('no channel for theta phase detection is specified.');
    end
end
    
if ~FileExists([FileBase '.phase']) | overwrite
    fprintf('Calculating theta phase and power... \n');
    Eeg = readsinglech([FileBase '.eeg'],numch,elc);
    [Phase.deg Phase.amp PhaseTot] = ThetaPhase(Eeg,[4.5 11],4,EegRate);
    ThPhase = Phase;
    save([FileBase '.phase'],'Phase');
elseif nargin>2
    Eeg = readsinglech([FileBase '.eeg'],numch,elc);
    [Phase.deg Phase.amp PhaseTot] = ThetaPhase(Eeg,[4.5 11],4,EegRate);
    ThPhase = Phase;
else
    fprintf('Loading theta phase and power... \n');
    load([FileBase '.phase'],'-MAT');
    ThPhase = Phase;
end

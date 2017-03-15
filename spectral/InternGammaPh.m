function GmPhase = InternGammaPh(fileinfo,overwrite)
% function GmPhase = InternGammaPh(fileinfo,overwrite)


if (nargin<2);overwrite = 0;end

filename = fileinfo.name;
FileBase = [filename '/' filename];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Gamma Phase and power
%% (needs: FileBase.elc, FileBase.par)
%% (output: GmPhase >> FileBase.phase)
%%

Par =LoadPar([FileBase '.par']); % either par or xml file needed
EegRate = Par.lfpSampleRate; % sampling rate of eeg file
numch = Par.nChannels;

if ~FileExists([FileBase '.gamma']) | overwrite
    fprintf('Calculating gamma phase and power... \n');
    if ~isempty(fileinfo.CA1thetach)
    elc = fileinfo.CA1thetach+1;
    elseif ~isempty(fileinfo.CA3thetach)
    elc = fileinfo.CA3thetach+1;
    else
      error('no channel for gamma phase detection is specified.');
    end
    Eeg = readsinglech([FileBase '.eeg'],numch,elc);
    [GmPhase.deg GmPhase.amp] = ThetaPhase(Eeg,[30 55],4,EegRate);
%     GmPhase = Phase;
    save([FileBase '.gamma'],'GmPhase');
else
  fprintf('Loading gamma phase and power... \n');
  load([FileBase '.gamma'],'-MAT');
end

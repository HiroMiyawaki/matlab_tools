%function Rips = DetectRipples(FileBase, Channels, FreqRange, Threshold, eSampleRate, Mode, Overwrite)
% gives out the structure: Rip.t - time of the ripple (eeg sampling rate),
% Rip.len = length is msec, Rip.pow - power of the ripple
function Rips = DetectRipples(fileinfo, varargin)


currentdir = pwd;
FileBase = [currentdir '/' fileinfo.name '/' fileinfo.name];

[FreqRange, Threshold,  Mode, Overwrite] = DefaultArgs(varargin,{[100 250],8, 'long',1});
Channels = fileinfo.ripch + 1;

Par = LoadPar([FileBase '.xml']);
% eSampleRate = Par.lfpSampleRate;
eSampleRate = 1252;
spw = sdetect_a([FileBase '.eeg'],Par.nChannels,Channels,FreqRange(end),FreqRange(1),Threshold, 0, eSampleRate);

if strcmp(Mode,'long') & ~isempty(spw)

    seglen = max(spw(:,3)-spw(:,1));
    seglen = seglen + mod(seglen,2);
    eeg = LoadBinary([FileBase '.eeg'],Channels(1),Par.nChannels)';
    [seg complete] = GetSegs(eeg,spw(:,2)-seglen/2,seglen,[]);
    seg = sq(seg);
    pow = FirFilter(seg,2,[120 230]/(eSampleRate/2),'bandpass');
    Rips.pow = mean(abs(pow),1)';

    Rips.t = spw(complete,2);
    Rips.len = (spw(complete,3)-spw(complete,1))*1000./eSampleRate;

    ripple_result = [spw(complete,1:3) Rips.pow];
    save([FileBase '-rip.mat'],'ripple_result'); %
    fprintf('%s  %d ripples detected successfully!\n',fileinfo.name,length(Rips.t));
%     msave([FileBase '.spw'],[Rips.t Rips.pow(:) Rips.len(:)]);
    MakeEvtFile(Rips.t(:), [FileBase '.rip.evt'],'rip',eSampleRate,1);
end

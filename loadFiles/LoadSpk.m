% Spk = LoadSpk(FileName, nChannels, SpkSampls, Spikes2Load)
%
% Loads a .spk file
%
% returns a 3d array Spk(Channel, Sample, Spike Number)
%
% nChannels will default to 4
% SpkSampls will default to 32
% Spikes2Load will default to inf - i.e. load them all.

function Spk = LoadSpk(FileName, nChannels, SpkSampls, Spikes2Load)

if (nargin<2) nChannels = 8; end;
if (nargin<3) SpkSampls = 54; end;
if (nargin<4) Spikes2Load = inf; end;

Spk = bload(FileName, [nChannels, Spikes2Load*SpkSampls],0,'short=>single');

nSpikes = size(Spk, 2)/SpkSampls;

Spk = reshape(Spk, [nChannels, SpkSampls, nSpikes]);


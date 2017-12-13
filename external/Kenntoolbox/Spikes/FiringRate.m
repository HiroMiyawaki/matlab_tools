function Rate = FiringRate(ResFile, CluFile, ClusterNo, SampleRate)
% calculates firing rate from a given res and clu file
% output is given in Hz
% function Rate = FiringRate(ResFile, CluFile, ClusterNo, SampleRate)

Res = load(ResFile);
Clu = LoadClu(CluFile);

LastSpikeTime = max(Res);
nSpikes = length(find(Clu==ClusterNo));

Rate = nSpikes * SampleRate / LastSpikeTime;
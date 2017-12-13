function Waveforms = getWaveformsFromDat(DatFile,SpkTime,ChMap,NChInDat,NPoints,PeakPos)
% Waveforms = getWaveformsFromDat(DatFile,SpkTime,ChMap,NChInDat,NPoints,PeakPos)
%
% Get waveforms from dat file.
%
% DatFile: dat file name
% SpkTime:
% ChMap: list of channels to use
% NChInDat: number of channels in the dat file
% NPoints: number of points to extract per spike per channel
% PeakPos: position where spike peaks are
%
% Developed by Hiro Miyawaki, 2017
FileInfo = dir(DatFile);
Source = memmapfile(DatFile, 'Format', {'int16', [NChInDat, (FileInfo.bytes/NChInDat/2)], 'x'});
Waveforms = zeros(length(ChMap), sum(NPoints), length(SpkTime));
for i=1:length(SpkTime)
     Waveforms(:,:,i) = Source.Data.x(ChMap,SpkTime(i)+(1:NPoints)-PeakPos);
end
function [Wave,Frequency]=HM_eegWavelet(EegFile,NumCh,UseCh,SamplingRate,FreqRange,FrameRange,DJ,K0)

if ~exist('K0','var'); K0=6; end
if ~exist('DJ','var'); DJ=0.25; end
if ~exist('FreqRange','var'); FreqRange=[1,120]; end

fileInfo=dir(EegFile);
numFrame=fileInfo.bytes/NumCh/2;

if ~exist('FrameRange','var')
    firstFrame=1;
    lastFrame=numFrame;
else
    firstFrame=min(FrameRange);
    if firstFrame<0; firstFrame=1; end
    lastFrame=min([max(FrameRange),numFrame]);
end

if FreqRange(1)>FreqRange(2); FreqRange=FreqRange([2,1]);end

lfpFile=memmapfile(EegFile, 'Format', {'int16', [NumCh, numFrame], 'val'});   

eeg=double(lfpFile.Data.val(UseCh,firstFrame:lastFrame));

% fh=fopen(EegFile);
% fseek(fh,2*(UseCh+NumCh*(firstFrame-1)),'bof');
% 
% if exist('FrameRange','var')
%     eeg=fread(fh,[1,lastFrame-firstFrame+1],'int16',2*(NumCh-1));
% else
%     eeg=fread(fh,[1,inf],'int16',2*(NumCh-1));
% end
% fclose(fh);


fourier_factor=(4*pi)/(K0 + sqrt(2 + K0^2));
scaleMax=(1/FreqRange(1))/fourier_factor;
scaleMin=(1/FreqRange(2))/fourier_factor;

J1=ceil(log2(scaleMax/scaleMin)/DJ);

[Wave,period] = wavelet(eeg,1/SamplingRate,0,DJ,scaleMin,J1,'MORLET',K0);

Frequency=arrayfun(@(x) 1/x, period);
% Frequency=arrayfun(@(x) (K0+sqrt(2+K0^2))/4/pi/x, period);




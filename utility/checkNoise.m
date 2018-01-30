function varargout=checkNoise(datFile,nCh,chToUse,sampleRate,tRange,doPlot)
%   do FFT to check 60Hz noise
%
%   checkNoise(datFile,nCh,sampleRate,chToUse,tRange)
%       do FFT and display the result
%   [power,frequency]=checkNoise(datFile,nCh,sampleRate,chToUse,tRange)
%       do FFT and return the result
%
%   datFile : target .dat file
%   nCh : number of channels in the dat
%   sampleRate : sampleRate of dat file (default 20e3)
%   chToUse : channel to be used for FFT (default 1)
%   tRange : range of time to calculate FFT in sec (default [0,10])
%   doPlot : show plots even in case output(s) are taken.
%
if ~exist('sampleRate','var')
    sampleRate=20e3;
end

if ~exist('chToUse','var')
    chToUse=1;
end

if ~exist('tRange','var')
    tRange=[0,10];
end

if ~exist('doPlot','var')
    doPlot=false;
end
fileInfo = dir(datFile);
dat = memmapfile(datFile, 'Format', {'int16', [nCh, (fileInfo.bytes/nCh/2)], 'raw'});    
lfp=single(dat.Data.raw(chToUse,tRange(1)*sampleRate+1:tRange(2)*sampleRate))*0.195;
    

y=fft(lfp);
len=size(lfp,2);
pow2=abs(y/len);
pow=pow2(1:len/2+1);
pow(2:end-1)=2*pow(2:end-1);

freq=sampleRate*(0:(len/2))/len;


dur=1;

if nargout==0 || doPlot
    subplot(1,4,1:3)
    plot((1:dur*sampleRate)/sampleRate,lfp(:,1:dur*sampleRate),'k-','linewidth',0.1)
    xlabel('Time (s)')
    ylabel('LFP (\muV)')
    axis tight
    box off
    subplot(1,4,4)
    plot(freq(freq<101),pow(freq<101),'k-','linewidth',0.5)
    set(gca,'yscale','log')
    xlabel('Hz')
    ylabel('\muV^2/Hz')
    xlim([0,100])
    ylim(10.^[-3,2])
else
    varargout{1}=pow(freq<101);
    varargout{2}=freq(freq<101);
end

clear

K0=6;
DJ=0.25;

FreqRange=[0.1,150];

useChList=[11,58];
fileCore='~/data/OCU/implanted/magician/magician_2017-09-19_06-10-17/magician_2017-09-19_06-10-17';
param=LoadXml(fileCore);


fileInfo=dir([fileCore '.lfp']);
numFrame=fileInfo.bytes/param.nChannels/2;
lfpFile=memmapfile(fullfile(fileInfo.folder,fileInfo.name), 'Format', {'int16', [param.nChannels, numFrame], 'val'});   

fourier_factor=(4*pi)/(K0 + sqrt(2 + K0^2));
scaleMax=(1/FreqRange(1))/fourier_factor;
scaleMin=(1/FreqRange(2))/fourier_factor;
J1=ceil(log2(scaleMax/scaleMin)/DJ);

k = [1:fix(numFrame/2)];
k = k.*((2.*pi)/(numFrame*(1/param.lfpSampleRate)));
k = [0., k, -k(fix((numFrame-1)/2):-1:1)];

scale = scaleMin*2.^((0:J1)*DJ);
for uChIdx=1:length(useChList);

    useCh=useChList(uChIdx);
    saveFileName=[fileCore '-wavelet_ch' num2str(useCh) '.mat'];

    lfp=double(lfpFile.Data.val(useCh,:));
    x = lfp - mean(lfp);

    f = fft(x);    % 

    mf=matfile(saveFileName,'writable',true);
    mf.power=zeros(length(scale),numFrame);
    mf.phase=zeros(length(scale),numFrame);
    mf.zscored=zeros(length(scale),numFrame);
    mf.frequency=arrayfun(@(x) 1/(fourier_factor*x), scale)';
    mf.sampleRate=param.lfpSampleRate;
    mf.filename=param.FileName;
    mf.ch=useCh;
    mf.madeby=mfilename;

    for n=1:length(scale)
        disp([datestr(now) ' ' num2str(n) '/' num2str(length(scale))])
        daughter=wave_bases('MORLET',k,scale(n),K0);	

        wave=ifft(f.*daughter);


        mf.power(n,:)=abs(wave);
        mf.phase(n,:)=unwrap(angle(wave));
        mf.zscored(n,:)=zscore(abs(wave));
    end
end
% Frequency=arrayfun(@(x) 1/x, period);

    

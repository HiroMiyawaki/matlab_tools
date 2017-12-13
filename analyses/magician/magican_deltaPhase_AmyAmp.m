clear

K0=6;
DJ=0.25;

FreqRange=[0.1,150];

amyCh=11;
pfcCh=58;
fileCore='~/data/OCU/implanted/magician/magician_2017-09-19_06-10-17/magician_2017-09-19_06-10-17';
param=LoadXml(fileCore);


fileInfo=dir([fileCore '.lfp']);
numFrame=fileInfo.bytes/param.nChannels/2;
lfpFile=memmapfile(fullfile(fileInfo.folder,fileInfo.name), 'Format', {'int16', [param.nChannels, numFrame], 'val'});   



pfcLfp=double(lfpFile.Data.val(pfcCh,:));

deltaBand=[0.5,4];
forder = 512;
firfiltb = fir1(forder,deltaBand/param.lfpSampleRate*2); 
pfcDelta=Filter0(firfiltb,pfcLfp);

temp=hilbert(pfcDelta);

deltaPow=log(abs(temp));
deltaPhase=angle(temp);

deltaPowZ=zscore(conv(deltaPow,ones(1,625),'same'));
%%
deltaPeriod=deltaPowZ>0.5;
%%
amyLfp=double(lfpFile.Data.val(amyCh,:));
amyFFT=fft(amyLfp-mean(amyLfp));

K0=6;
DJ=0.15;

FreqRange=[0.1,150];
fourier_factor=(4*pi)/(K0 + sqrt(2 + K0^2));
scaleMax=(1/FreqRange(1))/fourier_factor;
scaleMin=(1/FreqRange(2))/fourier_factor;
J1=ceil(log2(scaleMax/scaleMin)/DJ);

k = [1:fix(numFrame/2)];
k = k.*((2.*pi)/(numFrame*(1/param.lfpSampleRate)));
k = [0., k, -k(fix((numFrame-1)/2):-1:1)];

scale = scaleMin*2.^((0:J1)*DJ);

nBin=72;
phaseBin=ceil((deltaPhase(deltaPeriod)+pi)/2/pi*(nBin));

freq=1./(fourier_factor*scale);


clear phaseAmp
for n=1:length(scale)
    disp([datestr(now) ' ' num2str(n) '/' num2str(length(scale))])
    daughter=wave_bases('MORLET',k,scale(n),K0);	

    wave=ifft(amyFFT.*daughter);

    pow=zscore(abs(wave(deltaPeriod)).^2);
    logpow=zscore(log(abs(wave(deltaPeriod)).^2));

    for m=1:nBin
        phaseAmp.mean(n,m)=mean(pow(phaseBin==m));
        phaseAmp.logmean(n,m)=mean(logpow(phaseBin==m));
    end
end

%%
close all
for n=1:20
subplot(2,10,n)
plot((360/nBin/2):(360/nBin):720,zscore([phaseAmp.mean(2*n,:),phaseAmp.mean(2*n,:)]))
title(freq(2*n))
xlim([0,720])
end
%%
% figure
close all
fh=initFig4letter()

nRow=8;
subplotInMM(20,81,50,4,true)

plot(0:5:720,cos((0:5:720)/180*pi),'k-')
ylim([-1,1])
xlim([0,720])
axis off
subplotInMM(20,25,50,50,true)
% subplot(2,1,1)
mu = [0 0];
Sigma = eye(2);
[X1,X2] = meshgrid(-3:3,-3:3);
core = mvnpdf([X1(:) X2(:)],mu,Sigma);
core = reshape(core,size(X1,1),size(X2,2));
core=core./sum(core(:));

temp=conv2([phaseAmp.mean';phaseAmp.mean';phaseAmp.mean'],core);
% temp=conv2([phaseAmp.logmean';phaseAmp.logmean';phaseAmp.logmean'],core);

temp=temp(size(phaseAmp.mean,2)/2+(1:size(phaseAmp.mean,2)),:);

% imagescXY([0,720],[length(freq),1],log(+0.15))
% imagescXY([0,720],[length(freq),1],log([temp;temp]+0.15))
imagescXY([0,720],[length(freq),1],([temp;temp]))
set(gca,'ytick',1:length(freq),'yticklabel',flip(freq))
% ylim([23,70])
ylim([34,68.5])
colormap(gray)
% set(gca,'clim',[-2.25,-1.5])
set(gca,'clim',[-0.05,0.1])
set(gca,'xtick',0:180:720)
% subplot(2,1,2)
% imagescXY([0,720],[length(freq),1],zscore([phaseAmp.mean';phaseAmp.mean'],0,1))
% set(gca,'ytick',1:length(freq),'yticklabel',flip(freq))
%
% f= 1./(1/FreqRange(2)* 2.^((n-1)*DJ));
% 1/f= 1/FreqRange(2)* 2.^((n-1)*DJ);
% FreqRange(2)/f=  2.^((n-1)*DJ);
% log2(FreqRange(2)/f)=  (n-1)*DJ;
% log2(FreqRange(2)/f)/DJ=  (n-1);
% 1+log2(FreqRange(2)/f)/DJ= n;
f=[1,3,10,30,100];
set(gca,'ytick',73-(1+log2(FreqRange(2)./f)/DJ),'yticklabel',f)
ylabel('Frequency in Amy (Hz)')
xlabel('Delta phase in PFC (degree)')
set(get(gca,'xlabel'),'Position',get(get(gca,'xlabel'),'Position')+[0,-6,0])
box off
temp=get(gca,'clim')
subplotInMM(72,25,2,50,true)
imagescXY([0,1],temp,linspace(temp(1),temp(2),256))
set(gca,'clim',temp)
box off
set(gca,'xtick',[],'ytick',-0.05:0.05:0.1,'YAxisLocation','right')
% axis off
ylabel('Wavelet amp (z)')
set(get(gca,'YLabel'),'Rotation',-90)
set(get(gca,'ylabel'),'Position',get(get(gca,'ylabel'),'Position')+[5,0,0])

addScriptName(mfilename)

print(['~/Dropbox/Proposal/êVäwèp2017/' 'phase-amp.png'],'-dpng','-r300')
print(['~/Dropbox/Proposal/êVäwèp2017/' 'phase-amp.eps'],'-depsc','-painters')



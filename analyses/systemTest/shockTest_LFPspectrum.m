clear 
dataDir='~/data/OCU/Chamber_shockTest/shock_test/';
coreName='shockTest';

varList={'basics','eventTime'};
 for var=varList
     load([dataDir coreName '-' var{1} '.mat'])
 end

lfp=load([basics.FileName '.eegseg.mat']);
 
%%
ch=basics.Ch.theta(1);
fh=fopen([basics.FileName '.lfp']);
fseek(fh,2*(ch-1),'bof');
trace.y=fread(fh,[1,inf],'int16',2*(basics.nChannels-1))*0.19499999284744263;
fclose(fh)
trace.t=(0.5:length(trace.y))/basics.lfpSampleRate;
%%
close all
fh=initFig4JNeuro(2)
col.tone=[0.6,1,0.6];
col.shock=[1,0,0];

for shockIdx=1:3;
tRange=eventTime.shock(shockIdx,1)'/1e6+[-30,0]+30*[-1,1];

tone=eventTime.tone(shockIdx,:)/1e6;
shock=eventTime.shock(shockIdx,:)/1e6;


traceIdx=find(trace.t<tRange(1),1,'last'):find(trace.t>tRange(2),1,'first');

subplot(6,1,2*shockIdx-1)
rectangle('position',[tone(1),-1000,diff(tone),2000],'facecolor',col.tone,'linestyle','none')
rectangle('position',[shock(1),-1000,diff(shock),2000],'facecolor',col.shock,'linestyle','none')
ylim(1000*[-1,1])
hold on
plot(trace.t(traceIdx),trace.y(traceIdx),'k-','linewidth',0.5)
xlim(tRange)

tIdx=find(lfp.t<tRange(1),1,'last'):find(lfp.t>tRange(2),1,'first');
fIdx=1:find(lfp.f>30,1,'first');
xlabel('Time (s)')
ylabel('LFP (\muV)')

subplot(6,1,2*shockIdx)
imagescXY(lfp.t(tIdx),lfp.f(fIdx),log(squeeze(lfp.Pxx(tIdx,fIdx,1))))
xlim(tRange)
colormap(gca,'jet')
set(gca,'clim',[5,12.5])
xlabel('Time (s)')
ylabel('LFP (Hz)')

end

print(fh,[dataDir 'shock_LFPspec.pdf'],'-dpdf')oo

addScriptName(mfilename)


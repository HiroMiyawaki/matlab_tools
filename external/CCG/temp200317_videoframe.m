sessionList={
     1,0,0,'achel180320'
     1,0,0,'booyah180430'
     1,0,0,'chimay180612'
     1,0,0,'duvel190505'
     1,0,0,'estrella180808'
     1,0,0,'feuillien180830'
     1,0,0,'guiness181002'
     1,0,0,'hoegaarden181115'
     1,0,0,'innis190601'
     1,0,0,'jever190814'
     1,0,0,'karmeliet190901'
     1,0,0,'leffe200124'
     1,0,0,'maredsous200224'
     1,0,0,'nostrum200304'
             };
%%
for n=1:size(sessionList,1)%%
 ses=sessionList{n,end}
 load(sprintf('~/data/Fear/triple/%s/%s.basicMetaData.mat',ses,ses));
 vr=VideoReader(basicMetaData.video.filename);
 load([basicMetaData.Basename '.videoFrames.events.mat'])
 
 gap(n)=vr.Duration*25-size(videoFrames.timestamps,1)
end
 %%
 n=9
  ses=sessionList{n,end}

 load(sprintf('~/data/Fear/triple/%s/%s.basicMetaData.mat',ses,ses));
 vr=VideoReader(basicMetaData.video.filename);
 load([basicMetaData.Basename '.videoFrames.events.mat'])
 
sum(diff(videoFrames.timestamps,1,2)<2.36e-3)


hist((diff(videoFrames.timestamps(:,1))-0.04)*1000*20)

size(videoFrames.timestamps)
vr.Duration*25;

n=0;
t=nan(1,max([vr.Duration*vr.FrameRate,size(videoFrames.timestamps,1)]));
while vr.hasFrame
    n=n+1;
    if mod(n,10000)==1
        fprintf('%s %d (%f %%?)\n',datestr(now),n,n/(vr.Duration*vr.FrameRate)*100)
    end
    t(n)=vr.CurrentTime;
    vr.readFrame;
end


%%
min(diff(videoFrames.timestamps(:,1)))*1000;
max(diff(videoFrames.timestamps(:,1)))*1000;
mean(diff(videoFrames.timestamps(:,1)))


ceil((videoFrames.timestamps(end,1)-videoFrames.timestamps(1,1))*25)
size(videoFrames.timestamps)


(videoFrames.timestamps(end,1)-videoFrames.timestamps(1,1))/(size(videoFrames.timestamps,1)-1)

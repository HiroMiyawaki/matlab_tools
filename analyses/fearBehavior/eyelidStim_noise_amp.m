dataDir='~/data/OCU/HR0016/2017-06-22_18-01-54/';
dataName='experiment1_101_0';

datFile=[dataDir dataName '.dat'];
nCh=21;
sampleRate=20e3;

fileInfo = dir(datFile);
clear temp
lfp2 = memmapfile(datFile, 'Format', {'int16', [nCh, (fileInfo.bytes/nCh/2)], 'x'});    

ttlCh=20:21;


bufSize=2^26;


for idx=1:length(ttlCh)
    ttlFrame{idx}=[];
    last=false;
    for n=1:ceil(size(lfp2.Data.x,2)/bufSize)
        temp=[last,lfp2.Data.x(ttlCh(idx),(n-1)*bufSize+1:min(n*bufSize,size(lfp2.Data.x,2)))>0];

        ttlFrame{idx}=[ttlFrame{idx};[find(diff(temp)==1)'+1,find(diff(temp)==-1)']-1+(n-1)*bufSize];
        last=temp(end);
    end

    ttlFrame{idx}=ttlFrame{idx}(diff(ttlFrame{idx},1,2)>sampleRate*0.2e-3,:); %should be > 0.2 ms
end

%%
stimAmp=[0,0,0.6,0.6,1,1,1,0.6,1.5,1.5,1.9,1.9,2.5,2.5,3.1,3.1,3.1,3.4,3.4,3.4,3.8,3.8,3.8,2.5,2.5,2.5];



stimFrame=ttlFrame{1}(1:8:201);

close all
fh=initFig4Nature(2);
tRange=[-1,3];
frames=tRange(1)*sampleRate:tRange(2)*sampleRate;

% 
% for idx=1:26
%     subplot(9,3,idx)
%     hold on
%     for ch=1:6
%         plot(frames/sampleRate,double(lfp2.data.x(ch,frames+stimFrame(idx)))*0.195-750*(ch-1),'linewidth',0.2)        
%     end
% ylim([-5000,2000])
% box off
% ax=fixAxis;
% text2(1,1,[num2str(stimAmp(idx)) 'mA'],ax,{'horizontalAlign','right','verticalAlign','top'})
% 
% xlabel('Time (s)')
% ylabel('LFP (mV)')
% end
% 
% addScriptName(mfilename)
% print(fh,['~/data/OCU/HR0016/' 'stimAmpTest.pdf'],'-dpdf','-painters')
%%

vr=VideoReader([dataDir '2017-06-22 18-02-02.151.m4v'])
cnt=0;
while hasFrame(vr)
    fr=vr.readFrame;
    cnt=cnt+1;
    LED(:,:,:,cnt)=fr(265+(-8:8),535+(-8:8),:);
end
%%
vr=VideoReader([dataDir '2017-06-22 18-02-02.151.m4v']);
cnt=0;
while hasFrame(vr)
    fr=vr.readFrame;
    cnt=cnt+1;
    video(:,:,cnt)=(max(fr,[],3)+min(fr,[],3))/2;
end


%%
clf
for idx=1:100
    subplot(10,10,idx)
%     imagesc(mean(squeeze(double(LED(:,:,:,idx+10520))),3))
    imagesc(squeeze(double(LED(:,:,3,idx+10520))))
     set(gca,'clim',[100,250])
end
%%
% clf
% hold on
% col=eye(3)
% for idx=1:3
% temp=squeeze(double(LED(:,:,idx,:)));
% plot(mean(squeeze(max(temp,[],1))),'color',col(idx,:))
% end

temp=squeeze(double(LED(:,:,3,:)));
temp=mean(squeeze(max(temp,[],1)));

isOn=temp>120;
onset=find(diff(isOn)==1);
offset=find(diff(isOn)==-1);

if offset(1)<onset(1); offset(1)=[]; end
if onset(end)>offset(end); onset(end)=[]; end

cand=[onset',offset'];

medDur=median(diff(cand,1,2));
questionable=find(diff(cand,1,2)<medDur*0.7);


isOn(1:10)=0;   

%%
for idx=1:length(questionable)
clf
    frm=max([cand(questionable(idx))-15,1]):min([cand(questionable(idx))+15,length(temp)]);
    subplot(2,1,1)
    hold on
    plot(1:length(frm),temp(frm));
    plot(1:length(frm),isOn(frm)*80+80,'.-');
    xlim([0.5,31.5])
    for n=1:length(frm)
        subplot(2,31,31+n)
         imagesc(video(220:320,490:590,frm(n)))
         title(frm(n))
         set(gca,'clim',[44,128])
    end

    [x,y,b] = ginput;
    isOn(frm(round(x)))=b==1;
end

%     imagesc(video(220:320,490:590,idx+100))
%     
% end
%%
save([dataDir 'LED.mat'],'isOn')


(find(isOn==1,1,'last')-find(isOn==1,1,'first'))
(ttlFrame{2}(end)-ttlFrame{2}(1))/20e3
    
    
%%

videoFrameRate=vr.FrameRate;
floor(size(lfp2.data.x,2)/sampleRate)


ephysZero=ttlFrame{2}(1);
videoZero=find(isOn==1,1,'first')-1;

for t=568:0.5:floor((size(lfp2.data.x,2)-ephysZero)/sampleRate)
clf

    frmCenter=round(sampleRate*t)+ephysZero;
    frm=max([floor(frmCenter-15/videoFrameRate*sampleRate),1]):min([ceil(frmCenter+15/videoFrameRate*sampleRate),size(lfp2.data.x,2)]);
    subplot(3,1,1)
    plot((frm-ephysZero)/sampleRate,lfp2.data.x(21,frm))
    axis tight
    ylim(4e4*[-1,1])
    title(t)
    ax=fixAxis;
    
    frmCenter=round(videoFrameRate*t)+videoZero;

    frm=max([frmCenter-15,1]):min([frmCenter+15,length(temp)]);
    subplot(3,1,2)
    hold on
    plot((frm-videoZero)/videoFrameRate,temp(frm));
    plot((frm-videoZero)/videoFrameRate,isOn(frm)*80+80,'.-');
    xlim(ax(1:2))
    ylim([80,160])
    
    for n=1:length(frm)
        subplot(3,31,31*2+n)
         imagesc(video(220:320,490:590,frm(n)))
         title(frm(n))
         set(gca,'clim',[44,128])
    end


    
    [x,y,b] = ginput;
    for n=1:length(x)
        [~,idx]=min(abs((frm-videoZero)/videoFrameRate-x(n)))
        isOn(frm(idx))=b(n)==1;
    end
end


    
    
%%    
ttl=sortrows([ttlFrame{2}(:,1),ones(size(ttlFrame{2}(:,1)))
ttlFrame{2}(:,2),ones(size(ttlFrame{2}(:,2)))
ttlFrame{2}(:,1)-1,zeros(size(ttlFrame{2}(:,1)))
ttlFrame{2}(:,2)+1,zeros(size(ttlFrame{2}(:,2)))]);


hold on
plot((1:(length(isOn)-videoZero+1))/videoFrameRate,isOn(videoZero:end))
plot((ttl(:,1)-ephysZero)/sampleRate,ttl(:,2)*0.5)







    
    
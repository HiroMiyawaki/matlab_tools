clear
dataDir='~/data/OCU/HR0016/2017-06-22_16-57-17/';
dataName='experiment1_101_0'

datFile=[dataDir dataName '.dat'];
nCh=21;
sampleRate=20e3;

fileInfo = dir(datFile);
clear temp
lfp = memmapfile(datFile, 'Format', {'int16', [nCh, (fileInfo.bytes/nCh/2)], 'x'});    

ttlCh=17:21;


bufSize=2^26;
frameRange=[25,43*60+35]*20e3;


for idx=1:length(ttlCh)
    ttlFrame{idx}=[];
    last=false;
    for n=1:ceil(size(lfp.Data.x,2)/bufSize)
        temp=[last,lfp.Data.x(ttlCh(idx),(n-1)*bufSize+1:min(n*bufSize,size(lfp.Data.x,2)))>0];

        ttlFrame{idx}=[ttlFrame{idx};[find(diff(temp)==1)'+1,find(diff(temp)==-1)']-1+(n-1)*bufSize];
        last=temp(end);
    end

    ttlFrame{idx}=ttlFrame{idx}(diff(ttlFrame{idx},1,2)>sampleRate*0.2e-3,:); %should be > 0.2 ms
end

for idx=1:length(ttlFrame)
    ttlFrame{idx}(ttlFrame{idx}(:,1)<frameRange(1)|ttlFrame{idx}(:,2)>frameRange(2),:)=[];
end
%%
    
%%
cue=[];
for n=1:2
    for m=1:size(ttlFrame{n},2)
        cue=[cue;[ttlFrame{n}(:,m),(2*(n-1)+m)*ones(size(ttlFrame{n}(:,m)))]];
    end
end
cue=sortrows(cue);
labelList={'onset1','offset1','onset2','offset2'};

fid = fopen([dataDir dataName '.cue.evt'],'w');

for n=1:size(cue,1)
    fprintf(fid,'%f %s\n',(cue(n,1)*1000/sampleRate),labelList{cue(n,2)});
end
fclose(fid);

MakeEvtFile(ttlFrame{3},[dataDir dataName '.trg.evt'],{'onset','offset'},sampleRate)
MakeEvtFile(ttlFrame{4},[dataDir dataName '.shk.evt'],{'onset','offset'},sampleRate)

%%
fh=fopen([dataDir 'twoToneCond.txt']);

l=fgetl(fh)

l=fgetl(fh)

for n=1:3
   evt{n}=[];
end

while ischar(l)
    temp=strsplit(l,',');
    if strcmp(temp{1},'duration')
%         duration(4)=str2num(temp{2});
    elseif strcmp(temp{1},'tone1')
        duration(1)=str2num(temp{2});        
    elseif strcmp(temp{1},'tone2')
        duration(2)=str2num(temp{2});        
    elseif strcmp(temp{1},'shock')
        duration(3)=str2num(temp{2});        
    else
        if strcmp(temp{2},'t1')
            evt{1}(end+1)=str2num(temp{1});
        elseif strcmp(temp{2},'t2')
            evt{2}(end+1)=str2num(temp{1});
        elseif strcmp(temp{2},'s')
            evt{3}(end+1)=str2num(temp{1});
        end
    end
    l=fgetl(fh);
    
end
fclose(fh);
    
for n=1:3
    evt{n}=[evt{n}',evt{n}'+duration(n)];
end
    
%%
%%
dataDir='~/data/OCU/HR0016/2017-06-22_18-01-54/';
dataName='experiment1_101_0';

datFile=[dataDir dataName '.dat'];
nCh=21;
sampleRate=20e3;

fileInfo = dir(datFile);
clear temp
lfp2 = memmapfile(datFile, 'Format', {'int16', [nCh, (fileInfo.bytes/nCh/2)], 'x'});    

ttlCh=20;


bufSize=2^24;


for idx=1:length(ttlCh)
    ttlFrame2{idx}=[];
    last=false;
    for n=1:ceil(size(lfp2.Data.x,2)/bufSize)
        temp=[last,lfp2.Data.x(ttlCh(idx),(n-1)*bufSize+1:min(n*bufSize,size(lfp2.Data.x,2)))>0];

        ttlFrame2{idx}=[ttlFrame2{idx};[find(diff(temp)==1)'+1,find(diff(temp)==-1)']-1+(n-1)*bufSize];
        last=temp(end);
    end

    ttlFrame2{idx}=ttlFrame2{idx}(diff(ttlFrame2{idx},1,2)>sampleRate*0.2e-3,:); %should be > 0.2 ms
end



%%
period=[30,210];
for idx=1:6
    temp=lfp.data.x(2*idx-1,period(1,1)*20e3+1:period(1,2)*20e3);
    temp=double(temp)*0.192;
    y=fft(temp);
    len=length(y);
    pow2=abs(y/len);
    pow{idx}=pow2(1:len/2+1);
    pow{idx}(2:end-1)=2*pow{idx}(2:end-1);

    freq{idx}=20e3*(0:(len/2))/len;
end

period=[30,430];
Window=0.5;
clear Pxx f t 
for idx=1:6
    temp=lfp.data.x(2*idx-1,period(1,1)*20e3+1:period(1,2)*20e3);
    temp=double(temp)*0.192;
    
    nFFT = 2^round(log2(2^16)); %compute nFFT according to different sampling rates
    SpecWindow = 2^round(log2(Window*sampleRate));% choose window length as power of two

    display([datestr(now),' whitening the signal'])    
    weeg = WhitenSignal(temp,[],1);
    %%%%      mtcsglong(x,nFFT,Fs,WinLength,nOverlap,NW,Detrend,nTapers,FreqRange);
    display([datestr(now),' performing FFT'])    
    [Pxx(:,:,idx),fr,ti]=mtcsglong(weeg,nFFT,sampleRate,SpecWindow,[],2,'linear');
end
    


%%
minFrame=min(min(cat(1,ttlFrame{1:3})));
minTime=min(min(cat(1,evt{1:3})));

close all
fh=initFig4Nature(2)
subplot(8,1,1)
hold on
col=[0,1,0;0,0,1;1,0,0]
for n=1:2
    frame=ttlFrame{n}-minFrame;
    frame(:,2)=frame(:,2)+1;
    noError=(evt{n}-minTime)*sampleRate;
    
    plot(frame'/sampleRate,(frame-noError)'/sampleRate*1000,'k.-','color',col(n,:))    
end
xlim([0,2500])
ylim([-5,25])

xlabel('Time (s)')
ylabel('Error (ms)')
title('Triggered by custom made software')

subplot(8,1,2)

t=[];
for n=0:25
    t=[t,n*30+(0:7)*0.125];
end
t=t';
t=[t,t+1/1e3];

f=ttlFrame2{1}-min(ttlFrame2{1}(:));
f(:,2)=f(:,2)+1

plot(f'/sampleRate,(f-t*sampleRate)'/sampleRate*100,'k.-')
xlim([0,2500])
ylim([-20,10])
box off
xlabel('Time (s)')
ylabel('Error (ms)')
title('Triggered by stimulator')

tList={'Amy?','M1?','mPFC?','Screw','Screw','Screw'};

for idx=1:6
    subplot(8,4,4*(idx+1)+(1:3))
    imagescXY(ti,fr(fr<80),log10(squeeze(Pxx(:,fr<80,idx))))
    xlabel('time (s)')
    ylabel('Freq (Hz)')
    set(gca,'clim',[-1,2.5])
    colormap(gca,jet)
    box off
    title(tList{idx})

    subplot(8,4,4*(idx+2))
    plot(freq{idx}(freq{idx}<100),(pow{idx}(freq{idx}<100)))
    xlabel('Freq (Hz)')
    ylabel('Power')
    set(gca,'yscale','log')
    title('First 3 min')    
    box off
end

addScriptName(mfilename)
%%
print(fh,'~/data/OCU/HR0016/customSystemEvaluation.pdf','-dpdf','-painters')
%%

period=[30,430];

emg=lfp.data.x(13,period(1,1)*20e3+1:period(1,2)*20e3);

temp=lfp.data.x(14:16,period(1,1)*20e3+1:period(1,2)*20e3);
acc=sqrt(sum(double(temp).^2,1));

%%
subplot(3,1,1)
imagescXY(ti,fr(fr<80),log10(squeeze(Pxx(:,fr<80,6))))
xlim([100,380])

subplot(3,1,2)
plot((1:length(emg))/sampleRate,emg)
ylim(2000*[-1,1])
xlim([100,380])

subplot(3,1,3)
plot((1:length(acc))/sampleRate,acc)
ylim(30000*[0,1])
xlim([100,380])










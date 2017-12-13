clear

fileName='experiment1_101_0';
dataDir='~/data/OCU/HR0016/2017-06-14_08-58-57/';
saveDir='~/data/OCU/HR0016/';

nCh=21;
ch=1;


DatFile=[dataDir fileName '.dat'];
FileInfo = dir(DatFile);
lfp = memmapfile(DatFile, 'Format', {'int16', [nCh, (FileInfo.bytes/nCh/2)], 'x'});
sampleRate=20e3;

shockCh=21;
bufSize=2^24;
shockBin=[];
last=false;

%%
shockCh=20;
bufSize=2^24;
toneOn=[];
toneOff=[];

last=false;
for n=1:ceil(size(lfp.Data.x,2)/bufSize)
    temp=[last,lfp.Data.x(shockCh,(n-1)*bufSize+1:min(n*bufSize,size(lfp.Data.x,2)))>0];
    
    toneOn=[toneOn;find(diff(temp)==1)'+1-1+(n-1)*bufSize];
    toneOff=[toneOff;find(diff(temp)==-1)'-1+(n-1)*bufSize];
    last=temp(end);
end
toneBin=[toneOn,toneOff];
toneBin=toneBin(diff(toneBin,1,2)>sampleRate*0.2e-3,:); %should be > 0.2 ms


MakeEvtFile(toneBin,[dataDir fileName '.cue.evt'],{'onset','offset'},sampleRate)

%%
videoCh=19;
bufSize=2^24;
last=false;
videoBin=[];
for n=1:ceil(size(lfp.Data.x,2)/bufSize)
    temp=[last,lfp.Data.x(videoCh,(n-1)*bufSize+1:min(n*bufSize,size(lfp.Data.x,2)))>0];
    
    videoBin=[videoBin;[find(diff(temp)==1)'+1,find(diff(temp)==-1)']-1+(n-1)*bufSize];
    last=temp(end);
end

videoBin=videoBin(diff(videoBin,1,2)>sampleRate*10e-3,:); %should be > 1 ms


MakeEvtFile(videoBin(:,1),[dataDir fileName '.grb.evt'],'grab',sampleRate)

%%
% close all
% fh=initFig4Nature(2)
% 
% col.amy=hsv2rgb([0,1,1]);
% col.hpc=hsv2rgb([0,0.75,0.75]);
% col.pfc=hsv2rgb([0,0.5,0.5]);
% col.m1=hsv2rgb([2/3,1,1]);
% col.s1=hsv2rgb([2/3,0.75,0.75]);
% col.v1=hsv2rgb([2/3,0.5,0.5]);
% 
% tRangeList=[-2,8;
%     -0.2,1;
%     -0.005,0.02];
% %             -0.002,0.01];
% 
% yRange=[-15000,4000];
% 
% tText={'1st','2nd','3rd','4th'};
% emgCh=13:14;
% accCh=15:17;
% for m=1:4
%     for zoom=1:3
%         subplot(7,2,m+(ceil(m/2)-1)*6+(zoom-1)*2)
%         sIdx=m*8-7;
%         hold on
%         
%         tRange=tRangeList(zoom,:);
%         
%         
%         
%         type={'amy','amy','hpc','hpc','pfc','pfc','m1','m1','s1','s1','v1','v1'};
%         
%         if zoom<3
%             rectangle('position',[tRangeList(zoom+1,1),yRange(1),diff(tRangeList(zoom+1,:)),diff(yRange)],...
%                 'facecolor',[1,1,0.7],'linestyle','none')
%         end
%         for n=1:12
%             plot((sampleRate*tRange(1):sampleRate*tRange(2))/sampleRate,...
%                 lfp.Data.x(n,shockBin(sIdx,1)+(sampleRate*tRange(1):sampleRate*tRange(2)))*0.195-(n-1)*500,...
%                 '-','color',col.(type{n}),'linewidth',0.2)
%         end
%         
%         plot((sampleRate*tRange(1):sampleRate*tRange(2))/sampleRate,...
%             diff(double(lfp.Data.x(emgCh,shockBin(sIdx,1)+(sampleRate*tRange(1):sampleRate*tRange(2)))),1,1)*0.195/10-12*500-1000,...
%             'k-','linewidth',0.2);
% 
%         for n=1:length(accCh)
%             plot((sampleRate*tRange(1):sampleRate*tRange(2))/sampleRate,...
%             lfp.Data.x(accCh(n),shockBin(sIdx,1)+(sampleRate*tRange(1):sampleRate*tRange(2)))*0.195/3-12*500-1000-n*1000,...
%             '-','color',[0,0.7,0],'linewidth',0.2);
%         end
%         
%         
%         ylim(yRange)
%         if zoom==1
%             title([tText{m} ' stim'])
%             ax=fixAxis;
%             text2(1,1,{'\color[rgb]{1,0,0}LFP','\color[rgb]{0,0,1}EEG','\color[rgb]{0,0,0}EMG','\color[rgb]{0,0.7,0}Acc'},...
%                 ax,{'horizontalAlign','left','verticalALign','top'})
%         end
%         xlabel('Time (s)')
%         ylabel('LFP/EEG (mV)')
%         
%         
%         
%     end
% end
% 
% addScriptName(mfilename);
% 
% print(fh,[saveDir 'eyelid_stim_noise.pdf'],'-dpdf','-r300')

    
%%
sesBorder=find(diff(videoBin(:,1))>sampleRate*10);

videoOnsets{1}=videoBin(1:sesBorder-1,1);
videoOnsets{2}=videoBin(sesBorder+1:end-1,1);

tRange{1}=videoBin(1,1):videoBin(sesBorder,1);
tRange{2}=videoBin(sesBorder+1,1):videoBin(end,1);


for n=1:2
emg{n}=diff(double(lfp.Data.x(13:14,tRange{n})),1,1);

acc{n}=double(lfp.Data.x(15:17,tRange{n}));
end

tone{1}=[];
tone{2}=sortrows([tRange{2}(1),0;
        toneBin(:),ones(size(toneBin(:)));
        toneBin(:,1)-1,zeros(size(toneBin(:,1)));
        toneBin(:,2)+1,zeros(size(toneBin(:,2)))
        tRange{2}(end),0]);    
 
%%

[res{1},header,param,data]=readOharaXY([dataDir '20170614/' 'XYdata/' 'HR0016' '_XY.txt']);    
[res{2},header,param,data]=readOharaXY([dataDir '20170614-1/' 'XYdata/' 'HR0016' '_XY.txt']);    

%%
Window=0.5;

clear Pxx
for m=1:2
for n=1:6
Eeg=double(lfp.Data.x(2*n-1,tRange{m}));

nFFT = 2^round(log2(2^16)); %compute nFFT according to different sampling rates
SpecWindow = 2^round(log2(Window*sampleRate));% choose window length as power of two

display([datestr(now),' whitening the signal'])    
weeg = WhitenSignal(Eeg,[],1);
%%%%      mtcsglong(x,nFFT,Fs,WinLength,nOverlap,NW,Detrend,nTapers,FreqRange);
display([datestr(now),' performing FFT'])    
[Pxx{m}(:,:,n),f{m},t{m}]=mtcsglong(weeg,nFFT,sampleRate,SpecWindow,[],2,'linear',[],[0,100]);
end
end

%%
close all

doAppend='';

sesTitle={'Context','Cue-1','Cue-2'}

nRow=9;

for m=1:3
fh=initFig4Nature(2);
    if m==1
        n=1;
        xRange=[0,diff(tRange{n}([1,end]))]/sampleRate;
    else 
        n=2;
        if m==2
            xRange=[0,1500];
        else
            xRange=[1500,3000];
        end
    end
    
    subplot(nRow,1,1)
    hold on
    if ~isempty(tone{n})
        plot((tone{n}(:,1)-tRange{n}(1))/sampleRate,tone{n}(:,2)*0.8,'b-','linewidth',0.2)
    end
    plot((videoOnsets{n}-tRange{n}(1))/sampleRate,res{n}.freeze*0.4,'k-','linewidth',0.2)
    xlim(xRange)
    box off
    set(gca,'ytick',[])
    ylim([0,1])
    
    xlabel('Time (s)')
    ax=fixAxis;
    text2(1,1,{'\color[rgb]{1,0,0}Shock','\color[rgb]{0,0,1}Tone','\color[rgb]{0,0,0}Freeze'},ax,...
            {'horizontalAlign','left','verticalAlign','top'})
        title(sesTitle{m})

    subplot(nRow,1,2)
    plot((tRange{n}-tRange{n}(1))/sampleRate,emg{n},'k-','linewidth',0.2)
    xlabel('Time (s)')
    ylabel('EMG (A.U.)')
    xlim(xRange)
    box off

    subplot(nRow,1,3)
    plot((tRange{n}-tRange{n}(1))/sampleRate,sum(acc{n}.^2,1).^0.5,'k-','linewidth',0.2)
    xlabel('Time (s)')
    ylabel('Acceleration (A.U.)')
    xlim(xRange)
    box off

    titleList={'Deep (Amy?)','Superficial (M1?)','Frontal (PFC?)','Screw (Ant)','Screw (Mid)','Screw (Post)'}
    logF=logspace(log10(0.5),2,30)
    for k=1:6
        subplot(nRow,1,3+k)
        
        temp=interp1(f{n},log(squeeze(Pxx{n}(:,:,k)))',logF)';

        
        imagescXY(t{n},log10(logF),temp)
        yTickPos=[1,3,10,30,100];
        set(gca,'ytick',log10(yTickPos),'yticklabel',yTickPos)
        box off
        colormap(jet)
        xlabel('Time (s)')
        ylabel('Hz')
        title(titleList{k})
        xlim(xRange)
        set(gca,'clim',[3,11])
    end
    addScriptName(mfilename);

    print(fh,[saveDir 'eyelid_retention_behavior.ps'],'-dpsc','-r300',doAppend)
    doAppend='-append';

end

%%


            
            
            


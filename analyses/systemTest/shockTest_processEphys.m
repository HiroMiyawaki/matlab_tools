clear

sumFile='/Volumes/RAID_HDD/data/OCU/Chamber_shockTest/shockSummary.ps';

ephysDir='/Volumes/RAID_HDD/data/OCU/Chamber_shockTest/shock_test/openephys_2017-03-17_13-18-49/';
saveDir='/Volumes/RAID_HDD/data/OCU/Chamber_shockTest/shock_test/';
nameBase='shockTest';

data=[];
for ch=1:32
    fileName=[ephysDir '110_CH' num2str(ch) '.continuous'];
    [data(ch,:), timestamps, info]=load_open_ephys_data_faster(fileName);
end

[evt, evtTime, evtInfo] =load_open_ephys_data_faster([ephysDir 'all_channels.events'])

timestamps=timestamps/info.header.sampleRate;
timestamps=timestamps-evtTime(1);


%%

% probeMap=repmat([1 3 5 7 8 6 4 2],1,4)+8*reshape(repmat(0:3,8,1),1,[])
proMap=[ 1  8  2  7  3  6  4  5  9 16 10 15 11 14 12 13 17 24 18 23 19 22 20 21 25 32 26 31 27 30 28 29];
conMap=[18 27 28 29 17 30 31 32  1  2  3 16  4  5  6 15 20 21 22 23 19 24 25 26  7  8  9 14 10 11 12 13];
ampMap=[ 8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23  7  6  5  4  3  2  1  0 31 30 29 28 27 26 25 24]+1;

ampMap(find(conMap==proMap(1)))


clear cMap
for sh=1:4
    for ch=1:8
    idx=8*(sh-1)+ch;
    pMap(sh,ch)=idx;
    
    cMap(sh,ch)=ampMap(find(conMap==proMap(idx)));

    end
end


linMap=(cMap');
linMap=linMap(:);
data=data(linMap,:);

% fh=fopen([saveDir nameBase '.dat'],'w');
% fwrite(fh, data, 'int16')
% fclose(fh)

%%

eNameList={'grab','tone','shock'};
for idx=0:2
    eName=eNameList{idx+1};
    onset=evtTime(evt==idx&evtInfo.eventId==1&evtInfo.eventType==3);
    offset=evtTime(evt==idx&evtInfo.eventId==0&evtInfo.eventType==3);

    ttl.(eName)=[onset,offset];
    
    temp=[onset,zeros(size(onset));
          offset,ones(size(offset))];
    pulse.(eName)=sortrows([temp;temp(:,1)+1/info.header.sampleRate,1-temp(:,2)]);
    
end

% MakeEvtFile(ttl.grab*20e3,[saveDir nameBase '.grb.evt'],{'onset','offset'},20e3)
% MakeEvtFile(ttl.tone*20e3,[saveDir nameBase '.ton.evt'],{'onset','offset'},20e3)
% MakeEvtFile(ttl.shock*20e3,[saveDir nameBase '.shk.evt'],{'onset','offset'},20e3)

%%
ch=16+(1:4);
tOffset=ttl.grab(1);
chOffset=1000;

wideRange=[580,640]+tOffset;

zoomRange{1}=[590,595]+tOffset; 
zoomRange{2}=[599,604]+tOffset; 
zoomRange{3}=[604,609]+tOffset;
zoomRange{4}=[628,633]+tOffset;



grab=[ttl.grab(:,1),zeros(size(ttl.grab(:,1)))
     ttl.grab(:,2),ones(size(ttl.grab(:,2)))];
 
grab=sortrows([grab;grab(:,1)+1/info.header.sampleRate,1-grab(:,2)])
 

close all
fh=initFig4JNeuro(2);

traceHeight=15;
pulseHeight=2;
innerY=4;
marginY=15;
xOrig=10;
yOrig=10;
width=150;
for idx=0:length(zoomRange);
    if idx==0
        tRange=wideRange;
        linewidth=0.1;
    else
        tRange=zoomRange{idx};
        linewidth=0.5;
    end
    first=find(timestamps<tRange(1),1,'last');
    last=find(timestamps>tRange(2),1,'first');
    
    totalGapX=0;
    totalGapY=(traceHeight+pulseHeight*2+innerY*2+marginY)*idx+(idx>0)*marginY*0.5;
    
    xPos=xOrig+totalGapX;
    
    for pIdx=0:1
        if pIdx==0;
            pName='grab'; 
        elseif pIdx==1; 
            pName='shock'; 
        else
            continue; 
        end
        
        yPos=yOrig+(innerY+pulseHeight)*pIdx+totalGapY;
        subplotInMM(xPos,yPos,width,pulseHeight,true)
        pFirst=find(pulse.(pName)(:,1)<tRange(1),1,'last');
        pLast=find(pulse.(pName)(:,1)>tRange(2),1,'first');
        plot(pulse.(pName)(pFirst:pLast,1)-tOffset,pulse.(pName)(pFirst:pLast,2),'k-','linewidth',linewidth)
        xlim(tRange-tOffset)
        ylim([0,1])
        ax=fixAxis;
        text2(0,1,['TTL:' pName],ax,{'horizontalAlign','left','verticalALign','bottom'}) 
        axis off
    end
    
    
    
    yPos=yOrig+2*(innerY+pulseHeight)+totalGapY;    
    subplotInMM(xPos,yPos,width,traceHeight,true)

    hold on
    for cIdx=1:length(ch)
        plot(timestamps(first:last)-tOffset,data(ch(cIdx),first:last)-chOffset*(cIdx-1),'k-','linewidth',linewidth)
    end
    xlim(tRange-tOffset)
    ylim([-6000,2000])        
    
    ylabel('LFP (\muV)')
    xlabel('Time (s)')
    
    ax=fixAxis;
    if idx==0
        for zIdx=1:length(zoomRange)
            rectangle('position',[zoomRange{zIdx}(1)-tOffset,ax(3),diff(zoomRange{zIdx}),diff(ax(3:4))],...
                'edgecolor','r','linewidth',1.5)
            text(mean(zoomRange{zIdx}-tOffset),ax(4),num2str(zIdx),'color','r','verticalALign','bottom','fontsize',10)
        end
        text2(-0.03,2,'Open ephys',ax,{'horizontalAlign','left','fontsize',12,'verticalALign','bottom'})
    else
        text2(-0.03,1.9,num2str(idx),ax,{'color','r','fontsize',10})
    end
end

% print(fh,'/Volumes/RAID_HDD/data/OCU/Chamber_shockTest/shockChamber_ttlTest.pdf','-dpdf','-r300')

addScriptName(mfilename);

% print(fh,sumFile,'-dpsc','-r300')

%%

ephysDir='/Volumes/RAID_HDD/data/OCU/Chamber_shockTest/amplipex/';
saveDir='/Volumes/RAID_HDD/data/OCU/Chamber_shockTest/amplipex/';
nameBase='shock_test5'
fh=fopen([ephysDir nameBase '.dat']);
data=fread(fh,[35,inf],'int16');
fclose(fh);

proMap=[ 1  8  2  7  3  6  4  5  9 16 10 15 11 14 12 13 17 24 18 23 19 22 20 21 25 32 26 31 27 30 28 29];
conMap=[18 27 28 29 17 30 31 32  1  2  3 16  4  5  6 15 20 21 22 23 19 24 25 26  7  8  9 14 10 11 12 13];
ampMap=[1:2:31 2:2:32];

ampMap(find(conMap==proMap(1)))


clear cMap
for sh=1:4
    for ch=1:8
    idx=8*(sh-1)+ch;
    pMap(sh,ch)=idx;
    
    cMap(sh,ch)=ampMap(find(conMap==proMap(idx)));

    end
end


linMap=(cMap');
linMap=linMap(:);
ttlRaw=data(33:35,:);
data=data(linMap,:);
data=data/2^15*5e6/400;
data=data-repmat(mean(data,2),1,size(data,2));
%%


eNameList={'grab','tone','shock'};
clear ttl
for idx=1:3
    eName=eNameList{idx};

    onset=find(diff(ttlRaw(idx,:))>5000);
    onset(find(diff(onset)<4)+1)=[];
    onset=onset'/20e3;

    offset=find(diff(ttlRaw(idx,:))<-5000);
    offset(find(diff(offset)<4))=[];
    offset=offset'/20e3;

    ttl.(eName)=[onset,offset];
    
    temp=[onset,zeros(size(onset));
          offset,ones(size(offset))];
    temp=sortrows([temp;temp(:,1)+1/20e3,1-temp(:,2)]); 
    temp=[0,0;temp;size(ttlRaw,2)/20e3,0];
    pulse.(eName)=temp;
end

% MakeEvtFile(ttl.grab*20e3,[saveDir nameBase '.grb.evt'],{'onset','offset'},20e3)
% MakeEvtFile(ttl.tone*20e3,[saveDir nameBase '.ton.evt'],{'onset','offset'},20e3)
% MakeEvtFile(ttl.shock*20e3,[saveDir nameBase '.shk.evt'],{'onset','offset'},20e3)

%%
ch=16+(1:4);
tOffset=0;
chOffset=1000;

wideRange=[55,140]+tOffset;
clear zoomRange
zoomRange{1}=[62,67]+tOffset; 
zoomRange{2}=[72,77]+tOffset; 
zoomRange{3}=[92,97]+tOffset; 
zoomRange{4}=[133,138]+tOffset; 

close all
fh=initFig4JNeuro(2);

traceHeight=15;
pulseHeight=2;
innerY=4;
marginY=15;
xOrig=10;
yOrig=10;
width=150;
for idx=0:length(zoomRange);
    if idx==0
        tRange=wideRange;
        linewidth=0.1;
    else
        tRange=zoomRange{idx};
        linewidth=0.5;
    end
    first=find(timestamps<tRange(1),1,'last');
    last=find(timestamps>tRange(2),1,'first');
    
    totalGapX=0;
    totalGapY=(traceHeight+pulseHeight*2+innerY*2+marginY)*idx+(idx>0)*marginY*0.5;
    
    xPos=xOrig+totalGapX;
    
    for pIdx=0:1
        if pIdx==0;
            pName='grab'; 
        elseif pIdx==1; 
            pName='shock'; 
        else
            continue; 
        end
        
        yPos=yOrig+(innerY+pulseHeight)*pIdx+totalGapY;
        subplotInMM(xPos,yPos,width,pulseHeight,true)
        pFirst=find(pulse.(pName)(:,1)<tRange(1),1,'last');
        pLast=find(pulse.(pName)(:,1)>tRange(2),1,'first');
        plot(pulse.(pName)(pFirst:pLast,1)-tOffset,pulse.(pName)(pFirst:pLast,2),'k-','linewidth',linewidth)
        xlim(tRange-tOffset)
        ylim([0,1])
        ax=fixAxis;
        text2(0,1,['TTL:' pName],ax,{'horizontalAlign','left','verticalALign','bottom'}) 
        axis off
    end
    
    
    
    yPos=yOrig+2*(innerY+pulseHeight)+totalGapY;    
    subplotInMM(xPos,yPos,width,traceHeight,true)

    hold on
    for cIdx=1:length(ch)
        plot(timestamps(first:last)-tOffset,data(ch(cIdx),first:last)-chOffset*(cIdx-1),'k-','linewidth',linewidth)
    end
    xlim(tRange-tOffset)
    ylim([-6000,2000])        
    
    ylabel('LFP (\muV)')
    xlabel('Time (s)')
    
    ax=fixAxis;
    if idx==0
        for zIdx=1:length(zoomRange)
            rectangle('position',[zoomRange{zIdx}(1)-tOffset,ax(3),diff(zoomRange{zIdx}),diff(ax(3:4))],...
                'edgecolor','r','linewidth',1.5)
            text(mean(zoomRange{zIdx}-tOffset),ax(4),num2str(zIdx),'color','r','verticalALign','bottom','fontsize',10)
        end
        text2(-0.03,2,'amplipex',ax,{'horizontalAlign','left','fontsize',12,'verticalALign','bottom'})
    else
        text2(-0.03,1.9,num2str(idx),ax,{'color','r','fontsize',10})
    end
end

addScriptName(mfilename);

% print(fh,sumFile,'-dpsc','-append','-r300')
vecSumFile='/Volumes/RAID_HDD/data/OCU/Chamber_shockTest/shockSummary_vector.pdf';


% print(fh,vecSumFile,'-dpdf','-painters')

%%
close all
ch=16+(1:4);
tOffset=0;
chOffset=1000;
fh=figure()
wideRange=[55,140]+tOffset;
clear zoomRange
zoomRange{1}=[62,67]+tOffset; 

first=find(timestamps<tRange(1),1,'last');
last=find(timestamps>tRange(2),1,'first');

tRange=zoomRange{1};


% temp=data-repmat(mean(data,1),size(data,1),1);
temp=data;
hold on
    for cIdx=1%:length(ch)
        plot(timestamps(first:last)-tOffset,temp(ch(cIdx),first:last)-chOffset*(cIdx-1),'k-','linewidth',linewidth)
    end
    xlim(tRange-tOffset)
%     ylim([-6000,2000])        
    
    ylabel('LFP (\muV)')
    xlabel('Time (s)')

vecSumFile='/Volumes/RAID_HDD/data/OCU/Chamber_shockTest/shockExample.pdf';


print(fh,vecSumFile,'-dpdf','-painters')













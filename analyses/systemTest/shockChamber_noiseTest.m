clear 

rootDir='/Volumes/RAID_HDD/data/OCU/Chamber_noiseTest';
ch=1;

dirList.homecage='homecage/openephys_2017-03-16_12-58-30';
dirList.separated='grid-base/openephys_2017-03-16_12-49-34';
dirList.bundled='grid-bandled/openephys_2017-03-16_12-51-07';
dirList.grounded='grid-granded/openephys_2017-03-16_12-51-40';
dirList.local='gridLocalGround/openephys_2017-03-17_11-19-43';
dirList.floor='floor/openephys_2017-03-16_12-59-48';

dList=fieldnames(dirList);

tStart.homecage=16;
tStart.separated=5;
tStart.bundled=5.1;
tStart.grounded=73;
tStart.local=16.5;
tStart.floor=17;
nSample=1024*64;

for dIdx=1:length(dList)
    dName=dList{dIdx};
    fileName=fullfile(rootDir,dirList.(dName),['110_CH' num2str(ch) '.continuous']);
    [data, timestamps, info]=load_open_ephys_data_faster(fileName);
    
    frame=tStart.(dName)*info.header.sampleRate+(0:nSample-1);
    
    lfp.(dName)=data(frame);
    t.(dName)=(timestamps(frame)-timestamps(frame(1)))/info.header.sampleRate;
end    

for dIdx=1:length(dList)
    dName=dList{dIdx};

    y=fft(lfp.(dName));
    len=length(lfp.(dName));
    pow2=abs(y/len);
    pow=pow2(1:len/2+1);
    pow(2:end-1)=2*pow(2:end-1);
    freq=20e3*(0:(len/2))/len;
    fMax=find(freq>150,1,'first');
    
    spec.(dName)=pow(1:fMax);
    f.(dName)=freq(1:fMax);
end
    

   
close all
fh=initFig4Nature(2);

origX=15;
origY=10;
marginY=13;
marginX=15;
innerGap=3;

traceWidth=120;
traceHight=10;

specWidth=30;
specHight=traceHight*2+innerGap;

tText.homecage='Homecage';
tText.separated='Chamber with grid, separated each other';
tText.bundled='Chamber with grid, bundled but not grounded';
tText.grounded='Chamber with grid, grounded to room ground';
tText.local='Chamber with grid, grounded to local ground';
tText.floor='Chamber with smooth floor';

for dIdx=1:length(dList)
    dName=dList{dIdx};
    
    totalGapY=(dIdx-1)*(traceHight*2+innerGap+marginY);
    totalGapX=0;
    
    xPos=origX+totalGapX;
    yPos=origY+totalGapY;     
    subplotInMM(xPos,yPos,traceWidth,traceHight,true)
    
    plot(t.(dName),lfp.(dName),'-k','linewidth',0.5)
    axis tight
    ylim(2000*[-1,1])
    box off
    hold on
    ax=fixAxis;
    rectangle('position',[1,ax(3),0.2,diff(ax(3:4))],'edgeColor','r')
%     xlabel('Time (s)')
    ylabel('LFP (\muV)')
    
    text2(-0.05,1.2,tText.(dName),ax,{'horizontalAlign','left','verticalAlign','bottom','fontsize',7})
    
    xPos=origX+totalGapX;
    yPos=origY+totalGapY+traceHight+innerGap;
    subplotInMM(xPos,yPos,traceWidth,traceHight,true)

    plot(t.(dName),lfp.(dName),'-k','linewidth',0.5)
    xlim([1,1.2])
    ylim(1200*[-1,1])
    box off
    xlabel('Time (s)')
    ylabel('LFP (\muV)')
    ax=fixAxis;
     
    if strcmpi(dName,'grounded')
        hold on
        xval=[1.012,1.028,1.044,1.058,1.072,1.087,1.102,1.119,1.133,1.147,1.163,1.177,1.193];
        plot(xval,interp1(t.(dName),lfp.(dName),xval)+diff(ax(3:4))*0.25,...
            'kv','MarkerFaceColor','k','markersize',4)
    end
    
    
    xPos=origX+totalGapX+traceWidth+marginY;
    yPos=origY+totalGapY;
    subplotInMM(xPos,yPos,specWidth,specHight,true)

    plot(f.(dName),spec.(dName),'k-','linewidth',0.5)
    set(gca,'yscale','log')
    axis tight
    box off
    xlabel('Frequency (Hz)')
    ylabel('PSD (\muV^2/Hz)')
    ax=fixAxis;
end
addScriptName(mfilename)
print(fh,[rootDir '/' 'shockChamber_nosieTest.pdf'],'-dpdf','-r300')


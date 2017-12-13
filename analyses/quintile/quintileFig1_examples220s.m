%%
clear
% baseDir='~/data/sleep/pooled/';
baseDir='~/data/sleep/pooled_withCohEMG/';
coreName='sleep';

varList={'basics'
    'behavior'
    'detailedBehavior'
    'MA'
    ...'ripple'
    ...'spindle'
    ...'hpcSpindlePhase'
    ...'ctxSpindlePhase'
    'HLfine'
    ...'LowExMa'
    ...'hpcSWA'
    ...'pfcSWA'
    ...'recStart'
    ...'position'
    ...'speed'
    ...'spectrum'
    'spikes'
    ...'modulatedCell'
    ...thetaPhase'
    ...'pfcEeg'
    ...'emg'
    ...'firing'
    ...'eventRate'
    'stableSleep20s'
    ...'stableWake'
    ...'stateChange'
    ...'trisecFiring'
    ...'binnedFiring'
    ...'thetaBand'
    ...'sleepPeriod'
    ...'recStart'
    ...'deltaBand'
    ...'thetaBand'
    ...'pairCorr'
    ...'pairCorrHIGH'
    }';

for varName=varList
    load([baseDir coreName '-' varName{1} '.mat'])
end

dList=fieldnames(basics);
HL=HLfine;

%%
close all
binSize=20e6;
nGrp=5;
windowSize=3*60;

fh=initFig4Nature(2);

width=160;
heightHyp=12;
heightFR=60;
origX=10;
origY=20;
marginY=13;
gapY=0;

basePyrCol=rgb2hsv([1,0.6,0]);

frCol=hsv2rgb([basePyrCol(1)*ones(nGrp,1),linspace(0.5,1,nGrp)',linspace(1,1,nGrp)']);
behCol=[0.5,0.5,1;
        0.7,0.7,1;
        1,0.5,0.5;
        1,0.7,0.7];


dName='RoySleep1';
tRange=(376.5+[0,120])*60e6+behavior.(dName).time(1);
% tRange=(500+[0,120])*60e6+behavior.(dName).time(1);


pyr=spikes.(dName)([spikes.(dName).quality]<4&cellfun(@all,{spikes.(dName).isStable}));    
grp=tiedrank([pyr.meanF],'descend');
grp=ceil(grp/length(grp)*nGrp);


tBin=tRange(1)-binSize*5/2:binSize:tRange(2)+binSize*5/2;

temp=cellfun(@(x) hist(x,tBin),{pyr.time},'uniformOutput',false);
rate=cat(1,temp{:})/binSize*1e6;

rate(:,1)=[];
rate(:,end)=[];
for idx=1:size(rate,1)
    rate(idx,:)=conv(rate(idx,:),ones(1,3)/3,'same');
end

clear meanF steF
for n=1:nGrp
    meanF(n,:)=mean(rate(grp==n,:));
    steF(n,:)=ste(rate(grp==n,:));
    nCell(n)=sum(grp==n)
end    

beh=behavior.(dName).list;
beh(beh(:,3)==4,3)=3;
beh=beh(beh(:,2)>tRange(1)&beh(:,1)<tRange(2),:);
if beh(1,1)<tRange(1); beh(1,1)=tRange(1); end
if beh(end,2)>tRange(2); beh(end,2)=tRange(2); end

beh(:,1:2)=(beh(:,1:2)-tRange(1))/60e6;
tBin=(tBin(2:end-1)-tRange(1))/60e6;



clf

xPos=origX;
yPos=origY;
subplotInMM(xPos,yPos,width,heightHyp,true);

clear xVal yVal
for idx=1:3
    xVal{idx}=[];
    yVal{idx}=idx+0.5*[-1,1];
end

for bIdx=1:size(beh,1)
    rectangle('position',[beh(bIdx,1),beh(bIdx,3)-0.5,diff(beh(bIdx,1:2)),1],...
            'facecolor',behCol(beh(bIdx,3),:),'linestyle','none');
        
    xVal{beh(bIdx,3)}(end+1,:)=beh(bIdx,1:2);        
end
xlim([0,diff(tRange)/60e6])
ylim([0.5,3.5])

text(0,1,'Non-REM','horizontalAlign','right')
text(0,2,'REM','horizontalAlign','right')
text(0,3,'Awake','horizontalAlign','right')
axis off

clear param
param.stateName={'Non-REM','REM','Awake'};
param.madeby=mfilename;

saveGraph('quantile20s2','g1a',...
        'rectangle',...
        xVal,... %x
        yVal,... %y
        '',... %error 
        behCol(1:3,:),... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename) 

subplotInMM(xPos,yPos+heightHyp+gapY,width,heightFR,true);

clear xVal yVal eVal
hold on
for gIdx=1:5
    plot(tBin,meanF(gIdx,:),'color',frCol(gIdx,:))
    xVal{gIdx}=tBin;
    yVal{gIdx}=meanF(gIdx,:);
    eVal{gIdx}=steF(gIdx,:);
end
xlabel('Time (min)')
xlim([0,diff(tRange)/60e6])
set(gca,'yscale','log')
ylabel('Mean FR (Hz)')
ylim([0.003,3])
box off

clear param
param.madeby=mfilename;
param.nCell=nCell;

saveGraph('quantile20s2','g1b',...
        'line',...
        xVal,... %x
        yVal,... %y
        eVal,... %error 
        frCol,... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        param,... %legend
        mfilename) 




















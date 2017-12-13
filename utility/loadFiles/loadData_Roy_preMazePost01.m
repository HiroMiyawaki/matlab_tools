clear
[xmlFile, xmlDir, loadFlag] = uigetfile( {'*.xml','xml file (*.xml)'; '*','any file (*)'}, 'select xml file');

[dir,fileName]=fileparts(fullfile(xmlDir,xmlFile));
fileBase =fullfile(dir,fileName);

load([fileBase '-basics.mat']); 

%% load recording setting and position
% basics = LoadXml(fileBase);
% basics.FileName = fileBase;
% basics.period = loadPeriods(basics.FileName);
% 
% dir='/Volumes/RAID_HDD/Roy/ncs/';
% nvts={'2012-04-05_20-54-04/VT1','2012-04-06_06-03-17/VT1','2012-04-06_09-49-59/VT1'};
% 
% tm= 0.3282
% tM= 0.7292
% 
% %tM = position.trackMax;
% %tm = position.trackMin;
% Position=LoadNvtMulti(dir,nvts,'I',basics.period,tM,tm);
% 
% position.origX=Position.x;
% position.origY=Position.y;
% position.t=Position.t;
% position.xMax=Position.xMax;
% position.yMax=Position.yMax;
% position.trackMin=Position.trackMin;
% position.trackMax=Position.trackMax;
% position.x=Position.normX;
% position.y=Position.normY;
% 
% basics.posSampleRate = Position.SamplingFrequency;
% 
% basics.Ch.CA1theta=[4,12];
% basics.Ch.ripple=[1:47,49:64];
% basics.Ch.CA1Shanks=1:8;
% 
% save([basics.FileName '-basics.mat'],'-v7.3','basics'); 
% save([basics.FileName '-position.mat'],'-v7.3','position'); 

load([fileBase '-basics.mat']); 
load([basics.FileName '-position.mat']); 
 
% makePosFile(basics.FileName,position.x*position.xMax,position.y*position.yMax)

clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

%% Add position information to fet files
% %
% % addXY2Fet(basics.FileName,position,basics.period,basics.posSampleRate,basics.SampleRate,[1:8]);    

%% Theta detection

% CheckEegStates_AutoRun(basics.Ch,basics.FileName,basics.nChannels,basics.lfpSampleRate)
% 
% theta=dlmread([basics.FileName '.theta.1']);
% theta=theta*1e3/basics.lfpSampleRate;
% save([basics.FileName,'-theta.mat'],'theta');
load([basics.FileName,'-theta.mat']);
clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe



%% Gamma detection

% [basics.Ch.Gamma,GammaChMedians] = BestGammaChannels(basics.FileName,basics.lfpSampleRate,basics.Ch,basics.nChannels,basics.SpkGrps);
% 
% save([basics.FileName '-basics.mat'],'-v7.3','basics'); 
% load([basics.FileName '-basics.mat']); 

% clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe


%% Ripple detection

% %ripple=rippleDetectionBasic(basics.lfpSampleRate,basics.nChannels,basics.FileName,[1:64],1);
% ripple=rippleDetectionBasic(basics.lfpSampleRate,basics.nChannels,basics.FileName,[1:64]);
% 
% save([basics.FileName '-ripple.mat'],'-v7.3','ripple')
% load([basics.FileName '-ripple.mat'],'ripple')
% 
% clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

%% Ripple and HFE detection by Hilbert transform
% [swr, hfe] = SWRdetectionHilbert(basics.lfpSampleRate,basics.nChannels,basics.FileName,basics.Ch.ripple);
% save([basics.FileName '-hfe.mat'],'-v7.3','swr','hfe')
load([basics.FileName '-hfe.mat'])
clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe



%% Run detection
%
% tempPos.t = position.t(position.t>=basics.period(2,1) & position.t <=basics.period(2,2));
% tempPos.x = position.x(position.t>=basics.period(2,1) & position.t <=basics.period(2,2));
% tempPos.y = position.y(position.t>=basics.period(2,1) & position.t <=basics.period(2,2));
% tempPos.xMax = position.xMax;
% tempPos.yMax = position.yMax;
% tempPos.trackMin = position.trackMin;
% tempPos.trackMax=position.trackMax;
% 
% Run = detectRun(tempPos,'I',100);
% run(1).period=Run.incomingX;
% run(1).name='incoming-All';
% run(2).period=Run.outgoingX;
% run(2).name='outgoing-All';
% save([basics.FileName '-run.mat'],'run'); 
load([basics.FileName '-run.mat']); 

clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

%% used for manual detection of error
%
% m=(position.t-position.t(1))/1e6/60;
% 
% plot(position.x,m,'k.-')
% hold on
% 
% temp=run(1).period(:,[1:3,5:15,17:22,24:86,88:end]);
% %temp=run(1).period;
% for n = 1:size(temp,2)
%     flag = (position.t>temp(1,n) & position.t<temp(2,n));
%     plot(position.x(flag),m(flag),'r.-')
% end
% 
% temp=run(2).period(:,[1:2,4:15,17:22,24:70,72:end]);
% %temp=run(2).period;
% for n = 1:size(temp,2)
%     flag = (position.t>temp(1,n) & position.t<temp(2,n));
%     plot(position.x(flag),m(flag),'b.-')
% end
% 
% 
% clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe
%% exclude error detection of run manually

% run(1).period = run(1).period(:,[1:3,5:15,17:22,24:86,88:end]);
% run(2).period = run(2).period(:,[1:2,4:15,17:22,24:70,72:end]);
% save([basics.FileName '-run.mat'],'run'); 
% load([basics.FileName '-run.mat']); 

%% set special runs

% run(3).period=run(1).period(:,1:10);
% run(3).name='incoming-1:10';
% run(4).period=run(2).period(:,1:10);
% run(4).name='outgoing-1:10';
% 
% run(5).period=run(1).period(:,11:20);
% run(5).name='incoming-11:20';
% run(6).period=run(2).period(:,11:20);
% run(6).name='outgoing-11:20';
% 
% run(7).period=run(1).period(:,21:50);
% run(7).name='incoming-21:50';
% run(8).period=run(2).period(:,21:50);
% run(8).name='outgoing-21:50';
% 
% run(9).period=run(1).period(:,51:85);
% run(9).name='incoming-51:85';
% run(10).period=run(2).period(:,51:85);
% run(10).name='outgoing-51:85';
% 
% 
% run(11).period=run(1).period(:,end-29:end);
% run(11).name='incoming-86:115';
% run(12).period=run(2).period(:,end-29:end);
% run(12).name='outgoing-86:115';
% 
% run(13).period=run(1).period(:,1:20);
% run(13).name='incoming-1:20';
% run(14).period=run(2).period(:,1:20);
% run(14).name='outgoing-1:20';
% run(15).period=run(1).period(:,21:end);
% run(15).name='incoming-21:115';
% run(16).period=run(2).period(:,21:end);
% run(16).name='outgoing-21:115';



% save([basics.FileName '-run.mat'],'run'); 
% load([basics.FileName '-run.mat']); 
% 
% clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

%% set trial numbers with block
% run(1).block=[1,20];
% run(2).block=[1,20];
% 
% save([basics.FileName '-run.mat'],'run'); 
% load([basics.FileName '-run.mat']); 
%
% clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe




%% load spikes

spikes = LoadSpike2(basics.FileName,[1:8],basics.SampleRate,basics.period);
save([basics.FileName '-spikes.mat'],'-v7.3','spikes'); 
load([basics.FileName '-spikes.mat']); 

%% add position and theta phase to spikes
eeg = readmulti([basics.FileName,'.eeg'],basics.nChannels, basics.Ch.CA1theta(1));
[ThetaPhase, ThetaAmp] = phaseDetection(eeg, [4,10],basics.lfpSampleRate,100);
eegTime = linspace(basics.period(1,1),basics.period(1,2),size(eeg,1));

for(n=1:size(spikes,2))
    spikes(n).x=interp1(position.t,position.x,spikes(n).time);
    spikes(n).y=interp1(position.t,position.y,spikes(n).time);
    spikes(n).tPhase=interp1(eegTime,ThetaPhase,spikes(n).time);
    spikes(n).tAmp=interp1(eegTime,ThetaAmp,spikes(n).time);
end
save([basics.FileName '-spikes.mat'],'-v7.3','spikes'); 
% load([basics.FileName '-spikes.mat']); 

clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta popbur swr hfe



%% detect poplation burst
pix2cm =(72*2.54/500 + 48*2.54/300)/2;

popbur = popBurDetection([spikes.time],position,pix2cm,basics.FileName);
save([basics.FileName '-popbur.mat'],'-v7.3','popbur'); 
%load([basics.FileName '-popbur.mat']); 
clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

%% set onTrack flags to spikes

for n = 1:length(spikes)
    for k=1:length(run)
        frame = run(k).period;
        frag = zeros(size(spikes(n).time));
        for m = 1:size(frame,2)
            frag=frag+m*(spikes(n).time>frame(1,m) & spikes(n).time<frame(2,m));
        end
        spikes(n).track(k,:) = frag;
    end
end

% save([basics.FileName '-spikes.mat'],'-v7.3','spikes'); 
% load([basics.FileName '-spikes.mat']); 

clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

%% set ripple flags to spikes
% 
% frame = [ripple(:,[1,3])*1e3+position.t(1)]';
% for n = 1:length(spikes)
%     frag = zeros(size(spikes(n).time));
%     for m = 1:size(frame,2)
%         frag=frag+m*(spikes(n).time>frame(1,m) & spikes(n).time<frame(2,m));
%     end
%     spikes(n).isRipple = frag;
% end
%
% save([basics.FileName '-spikes.mat'],'-v7.3','spikes'); 
% load([basics.FileName '-spikes.mat']); 
clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

%% set theta flags to spikes

frame = (theta*1e3+position.t(1))';
for n = 1:length(spikes)
    frag = zeros(size(spikes(n).time));
    for m = 1:size(frame,2)
        frag=frag+m*(spikes(n).time>frame(1,m) & spikes(n).time<frame(2,m));
    end
    spikes(n).isTheta = frag;
end

% save([basics.FileName '-spikes.mat'],'-v7.3','spikes'); 
% load([basics.FileName '-spikes.mat']); 
clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

%% set popbur flags to spikes
frame = [popbur(:,[1,3])*1e3+position.t(1)]';
for n = 1:length(spikes)
    frag = zeros(size(spikes(n).time));
    for m = 1:size(frame,2)
        frag=frag+m*(spikes(n).time>frame(1,m) & spikes(n).time<frame(2,m));
    end
    spikes(n).isPopbur = frag;
end

% save([basics.FileName '-spikes.mat'],'-v7.3','spikes'); 
% load([basics.FileName '-spikes.mat']); 

clearvars -except basics position ripple spikes run pmap omap smap cellType cellList swr hfe

%% set SWR and HFE flags to spikes

frame = [swr(:,[1,3])*1e3+position.t(1)]';
for n = 1:length(spikes)
    frag = zeros(size(spikes(n).time));
    for m = 1:size(frame,2)
        frag=frag+m*(spikes(n).time>frame(1,m) & spikes(n).time<frame(2,m));
    end
    spikes(n).isSWR = frag;
end


frame = [hfe(:,[1,3])*1e3+position.t(1)]';
for n = 1:length(spikes)
    frag = zeros(size(spikes(n).time));
    for m = 1:size(frame,2)
        frag=frag+m*(spikes(n).time>frame(1,m) & spikes(n).time<frame(2,m));
    end
    spikes(n).isHFE = frag;
end

% save([basics.FileName '-spikes.mat'],'-v7.3','spikes'); 
% load([basics.FileName '-spikes.mat']); 
% 
clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe



%% set run flags to spikes
allRun = [run(1).period,run(2).period;ones(1,size(run(1).period,2)),2*ones(1,size(run(2).period,2))]';
[temp,idx] = sort(allRun);
allRun = allRun(idx(:,1),:);
frame=allRun(:,1:2);
for n = 1:length(spikes)
    frag = zeros(size(spikes(n).time));
    direc = zeros(size(spikes(n).time));
    for m = 1:size(frame,1)
        temp = (spikes(n).time>frame(m,1) & spikes(n).time<frame(m,2));
        frag(temp)=m;
        direc(temp)=allRun(m,3);
    end
    spikes(n).isRun = frag;
    spikes(n).runDir=direc;
end

% save([basics.FileName '-spikes.mat'],'-v7.3','spikes'); 
% load([basics.FileName '-spikes.mat']); 
% 
clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe


%% add autocorrelogram 

for n=1:length(spikes)
    spikes(n).acg=CCG(spikes(n).time,ones(size(spikes(n).time)),1000,30,1e6);
end

save([basics.FileName '-spikes.mat'],'-v7.3','spikes');
% load([basics.FileName '-spikes.mat']); 
% 
clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

%% place fields

placebins = 200;
timebinsize = .01; % tbins in units of seconds;
fBeg=100;fEnd=length(position.t);

numofbins = round((position.t(fEnd)-position.t(fBeg))/1e6*(1/timebinsize));
xyt=binpos([position.x(fBeg:fEnd)',position.y(fBeg:fEnd)',position.t(fBeg:fEnd)'],numofbins);

pmap=struct;
omap=struct;
lim=struct;
for m=1:length(run)
    lim(m).frame = 1+floor((run(m).period-position.t(fBeg))/1e6/timebinsize);
    [omap(m).xyt,omap(m).edge] = trimXYT(xyt,lim(m).frame);
    omap(m).frame=[fBeg,fEnd];
    omap(m).timebinsize=timebinsize;
    omap(m).placebins=placebins;
end

for n = 1:length(spikes)
    %nspk=hist(spikes(n).time(spikes(n).isTheta>0),xyt(:,3));
    nspk=hist(spikes(n).time,xyt(:,3));
    nspk(1)=0;
    nspk(end)=0;

    for m=1:length(run)
        nspkp = trimNspk(nspk,lim(m).frame);
        [pmap(n,m).map2D,smap(n,m).map2D,omap(m).map2D]=PFClassic(omap(m).xyt(:,1:2),nspkp',0.02,omap(m).placebins,omap(m).timebinsize);
        [pmap(n,m).map1D,smap(n,m).map1D,omap(m).map1D]=PFClassic1D(omap(m).xyt(:,1),nspkp',0.01,omap(m).placebins,omap(m).timebinsize);
    end
end


save([basics.FileName '-pmap.mat'],'-v7.3','pmap','omap','smap');
%  load([basics.FileName '-pmap.mat']); 

clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

%% determine cell type

l=1; %left limit of the peak point
r=200; %right limit of the peak point

for n=1:length(spikes)
    for m=1:length(run)
        spikes(n).peakRate(m)=max(pmap(n,m).map1D(l:r));
        spikes(n).peakPoint(m)=l-1+find( pmap(n,m).map1D(l:r)==spikes(n).peakRate(m),1);
        spikes(n).avgRate(m)=sum(smap(n,m).map1D)/sum(omap(m).map1D);
    end
end

cellType{1}='place cell (direc 1)';
cellType{2}='place cell (direc 2)';
cellType{3}='place cell (both direc)';
cellType{4}='inter neuron';
cellType{5}='noise';
cellType{6}='no firing on track';

judgePeriod=[11,12];

for n=1:length(spikes)
    if(spikes(n).quality>8)
        spikes(n).type=5;
    elseif (spikes(n).avgRate(judgePeriod(1))>10 || spikes(n).avgRate(judgePeriod(2))>10)
        spikes(n).type=4;
    elseif(spikes(n).peakRate(judgePeriod(1))>3)
        if(spikes(n).peakRate(judgePeriod(2))>3)
            if(spikes(n).peakRate(judgePeriod(1))*0.5 > spikes(n).peakRate(judgePeriod(2)))
                spikes(n).type=1;        
            elseif(spikes(n).peakRate(judgePeriod(2))*0.5 > spikes(n).peakRate(judgePeriod(1)))
                spikes(n).type=2;
            else
                spikes(n).type=3;
            end
        else
            spikes(n).type=1;
        end
    elseif(spikes(n).peakRate(judgePeriod(2))>3)     
        spikes(n).type=2;
    else
        spikes(n).type=6;
    end
end

save([basics.FileName '-spikes.mat'],'-v7.3','spikes','cellType'); 
%load([basics.FileName '-spikes.mat']); 
clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

%% sort cells by the position of place field and make a list of cells
% 
% pc1 = find([spikes.type]==1&[spikes.quality]<4);
% pc2 = find([spikes.type]==2&[spikes.quality]<4);
% pc3 = find([spikes.type]==3&[spikes.quality]<4);
% inr = find([spikes.type]==4&[spikes.quality]<4);
% etc = find([spikes.type]==6&[spikes.quality]<4);
% 
% 
% temp = [spikes(pc1).peakPoint];
% temp = temp(1:length(run):length(temp));
% [temp,index]=sort(temp);
% pc1 = pc1(index);
% 
% temp = [spikes(pc2).peakPoint];
% temp = temp(2:length(run):length(temp));
% [temp,index]=sort(temp);
% pc2 = pc2(index);
% 
% clear temp
% for n=1:length(pc3)
%     if(spikes(pc3(n)).peakRate(3)>spikes(pc3(n)).peakRate(4))
%         temp(n) = spikes(pc3(n)).peakPoint(1);
%     else
%         temp(n) = spikes(pc3(n)).peakPoint(2);
%     end
% end 
% [temp,index]=sort(temp);
% pc3 = pc3(index);
% 
% 
% pc4=[pc1,pc3];
% temp = [spikes(pc4).peakPoint];
% temp = temp(1:length(run):length(temp));
% [temp,index]=sort(temp);
% pc4 = pc4(index);
% 
% pc5=[pc2,pc3];
% temp = [spikes(pc5).peakPoint];
% temp = temp(2:length(run):length(temp));
% [temp,index]=sort(temp);
% pc5 = pc5(index);
% 
% 
% 
% cellList(1).ids=pc1;
% cellList(1).type='place cell on direction 1';
% cellList(2).ids=pc2;
% cellList(2).type='place cell on direction 2';
% cellList(3).ids=pc3;
% cellList(3).type='place cell on both directions';
% cellList(4).ids=inr;
% cellList(4).type='interneurons';
% cellList(5).ids=etc;
% cellList(5).type='other cells';
% cellList(6).ids=pc4;
% cellList(6).type='place cell on direction 1 and on both directions';
% cellList(7).ids=pc5;
% cellList(7).type='place cell on direction 2 and on both directions';
% 
% save([basics.FileName '-spikes.mat'],'-v7.3','spikes','cellType','cellList'); 
% % load([basics.FileName '-spikes.mat']); 
% clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe



%% define place fields

 for n=1:size(pmap,1)
     for r=1:size(pmap,2)
        pmap(n,r).pf=[];
        [peak,pos]=max(pmap(n,r).map1D);
        if peak>3
            threshold = peak * 0.1;
            mask = pmap(n,r).map1D < threshold;
            left = mask(1:pos);
            right= mask(pos:end);

            pfMin=find(left==1);
            pfMax = find(right==1);
            
            if ~isempty(pfMax) && ~isempty(pfMin)
                pfMin = pfMin(end);
                pfMax = pos -1 + pfMax(1);
        
                leftPeak = max(pmap(n,r).map1D(1:pfMin));
                rightPeak = max(pmap(n,r).map1D(pfMax:end));
        
                if(leftPeak < 0.5 * peak && rightPeak < 0.5 * peak && pfMax - pfMin <100);        
                   pmap(n,r).pf=[pfMin,pfMax];
                end
            end
        end
    end
 end

save([basics.FileName '-pmap.mat'],'-v7.3','pmap','omap','smap');
%load([basics.FileName '-pmap.mat']); 
 
clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe

    
%% calculate PP within place Fields

for n = 1:size(spikes,2) 
    slope = zeros(size(run));
    offset = zeros(size(run));
    coeffcient = zeros(size(run));
    for r = 1: size(run,2)
        if ~isempty(pmap(n,r).pf)
            direction = mod(r+1,2)+1;
            idx = find(...
                spikes(n).runDir==direction & ...
                spikes(n).time >= run(r).period(1,1) & ...
                spikes(n).time <= run(r).period(2,end) &...
                spikes(n).x > pmap(n,r).pf(1)/200 & ...
                spikes(n).x < pmap(n,r).pf(2)/200 ...
                );
            [slope(r),offset(r),coeffcient(r)]=circularLinearRegression(spikes(n).x(idx),spikes(n).tPhase(idx));
        else
            slope(r)=NaN;
            offset(r)=NaN;
            coeffcient(r)=NaN;
        end
    end
    spikes(n).ppSlope=slope;
    spikes(n).ppOffset=offset;
    spikes(n).ppCoeffcient=coeffcient;
end
%save([basics.FileName '-spikes.mat'],'-v7.3','spikes','cellType','cellList'); 
% load([basics.FileName '-spikes.mat']); 
% 
 clearvars -except basics position ripple spikes run pmap omap smap cellType cellList theta swr hfe
% 

%% shuffling and determine threshold of significant circular correlation
phaseAll=[];posAll=[];spikeNum=[];
for n = 1:size(spikes,2)
    for r=11:12
        direction = mod(r+1,2)+1;
        if ~isempty( pmap(n,r).pf)
            idx = find(...
                spikes(n).runDir==direction & ...
                spikes(n).time >= run(r).period(1,1) & ...
                spikes(n).time <= run(r).period(2,end) &...
                spikes(n).x > pmap(n,r).pf(1)/200 & ...
                spikes(n).x < pmap(n,r).pf(2)/200 ...
                );
            phaseAll = [phaseAll,spikes(n).tPhase(idx)];
            posAll = [posAll,spikes(n).x(idx)];
            spikeNum=[spikeNum,length(idx)];
        end
    end
end

cofTh=zeros(1,50);
slpTh=zeros(1,50);
for n=1:50
    resampleNum = 1000;
    ppSlopeShuffle=zeros(1,resampleNum);
    ppCoeffcientShuffle=zeros(1,resampleNum);
    for cnt = 1:resampleNum
        num = spikeNum(floor(rand(1)*size(spikeNum,2)-eps)+1);
        idx1 = floor(rand(1,num)*size(phaseAll,2)-eps)+1;
        idx2 = floor(rand(1,num)*size(posAll,2)-eps)+1;
        [ppSlopeShuffle(cnt),o,ppCoeffcientShuffle(cnt)]=circularLinearRegression(posAll(idx1),phaseAll(idx2));
    end

    cofSort = sort(abs(ppCoeffcientShuffle));
    slpSort = sort(abs(ppSlopeShuffle));

    cofTh(n) = cofSort(floor(0.95*resampleNum+1+eps))
    slpTh(n) = slpSort(floor(0.95*resampleNum+1+eps));

    plot(cofSort*30,(1:resampleNum)/10)
    hold on
    plot(slpSort,(1:resampleNum)/10,'r-')
end

%%
selected(1).ids=[];
selected(2).ids=[];

for n=1:size(spikes,2)
    if spikes(n).ppCoeffcient(11) > mean(cofTh)
        selected(1).ids= [selected(1).ids,n];
    end
    
    if spikes(n).ppCoeffcient(12) < -mean(cofTh)
        selected(2).ids = [selected(2).ids,n];
    end

end
%%
selected(1).ids=[];
selected(2).ids=[];

for n=1:size(spikes,2)
    if ~isnan(spikes(n).ppCoeffcient(11))
        selected(1).ids= [selected(1).ids,n];
    end
    
    if ~isnan(spikes(n).ppCoeffcient(12))
        selected(2).ids = [selected(2).ids,n];
    end

end

%%
% 
% m=m+1;
% 
% direction=2;
% clf
% n=list(2+direction).id(m);
% subplot(2,1,1)
% plot(pmap(n,10+direction).map1D)
% xlim([0,200])
% 
% pval=max(pmap(n,10+direction).map1D);
% hold on
% plot([0,200],pval*[1;1]*[1,0.5,0.3,0.2,0.1],'-');
% 
% subplot(2,1,2)
% 
% idx = find(...
%     spikes(n).runDir==direction & ...
%     spikes(n).time >= run(10+direction).period(1,1) & ...
%     spikes(n).time <= run(10+direction).period(2,end)...
%     );
% plot(spikes(n).x,spikes(n).tPhase,'.')
% hold on
% plot(spikes(n).x,spikes(n).tPhase+2*pi,'.')
% idx = find(...
%     spikes(n).runDir==direction & ...
%     spikes(n).time >= run(10+direction).period(1,1) & ...
%     spikes(n).time <= run(10+direction).period(2,end) &...
%     spikes(n).x > pmap(n,10+direction).pf(1)/200 & ...
%     spikes(n).x < pmap(n,10+direction).pf(2)/200 ...
%     );
% plot(spikes(n).x(idx),spikes(n).tPhase(idx)+2*pi,'r.')
% plot(spikes(n).x(idx),spikes(n).tPhase(idx),'r.')
% title([spikes(n).ppCoeffcient(10+direction),spikes(n).ppSlope(10+direction)])
% xlim([0,1])
%% pick up good units
judgePeriod=[11,12];
% 
% temp= [cellList(1).ids([1,3,4,5,6,7,8,9,12,14,16,18,20,21,22]),...
%                   cellList(3).ids([5,6])];
% temp= [cellList(1).ids([1,3,4,5,6,7,8,9,12,14,16,18,20,21,22]),...
%                   cellList(3).ids([6])];

temp = selected(1).ids;

peaks = [spikes.peakPoint];
peaks = peaks(judgePeriod(1):size(run,2):size(peaks,2));
peaks = peaks(temp);


revPeaks = [spikes.peakRate];
revPeaks = revPeaks(judgePeriod(2):size(run,2):size(revPeaks,2));
revPeaks = revPeaks(temp);

Peaks = [spikes.peakRate];
Peaks = Peaks(judgePeriod(1):size(run,2):size(Peaks,2));
Peaks = Peaks(temp);


%temp =  temp((Peaks > revPeaks*2 | revPeaks <=3));

temp =  temp(peaks>45 & peaks<155 & (Peaks > revPeaks*2 | revPeaks <=3));

%temp =  temp(peaks>45 & peaks<155);
%temp =  temp(peaks<=45 | peaks>=155);

selected(1).ids=temp;              
              
% temp= [cellList(2).ids([3,9,10,12,16,17,18,19,21,22,25,26,27,28]),...
%                   cellList(3).ids([5,6,12])];
% 
%             
% temp= [cellList(2).ids([3,9,10,12,17,18,21,22,25,26,27,28]),...
%                   cellList(3).ids([6,12])];              

temp = selected(2).ids;

peaks = [spikes.peakPoint];
peaks = peaks(judgePeriod(2):size(run,2):size(peaks,2));
peaks = peaks(temp);

revPeaks = [spikes.peakRate];
revPeaks = revPeaks(judgePeriod(1):size(run,2):size(revPeaks,2));
revPeaks = revPeaks(temp);

Peaks = [spikes.peakRate];
Peaks = Peaks(judgePeriod(2):size(run,2):size(Peaks,2));
Peaks = Peaks(temp);

%temp =  temp((Peaks > revPeaks*2 | revPeaks <=3));

temp =  temp(peaks>45 & peaks<155 & (Peaks > revPeaks*2 | revPeaks <=3));

%temp =  temp(revPeaks <3);
%temp =  temp(peaks>45 & peaks<155 & revPeaks <3);
%temp =  temp(peaks<=45 | peaks>=155);

selected(2).ids=temp; 
              
              
              
temp = [spikes([selected(1).ids]).peakPoint];
temp = temp(judgePeriod(1):length(run):length(temp));
[temp,index]=sort(temp);
selected(1).ids = selected(1).ids(index);

temp = [spikes([selected(2).ids]).peakPoint];
temp = temp(judgePeriod(2):length(run):length(temp));
[temp,index]=sort(temp);
selected(2).ids = selected(2).ids(index);
% selected(1).ids=[cellList(6).ids];
% selected(2).ids=[cellList(7).ids];
% %
% 
% %%
% willdo{1}=[142,136,40,43,38,41];
% doing{1}=[116,133,42,20,15,24];
% done{1}=[120,145,12];
% 
% willdo{2}=[19,76,47,107,52];
% doing{2}=[139,20,138,150,84,143,86,125,50];
% done{2}=[117,24,12];
% 
% 
% selected(1).ids=[willdo{1},doing{1}];
% selected(2).ids=[willdo{2},doing{2}];
% 
% 
% temp = [spikes([selected(1).ids]).peakPoint];
% temp = temp(3:length(run):length(temp));
% [temp,index]=sort(temp);
% selected(1).ids = selected(1).ids(index);
% 
% temp = [spikes([selected(2).ids]).peakPoint];
% temp = temp(4:length(run):length(temp));
% [temp,index]=sort(temp);
% selected(2).ids = selected(2).ids(index);
% 
% %%
% willdo{1}=[142,136,40,43,38,41];
% doing{1}=[116,133,42,20,15];
% done{1}=[120,145,12];
% change{1}=[24];
% 
% willdo{2}=[19,76,47,107,52];
% doing{2}=[20,150,86,125];
% done{2}=[12,84];
% change{2}=[139,117,24,138,50,143];
% 
% selected(1).ids=[willdo{1},doing{1},change{1}];
% selected(2).ids=[willdo{2},doing{2},change{2}];
% % 
% % selected(1).ids=[willdo{1}];
% % selected(2).ids=[willdo{2}];
% % selected(1).ids=[doing{1}];
% % selected(2).ids=[doing{2}];
% % selected(1).ids=[done{1}];
% % selected(2).ids=[done{2}];
% % selected(1).ids=[change{1}];
% % selected(2).ids=[change{2}];
% 
% 
% temp = [spikes([selected(1).ids]).peakPoint];
% temp = temp(3:length(run):length(temp));
% [temp,index]=sort(temp);
% selected(1).ids = selected(1).ids(index);
% 
% temp = [spikes([selected(2).ids]).peakPoint];
% temp = temp(4:length(run):length(temp));
% [temp,index]=sort(temp);
% selected(2).ids = selected(2).ids(index);
% 
% clf
% for m=3:12
%     d=mod(m+1,2)+1;
%     col = jet(size(selected(d).ids,2));
%     subplot(6,2,m)
%     for n=size(selected(d).ids,2):-1:1
%         hold on
%         plot((1:200),pmap(selected(d).ids(n),m).map1D+n/5,'color',col(n,:),'linewidth',2);
%     end
%     grid()
%     ylim([0,30])
%     title(run(m).name)
% end    

%% calcurate CCG among good units
pcSpikes{1}=spikes([selected(1).ids]);
pcSpikes{2}=spikes([selected(2).ids]);

clear runSpk swrSpk runGrp swrGrp popSpk popGrp corr revSpk revGrp

for m=1:(size(run,2));
    runSpk{m}=[];
    runGrp{m}=[];
    revSpk{m}=[];
    revGrp{m}=[];
    
    swrSpk{m}=[];
    swrGrp{m}=[];
%     popSpk{m}=[];
%     popGrp{m}=[];
%     hfeSpk{m}=[];
%     hfeGrp{m}=[];
end

for m=1:2
    for n=1:size(pcSpikes{m},2)

        %if isempty(pmap(selected(m).ids(n),m).pf)
            
            temp=pcSpikes{m}(n).time(pcSpikes{m}(n).runDir==m&pcSpikes{m}(n).isTheta>0);
            
            if isempty(temp)
                runSpk{m}=[runSpk{m},0];
                runGrp{m}=[runGrp{m},n];
            else
                runSpk{m}=[runSpk{m},temp];
                runGrp{m}=[runGrp{m},n*ones(size(temp))];
            end
            
            temp=pcSpikes{m}(n).time(pcSpikes{m}(n).runDir==(mod(m,2)+1)&pcSpikes{m}(n).isTheta>0);
            
            if isempty(temp)             
                revSpk{m}=[revSpk{m},0];
                revGrp{m}=[revGrp{m},n];
            else
                revSpk{m}=[revSpk{m},temp];
                revGrp{m}=[revGrp{m},n*ones(size(temp))];
            end
            
%          else
%             temp=pcSpikes{m}(n).time(pcSpikes{m}(n).runDir==m&pcSpikes{m}(n).isTheta>0 & ...
%                 pcSpikes{m}(n).x > pmap(selected(m).ids(n),m).pf(1)/200 & pcSpikes{m}(n).x > pmap(selected(m).ids(n),m).pf(2)/200);    
%             
%              if isempty(temp)
%                 runSpk{m}=[runSpk{m},0];
%                 runGrp{m}=[runGrp{m},n];
%             else
%                 runSpk{m}=[runSpk{m},temp];
%                 runGrp{m}=[runGrp{m},n*ones(size(temp))];
%              end
%             
%            temp=pcSpikes{m}(n).time(pcSpikes{m}(n).runDir==(mod(m,2)+1)&pcSpikes{m}(n).isTheta>0 & ...
%                 pcSpikes{m}(n).x > pmap(selected(m).ids(n),m).pf(1)/200 & pcSpikes{m}(n).x > pmap(selected(m).ids(n),m).pf(2)/200);
%             if isempty(temp)
%                 
%                 revSpk{m}=[revSpk{m},0];
%                 revGrp{m}=[revGrp{m},n];
%             else
%                 revSpk{m}=[revSpk{m},temp];
%                 revGrp{m}=[revGrp{m},n*ones(size(temp))];
%             end
%         end
        
        

        
        swrSpk{m}=[swrSpk{m},pcSpikes{m}(n).time(pcSpikes{m}(n).isSWR>0)];
        swrGrp{m}=[swrGrp{m},n*ones(size(pcSpikes{m}(n).time(pcSpikes{m}(n).isSWR>0)))];
%         popSpk{cellSet}=[popSpk{cellSet},pcSpikes{cellSet}(n).time(pcSpikes{cellSet}(n).isPopbur>0)];
%         popGrp{cellSet}=[popGrp{cellSet},n*ones(size(pcSpikes{cellSet}(n).time(pcSpikes{cellSet}(n).isPopbur>0)))];
%         hfeSpk{cellSet}=[hfeSpk{cellSet},pcSpikes{cellSet}(n).time(pcSpikes{cellSet}(n).isHFE>0|pcSpikes{cellSet}(n).isSWR>0)];
%         hfeGrp{cellSet}=[hfeGrp{cellSet},n*ones(size(pcSpikes{cellSet}(n).time(pcSpikes{cellSet}(n).isHFE>0|pcSpikes{cellSet}(n).isSWR>0)))];
%         hfeSpk{m}=[hfeSpk{m},pcSpikes{m}(n).time(pcSpikes{m}(n).isHFE>0)];
%         hfeGrp{m}=[hfeGrp{m},n*ones(size(pcSpikes{m}(n).time(pcSpikes{m}(n).isHFE>0)))];
    end
end

for m=3:size(run,2)
    d=mod(m+1,2)+1;
    for n=1:size(pcSpikes{d},2)
     
        %if isempty(pmap(selected(d).ids(n),m).pf)
            
            temp = pcSpikes{d}(n).time(pcSpikes{d}(n).runDir==d & pcSpikes{d}(n).isTheta>0 & ...
                pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end));
            
            if isempty(temp)
                runSpk{m}=[runSpk{m},0];
                runGrp{m}=[runGrp{m},n];
            else
                runSpk{m}=[runSpk{m},temp];
                runGrp{m}=[runGrp{m},n*ones(size(temp))];
            end
            
            temp = pcSpikes{d}(n).time(pcSpikes{d}(n).runDir==(mod(d,2)+1)&pcSpikes{d}(n).isTheta>0 & ...
                pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end));
            
            if isempty(temp)
           
            revSpk{m}=[revSpk{m},0];
            revGrp{m}=[revGrp{m},n];
            else
                revSpk{m}=[revSpk{m},temp];
                revGrp{m}=[revGrp{m},n*ones(size(temp))];
            end
            
%         else
%             
%             temp = pcSpikes{d}(n).time(pcSpikes{d}(n).runDir==d&pcSpikes{d}(n).isTheta>0 & ...
%                 pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end)& ...
%                 pcSpikes{d}(n).x > pmap(selected(d).ids(n),m).pf(1)/200 & pcSpikes{d}(n).x > pmap(selected(d).ids(n),m).pf(2)/200);
%             
%             if isempty(temp)
%                 runSpk{m}=[runSpk{m},0];
%                 runGrp{m}=[runGrp{m},n];
%             else
%                 runSpk{m}=[runSpk{m},temp];
%                 runGrp{m}=[runGrp{m},n*ones(size(temp))];
%             end
%             
%             temp = pcSpikes{d}(n).time(pcSpikes{d}(n).runDir==(mod(d,2)+1)&pcSpikes{d}(n).isTheta>0 & ...
%                 pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end)& ...
%                 pcSpikes{d}(n).x > pmap(selected(d).ids(n),m).pf(1)/200 & pcSpikes{d}(n).x > pmap(selected(d).ids(n),m).pf(2)/200);
%             
%              if isempty(temp)
%            
%             revSpk{m}=[revSpk{m},0];
%             revGrp{m}=[revGrp{m},n];
%             else
%                 revSpk{m}=[revSpk{m},temp];
%                 revGrp{m}=[revGrp{m},n*ones(size(temp))];
%             end
%             
%             
%         end
        swrSpk{m}=[swrSpk{m},pcSpikes{d}(n).time(pcSpikes{d}(n).isSWR>0 & ...
                    pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end))];
        swrGrp{m}=[swrGrp{m},n*ones(size(pcSpikes{d}(n).time(pcSpikes{d}(n).isSWR>0 & ...
                    pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end))))];
%         popSpk{m}=[popSpk{m},pcSpikes{d}(n).time(pcSpikes{d}(n).isPopbur>0 & ...
%                     pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end))];
%         popGrp{m}=[popGrp{m},n*ones(size(pcSpikes{d}(n).time(pcSpikes{d}(n).isPopbur>0 & ...
%                     pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end))))];
%         hfeSpk{m}=[hfeSpk{m},pcSpikes{d}(n).time((pcSpikes{d}(n).isHFE>0 |pcSpikes{d}(n).isSWR>0)& ...
%                     pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end))];
%         hfeGrp{m}=[hfeGrp{m},n*ones(size(pcSpikes{d}(n).time((pcSpikes{d}(n).isHFE>0 |pcSpikes{d}(n).isSWR>0) & ...
%                     pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end))))];
%         hfeSpk{m}=[hfeSpk{m},pcSpikes{d}(n).time((pcSpikes{d}(n).isHFE>0 )& ...
%                     pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end))];
%         hfeGrp{m}=[hfeGrp{m},n*ones(size(pcSpikes{d}(n).time((pcSpikes{d}(n).isHFE>0) & ...
%                     pcSpikes{d}(n).time >= run(m).period(1,1)& pcSpikes{d}(n).time <= run(m).period(end,end))))];
    end
end

clear corr
for m=1:size(runSpk,2)
    [corr(m,1).ccg,corr(m,1).t]=CCG(runSpk{m},runGrp{m}, 2000,2000,1e6,'count');
    corr(m,1).name=run(m).name;
    corr(m,1).ids=[selected(mod(m+1,2)+1).ids];
    
    [corr(m,2).ccg,corr(m,2).t]=CCG(swrSpk{m},swrGrp{m}, 2000,2000,1e6,'count');
    corr(m,2).name=[run(m).name,'-during swr'];
    corr(m,2).ids=[selected(mod(m+1,2)+1).ids];
    
    [corr(m,3).ccg,corr(m,3).t]=CCG(revSpk{m},revGrp{m}, 2000,2000,1e6,'count');
    corr(m,3).name=[run(m).name,'-reverse'];
    corr(m,3).ids=[selected(mod(m+1,2)+1).ids];
%     [corr(m,3).ccg,corr(m,3).t]=CCG(popSpk{m},popGrp{m}, 2000,2000,1e6,'count');
%     corr(m,3).name=[run(m).name,'-during popBur'];
%     corr(m,3).ids=[selected(mod(m+1,2)+1).ids];
%     [corr(m,4).ccg,corr(m,4).t]=CCG(hfeSpk{m},hfeGrp{m}, 2000,2000,1e6,'count');
%     corr(m,4).name=[run(m).name,'-during hfe'];
%     corr(m,4).ids=[selected(mod(m+1,2)+1).ids];
end

sigma = 5; %in ms
gaussNarrow = exp(-(-2000:2:2000).^2/(2*sigma^2))/(sigma*(2*pi)^0.5);
sigma = 250; %in ms
gaussWide = exp(-(-2000:2:2000).^2/(2*sigma^2))/(sigma*(2*pi)^0.5);

for m=1:size(corr,1)
    for p=1:size(corr,2)
        for n = 1:size(corr(m,p).ccg,2)
            for k = 1:size(corr(m,p).ccg,3)
                filNarrow = conv(gaussNarrow, corr(m,p).ccg(:,n,k));
                filWide = conv(gaussWide, corr(m,p).ccg(:,n,k));
                corr(m,p).nFil(:,n,k)=filNarrow(1001:(end-1000));
                corr(m,p).wFil(:,n,k)=filWide(1001:(end-1000));
            end
        end
    end
end

for m=1:size(corr,1)
    for p=1:size(corr,2)
        for n = 1:size(pcSpikes{mod(m+1,2)+1},2)
            for k = 1:size(pcSpikes{mod(m+1,2)+1},2)
                corr(m,p).pfDiff(n,k)=pcSpikes{mod(m+1,2)+1}(n).peakPoint(m) - pcSpikes{mod(m+1,2)+1}(k).peakPoint(m) ;
            end
        end
    end
end

%save([basics.FileName '-ccg.mat'],'-v7.3','corr'); 
%load([basics.FileName '-ccg.mat']); 

%% make .n.clu and .n.fet of good units (sorted by place field)
% pcSpikes{1}=spikes([selected(1).ids]);
% pcSpikes{2}=spikes([selected(2).ids]);
% 
% for m=1:2
%     spkFrame{m}=[];
%     spkGrp{m}=[];
%     peakPos{m}=[];
%     for n=1:size(pcSpikes{m},2)
%         spkFrame{m}=[spkFrame{m},pcSpikes{m}(n).frame];    
%         spkGrp{m}=[spkGrp{m},n*ones(size(pcSpikes{m}(n).frame))]; 
%         peakPos{m}(n) = pcSpikes{m}(n).peakPoint(6-mod(m,2));
% 
%     end
%     mkCluFet(spkFrame{m},spkGrp{m},peakPos{m},basics.FileName,m+2)
% end






     
     
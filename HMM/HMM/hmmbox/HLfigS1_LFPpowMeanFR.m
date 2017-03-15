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
    ...'HLfine'
    ...'onOff'
    ...'hpcSWA'
    ...'pfcSWA'
    ...'recStart'
    ...'position'
    ...'speed'
    ...'spectrum'
    ...'spikes'
    'FRinSlidingWindow'
    ...'modulatedCell'
    ...thetaPhase'
    ...'pfcEeg'
    ...'emg'
    'firing'
    ...'eventRate'
    ...'eventFiring'
    ...'stableSleep'
    ...'stableWake'
    'stateChange'
    ...'firing1secBin'
    ...'trisecFiring'
    ...'trisecEvent'
    ...'binnedFiring'
    ...'thetaBand'
    ...'recStart'
    ...'deltaBand'
    ...'thetaBand'
    }';

for varName=varList
    load([baseDir coreName '-' varName{1} '.mat'])
end
dList=fieldnames(basics);
%HL=HLfine;

%%
psFileName='~/Dropbox/LOW/preliminary/LFPpow_meanFR.pdf';

fh=initFig4Nature(2)
%%
for dIdx=1:length(dList);
    dName=dList{dIdx};
    display([datestr(now) ' ' dName])

    lfp=load([basics.(dName).filename '-fineEegSpec.mat']);

    
    fst=find( lfp.t<behavior.(dName).time(1),1,'last');
    if ~isempty(fst)
        lfp.Pxx(1:fst,:)=[];
        lfp.t(1:fst)=[];
    end
    
    lst=find(lfp.t>behavior.(dName).time(2),1,'first');
    if ~isempty(lst)
        lfp.Pxx(lst:end,:)=[];
        lfp.t(lst:end)=[];
    end    
    
    %%
    behId=FRinSlidingWindow.(dName).behType;

    %%
    fRange=[5,50];
    [a,b]=findRange(lfp.f,fRange);
    fIdx=a:b;

    pow=mean(lfp.Pxx(:,fIdx),2);
    powZ=log(pow);
%     powZ=pow;
    powZ(isinf(powZ))=NaN;
    powZ=(powZ-nanmean(powZ))/nanstd(powZ);
    %%

    fRange=[4,8];
    [a,b]=findRange(lfp.f,fRange);

    inTheta=log(mean(lfp.Pxx(:,a:b),2));


    fRange=[1,3];
    [a,b]=findRange(lfp.f,fRange);
    fRange=[9,12];
    [c,d]=findRange(lfp.f,fRange);
    outTheta=log(mean([lfp.Pxx(:,a:b),lfp.Pxx(:,c:d)],2));

    thetaRatio=inTheta-outTheta;

    %%
    frZ=mean(FRinSlidingWindow.(dName).percent(FRinSlidingWindow.(dName).cellType==1,:),1);

    % temp=zscore(FRinSlidingWindow.(dName).rate(FRinSlidingWindow.(dName).cellType==1,:));
    % 
    % frZ=mean(,1);

    %%
    slpIdx=find(behId<3);

    % idx=randperm(length(slpIdx),30000);
    % showIdx=slpIdx(idx)
    showIdx=slpIdx;

    col=[0.5,0.5,1.0;
         0.6,0.0,0.6;
         0.6,0.6,0.0];

    subplot(5,4,dIdx)
    % scatter3(log(pow(showIdx)),frZ(showIdx),thetaRatio(showIdx),1,col(behId(showIdx),:),'filled')
    scatter((powZ(showIdx)),frZ(showIdx),1,col(behId(showIdx),:),'filled')
    xlabel('Log power in 5-50Hz (z)')
    ylabel('Mean FR (%)')
    zlabel('Theta ratio')
    title(getDispName(dName))
    if strcmp(dName,'KevinRest0')
        ylim([0,1000])
    end

end
addScriptName(mfilename);

print(fh,psFileName,'-dpdf')







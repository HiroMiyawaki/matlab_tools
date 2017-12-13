clear
% baseDir='/Volumes/RAID_HDD/sleep/pooled/';
% baseDir='~/data/sleep/pooled/';
baseDir='~/data/sleep/pooled_withCohEMG/';
coreName='sleep';

varList={'basics'
    'behavior'
    ...'ripple'
    ...'spindle'
    ...'hpcSpindlePhase'
    ...'ctxSpindlePhase'
    ...'HL'
    ...'HLwavelet'
    'HLfine'
    ...'onOff'
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
    'firing'
    ...'eventRate'
    ...'stableSleep'
    ...'stableWake'
    'stateChange20s'
    ...'trisecFiring'
    ...'binnedFiring'
    ...'thetaBand'
    ...'sleepPeriod'
    ...'recStart'
    ...'deltaBand'
    ...'thetaBand'
    ...'pairCorr'
    ...'pairCorrHIGH'
    'timeNormFR'
    }';

for varName=varList
    load([baseDir coreName '-' varName{1} '.mat'])
end

HL=HLfine;
dList=fieldnames(basics);

%%

state='nrem2rem2nrem';
display([datestr(now) ' started ' state])
clear fr
fr=[];
for dIdx=1:length(dList)
    dName=dList{dIdx};
    idx=stateChange.(dName).nrem2rem2nrem;
    
    fr=[fr;[firing.(dName).pyr.rate{idx(:,1)}]',[firing.(dName).pyr.rate{idx(:,2)}]',[firing.(dName).pyr.rate{idx(:,3)}]'];
end


logFR=fr;
logFR(logFR==0)=1e-3;
logFR=log10(logFR);


frBin=-3:0.075:1
close all
fh=initFig4Nature(2)
for n=1:2
    subplot(4,3,n)
    cnt=hist2(logFR(:,[1,n+1]),frBin,frBin);
    rate=conv2(cnt,[0 1 0;1 1 1;0 1 0]/5,'same')/sum(cnt(:))*100;

    r=corr(logFR(:,1),logFR(:,n+1));
    rho=corr(logFR(:,1),logFR(:,n+1),'type','spearman');
    
    a=polyfit(logFR(:,1),logFR(:,n+1),1);
    
    
    imagescXY(frBin,frBin,rate)
    set(gca,'clim',[0,1])

    hold on
    plot(frBin([1,end]),polyval(a,frBin([1,end])),'color',0.99*[1,1,1])
    plot(frBin([1,end]),frBin([1,end]),'--','color',0.99*[1,1,1])
    
    set(gca,'XTick',-3:1,'XTickLabel',{'>0.001',10.^(-2:1)})
    set(gca,'YTick',-3:1,'YTickLabel',{'>0.001',10.^(-2:1)})
    xlabel('FR_{NREM1} (Hz)')
    
    if n==1
        ylabel('FR_{REM} (Hz)')
        title('NREM1 vs REM in NREM-REM-NREM triplets')

    else
        ylabel('FR_{NREM2} (Hz)')
        title('NREM1 vs NREM2 in NREM-REM-NREM triplets')
    end
    text(-2.9,1,sprintf('Pearson''s r = %0.2f\nSpearman''s \\rho = %0.2f',r,rho),'color',0.99*[1,1,1],'verticalAlign','top')
end

addScriptName(mfilename);

print(fh,'~/Dropbox/Quantile/preliminary/corr-triplets.pdf','-dpdf')




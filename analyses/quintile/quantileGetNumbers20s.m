%%
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
    ...'firing'
    ...'eventRate'
    ...'stableSleep'
    ...'stableWake'
    'stateChange20s'
    'trisecFiring'
    'exLowTrisecFiring'
    ...'trisecEvent'
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

HL=HLfine;
dList=fieldnames(basics);

%%
n.pyr=0;
n.inh=0;
for dIdx=1:length(dList)
    dName=dList{dIdx};
    n.pyr=n.pyr+size(trisecFiring.(dName).pyr.rate{1},1);
    n.inh=n.inh+size(trisecFiring.(dName).inh.rate{1},1);
end

%% changes within nrem
clear fr
fr.pyr=[];
fr.inh=[];
for dIdx=1:length(dList)
    dName=dList{dIdx};
    for type={'pyr','inh'}
        fr.(type{1})=[fr.(type{1});cat(1,trisecFiring.(dName).(type{1}).rate{stateChange.(dName).nrem})];
    end
end

for type={'pyr','inh'}
    mi.(type{1})=diff(fr.(type{1})(:,[1,3]),1,2)./sum(fr.(type{1})(:,[1,3]),2);
    p.(type{1})=signrank(mi.(type{1}))
    avg.(type{1})=nanmean(mi.(type{1}))
    err.(type{1})=nanste(mi.(type{1}))
end

%% changes within rem
clear fr
fr.pyr=[];
fr.inh=[];
for dIdx=1:length(dList)
    dName=dList{dIdx};
    for type={'pyr','inh'}
        fr.(type{1})=[fr.(type{1});cat(1,trisecFiring.(dName).(type{1}).rate{stateChange.(dName).rem})];
    end
end

for type={'pyr','inh'}
    mi.(type{1})=diff(fr.(type{1})(:,[1,3]),1,2)./sum(fr.(type{1})(:,[1,3]),2);
    p.(type{1})=signrank(mi.(type{1}))
    avg.(type{1})=nanmean(mi.(type{1}))
    err.(type{1})=nanste(mi.(type{1}))
end

%% changes on transiton from nrem to rem
clear fr
fr.pyr=[];
fr.inh=[];
for dIdx=1:length(dList)
    dName=dList{dIdx};
    for type={'pyr','inh'}
        fr.(type{1})=[fr.(type{1});
                        cat(1,trisecFiring.(dName).(type{1}).rate{stateChange.(dName).nrem2rem(:,1)}),...
                        cat(1,trisecFiring.(dName).(type{1}).rate{stateChange.(dName).nrem2rem(:,2)})];
    end
end

for type={'pyr','inh'}
    mi.(type{1})=diff(fr.(type{1})(:,[3,4]),1,2)./sum(fr.(type{1})(:,[3,4]),2);
    p.(type{1})=signrank(mi.(type{1}))
    avg.(type{1})=nanmean(mi.(type{1}))
    err.(type{1})=nanste(mi.(type{1}))
end

%% changes on transiton from nrem to rem
clear fr
fr.pyr=[];
fr.inh=[];
for dIdx=1:length(dList)
    dName=dList{dIdx};
    for type={'pyr','inh'}
        fr.(type{1})=[fr.(type{1});
                        cat(1,trisecFiring.(dName).(type{1}).rate{stateChange.(dName).rem2nrem(:,1)}),...
                        cat(1,trisecFiring.(dName).(type{1}).rate{stateChange.(dName).rem2nrem(:,2)})];
    end
end

for type={'pyr','inh'}
    mi.(type{1})=diff(fr.(type{1})(:,[3,4]),1,2)./sum(fr.(type{1})(:,[3,4]),2);
    p.(type{1})=signrank(mi.(type{1}))
    avg.(type{1})=nanmean(mi.(type{1}))
    err.(type{1})=nanste(mi.(type{1}))
end
%% changes within stable wake
clear fr
temp1=loadGraph('quantile20s4','a1');
fr=[cat(1,temp1.xValue{:}),cat(1,temp1.yValue{:})];
mi=diff(fr,1,2)./sum(fr,2)
avg=nanmean(mi)
err=nanste(mi)
p=signrank(mi)


%% changes on transiton from wake to nrem
clear fr
fr.pyr=[];
fr.inh=[];
for dIdx=1:length(dList)
    dName=dList{dIdx};
    for type={'pyr','inh'}
        fr.(type{1})=[fr.(type{1});
                        cat(1,trisecFiring.(dName).(type{1}).rate{stateChange.(dName).quiet2nrem(:,1)}),...
                        cat(1,trisecFiring.(dName).(type{1}).rate{stateChange.(dName).quiet2nrem(:,2)})];
    end
end

for type={'pyr','inh'}
    mi.(type{1})=diff(fr.(type{1})(:,[3,4]),1,2)./sum(fr.(type{1})(:,[3,4]),2);
    p.(type{1})=signrank(mi.(type{1}))
    avg.(type{1})=nanmean(mi.(type{1}))
    err.(type{1})=nanste(mi.(type{1}))
end

%%



%% zscore
indexLetter='b';
%within epochs
% % within wake
summaryPanels.(indexLetter){1}=loadGraph('quantile20s6','j4a');
% % within nrem
summaryPanels.(indexLetter){2}=loadGraph('quantile20s6',['a4a' postFix]);
% % within rem
summaryPanels.(indexLetter){3}=loadGraph('quantile20s6','b4a');

%across transition
% % wake to nrem
% panels.(indexLetter){4}=loadGraph('quantile20s6',['g4a' postFix]); %1/3 vs 1/3
summaryPanels.(indexLetter){4}=loadGraph('quantile20s6',['n4a' postFix]); % min vs 1/3
summaryPanels.(indexLetter){4}.title='Wake to non-REM';
% % nrem to rem
summaryPanels.(indexLetter){5}=loadGraph('quantile20s6',['c4a' postFix]);
% % rem to nrem
summaryPanels.(indexLetter){6}=loadGraph('quantile20s6',['d4a' postFix]);
% % nrem to wake
% panels.(indexLetter){7}=loadGraph('quantile20s6',['h4a' postFix]); %1/3 vs 1/3
summaryPanels.(indexLetter){7}=loadGraph('quantile20s6',['o4a' postFix]); % 1/3 vs min
% % rem to wake
% panels.(indexLetter){8}=loadGraph('quantile20s6','i4a'); %1/3 vs 1/3
summaryPanels.(indexLetter){8}=loadGraph('quantile20s6','p4a'); % 1/3 vs min

%across triplets
% % nrem/rem/nrem
% panels.(indexLetter){9}=loadGraph('quantile20s6',['e4a' postFix]);%1/3 vs 1/3
summaryPanels.(indexLetter){9}=loadGraph('quantile20s6',['q4a' postFix]); % mean vs mean
% % rem/nrem/rem
% panels.(indexLetter){10}=loadGraph('quantile20s6','f4a');%1/3 vs 1/3
summaryPanels.(indexLetter){10}=loadGraph('quantile20s6','r4a');% mean vs mean

%%
%% modulation index
indexLetter='a';
%within epochs
colNrem=hsv2rgb([2/3*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
% % within wake
summaryPanels.(indexLetter){1}=loadGraph('quantile20s4','a4a');
% temp=loadGraph('quantile20s4','a1');
% panels.(indexLetter){1}.title=temp.title;
summaryPanels.(indexLetter){1}.title='Within wake';
% % within nrem
if exLow
    summaryPanels.(indexLetter){2}=loadGraph('quantile20s5','b4a');
    summaryPanels.(indexLetter){2}.color=colNrem
%     temp=loadGraph('quantile20s5','b1');
%     panels.(indexLetter){2}.title=temp.title;
    summaryPanels.(indexLetter){2}.title=['Within non-REM'];
else
    summaryPanels.(indexLetter){2}=loadGraph('quantile20s2','a4a');
%     temp=loadGraph('quantile20s2','a1');
%     panels.(indexLetter){2}.title=temp.title;
    summaryPanels.(indexLetter){2}.title=['Within non-REM'];
end
% % within rem
summaryPanels.(indexLetter){3}=loadGraph('quantile20s2','b4a');
temp=loadGraph('quantile20s2','b1');
summaryPanels.(indexLetter){3}.title=temp.title;

%across transition
% % wake to nrem
% panels.(indexLetter){4}=loadGraph('quantile20s4',['b4a' postFix]); % 1/3 vs 1/3
summaryPanels.(indexLetter){4}=loadGraph('quantile20s4',['f4a' postFix]); % min vs 1/3
% temp=loadGraph('quantile20s4','b1');
% panels.(indexLetter){4}.title=temp.title;
summaryPanels.(indexLetter){4}.title='Wake to non-REM';
% % nrem to rem
summaryPanels.(indexLetter){5}=loadGraph('quantile20s3',['a4a' postFix]);
% temp=loadGraph('quantile20s3','a1');
% panels.(indexLetter){5}.title=temp.title;
summaryPanels.(indexLetter){5}.title='Non-REM to REM';
% % rem to nrem
summaryPanels.(indexLetter){6}=loadGraph('quantile20s3',['b4a' postFix]);
temp=loadGraph('quantile20s3','b1');
summaryPanels.(indexLetter){6}.title=temp.title;
% % nrem to wake
% panels.(indexLetter){7}=loadGraph('quantile20s4',['c4a' postFix]); % 1/3 vs 1/3
summaryPanels.(indexLetter){7}=loadGraph('quantile20s4',['g4a' postFix]); % 1/3 vs min
temp=loadGraph('quantile20s4','c1');
summaryPanels.(indexLetter){7}.title=temp.title;
% % rem to wake
% panels.(indexLetter){8}=loadGraph('quantile20s4','d4a'); % 1/3 vs 1/3
summaryPanels.(indexLetter){8}=loadGraph('quantile20s4',['h4a' postFix]); % 1/3 vs min
temp=loadGraph('quantile20s4','d1');
summaryPanels.(indexLetter){8}.title=temp.title;

%across triplets
% % nrem/rem/nrem
% panels.(indexLetter){9}=loadGraph('quantile20s3',['f4a' postFix]);% 1/3 vs 1/3
summaryPanels.(indexLetter){9}=loadGraph('quantile20s3',['h4a' postFix]);% mean vs mean
temp=loadGraph('quantile20s3','f1');
summaryPanels.(indexLetter){9}.title=temp.title;
% % rem/nrem/rem
% panels.(indexLetter){10}=loadGraph('quantile20s3','g4a');% 1/3 vs 1/3
summaryPanels.(indexLetter){10}=loadGraph('quantile20s3','i4a');% mean vs mean
temp=loadGraph('quantile20s3','g1');
summaryPanels.(indexLetter){10}.title=temp.title;

% % wake pre vs post sleep
summaryPanels.(indexLetter){11}=loadGraph('quantile20s4','i4a');% min vs min
% temp=loadGraph('quantile20s4','i1');
% summaryPanels.(indexLetter){11}.title=temp.title;
summaryPanels.(indexLetter){11}.title='Wake_i/sleep/wake_{i+1}';

for idx=1:length(summaryPanels.(indexLetter))
    summaryPanels.(indexLetter){idx}.info.YLim=[-1.1,0.5];
    summaryPanels.(indexLetter){idx}.info.YTick=-1.5:0.5:0.5;
    summaryPanels.(indexLetter){idx}.info.YTickLabel=summaryPanels.a{idx}.info.YTick;
end
measureType.(indexLetter)='Deflection index';

%% ANOVA, zscore, wake pre vs post sleep
temp1=loadGraph('quantile20s6','s2');
temp2=loadGraph('quantile20s6','s3a');

zs=temp1.legend.rawData;
dz=diff(zs,1,2);
ranking=tiedrank(zs(:,1))/size(zs,1);
shuffled=temp2.legend.shuffleMean;
di=[];grp=[];
for n=1:nDiv
    temp=dz(ranking>(n-1)/nDiv & ranking<=n/nDiv)-shuffled(n);    
    di=[di;temp];
    grp=[grp;n*ones(size(temp))];
end

[p,~,stats]=anova1(di,grp);
multcompare(stats);

%% ANOVA, DI, wake pre vs post sleep
temp1=loadGraph('quantile20s4','i1');
temp2=loadGraph('quantile20s4','i3a');
temp3=loadGraph('quantile20s4','i4a');

shuffled=temp2.legend.confInt(1,:)-temp3.legend.confInt(1,:);
di=[];grp=[];
for n=1:nDiv
    temp=temp1.yValue{n}-temp1.xValue{n}-shuffled(n);    
    di=[di;temp];
    grp=[grp;n*ones(size(temp1.yValue{n}))];
end

[p,~,stats]=anova1(di,grp);

multcompare(stats);

%%
clear
epochIdx=2;
for circadianIdx=1:4
    raw(circadianIdx)=loadGraph('quantile20sS2', [alphabet(epochIdx) '1' alphabet(circadianIdx)])
    ci(circadianIdx)=loadGraph('quantile20sS2', [alphabet(epochIdx) '3a' num2str(circadianIdx)])
end

gr1=[];
gr2=[];
di=[];
for circadianIdx=1:4
for populatinIdx=1:5
    fr=[raw(circadianIdx).xValue{populatinIdx},raw(circadianIdx).yValue{populatinIdx}];
    temp=(diff(fr,1,2)./sum(fr,2))-ci(circadianIdx).legend.shuffleMean(populatinIdx);
    
    temp(isnan(temp))=[];
    temp(isinf(temp))=[];
    
    gr1=[gr1;populatinIdx*ones(size(temp))];
    gr2=[gr2;circadianIdx*ones(size(temp))];
    di=[di;temp];
end
end

anovan(di,{gr1,gr2},'varnames',{'Quintile','Circadian'},'model',2)

%%
temp=loadGraph('quantile20s4', [alphabet(2) '1' ]);
fr=[cat(1,temp.xValue{:}),cat(1,temp.yValue{:})];
ci=diff(fr,1,2)./sum(fr,2)
nanmean(ci)
nanste(ci)

signrank(ci)








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
clear temFR
nDiv=5;
nShuffle=10;
% stateList={'nrem','rem','quiet2nrem','nrem2quiet','rem2quiet','rem2nrem','nrem2rem'};
stateList={'rem2nrem'};
funcCI=@(x) diff(x,1,2)./sum(x,2);

% orderList={'mean','onset','offset'};
% baseBin={[1,2],1,2};
clear cnt
cnt{1}=[];
cnt{2}=[];

for stateIdx=1:length(stateList)
    state=stateList{stateIdx};  
    display([datestr(now) ' started ' state])
    clear fr
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        targetIdx=stateChange.(dName).(state);

        fr(dIdx).pyr={};
        fr(dIdx).inh={};
        for tIdx=1:size(targetIdx,1)
            if size(targetIdx,2)==2
                if isempty(timeNormFR.(dName).offset.pyr{targetIdx(tIdx,1)})||...
                        isempty(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,2)})
                    continue
                end
                    fr(dIdx).pyr{end+1}=[timeNormFR.(dName).offset.pyr{targetIdx(tIdx,1)}(:,end),timeNormFR.(dName).onset.pyr{targetIdx(tIdx,2)}(:,1)];
                    fr(dIdx).inh{end+1}=[timeNormFR.(dName).offset.inh{targetIdx(tIdx,1)}(:,end),timeNormFR.(dName).onset.inh{targetIdx(tIdx,2)}(:,1)];                                                   
            elseif size(targetIdx,2)==1
                if isempty(timeNormFR.(dName).offset.pyr{targetIdx(tIdx)})
                     continue
                end

                fr(dIdx).pyr{end+1}=timeNormFR.(dName).offset.pyr{targetIdx(tIdx)}(:,[1,end]);
                fr(dIdx).inh{end+1}=timeNormFR.(dName).offset.inh{targetIdx(tIdx)}(:,[1,end]);        

            else
                continue
            end
        end
    end

    for shIdx=1:nShuffle
%         if mod(shIdx,100)==0        
%             display(['   ' datestr(now) ' shuffling ' num2str(shIdx) '/' num2str(nShuffle)])
%         end
          
        shuffleTypeList={'allFirst','allLast','flip','adjacentFirst','adjacentLast'};
        
        for shTypeIdx=1:length(shuffleTypeList)
            shName=shuffleTypeList{shTypeIdx};

            for cTypeIdx=1:2
                switch cTypeIdx
                    case 1
                        cType='pyr';
                    case 2
                        cType='inh';
                    otherwise
                        continue
                end
                temFR.(cType).(shName){shIdx}=[];

                for dIdx=1:length(fr)
                    if length(fr(dIdx).pyr)<2
                        continue
                    end
                    for tIdx=1:length(fr(dIdx).(cType))
                        if isempty(fr(dIdx).(cType){tIdx})
%                             disp('skip')
                            continue
                        end
                        if shIdx>1
                            %do shuffling
                            
                            switch shName
                                case 'allFirst'
                                    surIdx=randi(length(fr(dIdx).pyr)-1,1);
                                    if surIdx>=tIdx;surIdx=surIdx+1; end
                                        
                                    temp=[fr(dIdx).(cType){tIdx}(:,1),fr(dIdx).(cType){surIdx}(:,1)];
                                    flipIdx=randi(2,size(temp,1),1)-1;
                                    flipIdx=[flipIdx,1-flipIdx]*size(flipIdx,1)+(1:size(flipIdx,1))';
                                    temp=temp(flipIdx);
                                case 'allLast'
                                    surIdx=randi(length(fr(dIdx).pyr)-1,1);
                                    if surIdx>=tIdx;surIdx=surIdx+1; end

                                    temp=[fr(dIdx).(cType){tIdx}(:,2),fr(dIdx).(cType){surIdx}(:,2)];
                                    flipIdx=randi(2,size(temp,1),1)-1;
                                    flipIdx=[flipIdx,1-flipIdx]*size(flipIdx,1)+(1:size(flipIdx,1))';
                                    temp=temp(flipIdx);
                                case 'flip'
                                    temp=fr(dIdx).(cType){tIdx};
                                    flipIdx=randi(2,size(temp,1),1)-1;
                                    flipIdx=[flipIdx,1-flipIdx]*size(flipIdx,1)+(1:size(flipIdx,1))';
                                    temp=temp(flipIdx);
                                case 'adjacentFirst'
                                    if tIdx==1
                                        surIdx=tIdx+1;
                                    elseif tIdx==length(fr(dIdx).(cType))
                                        surIdx=tIdx-1;
                                    else
                                        surIdx=tIdx+2*(rand>0.5)-1;
                                    end
                                    temp=[fr(dIdx).(cType){tIdx}(:,1),fr(dIdx).(cType){surIdx}(:,1)];
                                    flipIdx=randi(2,size(temp,1),1)-1;
                                    flipIdx=[flipIdx,1-flipIdx]*size(flipIdx,1)+(1:size(flipIdx,1))';
                                    temp=temp(flipIdx);
                                        
                                case 'adjacentLast'
                                    if tIdx==1
                                        surIdx=tIdx+1;
                                    elseif tIdx==length(fr(dIdx).(cType))
                                        surIdx=tIdx-1;
                                    else
                                        surIdx=tIdx+2*(rand>0.5)-1;
                                    end
                                    temp=[fr(dIdx).(cType){tIdx}(:,2),fr(dIdx).(cType){surIdx}(:,2)];
                                    flipIdx=randi(2,size(temp,1),1)-1;
                                    flipIdx=[flipIdx,1-flipIdx]*size(flipIdx,1)+(1:size(flipIdx,1))';
                                    temp=temp(flipIdx);  
                                otherwise
                                    disp('ERROR')
                                    continue
                            end

                        else
                            temp=fr(dIdx).(cType){tIdx};
                        end

                        temFR.(cType).(shName){shIdx}=[temFR.(cType).(shName){shIdx};temp];
                    end
                end
            end
        end
    end
end

%%
shuffleTypeList={'flip','allFirst','allLast','adjacentFirst','adjacentLast'};

tText.flip='Old method';
tText.allFirst='New method - first bin';
tText.allLast='New method - last bin';

tText.adjacentFirst='Adjacent only - first bin';
tText.adjacentLast='Adjacent only - last bin';

logFbin=-2:0.05:1.2;

close all
fh=initFig4Nature(2);
for shTypeIdx=0:length(shuffleTypeList)
    if shTypeIdx==0
        shName=shuffleTypeList{1};
        nExample=1;
    else
        shName=shuffleTypeList{shTypeIdx};
        nExample=6;
    end
    
    for n=1:nExample
        subplot2(7,5,n+(shTypeIdx>0),shTypeIdx+(shTypeIdx==0))
        if shTypeIdx==0
            temp=temFR.pyr.(shName){1}
        else
            temp=temFR.pyr.(shName){n+1};
        end
        
        tempExZero=temp;
        tempExZero(any(tempExZero==0,2),:)=[];
        tempExZero=log10(tempExZero);
        
        temp(temp==0)=1e-2;
        temp=log10(temp);
        r=corr(temp(:,1),temp(:,2));
        rho=corr(temp(:,1),temp(:,2),'type','spearman');
        
        rExZero=corr(tempExZero(:,1),tempExZero(:,2));
        rhoExZero=corr(tempExZero(:,1),tempExZero(:,2),'type','spearman');

        cnt=hist2(temp,logFbin,logFbin);
        cnt=cnt/sum(cnt(:))*100;
        cnt=conv2(cnt,[0,1,0;1,1,1;0,1,0]/5,'same');
        imagescXY(logFbin,logFbin,cnt);
        plotIdentityLine(gca,{'color','r'})
        set(gca,'clim',[0,0.08])
        set(gca,'xtick',-2:1,'XTickLabel',{'<0.01',10.^(-1:1)})
        set(gca,'ytick',-2:1,'yTickLabel',{'<0.01',10.^(-1:1)})
        xlabel('FR_{REM} (Hz)')
        ylabel('FR_{NREM} (Hz)')
        text(-1.9,1,sprintf('w/o zero-F\nr=%0.3f,\\rho=%0.3f\n\nw/ zero-F\nr=%0.3f\\rho=%0.3f',rExZero,rhoExZero,r,rho),'horizontalALign','left','verticalAlign','top','color',0.99*[1,1,1])
        if n==1
            if shTypeIdx==0
                title({'REM-NREM transition','Real Data'})
            else
                title(tText.(shName))
            end
        end
    end
end

addScriptName(mfilename);

print(fh,'~/Dropbox/Quantile/preliminary/shuffle-compare.pdf','-dpdf','-painters')






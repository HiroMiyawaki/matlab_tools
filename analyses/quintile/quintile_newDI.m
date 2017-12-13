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

nDiv=5;
nShuffle=2000;
stateList={'nrem','rem','quiet2nrem','nrem2quiet','rem2quiet','rem2nrem','nrem2rem'};
funcCI=@(x) diff(x,1,2)./sum(x,2);

orderList={'mean','onset','offset'};
baseBin={[1,2],1,2};

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

    for shIdx=1:nShuffle+1
        if mod(shIdx,100)==0        
            display(['   ' datestr(now) ' shuffling ' num2str(shIdx) '/' num2str(nShuffle)])
        end
               
        temFR.firstBin.pyr={};
        temFR.firstBin.inh={};
        temFR.lastBin.pyr={};
        temFR.lastBin.inh={};
        for cTypeIdx=1:2
            switch cTypeIdx
                case 1
                    cType='pyr';
                case 2
                    cType='inh';
                otherwise
                    continue
            end
            
            for dIdx=1:length(fr)
                if length(fr(dIdx).pyr)<2
                    continue
                end
                surIdx=randi(length(fr(dIdx).pyr)-1,1,length(fr(dIdx).pyr));
                surIdx(surIdx-(1:length(fr(dIdx).pyr))>=0)=surIdx(surIdx-(1:length(fr(dIdx).pyr))>=0)+1;
                for tIdx=1:length(fr(dIdx).(cType))
                    if isempty(fr(dIdx).(cType){tIdx})
                        continue
                    end
                    if shIdx>1
                        %do shuffling
                        temp=[fr(dIdx).(cType){tIdx}(:,1),fr(dIdx).(cType){surIdx(tIdx)}(:,1)];
                        flipIdx=randi(2,size(temp,1),1)-1;
                        flipIdx=[flipIdx,1-flipIdx]*size(flipIdx,1)+(1:size(flipIdx,1))';
                        temFR.firstBin.(cType){end+1}=temp(flipIdx);
                        
                        temp=[fr(dIdx).(cType){tIdx}(:,2),fr(dIdx).(cType){surIdx(tIdx)}(:,2)];
                        flipIdx=randi(2,size(temp,1),1)-1;
                        flipIdx=[flipIdx,1-flipIdx]*size(flipIdx,1)+(1:size(flipIdx,1))';
                        temFR.lastBin.(cType){end+1}=temp(flipIdx);
                    else
                        temFR.firstBin.(cType){end+1}=fr(dIdx).(cType){surIdx(tIdx)};
                        temFR.lastBin.(cType){end+1}=fr(dIdx).(cType){surIdx(tIdx)};
                    end
                end
            end
        end
                
        for orderTypeIdx=1:length(baseBin)
            orderType=orderList{orderTypeIdx}; 
            
            for tPointIdx=1:2
                if tPointIdx==1
                    tPoint='firstBin';
                else
                    tPoint='lastBin';
                end
                quintile=cellfun(@(x) ceil(tiedrank(mean(x(:,baseBin{orderTypeIdx}),2))/length(x)*nDiv),temFR.(tPoint).pyr,'uniformOutput',false);
                
                for qIdx=1:nDiv
                    temp=cellfun(@(x,y) x(y==qIdx,:),temFR.(tPoint).pyr,quintile,'uniformOutput',false);
                    tempCI{qIdx}=funcCI(cat(1,temp{:}));
                end
                
                tempCI{nDiv+1}=funcCI(cat(1,temFR.(tPoint).inh{:}));
            

            if shIdx==1
                newCI.(state).(orderType).real.mean=cellfun(@nanmean,tempCI);
                newCI.(state).(orderType).real.ste=cellfun(@nanste,tempCI);
                newCI.(state).(orderType).real.n=cellfun(@(x) sum(~isnan(x)),tempCI);
                newCI.(state).(orderType).real.totalN=cellfun(@length,tempCI);
            else            
                newCI.(state).(orderType).shuffle.(tPoint)(shIdx-1,:)=cellfun(@nanmean,tempCI);
            end
            end
            newCI.(state).(orderType).param.orderBin=baseBin{orderTypeIdx};
            newCI.(state).(orderType).param.madeby=mfilename;
            newCI.(state).(orderType).param.nDiv=nDiv;
            newCI.(state).(orderType).param.nShuffle=nShuffle;          
        end   
    end
    
    for orderTypeIdx=1:length(baseBin)
        orderType=orderList{orderTypeIdx}; 
        for tPointIdx=1:2
            if tPointIdx==1
                tPoint='firstBin';
            else
                tPoint='lastBin';
            end
                   
            temp=sort(newCI.(state).(orderType).shuffle.(tPoint));
            
            realNum=newCI.(state).(orderType).real.mean;
            
            for qIdx=1:size(temp,2)
                n=find(temp(:,qIdx)<realNum(qIdx),1,'last');
                if isempty(n); n=0;
                elseif n>size(temp,1)/2; n=size(temp,1)-n;end
                p(qIdx)=n/size(temp,1)*2;
            end

            newDI.(state).(orderType).(tPoint).mean=newCI.(state).(orderType).real.mean-mean(temp);
            newDI.(state).(orderType).(tPoint).ste=newCI.(state).(orderType).real.ste;
            newDI.(state).(orderType).(tPoint).p=p;
            newDI.(state).(orderType).(tPoint).n=newCI.(state).(orderType).real.n;
            newDI.(state).(orderType).(tPoint).totalN=newCI.(state).(orderType).real.totalN;
            newDI.(state).(orderType).(tPoint).null=mean(temp);
            newDI.(state).(orderType).(tPoint).confInt=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);
    
        end
    end
end


save([baseDir coreName '-' 'newDI' '.mat'],'newDI','newCI','-v7.3')










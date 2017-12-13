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
stateList={'nrem','rem','quiet2nrem','nrem2quiet','rem2quiet','rem2nrem','nrem2rem','nrem2rem2nrem','rem2nrem2rem'};
funcCI=@(x) diff(x,1,2)./sum(x,2);

shuffleList={'entire','adjacent','flip'};
zeroList={'includeZero','excludeZero'};

for stateIdx=1:length(stateList)
    state=stateList{stateIdx};
    display([datestr(now) ' started ' state])
    clear fr baseFR
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        targetIdx=stateChange.(dName).(state);
        
        fr(dIdx).pyr={};
        fr(dIdx).inh={};
        baseFR(dIdx).pyr={};
        baseFR(dIdx).inh={};
        
        for tIdx=1:size(targetIdx,1)
            if size(targetIdx,2)==2
                if isempty(timeNormFR.(dName).offset.pyr{targetIdx(tIdx,1)})||...
                        isempty(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,2)})
                    continue
                end
                fr(dIdx).pyr{end+1}=[mean(timeNormFR.(dName).offset.pyr{targetIdx(tIdx,1)}(:,end-2:end),2),mean(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,2)}(:,1:3),2)];
                fr(dIdx).inh{end+1}=[mean(timeNormFR.(dName).offset.inh{targetIdx(tIdx,1)}(:,end-2:end),2),mean(timeNormFR.(dName).onset.inh{targetIdx(tIdx,2)}(:,1:3),2)];
                
                baseFR(dIdx).pyr{end+1}=[mean(timeNormFR.(dName).offset.pyr{targetIdx(tIdx,1)},2),mean(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,2)},2)];
                baseFR(dIdx).inh{end+1}=[mean(timeNormFR.(dName).offset.inh{targetIdx(tIdx,1)},2),mean(timeNormFR.(dName).onset.inh{targetIdx(tIdx,2)},2)];
                
            elseif size(targetIdx,2)==1
                if isempty(timeNormFR.(dName).offset.pyr{targetIdx(tIdx)})
                    continue
                end
                
                fr(dIdx).pyr{end+1}=[mean(timeNormFR.(dName).offset.pyr{targetIdx(tIdx)}(:,1:3),2),mean(timeNormFR.(dName).offset.pyr{targetIdx(tIdx)}(:,end-2:end),2)];
                fr(dIdx).inh{end+1}=[mean(timeNormFR.(dName).offset.inh{targetIdx(tIdx)}(:,1:3),2),mean(timeNormFR.(dName).offset.inh{targetIdx(tIdx)}(:,end-2:end),2)];
                nHalfBin=round(size(timeNormFR.(dName).offset.pyr{targetIdx(tIdx)},2)/2);
                
                baseFR(dIdx).pyr{end+1}=[mean(timeNormFR.(dName).offset.pyr{targetIdx(tIdx)}(:,1:nHalfBin),2),mean(timeNormFR.(dName).onset.pyr{targetIdx(tIdx)}(:,nHalfBin+1:end),2)];
                baseFR(dIdx).inh{end+1}=[mean(timeNormFR.(dName).offset.inh{targetIdx(tIdx)}(:,1:nHalfBin),2),mean(timeNormFR.(dName).onset.inh{targetIdx(tIdx)}(:,nHalfBin+1:end),2)];
                
                
            elseif size(targetIdx,2)==3
                if isempty(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,1)})||...
                        isempty(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,3)})
                    continue
                end
                fr(dIdx).pyr{end+1}=[mean(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,1)}(:,1:3),2),mean(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,3)}(:,1:3),2)];
                fr(dIdx).inh{end+1}=[mean(timeNormFR.(dName).onset.inh{targetIdx(tIdx,1)}(:,1:3),2),mean(timeNormFR.(dName).onset.inh{targetIdx(tIdx,3)}(:,1:3),2)];
                
                baseFR(dIdx).pyr{end+1}=[mean(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,1)},2),mean(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,3)},2)];
                baseFR(dIdx).inh{end+1}=[mean(timeNormFR.(dName).onset.inh{targetIdx(tIdx,1)},2),mean(timeNormFR.(dName).onset.inh{targetIdx(tIdx,3)},2)];
                
                
            else
                continue
            end
        end
    end
    
    for shIdx=1:nShuffle+1
        if mod(shIdx,100)==0
            display(['   ' datestr(now) ' shuffling ' num2str(shIdx) '/' num2str(nShuffle)])
        end
        
        clear tempFR tempBaseFR
        for cTypeIdx=1:2
            switch cTypeIdx
                case 1
                    cType='pyr';
                case 2
                    cType='inh';
                otherwise
                    continue
            end
            
            for shTypeIdx=1:length(shuffleList)
                shType=shuffleList{shTypeIdx};
                
                for zeroTypeIdx=1:length(zeroList)
                    zeroType=zeroList{zeroTypeIdx};
                    tempFR.(shType).(zeroType).(cType)={};
                    tempBaseFR.(shType).(zeroType).(cType)={};
                end
            end
        end
        for dIdx=1:length(fr)
            if length(fr(dIdx).pyr)<2
                continue
            end
            
            for shTypeIdx=1:length(shuffleList)
                shType=shuffleList{shTypeIdx};
                
                if strcmpi(shType,'entire')
                    surIdx=randi(length(fr(dIdx).pyr)-1,1,length(fr(dIdx).pyr));
                    surIdx(surIdx>=(1:length(fr(dIdx).(cType))))= surIdx(surIdx>=(1:length(fr(dIdx).(cType))))+1;
                elseif strcmpi(shType,'adjacent')
                    surIdx=2*randi(2,1,length(fr(dIdx).pyr))-3;
                    surIdx(1)=1;surIdx(end)=-1;
                    surIdx=surIdx+(1:length(fr(dIdx).(cType)));
                elseif strcmpi(shType,'flip')
                    surIdx=[];
                end
                
                for cTypeIdx=1:2
                    switch cTypeIdx
                        case 1
                            cType='pyr';
                        case 2
                            cType='inh';
                        otherwise
                            continue
                    end
                    for tIdx=1:length(fr(dIdx).(cType))
                        if isempty(fr(dIdx).(cType){tIdx})
                            continue
                        end
                        if shIdx>1
                            %do shuffling
                            switch shType
                                case 'flip'
                                    temp=fr(dIdx).(cType){tIdx};
                                    tempBase=baseFR(dIdx).(cType){tIdx};
                                otherwise
                                    temp=[fr(dIdx).(cType){tIdx}(:,1),fr(dIdx).(cType){surIdx(tIdx)}(:,1)];
                                    tempBase=[baseFR(dIdx).(cType){tIdx}(:,1),baseFR(dIdx).(cType){surIdx(tIdx)}(:,1)];
                            end
                            flipIdx=randi(2,size(temp,1),1)-1;
                            flipIdx=[flipIdx,1-flipIdx]*size(flipIdx,1)+(1:size(flipIdx,1))';
                            temp=temp(flipIdx);
                            tempBase=tempBase(flipIdx);
                        else
                            temp=fr(dIdx).(cType){tIdx};
                            tempBase=baseFR(dIdx).(cType){tIdx};
                        end
                        
                        
                        for zeroTypeIdx=1:length(zeroList)
                            zeroType=zeroList{zeroTypeIdx};
                            
                            if strcmpi(zeroType,'includeZero')
                                tempFR.(shType).(zeroType).(cType){end+1}=temp;
                                tempBaseFR.(shType).(zeroType).(cType){end+1}=tempBase;
                            else
                                tempFR.(shType).(zeroType).(cType){end+1}=temp(all(temp~=0,2),:);
                                tempBaseFR.(shType).(zeroType).(cType){end+1}=tempBase(all(temp~=0,2),:);
                            end
                        end
                    end
                end
            end
        end
        
        for shTypeIdx=1:length(shuffleList)
            shType=shuffleList{shTypeIdx};
            for zeroTypeIdx=1:length(zeroList)
                zeroType=zeroList{zeroTypeIdx};
                
                quintile=cellfun(@(x) ceil(tiedrank(x(:,1),2)/length(x)*nDiv),tempBaseFR.(shType).(zeroType).pyr,'uniformOutput',false);
                
                for qIdx=1:nDiv
                    temp=cellfun(@(x,y) x(y==qIdx,:),tempFR.(shType).(zeroType).pyr,quintile,'uniformOutput',false);
                    tempCI{qIdx}=funcCI(cat(1,temp{:}));
                end
                
                tempCI{nDiv+1}=funcCI(cat(1,tempFR.(shType).(zeroType).inh{:}));
                
                if shIdx==1
                    newCI_bigBin.(state).(shType).(zeroType).real.mean=cellfun(@nanmean,tempCI);
                    newCI_bigBin.(state).(shType).(zeroType).real.ste=cellfun(@nanste,tempCI);
                    newCI_bigBin.(state).(shType).(zeroType).real.n=cellfun(@(x) sum(~isnan(x)),tempCI);
                    newCI_bigBin.(state).(shType).(zeroType).real.totalN=cellfun(@length,tempCI);
                else
                    newCI_bigBin.(state).(shType).(zeroType).shuffle(shIdx-1,:)=cellfun(@nanmean,tempCI);
                end
            end
        end
    end
    newCI_bigBin.(state).param.madeby=mfilename;
    newCI_bigBin.(state).param.nDiv=nDiv;
    newCI_bigBin.(state).param.nShuffle=nShuffle;
    
    
    for shTypeIdx=1:length(shuffleList)
        shType=shuffleList{shTypeIdx};
        for zeroTypeIdx=1:length(zeroList)
            zeroType=zeroList{zeroTypeIdx};
            
            temp=sort(newCI_bigBin.(state).(shType).(zeroType).shuffle);
            realNum=newCI_bigBin.(state).(shType).(zeroType).real.mean;
            
            for qIdx=1:size(temp,2)
                n=find(temp(:,qIdx)<realNum(qIdx),1,'last');
                if isempty(n); n=0;
                elseif n>size(temp,1)/2; n=size(temp,1)-n;end
                p(qIdx)=n/size(temp,1)*2;
            end
            
            newCI_bigBin.(state).(shType).(zeroType).real.confInt=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);
            
            newDI_bigBin.(state).(shType).(zeroType).mean=realNum-mean(temp);
            newDI_bigBin.(state).(shType).(zeroType).ste=newCI_bigBin.(state).(shType).(zeroType).real.ste;
            newDI_bigBin.(state).(shType).(zeroType).p=p;
            newDI_bigBin.(state).(shType).(zeroType).n=newCI_bigBin.(state).(shType).(zeroType).real.n;
            newDI_bigBin.(state).(shType).(zeroType).totalN=newCI_bigBin.(state).(shType).(zeroType).real.totalN;
            newDI_bigBin.(state).(shType).(zeroType).null=mean(temp);
            newDI_bigBin.(state).(shType).(zeroType).confInt=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:)-mean(temp);
            
        end
    end
    newDI_bigBin.(state).param.madeby=mfilename;
    newDI_bigBin.(state).param.nDiv=nDiv;
    newDI_bigBin.(state).param.nShuffle=nShuffle;
    
end


save([baseDir coreName '-' 'newDI_bigBin' '.mat'],'newDI_bigBin','newCI_bigBin','-v7.3')


%%
col=[1,0,0;0,0,1;0,0.8,0];
zeroText.includeZero='w/ zero-firing cells';
zeroText.excludeZero='w/o zero-firing cells';

nCol=5;
nRow=9;
close all
fh=initFig4Nature(2);

stateList={'nrem2rem','rem2nrem','nrem','rem','nrem2rem2nrem','rem2nrem2rem','quiet2nrem','nrem2quiet','rem2quiet'};

stateText.nrem='Within NREM';
stateText.rem='Within REM';

stateText.quiet2nrem='Quiet to NREM';
stateText.nrem2quiet='NREM to Quiet';
stateText.rem2quiet='REM to Quiet';

stateText.rem2nrem='REM to NREM';
stateText.nrem2rem='NREM to REM';
stateText.nrem2rem2nrem='NREM/REM/NREM triplets';
stateText.rem2nrem2rem='REM/NREM/REM triplets';

for stateIdx=1:length(stateList)
    state=stateList{stateIdx};
    
    
    for zeroTypeIdx=1:length(zeroList)
        zeroType=zeroList{zeroTypeIdx};
        
        subplot2(nRow,nCol,zeroTypeIdx+ceil(nRow/2)*(stateIdx>nCol),mod(stateIdx-1,nCol)+1)
        hold on
        bar(1:nDiv,newCI_bigBin.(state).flip.(zeroType).real.mean(1:nDiv),'k')
        bar(nDiv+1,newCI_bigBin.(state).flip.(zeroType).real.mean(end),'facecolor',0.99*[1,1,1])
        
        for shTypeIdx=1:length(shuffleList)
            shType=shuffleList{shTypeIdx};
            fill([1:nDiv+1,nDiv+1:-1:1],...
                [newCI_bigBin.(state).(shType).(zeroType).real.confInt(1,:),flip(newCI_bigBin.(state).(shType).(zeroType).real.confInt(2,:))],...
                col(shTypeIdx,:),'edgeColor','none','facealpha',0.5)
        end
        ylabel({'CI',zeroText.(zeroType)})
        set(gca,'xtick',[1,3,5,6],'xticklabel',{'L','M','H','I'})
        xlim([0.5,nDiv+1.5])
        
        if zeroTypeIdx==1
            title(stateText.(state))
        end
    end
end

for stateIdx=1:length(stateList)
    state=stateList{stateIdx};
    
    
    for zeroTypeIdx=1:length(zeroList)
        zeroType=zeroList{zeroTypeIdx};
        
        subplot2(nRow,nCol,zeroTypeIdx+ceil(nRow/2)*(stateIdx>nCol)+2,mod(stateIdx-1,nCol)+1)
        hold on
        for shTypeIdx=1:length(shuffleList)
            shType=shuffleList{shTypeIdx};
            bar((1:nDiv)-0.25*(shTypeIdx-2),newDI_bigBin.(state).(shType).(zeroType).mean(1:nDiv),0.25,...
                'edgeColor','none','facecolor',col(shTypeIdx,:))
            bar((nDiv+1)-0.25*(shTypeIdx-2),newDI_bigBin.(state).(shType).(zeroType).mean(end),0.25,...
                'edgeColor','none','facecolor',col(shTypeIdx,:))
            fill([1:nDiv+1,nDiv+1:-1:1]-0.25*(shTypeIdx-2),...
                [newDI_bigBin.(state).(shType).(zeroType).confInt(1,:),flip(newDI_bigBin.(state).(shType).(zeroType).confInt(2,:))],...
                col(shTypeIdx,:),'edgeColor','none','facealpha',0.5)
        end
        ylabel({'DI',zeroText.(zeroType)})
        set(gca,'xtick',[1,3,5,6],'xticklabel',{'L','M','H','I'})
        xlim([0.5,nDiv+1.5])
    end
end

subplot2(nRow,nCol,1+ceil(nRow/2),mod(stateIdx-1,nCol)+2)
legendText.flip='old shuffling';
legendText.entire='entire shuffling';
legendText.adjacent='adjacent shuffling';

legendText.pyr='Pyramidal cells';
legendText.inh='Interneurons';

legendCol=[0,0,0;0.99*[1,1,1];col];
legendCol(:,4)=0.5;
legendCol(1:2,4)=1;

edgeCol={'none'}
edgeCol=repmat(edgeCol,1,5);
edgeCol{2}=[0,0,0];
xlim([0,1])
ylim([0,1])

hold on
typeList={'pyr','inh',shuffleList{:}};
for n=1:length(typeList)
    fill([0,0.2,0.2,0],[1,1,1.1,1.1]-0.2*n,legendCol(n,1:3),'faceAlpha',legendCol(n,4),'edgeColor',edgeCol{n})
    if n>3
        text(0.22,1.05-0.2*n,['95% CI of ' legendText.(typeList{n})],'horizontalAlign','left','verticalAlign','middle')
    else
        text(0.22,1.05-0.2*n,[legendText.(typeList{n})],'horizontalAlign','left','verticalAlign','middle')
    end
end
axis off

addScriptName(mfilename)
figName='~/Dropbox/Quantile/preliminary/meanOrdered_largeBinDI_summary.pdf';
print(figName,'-dpdf','-painters')









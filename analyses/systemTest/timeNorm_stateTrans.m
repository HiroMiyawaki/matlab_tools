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

for stateIdx=1:length(stateList)
    state=stateList{stateIdx};  
    
    divider=findstr(state,'2');
    
    clear nBin baseBin orderList
    if ~isempty(divider)
    
        nBin(1)=timeNormFR.(dList{1}).param.nBin.(state(1:divider-1));
        nBin(2)=timeNormFR.(dList{1}).param.nBin.(state(divider+1:end));

        baseBin{1}=1:nBin(1);
        baseBin{2}=(1:nBin(2))+nBin(1);
        baseBin{3}=1:sum(nBin);
        baseBin{4}=(-ceil(nBin(1)/5)+1:0)+nBin(1);
        baseBin{5}=nBin(1)+(1:ceil(nBin(2)/5));
    
        orderList={'prev','next','both','offset','onset'};
    else
        nBin(1)=timeNormFR.(dList{1}).param.nBin.(state);

        baseBin{1}=1:nBin(1);
        baseBin{2}=1:ceil(nBin(1)/5);
        baseBin{3}=(-ceil(nBin(1)/5)+1:0)+nBin(1);   
        
        orderList={'mean','onset','offset'};
    end
        
    display([datestr(now) ' started ' state])
    
    for shIdx=1:nShuffle+1
        if mod(shIdx,100)==0        
            display(['   ' datestr(now) ' shuffling ' num2str(shIdx) '/' num2str(nShuffle)])
        end
        
        clear temp
        for orderTypeIdx=1:length(baseBin);
            orderType=orderList{orderTypeIdx};        
            for qIdx=1:nDiv+1
                temp.(orderType){qIdx}=[];
                tempPercent.(orderType){qIdx}=[];
                tempZ.(orderType){qIdx}=[];
            end
        end

        for dIdx=1:length(dList)
            dName=dList{dIdx};
            targetIdx=stateChange.(dName).(state);

            for tIdx=1:size(targetIdx,1)
                if size(targetIdx,2)==2
                    if isempty(timeNormFR.(dName).offset.pyr{targetIdx(tIdx,1)})||...
                            isempty(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,2)})
                        continue
                    end
                
                    frPyr=[timeNormFR.(dName).offset.pyr{targetIdx(tIdx,1)},timeNormFR.(dName).onset.pyr{targetIdx(tIdx,2)}];
                    frInh=[timeNormFR.(dName).offset.inh{targetIdx(tIdx,1)},timeNormFR.(dName).onset.inh{targetIdx(tIdx,2)}];                          
                elseif size(targetIdx,2)==1
                    if isempty(timeNormFR.(dName).offset.pyr{targetIdx(tIdx)})
                         continue
                    end
                
                    frPyr=timeNormFR.(dName).offset.pyr{targetIdx(tIdx)};
                    frInh=timeNormFR.(dName).offset.inh{targetIdx(tIdx)};        
                    
                else
                    continue
                end

                percentPyr=frPyr./mean(frPyr,2)*100;
                mF=[spikes.(dName)(cellfun(@all,{spikes.(dName).isStable})&([spikes.(dName).quality]<4)).meanF];
                sF=[spikes.(dName)(cellfun(@all,{spikes.(dName).isStable})&([spikes.(dName).quality]<4)).stdF];                
                zPyr=(frPyr-repmat(mF',1,sum(nBin)))./repmat(sF',1,sum(nBin));
                
                if ~isempty(frInh)
                    percentInh=frInh./mean(frInh,2)*100;        
                    mF=[spikes.(dName)(cellfun(@all,{spikes.(dName).isStable})&([spikes.(dName).quality]==8)).meanF];
                    sF=[spikes.(dName)(cellfun(@all,{spikes.(dName).isStable})&([spikes.(dName).quality]==8)).stdF];                
                    zInh=(frInh-mF')./sF';
                else
                    percentInh=[];
                    zInh=[];
                end
                
                
                if shIdx>1
                    %do shuffling
                    for cIdx=1:size(frPyr,1)
                        binOrder=randperm(sum(nBin));
                        frPyr(cIdx,:)=frPyr(cIdx,binOrder);
                        percentPyr(cIdx,:)=percentPyr(cIdx,binOrder);
                        zPyr(cIdx,:)=zPyr(cIdx,binOrder);
                    end
                    for cIdx=1:size(frInh,1)
                        binOrder=randperm(sum(nBin));
                        frInh(cIdx,:)=frInh(cIdx,binOrder);
                        percentInh(cIdx,:)=percentInh(cIdx,binOrder);
                        zInh(cIdx,:)=zInh(cIdx,binOrder);
                    end                    
                end
                
                for orderTypeIdx=1:length(baseBin)
                    orderType=orderList{orderTypeIdx}; 
                    quintile=ceil(tiedrank(mean(frPyr(:,baseBin{orderTypeIdx}),2))/size(frPyr,1)*nDiv);

                    for qIdx=1:nDiv
                        temp.(orderType){qIdx}=[temp.(orderType){qIdx};frPyr(quintile==qIdx,:)];
                        tempPercent.(orderType){qIdx}=[tempPercent.(orderType){qIdx};percentPyr(quintile==qIdx,:)];
                        tempZ.(orderType){qIdx}=[tempZ.(orderType){qIdx};zPyr(quintile==qIdx,:)];
                    end
                    temp.(orderType){nDiv+1}=[temp.(orderType){nDiv+1};frInh];
                    tempPercent.(orderType){nDiv+1}=[tempPercent.(orderType){nDiv+1};percentInh];
                    tempZ.(orderType){nDiv+1}=[tempZ.(orderType){nDiv+1};zInh];
                end
            end
        end
        
        for orderTypeIdx=1:length(baseBin);
            orderType=orderList{orderTypeIdx}; 
            tempMeanFr=cellfun(@(x) nanmean(x,1),temp.(orderType),'uniformOutput',false);
            tempMeanPercent=cellfun(@(x) nanmean(x,1),tempPercent.(orderType),'uniformOutput',false);
            tempMeanZ=cellfun(@(x) nanmean(x,1),tempZ.(orderType),'uniformOutput',false);
            
            if ~isempty(divider)
                tempCI=cellfun(@(x) funcCI(x(:,nBin(1)+(0:1))),temp.(orderType),'uniformOutput',false);
            else
                tempCI=cellfun(@(x) funcCI(x(:,[1,nBin(1)])),temp.(orderType),'uniformOutput',false);
            end
            
            if shIdx==1
                real.fr.(state).(orderType).mean=cat(1,tempMeanFr{:});
                tempMeanFr=cellfun(@(x) nanste(x,1),temp.(orderType),'uniformOutput',false);
                real.fr.(state).(orderType).ste=cat(1,tempMeanFr{:});
                real.fr.(state).(orderType).n=cellfun(@(x) size(x,1),temp.(orderType));

                real.percent.(state).(orderType).mean=cat(1,tempMeanPercent{:});
                tempMeanFr=cellfun(@(x) nanste(x,1),tempPercent.(orderType),'uniformOutput',false);
                real.percent.(state).(orderType).ste=cat(1,tempMeanFr{:});
                real.percent.(state).(orderType).n=cellfun(@(x) size(x,1),temp.(orderType));
                
                real.z.(state).(orderType).mean=cat(1,tempMeanZ{:});
                tempMeanFr=cellfun(@(x) nanste(x,1),tempZ.(orderType),'uniformOutput',false);
                real.z.(state).(orderType).ste=cat(1,tempMeanFr{:});
                real.z.(state).(orderType).n=cellfun(@(x) size(x,1),temp.(orderType));

                real.ci.(state).(orderType).mean=cellfun(@nanmean,tempCI);
                real.ci.(state).(orderType).ste=cellfun(@nanste,tempCI);
                real.ci.(state).(orderType).n=cellfun(@length,tempCI);
                
                real.param.(state).(orderType).nBin=nBin;
                real.param.(state).(orderType).orderBin=baseBin{orderTypeIdx};
                real.param.(state).(orderType).madeby=mfilename;
                real.param.(state).(orderType).nDiv=nDiv;
            else
                shuffle.fr.(state).(orderType)(:,:,shIdx-1)=cat(1,tempMeanFr{:});     
                shuffle.percent.(state).(orderType)(:,:,shIdx-1)=cat(1,tempMeanPercent{:});     
                shuffle.z.(state).(orderType)(:,:,shIdx-1)=cat(1,tempMeanZ{:});     
                shuffle.ci.(state).(orderType)(:,shIdx-1)=cellfun(@nanmean,tempCI);
                shuffle.param.(state).(orderType).nBin=nBin;
                shuffle.param.(state).(orderType).orderBin=baseBin{orderTypeIdx};
                shuffle.param.(state).(orderType).madeby=mfilename;
                shuffle.param.(state).(orderType).nDiv=nDiv;
                shuffle.param.(state).(orderType).nShuffle=nShuffle;
            end
        end
    
    end
end

save([baseDir coreName '-' 'timeNorm_stateChange_fineBins' '.mat'],'real','shuffle','-v7.3')
%%
% clear
% baseDir='~/data/sleep/pooled_withCohEMG/';
% coreName='sleep';
% 
% load([baseDir coreName '-' 'timeNorm_stateChange_fineBins' '.mat'])
% %%
% close all
% fh=initFig4Nature(2);
% basePyrCol=rgb2hsv([1,0.4,0]);
% 
% nDiv=real.param.nrem.onset.nDiv;
% 
% col=[hsv2rgb([basePyrCol(1)*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,1,nDiv)']);
%      [0,0.6,1]];
% 
% titleText.quiet2nrem='Wake to NREM';
% titleText.nrem2quiet='NREM to Wake';
% titleText.rem2quiet='REM to Wake';
% titleText.rem2nrem='REM to NREM';
% titleText.nrem2rem='NREM to REM';
%     
% orderText.prev='mean in previous state';
% orderText.next='mean in next state';
% orderText.both='mean in both state';
% 
% stateList={'quiet2nrem','nrem2rem','rem2nrem','nrem2quiet','rem2quiet'};
% 
% 
% for stateIdx=1:length(stateList)
%     state=stateList{stateIdx}; 
% 
%     
%     clear baseBin nBin
%     
%     for orderTypeIdx=1:length(baseBin);
%         orderType=orderList{orderTypeIdx}; 
%         
%         nBin=real.param.(state).(orderType).nBin;
%         baseBin=real.param.(state).(orderType).orderBin;
%         
%         subplot2(9,5,3*orderTypeIdx-2,stateIdx)
%         
%         hold on
%         for qIdx=1:nDiv+1
%             plot(real.fr.(state).(orderType).mean(qIdx,:)/mean(real.fr.(state).(orderType).mean(qIdx,baseBin{orderTypeIdx}))*100,'color',col(qIdx,:))
%         end
% %         set(gca,'yscale','log')
%         title({titleText.(state),'Ordered & normalized by ' orderText.(orderType)})
%         xlim([1,sum(nBin)])
%         ax=fixAxis;
%         plot(nBin(1)+0.5*[1,1],ax(3:4),'-','color',0.5*[1,1,1])
%         ylabel('FR (%)')
%         xlabel('Normalized time')
%         set(gca,'xtick',[])
%         
%         subplot2(9,5,3*orderTypeIdx-1,stateIdx)
%         
%         clear temp;
%         temp=mean(shuffle.fr.(state).(orderType)./repmat(mean(shuffle.fr.(state).(orderType)(:,baseBin{orderTypeIdx},:),2),1,sum(nBin))*100,3);
%         
%         hold on
%         for qIdx=1:nDiv+1
%             plot(temp(qIdx,:),'color',col(qIdx,:))
%         end
% %         set(gca,'yscale','log')
%         title(['shuffled mean'])
%         
%         xlim([1,sum(nBin)])
%         ylabel('FR (%)')
%         xlabel('Normalized time')
%         set(gca,'xtick',[])
% %         ylim(ax(3:4))
%         ax=fixAxis;
%         plot(nBin(1)+0.5*[1,1],ax(3:4),'-','color',0.5*[1,1,1])
% 
%         subplot2(9,5,3*orderTypeIdx,stateIdx)
%         hold on 
%         clear temp;
%         temp=sort(shuffle.ci.(state).(orderType),2);
%         temp=temp(:,[ceil(nShuffle*0.975),max([1,floor(nShuffle*0.025)])]);
%         
%         for qIdx=1:nDiv+1
%            bar(qIdx,real.ci.(state).(orderType).mean(qIdx),'facecolor',col(qIdx,:),'linestyle','none')
%         end
%         fill([1:nDiv+1,nDiv+1:-1:1],[temp(:,1);temp(end:-1:1,2)],0.5*[1,1,1],'linestyle','none','facealpha',0.5);
% 
%         xlim([0,nDiv+2])
%         ylabel('CI')
% %         xlabel('Quintile')
%         set(gca,'xtick',[1:2:5,6],'xticklabel',{'L','M','H','Inh'})
%         
%     end
% end        
% addScriptName(mfilename)
% print(fh,'~/Dropbox/Quantile/preliminary/timeNorm_stateChange_fineBins_percent.pdf','-dpdf')
% 
% %%
% close all
% fh=initFig4Nature(2);
% basePyrCol=rgb2hsv([1,0.4,0]);
% 
% col=[hsv2rgb([basePyrCol(1)*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,1,nDiv)']);
%      [0,0.6,1]];
% 
% titleText.quiet2nrem='Wake to NREM';
% titleText.nrem2quiet='NREM to Wake';
% titleText.rem2quiet='REM to Wake';
% titleText.rem2nrem='REM to NREM';
% titleText.nrem2rem='NREM to REM';
%     
% orderText.prev='mean in previous state';
% orderText.next='mean in next state';
% orderText.both='mean in both state';
% 
% stateList={'quiet2nrem','nrem2rem','rem2nrem','nrem2quiet','rem2quiet'};
% 
% 
% for stateIdx=1:length(stateList)
%     state=stateList{stateIdx}; 
% 
%     clear baseBin nBin
%     
%     for orderTypeIdx=1:length(baseBin);
%         orderType=orderList{orderTypeIdx}; 
%         
%         nBin=real.param.(state).(orderType).nBin;
%         baseBin=real.param.(state).(orderType).orderBin;
% 
%         subplot2(9,5,3*orderTypeIdx-2,stateIdx)
%         
%         hold on
%         for qIdx=1:nDiv+1
%             plot(real.fr.(state).(orderType).mean(qIdx,:),'color',col(qIdx,:))
%         end
%         set(gca,'yscale','log')
%         title({titleText.(state),'Ordered & normalized by ' orderText.(orderType)})
% %         axis tight
%         ylim(10.^[-3,1.5])
%         xlim([1,sum(nBin)])
%         ax=fixAxis;
%         plot(nBin(1)+0.5*[1,1],ax(3:4),'-','color',0.5*[1,1,1])
%         ylabel('FR (Hz)')
%         xlabel('Normalized time')
%         set(gca,'ytick',10.^[-2:2:0])
%         set(gca,'xtick',[])
%         
%         subplot2(9,5,3*orderTypeIdx-1,stateIdx)
%         
%         clear temp;
%         temp=mean(shuffle.fr.(state).(orderType),3);
%         
%         hold on
%         for qIdx=1:nDiv+1
%             plot(temp(qIdx,:),'color',col(qIdx,:))
%         end
%          set(gca,'yscale','log')
%         title(['shuffled mean'])
%         
% %         axis tight
%         ylim(10.^[-3,1.5])
%         xlim([1,sum(nBin)])
%         ylabel('FR (Hz)')
%         xlabel('Normalized time')
%         set(gca,'xtick',[])
%         set(gca,'ytick',10.^[-2:2:0])
% %         ylim(ax(3:4))
%         ax=fixAxis;
%         plot(nBin(1)+0.5*[1,1],ax(3:4),'-','color',0.5*[1,1,1])
% 
%         subplot2(9,5,3*orderTypeIdx,stateIdx)
%         hold on 
%         clear temp;
%         temp=sort(shuffle.ci.(state).(orderType),2);
%         temp=temp(:,[ceil(nShuffle*0.975),max([1,floor(nShuffle*0.025)])]);
%         
%         for qIdx=1:nDiv+1
%            bar(qIdx,real.ci.(state).(orderType).mean(qIdx),'facecolor',col(qIdx,:),'linestyle','none')
%         end
%         fill([1:nDiv+1,nDiv+1:-1:1],[temp(:,1);temp(end:-1:1,2)],0.5*[1,1,1],'linestyle','none','facealpha',0.5);
% 
%         xlim([0,nDiv+2])
%         ylabel('CI')
% %         xlabel('Quintile')
%         set(gca,'xtick',[1:2:5,6],'xticklabel',{'L','M','H','Inh'})
%         
%     end
% end        
% addScriptName(mfilename)
% print(fh,'~/Dropbox/Quantile/preliminary/timeNorm_stateChange_fineBins_FR.pdf','-dpdf')
% 
% 
% 
% 
% 
% 
% 
% 














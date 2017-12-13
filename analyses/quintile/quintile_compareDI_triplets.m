% clear
% % baseDir='/Volumes/RAID_HDD/sleep/pooled/';
% % baseDir='~/data/sleep/pooled/';
% baseDir='~/data/sleep/pooled_withCohEMG/';
% coreName='sleep';
% 
% varList={'basics'
%     'behavior'
%     ...'ripple'
%     ...'spindle'
%     ...'hpcSpindlePhase'
%     ...'ctxSpindlePhase'
%     ...'HL'
%     ...'HLwavelet'
%     'HLfine'
%     ...'onOff'
%     ...'hpcSWA'
%     ...'pfcSWA'
%     ...'recStart'
%     ...'position'
%     ...'speed'
%     ...'spectrum'
%     'spikes'
%     ...'modulatedCell'
%     ...thetaPhase'
%     ...'pfcEeg'
%     ...'emg'
%     ...'firing'
%     ...'eventRate'
%     ...'stableSleep'
%     ...'stableWake'
%     'stateChange20s'
%     ...'trisecFiring'
%     ...'binnedFiring'
%     ...'thetaBand'
%     ...'sleepPeriod'
%     ...'recStart'
%     ...'deltaBand'
%     ...'thetaBand'
%     ...'pairCorr'
%     ...'pairCorrHIGH'
%     'timeNormFR'
%     }';
% 
% for varName=varList
%     load([baseDir coreName '-' varName{1} '.mat'])
% end
% 
% HL=HLfine;
% dList=fieldnames(basics);
% 
% %%
% 
% nDiv=5;
% nShuffle=2000;
% funcCI=@(x) diff(x,1,2)./sum(x,2);
% 
% orderList={'mean','onset','offset'};
% shuffleList={'flip','entireFirst','entireLast','adjacentFirst','adjacentLast'};
% baseBin={[1,2],1,2};
% 
% state='nrem2rem2nrem';
% display([datestr(now) ' started ' state])
% clear fr
% for dIdx=1:length(dList)
%     dName=dList{dIdx};
%     targetIdx=stateChange.(dName).(state);
%     
%     fr(dIdx).pyr={};
%     fr(dIdx).inh={};
%     for tIdx=1:size(targetIdx,1)
%         if size(targetIdx,2)==2
%             if isempty(timeNormFR.(dName).offset.pyr{targetIdx(tIdx,1)})||...
%                     isempty(timeNormFR.(dName).onset.pyr{targetIdx(tIdx,2)})
%                 continue
%             end
%             fr(dIdx).pyr{end+1}=[timeNormFR.(dName).offset.pyr{targetIdx(tIdx,1)}(:,end),timeNormFR.(dName).onset.pyr{targetIdx(tIdx,2)}(:,1)];
%             fr(dIdx).inh{end+1}=[timeNormFR.(dName).offset.inh{targetIdx(tIdx,1)}(:,end),timeNormFR.(dName).onset.inh{targetIdx(tIdx,2)}(:,1)];
%         elseif size(targetIdx,2)==1
%             if isempty(timeNormFR.(dName).offset.pyr{targetIdx(tIdx)})
%                 continue
%             end
%             
%             fr(dIdx).pyr{end+1}=timeNormFR.(dName).offset.pyr{targetIdx(tIdx)}(:,[1,end]);
%             fr(dIdx).inh{end+1}=timeNormFR.(dName).offset.inh{targetIdx(tIdx)}(:,[1,end]);
%         elseif size(targetIdx,2)==3
%             if isempty(timeNormFR.(dName).offset.pyr{targetIdx(tIdx)})
%                 continue
%             end
%             
%             fr(dIdx).pyr{end+1}=[timeNormFR.(dName).offset.pyr{targetIdx(tIdx,1)}(:,1),timeNormFR.(dName).onset.pyr{targetIdx(tIdx,3)}(:,1)];
%             fr(dIdx).inh{end+1}=[timeNormFR.(dName).offset.inh{targetIdx(tIdx,1)}(:,1),timeNormFR.(dName).onset.inh{targetIdx(tIdx,3)}(:,1)];
%             
%         else
%             continue
%         end
%     end
% end
% %%
% for shIdx=1:nShuffle+1
%     if mod(shIdx,100)==0
%         display(['   ' datestr(now) ' shuffling ' num2str(shIdx) '/' num2str(nShuffle)])
%     end
%     
%     
%     clear tempFR
%     for cTypeIdx=1:2
%         switch cTypeIdx
%             case 1
%                 cType='pyr';
%             case 2
%                 cType='inh';
%             otherwise
%                 continue
%         end
%         
%         for shTypeIdx=1:length(shuffleList)
%             shType=shuffleList{shTypeIdx};
%             
%             tempFR.(shType).(cType)={};
%         end
%     end
%     for dIdx=1:length(fr)
%         if length(fr(dIdx).pyr)<2
%             continue
%         end
%         
%         for shTypeIdx=1:length(shuffleList)
%             shType=shuffleList{shTypeIdx};
%             
%             if strcmpi(shType,'entireFirst')
%                 surIdx=randi(length(fr(dIdx).pyr)-1,1,length(fr(dIdx).pyr));
%                 surIdx(surIdx>=(1:length(fr(dIdx).(cType))))= surIdx(surIdx>=(1:length(fr(dIdx).(cType))))+1;
%             elseif strcmpi(shType,'adjacentFirst')
%                 surIdx=2*randi(2,1,length(fr(dIdx).pyr))-3;
%                 surIdx(1)=1;surIdx(end)=-1;
%                 surIdx=surIdx+(1:length(fr(dIdx).(cType)));
%             elseif strcmpi(shType,'flip')
%                 surIdx=[];
%             end
%             
%             for cTypeIdx=1:2
%                 switch cTypeIdx
%                     case 1
%                         cType='pyr';
%                     case 2
%                         cType='inh';
%                     otherwise
%                         continue
%                 end
%                 for tIdx=1:length(fr(dIdx).(cType))
%                     if isempty(fr(dIdx).(cType){tIdx})
%                         continue
%                     end
%                     if shIdx>1
%                         %do shuffling
%                         switch shType
%                             case 'flip'
%                                 temp=fr(dIdx).(cType){tIdx};
%                             case 'entireFirst'
%                                 temp=[fr(dIdx).(cType){tIdx}(:,1),fr(dIdx).(cType){surIdx(tIdx)}(:,1)];
%                             case 'entireLast'
%                                 temp=[fr(dIdx).(cType){surIdx(tIdx)}(:,2),fr(dIdx).(cType){tIdx}(:,2)];
%                             case 'adjacentFirst'
%                                 temp=[fr(dIdx).(cType){tIdx}(:,1),fr(dIdx).(cType){surIdx(tIdx)}(:,1)];
%                             case 'adjacentLast'
%                                 temp=[fr(dIdx).(cType){surIdx(tIdx)}(:,2),fr(dIdx).(cType){tIdx}(:,2)];
%                         end
%                         flipIdx=randi(2,size(temp,1),1)-1;
%                         flipIdx=[flipIdx,1-flipIdx]*size(flipIdx,1)+(1:size(flipIdx,1))';
%                         temp=temp(flipIdx);
%                     else
%                         temp=fr(dIdx).(cType){tIdx};
%                     end
%                     
%                     tempFR.(shType).(cType){end+1}=temp;
%                 end
%             end
%         end
%     end
%     if shIdx<10
%         for shTypeIdx=1:length(shuffleList)
%             shType=shuffleList{shTypeIdx};
%             exampleFR.(state).(shType).pyr{shIdx}=cat(1,tempFR.(shType).pyr{:});
%             exampleFR.(state).(shType).inh{shIdx}=cat(1,tempFR.(shType).inh{:});
%         end
%     end
%     for orderTypeIdx=1:length(baseBin)
%         orderType=orderList{orderTypeIdx};
%         
%         for shTypeIdx=1:length(shuffleList)
%             shType=shuffleList{shTypeIdx};
% 
%             quintile=cellfun(@(x) ceil(tiedrank(mean(x(:,baseBin{orderTypeIdx}),2))/length(x)*nDiv),tempFR.(shType).pyr,'uniformOutput',false);
%             
%             for qIdx=1:nDiv
%                 temp=cellfun(@(x,y) x(y==qIdx,:),tempFR.(shType).pyr,quintile,'uniformOutput',false);
%                 tempCI{qIdx}=funcCI(cat(1,temp{:}));
%             end
%             
%             tempCI{nDiv+1}=funcCI(cat(1,tempFR.(shType).inh{:}));
%             
%             
%             if shIdx==1
%                 adjCI.(state).(orderType).real.mean=cellfun(@nanmean,tempCI);
%                 adjCI.(state).(orderType).real.ste=cellfun(@nanste,tempCI);
%                 adjCI.(state).(orderType).real.n=cellfun(@(x) sum(~isnan(x)),tempCI);
%                 adjCI.(state).(orderType).real.totalN=cellfun(@length,tempCI);
%             else
%                 adjCI.(state).(orderType).shuffle.(shType)(shIdx-1,:)=cellfun(@nanmean,tempCI);
%             end
%         end
%         adjCI.(state).(orderType).param.orderBin=baseBin{orderTypeIdx};
%         adjCI.(state).(orderType).param.madeby=mfilename;
%         adjCI.(state).(orderType).param.nDiv=nDiv;
%         adjCI.(state).(orderType).param.nShuffle=nShuffle;
%     end
% end
% 
% for orderTypeIdx=1:length(baseBin)
%     orderType=orderList{orderTypeIdx};
%     for shTypeIdx=1:length(shuffleList)
%         shType=shuffleList{shTypeIdx};
%         
%         temp=sort(adjCI.(state).(orderType).shuffle.(shType));
%         
%         realNum=adjCI.(state).(orderType).real.mean;
%         
%         for qIdx=1:size(temp,2)
%             n=find(temp(:,qIdx)<realNum(qIdx),1,'last');
%             if isempty(n); n=0;
%             elseif n>size(temp,1)/2; n=size(temp,1)-n;end
%             p(qIdx)=n/size(temp,1)*2;
%         end
%         
%         adjDI.(state).(orderType).(shType).mean=adjCI.(state).(orderType).real.mean-mean(temp);
%         adjDI.(state).(orderType).(shType).ste=adjCI.(state).(orderType).real.ste;
%         adjDI.(state).(orderType).(shType).p=p;
%         adjDI.(state).(orderType).(shType).n=adjCI.(state).(orderType).real.n;
%         adjDI.(state).(orderType).(shType).totalN=adjCI.(state).(orderType).real.totalN;
%         adjDI.(state).(orderType).(shType).null=mean(temp);
%         adjDI.(state).(orderType).(shType).confInt=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);
%         
%     end
% end
% %%
% origX=13;
% origY=13;
% panelLetterSize=12;
% letterGapX=10;
% letterGapY=5;
% marginX=15;
% marginY=12;
% timeNormWidth=40;
% height=22;
% ciWidth=25;
% 
% % %%
% % stateList={'nrem2rem','rem2nrem','nrem','rem','quiet2nrem','nrem2quiet','rem2quiet'};
% % % stateList=fieldnames(newCI)

%%
close all
fh=initFig4Nature(2);

orderList={'mean','onset','offset'};

stateName='nrem2rem2nrem';

orderText={'by mean of NREM onsets',['at NREM1 onset'],['at NREM2 onset']};

shName.flip='Old method';
shName.entireFirst='Entire shuffle, first bin';
shName.entireLast='Entire shuffle, last bin';
shName.adjacentFirst='Adjacent shuffle, first bin';
shName.adjacentLast='Adjacent shuffle, last bin';

for shTypeIdx=1:length(shuffleList)
    shType=shuffleList{shTypeIdx};

    for oIdx=1:length(orderList)
        orderType=orderList{oIdx}
        subplot2(6,5,oIdx,shTypeIdx)

        temp=sort(adjCI.(stateName).(orderType).shuffle.(shType));
        confInt=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:)        
        
        hold on
        bar(1:5,adjCI.(stateName).(orderType).real.mean(1:5),'faceColor',[0,0,0])
        bar(6,adjCI.(stateName).(orderType).real.mean(6),'faceColor',[1,1,1])

        fill([1:6,6:-1:1]-0.31,[confInt(1,:),fliplr(confInt(2,:))],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
        ylabel('CI')
        xlim([0.5,6.5])
        set(gca,'XTick',[1,3,5,6],'XTickLabel',{'L','M','H','I'});
        ax=fixAxis;
        if shTypeIdx==1
            text2(-0.5,0.5,{'Ordered ' orderText{oIdx}},ax,{'rotation',90,'verticalAlign','middle','horizontalAlign','center','fontsize',8})
        end
        if oIdx==1
            text2(0.5,1.1,shName.(shType),ax,{'verticalAlign','bottom','horizontalAlign','center','fontsize',8})
        end
            
    end
end
addScriptName(mfilename)
print(fh,'~/Dropbox/Quantile/preliminary/DIcompare-triplets.pdf','-dpdf');
%
%
% % save([baseDir coreName '-' 'adjDI' '.mat'],'adjDI','adjCI','-v7.3')
%
% %%
% % clear
% baseDir='~/data/sleep/pooled_withCohEMG/';
% coreName='sleep';
%
% load([baseDir coreName '-' 'timeNorm_stateChange_fineBins' '.mat'])
% load([baseDir coreName '-' 'adjDI' '.mat'])
%
% newDI=adjDI;
% newCI=adjCI;
% %%
% origX=13;
% origY=13;
% panelLetterSize=12;
% letterGapX=10;
% letterGapY=5;
% marginX=15;
% marginY=12;
% timeNormWidth=40;
% height=22;
% ciWidth=25;
%
% %%
% stateList={'nrem2rem','rem2nrem','nrem','rem','quiet2nrem','nrem2quiet','rem2quiet'};
% % stateList=fieldnames(newCI)
%
% %%
% close all
% fh=initFig4Nature(2);
%
% orderList={'mean','onset','offset'};
% for sIdx=1:length(stateList);
%     stateName=stateList{sIdx};
%
%     sep=findstr(stateName,'2')
%
%     if ~isempty(sep)
%         orderText={'by mean',['at ' upper(stateName(1:sep-1)) ' offset'],['at ' upper(stateName(sep+1:end)) ' onset']}
%         oldOrderTypeList={'both','offset','onset'}
%     else
%         orderText={'by mean',['at ' upper(stateName) ' onset'],['at ' upper(stateName) ' offset']};
%         oldOrderTypeList={'mean','onset','offset'}
%     end
%
%     for oIdx=1:length(orderList)
%         orderType=orderList{oIdx};
%         oldOrderType=oldOrderTypeList{oIdx};
%
%         xPos=origX+mod(sIdx-1,4)*(ciWidth+marginX);
%         yPos=origY+(3.5*(sIdx>4)+(oIdx-1))*(height+marginY);
%
%         subplotInMM(xPos,yPos,ciWidth,height,true);
%
%         temp=sort(newCI.(stateName).(orderType).shuffle.firstBin);
%         confInt.first=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);
%
%         temp=sort(newCI.(stateName).(orderType).shuffle.lastBin);
%         confInt.last=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);
%
%         temp=sort(shuffle.ci.(stateName).(oldOrderType)');
%         confInt.old=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);
%
%
%         hold on
%         bar(1:5,newCI.(stateName).(orderType).real.mean(1:5),'faceColor',[0,0,0])
%         bar(6,newCI.(stateName).(orderType).real.mean(6),'faceColor',[1,1,1])
%         fill([1:6,6:-1:1],[confInt.first(1,:),fliplr(confInt.first(2,:))],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
%         fill([1:6,6:-1:1],[confInt.last(1,:),fliplr(confInt.last(2,:))],[0,0,1],'faceAlpha',0.5,'edgeColor','none')
%         fill([1:6,6:-1:1],[confInt.old(1,:),fliplr(confInt.old(2,:))],[0,0.8,0],'faceAlpha',0.5,'edgeColor','none')
%         set(gca,'xtick',[1,3,5,6],'XTickLabel',{'L','M','H','I'})
%
%
%         title({strrep(upper(stateName),'2',' to '),['Ordered ' orderText{oIdx}]})
%         ylabel('CI')
%         xlim([0.5,6.5])
%     end
% end
%
% sIdx=length(stateList)+1;
% oIdx=1;
% xPos=origX+mod(sIdx-1,4)*(ciWidth+marginX);
% yPos=origY+(3.5*(sIdx>4)+(oIdx-1))*(height+marginY);
%
% subplotInMM(xPos,yPos,ciWidth,height,true);
% xlim([0,1])
% ylim([0,1])
%
% hold on
% rectangle('position',[0,0.8,0.2,0.1],'facecolor',[0,0,0])
% text(0.22,0.85,'Pyramidal cell','horizontalAlign','left','verticalAlign','middle')
%
% rectangle('position',[0,0.6,0.2,0.1],'facecolor',[1,1,1])
% text(0.22,0.65,'Interneuron','horizontalAlign','left','verticalAlign','middle')
%
% fill([0,0.2,0.2,0],[0.4,0.4,0.5,0.5],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
% text(0.22,0.45,'95% CI of first bin shuffling','horizontalAlign','left','verticalAlign','middle')
%
% fill([0,0.2,0.2,0],[0.2,0.2,0.3,0.3],[0,0,1],'faceAlpha',0.5,'edgeColor','none')
% text(0.22,0.25,'95% CI of last bin shuffling','horizontalAlign','left','verticalAlign','middle')
% axis off
%
% fill([0,0.2,0.2,0],[0.0,0.0,0.1,0.1],[0,0.8,0],'faceAlpha',0.5,'edgeColor','none')
% text(0.22,0.05,'95% CI of old shuffling method','horizontalAlign','left','verticalAlign','middle')
% axis off
%
% addScriptName(mfilename)
% figName1='~/Dropbox/Quantile/preliminary/adjDI_summary_1.pdf';
% print(figName1,'-dpdf','-painters')
%
% %%
% % close all
% fh=initFig4Nature(2);
%
% for sIdx=1:length(stateList)
%     stateName=stateList{sIdx};
%
%     sep=findstr(stateName,'2');
%
%     if ~isempty(sep)
%         orderText={'by mean',['at ' upper(stateName(1:sep-1)) ' offset'],['at ' upper(stateName(sep+1:end)) ' onset']}
%         oldOrderTypeList={'both','offset','onset'}
%     else
%         orderText={'by mean',['at ' upper(stateName) ' onset'],['at ' upper(stateName) ' offset']};
%         oldOrderTypeList={'mean','onset','offset'}
%     end
%
%     for oIdx=1:length(orderList)
%         orderType=orderList{oIdx};
%         oldOrderType=oldOrderTypeList{oIdx};
%
%         xPos=origX+mod(sIdx-1,4)*(ciWidth+marginX);
%         yPos=origY+(3.5*(sIdx>4)+(oIdx-1))*(height+marginY);
%
%         subplotInMM(xPos,yPos,ciWidth,height,true);
%
%         hold on
%         bar((1:5)-0.31,newDI.(stateName).(orderType).firstBin.mean(1:5),0.3,'facecolor',[0.8,0,0],'edgeColor','none');
%         bar((1:5)+0,newDI.(stateName).(orderType).lastBin.mean(1:5),0.3,'facecolor',[0,0,0.8],'edgeColor','none');
%
%         temp=sort(shuffle.ci.(stateName).(oldOrderType)');
%         oldDInull=mean(temp);
%         confInt.old=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:)-oldDInull;
%         bar((1:5)+0.31,real.ci.(stateName).(oldOrderType).mean(1:5)-oldDInull(1:5),0.3,'facecolor',[0,0.8,0],'edgeColor','none')
%
%         bar(6-0.31,newDI.(stateName).(orderType).firstBin.mean(6),0.3,'facecolor',[1,1,1],'edgeColor',[0.8,0,0],'lineWidth',1);
%         bar(6+0,newDI.(stateName).(orderType).lastBin.mean(6),0.3,'facecolor',[1,1,1],'edgeColor',[0,0,0.8],'lineWidth',1);
%         bar(6+0.31,real.ci.(stateName).(oldOrderType).mean(6)-oldDInull(6),0.3,'facecolor',[1,1,1],'edgeColor',[0,0.8,0])
%         confInt.first=newDI.(stateName).(orderType).firstBin.confInt-newDI.(stateName).(orderType).firstBin.null;
%         confInt.last=newDI.(stateName).(orderType).lastBin.confInt-newDI.(stateName).(orderType).lastBin.null;
%
%         fill([1:6,6:-1:1]-0.31,[confInt.first(1,:),fliplr(confInt.first(2,:))],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
%         fill([1:6,6:-1:1]+0,[confInt.last(1,:),fliplr(confInt.last(2,:))],[0,0,1],'faceAlpha',0.5,'edgeColor','none')
%         fill([1:6,6:-1:1]+0.31,[confInt.old(1,:),fliplr(confInt.old(2,:))],[0,0.8,0],'faceAlpha',0.5,'edgeColor','none')
%         set(gca,'xtick',[1,3,5,6],'XTickLabel',{'L','M','H','I'})
%
%
%         title({strrep(upper(stateName),'2',' to '),['Ordered ' orderText{oIdx}]})
%         ylabel('DI')
%         xlim([0.5,6.5])
%     end
% end
%
% sIdx=length(stateList)+1;
% oIdx=1;
% xPos=origX+mod(sIdx-1,4)*(ciWidth+marginX);
% yPos=origY+(3.5*(sIdx>4)+(oIdx-1))*(height+marginY);
%
% subplotInMM(xPos,yPos,ciWidth,height,true);
% xlim([0,1])
% ylim([0,1])
%
% hold on
%
% fill([0,0.2,0.2,0],[0.4,0.4,0.5,0.5],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
% text(0.22,0.45,'Based on first bin shuffling','horizontalAlign','left','verticalAlign','middle')
%
% fill([0,0.2,0.2,0],[0.2,0.2,0.3,0.3],[0,0,1],'faceAlpha',0.5,'edgeColor','none')
% text(0.22,0.25,'Based on last bin shuffling','horizontalAlign','left','verticalAlign','middle')
%
% fill([0,0.2,0.2,0],[0.0,0.0,0.1,0.1],[0,0.8,0],'faceAlpha',0.5,'edgeColor','none')
% text(0.22,0.05,'Old DI method','horizontalAlign','left','verticalAlign','middle')
% axis off
%
% addScriptName(mfilename)
% figName2='~/Dropbox/Quantile/preliminary/adjDI_summary_2.pdf';
% print(figName2,'-dpdf','-painters')
%
% %%
% figName='~/Dropbox/Quantile/preliminary/adjDI_summary.pdf';
% combinePDFs(figName,{figName1,figName2},'remove',true)
%
%



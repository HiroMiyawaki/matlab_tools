clear 
baseDir='~/data/sleep/pooled_withCohEMG/';
coreName='sleep';

load([baseDir coreName '-' 'newDI' '.mat'])
load([baseDir coreName '-' 'timeNorm_stateChange_fineBins' '.mat'])

%%
origX=13;
origY=13;
panelLetterSize=12;
letterGapX=10;
letterGapY=5;
marginX=15;
marginY=12;
timeNormWidth=40;
height=22;
ciWidth=25;

%%
stateList={'nrem2rem','rem2nrem','nrem','rem','quiet2nrem','nrem2quiet','rem2quiet'};
% stateList=fieldnames(newCI)

%%
close all
fh=initFig4Nature(2);

orderList={'mean','onset','offset'};
for sIdx=1:length(stateList);
    stateName=stateList{sIdx};
    
    sep=findstr(stateName,'2')
    
    if ~isempty(sep)
        orderText={'by mean',['at ' upper(stateName(1:sep-1)) ' offset'],['at ' upper(stateName(sep+1:end)) ' onset']}
        oldOrderTypeList={'both','offset','onset'}
    else
        orderText={'by mean',['at ' upper(stateName) ' onset'],['at ' upper(stateName) ' offset']};
        oldOrderTypeList={'mean','onset','offset'}
    end
    
    for oIdx=1:length(orderList)
        orderType=orderList{oIdx};
        oldOrderType=oldOrderTypeList{oIdx};
        
        xPos=origX+mod(sIdx-1,4)*(ciWidth+marginX);
        yPos=origY+(3.5*(sIdx>4)+(oIdx-1))*(height+marginY);
        
        subplotInMM(xPos,yPos,ciWidth,height,true);
        
        temp=sort(newCI.(stateName).(orderType).shuffle.firstBin);
        confInt.first=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);
        
        temp=sort(newCI.(stateName).(orderType).shuffle.lastBin);
        confInt.last=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);

        temp=sort(shuffle.ci.(stateName).(oldOrderType)');
        confInt.old=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);
        
        
        hold on
        bar(1:5,newCI.(stateName).(orderType).real.mean(1:5),'faceColor',[0,0,0])
        bar(6,newCI.(stateName).(orderType).real.mean(6),'faceColor',[1,1,1])
        fill([1:6,6:-1:1],[confInt.first(1,:),fliplr(confInt.first(2,:))],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
        fill([1:6,6:-1:1],[confInt.last(1,:),fliplr(confInt.last(2,:))],[0,0,1],'faceAlpha',0.5,'edgeColor','none')
        fill([1:6,6:-1:1],[confInt.old(1,:),fliplr(confInt.old(2,:))],[0,0.8,0],'faceAlpha',0.5,'edgeColor','none')
        set(gca,'xtick',[1,3,5,6],'XTickLabel',{'L','M','H','I'})
        
        
        title({strrep(upper(stateName),'2',' to '),['Ordered ' orderText{oIdx}]})
        ylabel('CI')
        xlim([0.5,6.5])
    end
end

sIdx=length(stateList)+1;
oIdx=1;
xPos=origX+mod(sIdx-1,4)*(ciWidth+marginX);
yPos=origY+(3.5*(sIdx>4)+(oIdx-1))*(height+marginY);

subplotInMM(xPos,yPos,ciWidth,height,true);
xlim([0,1])
ylim([0,1])

hold on
rectangle('position',[0,0.8,0.2,0.1],'facecolor',[0,0,0])
text(0.22,0.85,'Pyramidal cell','horizontalAlign','left','verticalAlign','middle')

rectangle('position',[0,0.6,0.2,0.1],'facecolor',[1,1,1])
text(0.22,0.65,'Interneuron','horizontalAlign','left','verticalAlign','middle')

fill([0,0.2,0.2,0],[0.4,0.4,0.5,0.5],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
text(0.22,0.45,'95% CI of first bin shuffling','horizontalAlign','left','verticalAlign','middle')

fill([0,0.2,0.2,0],[0.2,0.2,0.3,0.3],[0,0,1],'faceAlpha',0.5,'edgeColor','none')
text(0.22,0.25,'95% CI of last bin shuffling','horizontalAlign','left','verticalAlign','middle')
axis off

fill([0,0.2,0.2,0],[0.0,0.0,0.1,0.1],[0,0.8,0],'faceAlpha',0.5,'edgeColor','none')
text(0.22,0.05,'95% CI of old shuffling method','horizontalAlign','left','verticalAlign','middle')
axis off

addScriptName(mfilename)
figName='~/Dropbox/Quantile/preliminary/newDI_summary1.pdf';
print(figName,'-dpdf','-painters')

%%
% close all
fh=initFig4Nature(2);

for sIdx=1:length(stateList)
    stateName=stateList{sIdx};
    
    sep=findstr(stateName,'2');
    
    if ~isempty(sep)
        orderText={'by mean',['at ' upper(stateName(1:sep-1)) ' offset'],['at ' upper(stateName(sep+1:end)) ' onset']}
        oldOrderTypeList={'both','offset','onset'}
    else
        orderText={'by mean',['at ' upper(stateName) ' onset'],['at ' upper(stateName) ' offset']};
        oldOrderTypeList={'mean','onset','offset'}
    end
    
    for oIdx=1:length(orderList)
        orderType=orderList{oIdx};
        oldOrderType=oldOrderTypeList{oIdx};
        
        xPos=origX+mod(sIdx-1,4)*(ciWidth+marginX);
        yPos=origY+(3.5*(sIdx>4)+(oIdx-1))*(height+marginY);
        
        subplotInMM(xPos,yPos,ciWidth,height,true);
        
        hold on
        bar((1:5)-0.31,newDI.(stateName).(orderType).firstBin.mean(1:5),0.3,'facecolor',[0.8,0,0],'edgeColor','none');
        bar((1:5)+0,newDI.(stateName).(orderType).lastBin.mean(1:5),0.3,'facecolor',[0,0,0.8],'edgeColor','none');
        
        temp=sort(shuffle.ci.(stateName).(oldOrderType)');
        oldDInull=mean(temp);
        confInt.old=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:)-oldDInull;
        bar((1:5)+0.31,real.ci.(stateName).(oldOrderType).mean(1:5)-oldDInull(1:5),0.3,'facecolor',[0,0.8,0],'edgeColor','none')
        
        bar(6-0.31,newDI.(stateName).(orderType).firstBin.mean(6),0.3,'facecolor',[1,1,1],'edgeColor',[0.8,0,0],'lineWidth',1);
        bar(6+0,newDI.(stateName).(orderType).lastBin.mean(6),0.3,'facecolor',[1,1,1],'edgeColor',[0,0,0.8],'lineWidth',1);
        bar(6+0.31,real.ci.(stateName).(oldOrderType).mean(6)-oldDInull(6),0.3,'facecolor',[1,1,1],'edgeColor',[0,0.8,0])
        confInt.first=newDI.(stateName).(orderType).firstBin.confInt-newDI.(stateName).(orderType).firstBin.null;
        confInt.last=newDI.(stateName).(orderType).lastBin.confInt-newDI.(stateName).(orderType).lastBin.null;
        
        fill([1:6,6:-1:1]-0.31,[confInt.first(1,:),fliplr(confInt.first(2,:))],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
        fill([1:6,6:-1:1]+0,[confInt.last(1,:),fliplr(confInt.last(2,:))],[0,0,1],'faceAlpha',0.5,'edgeColor','none')
        fill([1:6,6:-1:1]+0.31,[confInt.old(1,:),fliplr(confInt.old(2,:))],[0,0.8,0],'faceAlpha',0.5,'edgeColor','none')
        set(gca,'xtick',[1,3,5,6],'XTickLabel',{'L','M','H','I'})
        
        
        title({strrep(upper(stateName),'2',' to '),['Ordered ' orderText{oIdx}]})
        ylabel('DI')
        xlim([0.5,6.5])
    end
end

sIdx=length(stateList)+1;
oIdx=1;
xPos=origX+mod(sIdx-1,4)*(ciWidth+marginX);
yPos=origY+(3.5*(sIdx>4)+(oIdx-1))*(height+marginY);

subplotInMM(xPos,yPos,ciWidth,height,true);
xlim([0,1])
ylim([0,1])

hold on

fill([0,0.2,0.2,0],[0.4,0.4,0.5,0.5],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
text(0.22,0.45,'Based on first bin shuffling','horizontalAlign','left','verticalAlign','middle')

fill([0,0.2,0.2,0],[0.2,0.2,0.3,0.3],[0,0,1],'faceAlpha',0.5,'edgeColor','none')
text(0.22,0.25,'Based on last bin shuffling','horizontalAlign','left','verticalAlign','middle')

fill([0,0.2,0.2,0],[0.0,0.0,0.1,0.1],[0,0.8,0],'faceAlpha',0.5,'edgeColor','none')
text(0.22,0.05,'Old DI method','horizontalAlign','left','verticalAlign','middle')
axis off

addScriptName(mfilename)
figName2='~/Dropbox/Quantile/preliminary/newDI_summary2.pdf';
print(figName2,'-dpdf','-painters')

%%
! /usr/local/bin/gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=/Users/miyawaki/Dropbox/Quantile/preliminary/newDI_summary.pdf /Users/miyawaki//Dropbox/Quantile/preliminary/newDI_summary1.pdf /Users/miyawaki//Dropbox/Quantile/preliminary/newDI_summary2.pdf
eval(['! rm ' figName])
eval(['! rm ' figName2])


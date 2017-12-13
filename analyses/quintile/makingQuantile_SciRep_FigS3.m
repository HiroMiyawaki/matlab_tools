% 
% quintileS1_earlyLate_fllowWakeRemInh
% quintileS1_earlyLate_fllowWakeRem
% quintileS1_earlyLate_fllowWakeRem_exLow
% quintileS1_earlyLate_fllowWakeRemInh_exLow

% quintileS1_earlyLate_Rem_followingWake
% quintileS1_earlyLate_Rem_followingWakeInh

%%
clearvars -except AddLabelFlag

showMI=true; %for delta log(Hz), set false

exLow=false;

if exLow
    postFix='exLow';
else
    postFix='';
end


%1 NREM: 'quiet2nrem'
%2 NREM: 'rem2nrem'
%3 NREM: 'nrem2quiet'
%4 NREM: 'nrem2rem'
%5 NREM: 'rem2nrem2rem';
%6 REM: rem2nrem;
%7 REM: rem2quiet;

toUse=[1,5,3,6,7];
panelIdxList=1:5;
titleText={'NREM following wake' 'NREM Interleaving REM' 'NREM preceding wake','REM preceding NREM','REM preceding wake'};
periodName={'Light cycle - early','Light cycle - late','Dark cycle - early','Dark cycle - late'};

for epochIdx=1:length(toUse)
    panelIdx=panelIdxList(epochIdx);
    for pIdx=1:length(periodName)
        panel1.(alphabet(panelIdx))(pIdx)=loadGraph('quantileS2', [alphabet(toUse(epochIdx)+4) '1' alphabet(pIdx) postFix]);
        panel1b.(alphabet(panelIdx))(pIdx)=loadGraph('quantileS2', [alphabet(toUse(epochIdx)+4) '1' alphabet(pIdx) 'Inh' postFix]);

        panel4.(alphabet(panelIdx))(pIdx)=loadGraph('quantileS2', [alphabet(toUse(epochIdx)+4) '4a' num2str(pIdx) postFix]);
        panel4b.(alphabet(panelIdx))(pIdx)=loadGraph('quantileS2', [alphabet(toUse(epochIdx)+4) '4a'  num2str(pIdx) 'Inh' postFix]);

        panel4b.(alphabet(panelIdx))(pIdx).xValue=max(panel4.(alphabet(panelIdx))(pIdx).xValue)+1;
        panel4.(alphabet(panelIdx))(pIdx).title=titleText{epochIdx};
    end
end

for pIdx=1:length(periodName)
    for epochIdx=1:length(toUse)
        if toUse(epochIdx)>5
            panel4.(alphabet(epochIdx))(pIdx).info.YLim=[-0.5,0.2];
            panel4.(alphabet(epochIdx))(pIdx).info.YTick=-0.4:0.2:0.2;
        else
            panel4.(alphabet(epochIdx))(pIdx).info.YLim=[-0.2,0.18];
            panel4.(alphabet(epochIdx))(pIdx).info.YTick=-0.2:0.1:0.1;
        end
        panel4.(alphabet(epochIdx))(pIdx).info.YTickLabel=panel4.(alphabet(epochIdx))(pIdx).info.YTick;
    end
end
colError=0.5*[1,1,1];

%%


close all
origX=20;
origY=20;
panelLetterSize=12;
letterGapX=10;
letterGapY=12;
marginX=19;
marginY=22;
innerMarginY=16;
innerMarginX=18;
width=20;
height=width*2/3;


% fh=initFig4JNeuro(2);
fh=initFig4SleepSup(2);
set(fh,'defaultLineMarkerSize',1)
isPanelLetterCapital=true;

cLim=[0,0.3];
%%
totalGapX=0;
totalGapY=0;

for panelIdx=1:length(fieldnames(panel4))
    for pIdx=1:length(panel4.((alphabet(panelIdx))))
        target=panel4.(alphabet(panelIdx))(pIdx);
        targetB=panel4b.(alphabet(panelIdx))(pIdx);
        
    
        xPos=origX+(panelIdx-1)*(width+marginX);
        yPos=origY+(pIdx-1)*(height+marginY);
        xPos=xPos+totalGapX;
        yPos=yPos+totalGapY;

        subplotInMM(xPos,yPos,width,height,true)

        fill([target.xValue,fliplr(target.xValue)],...
            [target.legend.confInt(1,:),fliplr(target.legend.confInt(2,:))],...
            colError,'linestyle','none','facealpha',0.5)
        hold on
    
    
        restoreGraph(target)
         hold on
        plot(targetB.xValue*[1,1],targetB.yValue+targetB.error*[0,2*(targetB.yValue>0)-1],...
            '-','color',target.color(1,:))
        bar(targetB.xValue,targetB.yValue,'facecolor',0.999*[1,1,1],'edgecolor',target.color(1,:))
        xlim([0.25,6.75])
        set(gca,'xtick',1:6,'xticklabel',{1,2,3,4,5,'Inh'})

        
        for idx=1:length(target.xValue)
            if target.yValue(idx)>0
                text(target.xValue(idx),target.yValue(idx)+target.error(idx),...
                    getSigText(target.legend.p(idx)),'horizontalAlign','center','verticalAlign','middle')
            else
                text(target.xValue(idx),target.yValue(idx)-target.error(idx),...
                    getSigText(target.legend.p(idx)),'horizontalAlign','center','verticalAlign','top')
            end
            if targetB.yValue>0
                text(targetB.xValue,targetB.yValue+targetB.error,...
                    getSigText(targetB.legend.p),'horizontalAlign','center','verticalAlign','middle')
            else
                text(targetB.xValue,targetB.yValue-targetB.error,...
                    getSigText(targetB.legend.p),'horizontalAlign','center','verticalAlign','top')
            end   
        end
        
        ax=fixAxis;
        
     
        nPyr=sum(cellfun(@length,panel1.(alphabet(panelIdx))(pIdx).xValue));
        nInh=sum(cellfun(@length,panel1b.(alphabet(panelIdx))(pIdx).xValue));
       text2(0.7,1,{['\color[rgb]{0,0,0}n = ' num2str(nPyr)]
                     ['\color[rgb]{0.5,0.5,0.5}n = ' num2str(nInh)]},ax,...
            {'horizontalAlign','left','verticalALign','bottom'})

        title('');
        if pIdx==1
            text2(0.5,1.5,target.title,ax,{'horizontalAlign','center','verticalALign','bottom'})
            panelLetter(xPos-letterGapX,yPos-letterGapY,alphabet(panelIdx,isPanelLetterCapital),panelLetterSize)
        end
        if panelIdx==1
            text2(-0.6,0.5,periodName{pIdx},ax,...
                {'horizontalALign','center','verticalAlign','bottom','rotation',90,'fontsize',10})
        end


    end
end    
  

%%
figNum=['S3' postFix];

if ~exist('AddLabelFlag','var') || AddLabelFlag
    addFigureLabel(['Figure ' figNum])
end
saveDir='~/Dropbox/Quantile';


if ~exist(saveDir,'dir')
    mkdir(saveDir)
end
if ~exist([saveDir '/eps/'],'dir')
    mkdir([saveDir '/eps/'])
end
if ~exist([saveDir '/pdf/'],'dir')
    mkdir([saveDir '/pdf/'])
end
% % 
% print(fh,[saveDir '/eps/' 'QuantileFig' figNum '.eps'],'-depsc')
% print(fh,[saveDir '/pdf/' 'QuantileFig' figNum '.pdf'],'-dpdf')
% % 


    
    
    
    
    
    
    
    
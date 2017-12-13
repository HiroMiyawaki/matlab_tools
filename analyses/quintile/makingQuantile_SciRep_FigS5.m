% quintile6_zScore
% % quintile6_zScore_1minWake
% quintile6_zScoreExLow
% % quintile6_zScoreTripletsMean
% % quintile6_zScoreWakePrePostSleep
% quintile7_percent
% quintile7_percentInh

%%
%%
clearvars -except AddLabelFlag

exLow=false;
if exLow
    postFix='exLow'
else
    postFix='';
end

%% modulation index
%% zscore
indexLetter='a';
%within epochs
% % within wake
summaryPanels.(indexLetter){1}=loadGraph('quantile7','j4a');
summaryPanelsInh.(indexLetter){1}=loadGraph('quantile7','j4aInh');
summaryPanels.(indexLetter){1}.title='Within wake';
% % within nrem
summaryPanels.(indexLetter){2}=loadGraph('quantile7',['a4a' postFix]);
summaryPanelsInh.(indexLetter){2}=loadGraph('quantile7',['a4aInh' postFix]);
% % within rem
summaryPanels.(indexLetter){3}=loadGraph('quantile7','b4a');
summaryPanelsInh.(indexLetter){3}=loadGraph('quantile7','b4aInh');

%across transition
% % wake to nrem
% panels.(indexLetter){4}=loadGraph('quantile7',['g4a' postFix]); %1/3 vs 1/3
summaryPanels.(indexLetter){4}=loadGraph('quantile7',['n4a' postFix]); % min vs 1/3
summaryPanelsInh.(indexLetter){4}=loadGraph('quantile7',['n4aINh' postFix]); % min vs 1/3
summaryPanels.(indexLetter){4}.title='Wake to non-REM';
% % nrem to rem
summaryPanels.(indexLetter){5}=loadGraph('quantile7',['c4a' postFix]);
summaryPanelsInh.(indexLetter){5}=loadGraph('quantile7',['c4aInh' postFix]);
% % rem to nrem
summaryPanels.(indexLetter){6}=loadGraph('quantile7',['d4a' postFix]);
summaryPanelsInh.(indexLetter){6}=loadGraph('quantile7',['d4aInh' postFix]);
% % nrem to wake
% panels.(indexLetter){7}=loadGraph('quantile7',['h4a' postFix]); %1/3 vs 1/3
summaryPanels.(indexLetter){7}=loadGraph('quantile7',['o4a' postFix]); % 1/3 vs min
summaryPanelsInh.(indexLetter){7}=loadGraph('quantile7',['o4aInh' postFix]); % 1/3 vs min
% % rem to wake
% panels.(indexLetter){8}=loadGraph('quantile7','i4a'); %1/3 vs 1/3
summaryPanels.(indexLetter){8}=loadGraph('quantile7','p4a'); % 1/3 vs min
summaryPanelsInh.(indexLetter){8}=loadGraph('quantile7','p4aInh'); % 1/3 vs min

%across triplets
% % nrem/rem/nrem
% panels.(indexLetter){9}=loadGraph('quantile7',['e4a' postFix]);%1/3 vs 1/3
summaryPanels.(indexLetter){9}=loadGraph('quantile7',['q4a' postFix]); % mean vs mean
summaryPanelsInh.(indexLetter){9}=loadGraph('quantile7',['q4aInh' postFix]); % mean vs mean
% % rem/nrem/rem
% panels.(indexLetter){10}=loadGraph('quantile7','f4a');%1/3 vs 1/3
summaryPanels.(indexLetter){10}=loadGraph('quantile7','r4a');% mean vs mean
summaryPanelsInh.(indexLetter){10}=loadGraph('quantile7','r4aInh');% mean vs mean

% % wake pre vs post sleep
summaryPanels.(indexLetter){11}=loadGraph('quantile7','s4a');
summaryPanelsInh.(indexLetter){11}=loadGraph('quantile7','s4aInh');
summaryPanels.(indexLetter){11}.title='Wake_i/sleep/wake_{i+1}';
yRangeWidth=110;
indexLetter='a';
for idx=1:length(summaryPanels.(indexLetter))
    
    yMin=min([summaryPanels.(indexLetter){idx}.yValue+...
        (2*(summaryPanels.(indexLetter){idx}.yValue>0)-1).*summaryPanels.(indexLetter){idx}.error,0]);
    yMax=max([summaryPanels.(indexLetter){idx}.yValue+...
        (2*(summaryPanels.(indexLetter){idx}.yValue>0)-1).*summaryPanels.(indexLetter){idx}.error,0]);
    
    summaryPanels.(indexLetter){idx}.info.YLim=[yMin,yMax]+(yRangeWidth-(yMax-yMin))/2*[-1,1];
    summaryPanels.(indexLetter){idx}.info.YTick=-1.5:0.5:0.5;
    summaryPanels.(indexLetter){idx}.info.YTickLabel=summaryPanels.a{idx}.info.YTick;
end
%%
for let=1:length(fieldnames(summaryPanels))
for idx=1:length(summaryPanels.(indexLetter))
    summaryPanels.(alphabet(let)){idx}.title=...
        strrep(summaryPanels.(alphabet(let)){idx}.title,'non-REM','NREM')
    summaryPanels.(alphabet(let)){idx}.title=...
        strrep(summaryPanels.(alphabet(let)){idx}.title,'Non-REM','NREM')
end
end
measureType.(indexLetter)='Deflection of \Delta FR(%)';

summryScale.a=50;

%%
col.wake=hsv2rgb([0,0.5,1]);
col.nrem=hsv2rgb([2/3,0.5,1]);
col.rem=hsv2rgb([9/12,0.5,1]);

%%
% close all
origX=15;
origY=14;
panelLetterSize=12;
letterGapX=10;
letterGapY=10;
marginX=26;
marginY=10;
innerMarginY=18;
innerMarginX=18;
normalWidth=18;
normalHeight=27;
largerWidth=normalWidth;
largerHeight=normalHeight;

bandHeight=4;
bandGap=2;
stateWidth=180;

withinMargin=6;
halfWidthTransBar=3;
barGap=1;
barHeight=1.5;
barHeightTrans=6;
subPlotMarginY=5;

stateFontSize=9;

xLabelHight=7;

stateHeight=2*(normalHeight+subPlotMarginY)+barHeight+barGap+bandHeight+barGap+barHeight+subPlotMarginY*2+largerHeight+xLabelHight+1;

% fh=initFig4JNeuro(2);

isPanelLetterCapital=true;
cLim=[0,0.3];
colError=0.5*[1,1,1];
unit.a='%'
%%
close all
fh=initFig4SleepSup(2);
set(fh,'defaultLineMarkerSize',1)


%%
for typeIdx=1:length(fieldnames(summaryPanels))
totalGapY=(stateHeight+marginY)*(typeIdx-1);
totalGapX=0;

xPos=origX+totalGapX;
yPos=origY+totalGapY;

subplotInMM(xPos,yPos,stateWidth,stateHeight,true)
xlim([0,stateWidth]);
ylim([0,stateHeight]);
set(gca,'yDir','reverse')
epochWidth=stateWidth/14*3;

hold on

baseline=2*(normalHeight+subPlotMarginY)+barHeight+barGap;
%show states as band
rectangle('position',[0,baseline,epochWidth,bandHeight],'linestyle','none','facecolor',col.wake)
text((0+1/2)*epochWidth,baseline+bandHeight/2,'Wake',...
    'horizontalALign','center','verticalAlign','middle','fontsize',stateFontSize)

rectangle('position',[epochWidth,baseline,epochWidth,bandHeight],'linestyle','none','facecolor',col.nrem)
text((1+1/2)*epochWidth,baseline+bandHeight/2,'NREM',...
    'horizontalALign','center','verticalAlign','middle','fontsize',stateFontSize)

rectangle('position',[2*epochWidth,baseline,epochWidth,bandHeight],'linestyle','none','facecolor',col.rem)
text((2+1/2)*epochWidth,baseline+bandHeight/2,'REM',...
    'horizontalALign','center','verticalAlign','middle','fontsize',stateFontSize)

rectangle('position',[3*epochWidth,baseline,2/3*epochWidth,bandHeight],'linestyle','none','facecolor',col.nrem)
text((3+2/3/2)*epochWidth,baseline+bandHeight/2,'NREM',...
    'horizontalALign','center','verticalAlign','middle','fontsize',stateFontSize)

rectangle('position',[(3+2/3)*epochWidth,baseline,epochWidth,bandHeight],'linestyle','none','facecolor',col.rem)
text((3+2/3+2/3/2)*epochWidth,baseline+bandHeight/2,'REM',...
    'horizontalALign','center','verticalAlign','middle','fontsize',stateFontSize)

rectangle('position',[(3+4/3)*epochWidth,baseline,1/3*epochWidth,bandHeight],'linestyle','none','facecolor',col.wake)
text((3+4/3+1/3/2)*epochWidth,baseline+bandHeight/2,'Wake',...
    'horizontalALign','center','verticalAlign','middle','fontsize',stateFontSize)

rectangle('position',[(3+1/3)*epochWidth,baseline-bandGap-bandHeight,1/3*epochWidth,bandHeight],'linestyle','none','facecolor',col.nrem)
patch((3+1/3)*epochWidth+1/6*epochWidth*[-1,-1,0,0],baseline-bandGap-bandHeight*[0,1,1,0],[0,0,1,1],...
    'linestyle','none','FaceVertexCData',[1,1,1;1,1,1;col.nrem;col.nrem])
text((3+1/3+1/3/2-1/24)*epochWidth,baseline-bandGap-bandHeight+bandHeight/2,'NREM',...
    'horizontalALign','center','verticalAlign','middle','fontsize',stateFontSize)

rectangle('position',[(3+2/3)*epochWidth,baseline-bandGap-bandHeight,1/3*epochWidth,bandHeight],'linestyle','none','facecolor',col.wake)
patch(4*epochWidth+1/6*epochWidth*[1,1,0,0],baseline-bandGap-bandHeight*[0,1,1,0],[0,0,1,1],...
    'linestyle','none','FaceVertexCData',[1,1,1;1,1,1;col.wake;col.wake])
text((3+2/3+1/3/2+1/24)*epochWidth,baseline-bandGap-bandHeight+bandHeight/2,'Wake',...
    'horizontalALign','center','verticalAlign','middle','fontsize',stateFontSize)

%within states
% plot(epochWidth*(0+[0,0,1,1])+withinMargin.*[1,1,-1,-1],baseline-barGap-barHeight*[0,1,1,0],'k-')
% plot(epochWidth*(1+[0,0,1,1])+withinMargin.*[1,1,-1,-1],baseline-barGap-barHeight*[0,1,1,0],'k-')
% plot(epochWidth*(2+[0,0,1,1])+withinMargin.*[1,1,-1,-1],baseline-barGap-barHeight*[0,1,1,0],'k-')
% plot(0.5*epochWidth*[1,1],baseline-barGap-barHeight-[0,subPlotMarginY],'k-')
% plot(1.5*epochWidth*[1,1],baseline-barGap-barHeight-[0,subPlotMarginY],'k-')
% plot(2.5*epochWidth*[1,1],baseline-barGap-barHeight-[0,subPlotMarginY],'k-')
plot(0.5*epochWidth*[1,1],baseline-barGap-[0,subPlotMarginY],'k-')
plot(1.5*epochWidth*[1,1],baseline-barGap-[0,subPlotMarginY],'k-')
plot(2.5*epochWidth*[1,1],baseline-barGap-[0,subPlotMarginY],'k-')

%across states
% plot(1*epochWidth+halfWidthTransBar.*[-1,-1,1,1],baseline-barGap-barHeightTrans*[0,1,1,0],'k-')
% plot(2*epochWidth+halfWidthTransBar.*[-1,-1,1,1],baseline-barGap-barHeightTrans*[0,1,1,0],'k-')
% plot(3*epochWidth+halfWidthTransBar.*[-1,-1,1,1],baseline-barGap-barHeightTrans*[0,1,1,0],'k-')

plot(1*epochWidth*[1,1],baseline-barGap-[0,normalHeight+bandGap+subPlotMarginY],'k-')
plot(2*epochWidth*[1,1],baseline-barGap-[0,normalHeight+bandGap+subPlotMarginY],'k-')
plot(3*epochWidth*[1,1],baseline-barGap-[0,normalHeight+bandGap+subPlotMarginY],'k-')

% to wake
% plot((3+4/3)*epochWidth+halfWidthTransBar.*[-1,-1,1,1],baseline-barGap-barHeightTrans*[0,1,1,0],'k-')
% plot((3+2/3)*epochWidth+halfWidthTransBar.*[-1,-1,1,1],baseline-bandHeight-bandGap-barGap-barHeight*[0,1,1,0],'k-')

plot((3+4/3)*epochWidth*[1,1],baseline-barGap-[0,subPlotMarginY+bandHeight+bandGap],'k-')
plot((3+2/3)*epochWidth*[1,1],baseline-bandHeight-bandGap-barGap-[0,subPlotMarginY],'k-')

%across triplets
% plot(epochWidth*([1.5,1.5,3+1/3,3+1/3]),baseline+bandHeight+barGap+barHeight*[0,1,1,0],'k-')
% plot(epochWidth*([2.5,2.5,4,4]),baseline+bandHeight+barGap+2*barHeight*[0,1,1,0],'k-')
% plot((1.5*2+(3+1/3)*1)/3*epochWidth*[1,1],...
%      (baseline+bandHeight+barGap)+barHeight+subPlotMarginY*[0,1],'k-')
% plot((2.5*2+4*1)/3*epochWidth*[1,1],...
%      (baseline+bandHeight+barGap)+2*barHeight+(subPlotMarginY-barHeight)*[0,1],'k-')
plot(epochWidth*([1+1/6,1+1/6,3+1/9,3+1/9]),baseline+bandHeight+barGap+barHeight*[0,1,1,0],'k-')
plot(epochWidth*([2+1/6,2+1/6,3+2/3+1/9,3+2/3+1/9]),baseline+bandHeight+barGap+2*barHeight*[0,1,1,0],'k-')

plot(2*epochWidth*[1,1],...
     (baseline+bandHeight+barGap)+barHeight+subPlotMarginY*[0,1],'k-')
plot(3*epochWidth*[1,1],...
     (baseline+bandHeight+barGap)+2*barHeight+(subPlotMarginY-barHeight)*[0,1],'k-')

%wake to wake
plot([1,1,3+4/3,3+4/3]*epochWidth+halfWidthTransBar.*[-1,-1,1,1],...
    baseline+bandHeight+barGap+(barHeight+subPlotMarginY+largerHeight+xLabelHight)*[0,1,1,0],'k-')
plot(4*epochWidth*[1,1],...
     baseline+bandHeight+barGap+barHeight+subPlotMarginY+largerHeight+xLabelHight+subPlotMarginY/2*[-1,0],'k-')
    
 
axPos=get(gca,'position');

subPosList=[0.5*epochWidth,                baseline-barGap-subPlotMarginY;
            1.5*epochWidth                 baseline-barGap-subPlotMarginY;
            2*epochWidth+epochWidth/2      baseline-barGap-subPlotMarginY;
            
            epochWidth,                    baseline-barGap-normalHeight-bandGap-subPlotMarginY; 
            2*epochWidth,                  baseline-barGap-normalHeight-bandGap-subPlotMarginY; 
            3*epochWidth,                  baseline-barGap-normalHeight-bandGap-subPlotMarginY; 
            
            (3+2/3)*epochWidth             baseline-barGap-barHeightTrans-subPlotMarginY;
            (3+4/3)*epochWidth             baseline-barGap-barHeightTrans-subPlotMarginY;
            
%             (1.5*2+(3+1/3)*1)/3*epochWidth baseline+bandHeight+barGap+barHeight+subPlotMarginY+largerWidth;
%             (2.5*2+4*1)/3*epochWidth       baseline+bandHeight+barGap+barHeight+subPlotMarginY+largerWidth;
            2*epochWidth       baseline+bandHeight+barGap+barHeight+subPlotMarginY+largerHeight;
            3*epochWidth       baseline+bandHeight+barGap+barHeight+subPlotMarginY+largerHeight;
            4*epochWidth       baseline+bandHeight+barGap+barHeight+subPlotMarginY+largerHeight+xLabelHight-subPlotMarginY/2;
            ];
             
     
axis off  
        
% panelLetter(xPos-letterGapX,yPos+stateHeight+letterGapY,alphabet(typeIdx,isPanelLetterCapital),panelLetterSize)
% textInMM(xPos,yPos+stateHeight+letterGapY,measureType.(alphabet(typeIdx)),{'fontsize',8})

yRange=diff(summaryPanels.(alphabet(typeIdx)){1}.info.YLim);
scaleNum=yRange/3;


% scalePosX=(4+2/3-1/12)*epochWidth*[1,1];
% scalePosY=baseline-1.5*subPlotMarginY-[0, summryScale.(alphabet(typeIdx))/yRange*normalHeight];
% plot(scalePosX,scalePosY,'k-')
% text(mean(scalePosX)+1,mean(scalePosY),[num2str(summryScale.(alphabet(typeIdx))) unit.(alphabet(typeIdx))])

scalePosX=(4+2/3-1/12)*epochWidth*[1,1];
scalePosY=baseline+bandHeight+1.5*subPlotMarginY+[0, summryScale.(alphabet(typeIdx))/yRange*largerHeight];
plot(scalePosX,scalePosY,'k-')
text(mean(scalePosX)+1,mean(scalePosY),[num2str(summryScale.(alphabet(typeIdx))) unit.(alphabet(typeIdx))])

for idx=1:size(subPosList,1)
    

        switch idx
            case 5
                expantion=1.2;
            case 6
                expantion=1.2;
            case 7
                expantion=1.05;
            case 8
                expantion=1.05;
            otherwise
                expantion=1;
        end
    
    plotWidth=normalWidth;
    plotHeight=normalHeight*expantion;
    summaryPanels.(alphabet(typeIdx)){idx}.info.YLim=...
        summaryPanels.(alphabet(typeIdx)){idx}.info.YLim(2)-...
        [diff(summaryPanels.(alphabet(typeIdx)){idx}.info.YLim)*expantion,0];
    
    
    subXPos=subPosList(idx,1)-plotWidth/2;
    subYPos=subPosList(idx,2);
    subXPos=subXPos/stateWidth*axPos(3)+axPos(1);
    subYPos=(1-subYPos/stateHeight)*axPos(4)+axPos(2);
    subWidth=plotWidth/stateWidth*axPos(3);
    subHeight=plotHeight/stateHeight*axPos(4);

    axes('position', [subXPos,subYPos,subWidth,subHeight])
    restoreGraph(summaryPanels.(alphabet(typeIdx)){idx});
    
    inhVal=summaryPanelsInh.(alphabet(typeIdx)){idx}.yValue;
    inhErr=summaryPanelsInh.(alphabet(typeIdx)){idx}.error;
    hold on
    plot(6*[1,1],inhVal+inhErr*[0,2*(inhVal>0)-1],...
        '-','color',summaryPanels.(alphabet(typeIdx)){idx}.color(1,:))
    bar(6,inhVal,'facecolor',0.999*[1,1,1],'edgecolor',summaryPanels.(alphabet(typeIdx)){idx}.color(1,:))

    box off
    xlim([0.25,6.75])
    set(gca,'xtick',[])
    set(gca,'ytickLabel',[])
    xlabel('');
    ylabel('');
    title('');
    axis off
%     for n=1:length(summaryPanels.(alphabet(typeIdx)){idx}.xValue)
%         if summaryPanels.(alphabet(typeIdx)){idx}.legend.p(n) <0.05
%             
%             if summaryPanels.(alphabet(typeIdx)){idx}.yValue(n)>0
%                 textY=summaryPanels.(alphabet(typeIdx)){idx}.yValue(n)+summaryPanels.(alphabet(typeIdx)){idx}.error(n);
%                 verticalAlign='middle';
%             else
%                 textY=summaryPanels.(alphabet(typeIdx)){idx}.yValue(n)-summaryPanels.(alphabet(typeIdx)){idx}.error(n);
%                 verticalAlign='top';
%             end
%             text(n,textY,getSigText(summaryPanels.(alphabet(typeIdx)){idx}.legend.p(n)),...
%                 'horizontalALign','center','verticalAlign',verticalAlign)
%             
%             
%             
%         end
%             
%     end
%     if ismember(idx,[9,10,11])
%         set(gca,'xcolor','r','ycolor','r')
%     end

    ax=fixAxis;

    
    if ismember(idx,[9,10])
        text2(0.5,0.95,summaryPanels.(alphabet(typeIdx)){idx}.title,ax,...
            {'horizontalALign','center','verticalALign','top'})
    else
        text2(0.5,0,summaryPanels.(alphabet(typeIdx)){idx}.title,ax,...
            {'horizontalALign','center','verticalALign','bottom'})
        set(gca,'xaxisLocation','top')
    end

end
end

%%
figNum=['S5' postFix];

if ~exist('AddLabelFlag','var') || AddLabelFlag
    addFigureLabel(['Figure ' figNum],2.5,0.5)
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

print(fh,[saveDir '/eps/' 'QuantileFig' figNum '.eps'],'-depsc')
print(fh,[saveDir '/pdf/' 'QuantileFig' figNum '.pdf'],'-dpdf')



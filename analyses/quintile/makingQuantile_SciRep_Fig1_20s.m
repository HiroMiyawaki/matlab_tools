% % % ELfig3_quintiles.m
% % quantile2_withinEpoch
% % quintile2_withinEpochInt
% % quantile2_Zscore_withinEpoch
% % quantile2_distribution
% quantile2_withinEpoch20s
% quintile2_withinEpochInt20s
% quantile2_Zscore_withinEpoch20s
% quantile2_distribution20s

% % quantile_nremRemTransient
% % quantil3_distribution
% % quintile3_changeByNremRem
% % quantile_nremRemTransientInh
% % quintile3_changeByNremRemInh
% % quintile3_changeByNremRemWhole
% % quintile3_changeByNremRemWholeInh
% % quantile_nremRemTransientExLow
% % quintile3_changeByNremRemExLow
% % quantil3_distributionExLow
% % quantile_nremRemTransientInhExLow
% % quintile3_changeByNremRemInhExLow
% quantile_nremRemTransient20s
% quantil3_distribution20s
% quintile3_changeByNremRem20s
% quantile_nremRemTransientInh20s
% quintile3_changeByNremRemInh20s
% quintile3_changeByNremRemWhole20s
% quintile3_changeByNremRemWholeInh20s
% quantile_nremRemTransientExLow20s
% quintile3_changeByNremRemExLow20s
% quantil3_distributionExLow20s
% quantile_nremRemTransientInhExLow20s
% quintile3_changeByNremRemInhExLow20s

% % quantile_zScore_nremRemTransient
% quantile_zScore_nremRemTransient20s

% quintile_timeNormalized_withinEpoch
% quintile_timeNormalized_stateTransition
% quintileFig1_examples2

% quintile_timeNormalized_withinEpoch20s
% quintile_timeNormalized_stateTransition20s
% quintile_timeNormalized_withinEpoch20s_rankByThirds
% quintile_timeNormalized_stateTransition20s_rankByThirds
% quintileFig1_examples220s

%%
clearvars -except AddLabelFlag

showMI=true; %for delta log(Hz), set false

exLow=false;

if exLow
    postFix='exLow';
else
    postFix='';
end


exPanel.a=loadGraph('quantile20s2','g1a');
exPanel.b=loadGraph('quantile20s2','g1b');

% 1,2: log Hz
% 3,4: z score
toUse=[1,2]
for epochIdx=1:2
    
    if exLow && epochIdx==1
        figName='quantile20s5';
        toUse(epochIdx)=2;
    else
        figName='quantile20s2';
    end
    
    panel0.(alphabet(epochIdx))=loadGraph('quantile20s2',['f' num2str(epochIdx) 'a']);
    panel0.(alphabet(epochIdx)).xValue(end)=[];
    panel0.(alphabet(epochIdx)).yValue(end)=[];
    panel0.(alphabet(epochIdx)).error(end)=[];
    panel0.(alphabet(epochIdx)).color(end,:)=[];
    panel0.(alphabet(epochIdx)).xlabel='Normalized Time';
    
    panel1.(alphabet(epochIdx))=loadGraph(figName, [alphabet(toUse(epochIdx)) '1']);
    panel1b.(alphabet(epochIdx))=loadGraph(figName, [alphabet(toUse(epochIdx)) '1' 'Inh']);
    panel2.(alphabet(epochIdx))=loadGraph(figName, [alphabet(toUse(epochIdx)) '2']);
    
    if showMI
        panel3.(alphabet(epochIdx))=loadGraph(figName, [alphabet(toUse(epochIdx)) '3a']);
        panel4.(alphabet(epochIdx))=loadGraph(figName, [alphabet(toUse(epochIdx)) '4a']);

        panel3b.(alphabet(epochIdx))=loadGraph(figName, [alphabet(toUse(epochIdx)) '3a' 'inh']);
        panel4b.(alphabet(epochIdx))=loadGraph(figName, [alphabet(toUse(epochIdx)) '4a' 'inh']);
    else
        panel3.(alphabet(epochIdx))=loadGraph(figName, [alphabet(toUse(epochIdx)) '3b']);
        panel4.(alphabet(epochIdx))=loadGraph(figName, [alphabet(toUse(epochIdx)) '4b']);

        panel3b.(alphabet(epochIdx))=loadGraph(figName, [alphabet(toUse(epochIdx)) '3b' 'inh']);
        panel4b.(alphabet(epochIdx))=loadGraph(figName, [alphabet(toUse(epochIdx)) '4b' 'inh']);
    end
    
    panel5.(alphabet(epochIdx))=loadGraph('quantile20s2', ['e' num2str(toUse(epochIdx))]);

    panel3.(alphabet(epochIdx)).type='multiColorBar';
    panel4.(alphabet(epochIdx)).type='multiColorBar';
    
    panel3b.(alphabet(epochIdx)).xValue=max(panel3.(alphabet(epochIdx)).xValue)+1;
    panel4b.(alphabet(epochIdx)).xValue=max(panel4.(alphabet(epochIdx)).xValue)+1;
    
    if epochIdx>2
        panel1.(alphabet(epochIdx)).xlabel={'FR in first 1/3 (z)'};
        panel1.(alphabet(epochIdx)).ylabel={'FR in last 1/3 (z)'};
    else
        panel1.(alphabet(epochIdx)).xlabel={'FR in first 1/3 (Hz)'};
        panel1.(alphabet(epochIdx)).ylabel={'FR in last 1/3 (Hz)'};
    end
    panel2.(alphabet(epochIdx)).xlabel=panel1.(alphabet(epochIdx)).xlabel;
    panel2.(alphabet(epochIdx)).ylabel=panel1.(alphabet(epochIdx)).ylabel;

    if mod(epochIdx,2)==1
        panel2.(alphabet(epochIdx)).title='Within non-REM';
    else
        panel2.(alphabet(epochIdx)).title='Within REM';
    end
    
    panel2.(alphabet(epochIdx)).info.XTick=[-2,0];
    panel2.(alphabet(epochIdx)).info.YTick=[-2,0];
    panel2.(alphabet(epochIdx)).info.XTickLabel={'10^{-2}','10^{0}'};
    panel2.(alphabet(epochIdx)).info.YTickLabel={'10^{-2}','10^{0}'};

    panel3.(alphabet(epochIdx)).xlabel='Quintile';
    panel3.(alphabet(epochIdx)).ylabel='CI';

    panel4.(alphabet(epochIdx)).xlabel='Quintile';
    panel4.(alphabet(epochIdx)).ylabel='DI';
    
    panel2.(alphabet(epochIdx)).yValue=panel2.(alphabet(epochIdx)).yValue/sum(sum(panel2.(alphabet(epochIdx)).yValue))*100;

    panel5.(alphabet(epochIdx)).title='';
    panel5.(alphabet(epochIdx)).xlabel='FR (Hz)';
end
colError=0.5*[1,1,1];
colNrem=hsv2rgb([2/3*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');


panel3.a.color=colNrem;
panel4.a.color=colNrem;



% 1,2: log Hz
% 3,4: z-score
% 6,7: nrem/rem/nrem, rem/nrem/rem 1/3 vs 1/3
% 8,9: nrem/rem/nrem, rem/nrem/rem, mean vs mean

toUse=[1,2];
alphabetGap=2;
for epochIdx=1:2

    panel0.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s2',['f' num2str(epochIdx+2) 'a'])
    panel0.(alphabet(epochIdx+alphabetGap)).xValue(end)=[];
    panel0.(alphabet(epochIdx+alphabetGap)).yValue(end)=[];
    panel0.(alphabet(epochIdx+alphabetGap)).error(end)=[];
    panel0.(alphabet(epochIdx+alphabetGap)).color(end,:)=[];
    panel0.(alphabet(epochIdx+alphabetGap)).xlabel='Normalized Time';
     
    panel1.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '1' postFix]);
    panel1b.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '1' 'Inh' postFix]);
    panel2.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '2' postFix]);
    
    if showMI
        panel3.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '3a' postFix]);
        panel4.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '4a' postFix]);

        panel3b.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '3a' 'Inh' postFix]);
        panel4b.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '4a' 'Inh' postFix]);
    else
        panel3.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '3b' postFix]);
        panel4.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '4b' postFix]);

        panel3b.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '3b' 'Inh' postFix]);
        panel4b.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '4b' 'Inh' postFix]);
    end
    panel3.(alphabet(epochIdx+alphabetGap)).type='multiColorBar';
    panel4.(alphabet(epochIdx+alphabetGap)).type='multiColorBar';

    panel5.(alphabet(epochIdx+alphabetGap))=loadGraph('quantile20s3', ['e' num2str(toUse(epochIdx)-(toUse(epochIdx)>4)) postFix]);

    panel3b.(alphabet(epochIdx+alphabetGap)).xValue=max(panel3.(alphabet(epochIdx+alphabetGap)).xValue)+1;
    panel4b.(alphabet(epochIdx+alphabetGap)).xValue=max(panel4.(alphabet(epochIdx+alphabetGap)).xValue)+1;

    panel2.(alphabet(epochIdx+alphabetGap)).yValue=panel2.(alphabet(epochIdx+alphabetGap)).yValue/sum(sum(panel2.(alphabet(epochIdx+alphabetGap)).yValue))*100;
    
    if ismember(toUse(epochIdx),3:4)
        unit='(z)';
    else
        unit='(Hz)';
    end
    
    if toUse(epochIdx)<5
        if mod(epochIdx,2)==1                                        
            panel1.(alphabet(epochIdx+alphabetGap)).xlabel={'FR in last 1/3'
                                                ['of non-REM ' unit]};
                                            
            panel1.(alphabet(epochIdx+alphabetGap)).ylabel={'FR in first 1/3'
                                                ['of REM ' unit]};
        else
            panel1.(alphabet(epochIdx+alphabetGap)).xlabel={'FR in last 1/3'
                                                ['of REM ' unit]};

            panel1.(alphabet(epochIdx+alphabetGap)).ylabel={'FR in first 1/3'
                                                ['of non-REM ' unit]};
        end   
    else
        if mod(epochIdx,2)==1                                        
            panel1.(alphabet(epochIdx+alphabetGap)).xlabel={['FR in non-REM_i ' unit]};
                                            
            panel1.(alphabet(epochIdx+alphabetGap)).ylabel={['FR in non-REM_{i+1} ' unit]};
        else
            panel1.(alphabet(epochIdx+alphabetGap)).xlabel={['FR in REM_i ' unit]};

            panel1.(alphabet(epochIdx+alphabetGap)).ylabel={['FR in REM_{i+1} ' unit]};
        end          
    end
    panel2.(alphabet(epochIdx+alphabetGap)).xlabel=panel1.(alphabet(epochIdx+alphabetGap)).xlabel;
    panel2.(alphabet(epochIdx+alphabetGap)).ylabel=panel1.(alphabet(epochIdx+alphabetGap)).ylabel;

    
    panel2.(alphabet(epochIdx+alphabetGap)).info.XTick=[-2,0];
    panel2.(alphabet(epochIdx+alphabetGap)).info.YTick=[-2,0];
    panel2.(alphabet(epochIdx+alphabetGap)).info.XTickLabel={'10^{-2}','10^{0}'};
    panel2.(alphabet(epochIdx+alphabetGap)).info.YTickLabel={'10^{-2}','10^{0}'};

    
    panel3.(alphabet(epochIdx+alphabetGap)).ylabel='CI';
    panel4.(alphabet(epochIdx+alphabetGap)).ylabel='DI';

    
    panel2.(alphabet(epochIdx+alphabetGap)).title=panel5.(alphabet(epochIdx+alphabetGap)).title;
%     panel5.(alphabet(epochIdx)).title='';
%     panel5.(alphabet(epochIdx)).xlabel='FR (Hz)';
end

panel3.a.info.YLim=[-0.1,0.25];
panel3.b.info.YLim=[-0.25,0.45];
panel3.c.info.YTick=-0.3:0.3:0.3;
panel3.c.info.YTickLabel=panel3.c.info.YTick;

panel4.a.info.YTick=0:0.04:0.08;
panel4.a.info.YTickLabel=panel4.a.info.YTick;

panel4.b.info.YLim=[-0.125,0.025];

panel4.d.info.YLim=[-0.2,0.31];
panel4.d.info.YTick=-0.2:0.2:0.4;
panel4.d.info.YTickLabel=panel4.d.info.YTick;
colError=0.5*[1,1,1];

for idx=1:length(fieldnames(panel0))
    panel0.(alphabet(idx)).title=panel2.(alphabet(idx)).title
    panel2.(alphabet(idx)).title='';
    panel0.(alphabet(idx)).color=panel3.(alphabet(idx)).color
end
%%
close all
origX=15;
origY=13;
panelLetterSize=12;
letterGapX=10;
letterGapY=5;
marginX=20;
marginY=20;
innerMarginY=15;
innerMarginX=15;
width=23;
height=width*2/3;

exWidth=4*width+3*marginX;
exHeight=45;
hipnoHeight=8;

% fh=initFig4JNeuro(2);
fh=initFig4Sleep2(2);
set(fh,'defaultLineMarkerSize',1)
isPanelLetterCapital=true;

cLim=[0,0.3];


%%
% for epochIdx=1:length(fieldnames(panel1))
%     totalGapX=(epochIdx-1)*(width+marginX);
%     totalGapY=0*(3*height+2*innerMarginY+marginY);
% 
%     
%     xPos=origX;
%     yPos=origY;
%     xPos=xPos+totalGapX;
%     yPos=yPos+totalGapY;
%     
%     subplotInMM(xPos,yPos,width,height,true)
%     restoreGraph(panel1.(alphabet(epochIdx)))
%     plotIdentityLine(gca,{'color',[0,1,1]})
%     
%     panelLetter(xPos-letterGapX,yPos-letterGapY,alphabet(epochIdx,isPanelLetterCapital),panelLetterSize)
% end
totalGapX=0;
totalGapY=0;

xPos=origX+totalGapX;
yPos=origY+totalGapY;

subplotInMM(xPos,yPos,exWidth,hipnoHeight,true)
restoreGraph(exPanel.a)
axis off
text(0,1,'Non-REM','horizontalAlign','right')
text(0,2,'REM','horizontalAlign','right')
text(0,3,'Awake','horizontalAlign','right')

panelLetter(xPos-letterGapX,yPos-letterGapY,'A',panelLetterSize)

subplotInMM(xPos,yPos+hipnoHeight+1,exWidth,exHeight,true)
hold on
for idx=1:length(exPanel.b.xValue)
    fill([exPanel.b.xValue{idx},fliplr(exPanel.b.xValue{idx})],...
         [exPanel.b.yValue{idx}+exPanel.b.error{idx},fliplr(exPanel.b.yValue{idx}-exPanel.b.error{idx})],...
         exPanel.b.color(idx,:),'facealpha',0.3,'linestyle','none')
end
for idx=1:length(exPanel.b.xValue)
    plot(exPanel.b.xValue{idx},exPanel.b.yValue{idx},'color', exPanel.b.color(idx,:))
end
xlim(exPanel.b.info.XLim)
ylim([0.001,3])
set(gca,'xtick',[]);
set(gca,'yscale','log')
set(gca,'ytick',[0.001,0.003,0.01,0.03,0.1,0.3,1,3])

ax=fixAxis;
axis off
plot(ax(1)*[1,1],ax(3:4),'k-')
for n=-3:0
    plot(ax(1)+diff(ax(1:2))*[0,0.005],[2,4:9;2,4:9]' *10^n,'k-')
    plot(ax(1)+diff(ax(1:2))*[0,0.009],[1,3;1,3] *10^n,'k-')
    text(ax(1)-diff(ax(1:2))*0.005,10^n,num2str(10^n),'horizontalALign','right')
    text(ax(1)-diff(ax(1:2))*0.005,3*10^n,num2str(3*10^n),'horizontalALign','right')
end


plot(5+[0,10],0.005*[1,1],'k-')
text(10,0.005,'10 min','verticalAlign','bottom','horizontalAlign','center')

%%
totalGapX=0;
totalGapY=exHeight+hipnoHeight+marginY-10;

for epochIdx=1:length(fieldnames(panel2))
    
    xPos=origX+(epochIdx-1)*(width+marginX);
    yPos=origY+0*(height+innerMarginY)+5;
    xPos=xPos+totalGapX;
    yPos=yPos+totalGapY;
    
    subplotInMM(xPos,yPos,width,height,true)
    hold on

    for idx=1:length(panel0.(alphabet(epochIdx)).xValue)
        scale=100/mean(panel0.(alphabet(epochIdx)).yValue{idx});
        shift=0*(idx-1);
        fill([panel0.(alphabet(epochIdx)).xValue{idx},fliplr(panel0.(alphabet(epochIdx)).xValue{idx})],...
            [panel0.(alphabet(epochIdx)).yValue{idx}+panel0.(alphabet(epochIdx)).error{idx},...
            fliplr(panel0.(alphabet(epochIdx)).yValue{idx}-panel0.(alphabet(epochIdx)).error{idx})]*scale+shift,...
            panel0.(alphabet(epochIdx)).color(idx,:),'facealpha',0.3,'linestyle','none')
        plot(panel0.(alphabet(epochIdx)).xValue{idx},...
            panel0.(alphabet(epochIdx)).yValue{idx}*scale+shift,...
            '-','color',panel0.(alphabet(epochIdx)).color(idx,:))
    end
%     set(gca,'yscale','log')
%     ylim([60,140])
    axis tight

    ax=fixAxis;
    if isfield(panel0.(alphabet(epochIdx)).legend,'nBin')
        plot(panel0.(alphabet(epochIdx)).legend.nBin(1)-0.5*[1,1],ax(3:4),...
            '-','color',0.7*[1,1,1])

        set(gca,'xtick',...
            [panel0.(alphabet(epochIdx)).legend.nBin(1)/3*[1,2]-0.5,...
            panel0.(alphabet(epochIdx)).legend.nBin(1)+panel0.(alphabet(epochIdx)).legend.nBin(2)/3*[1,2]-0.5])
        
    else
        set(gca,'xtick',[5.5,11.5])    
    end    
%     set(gca,'ytick',[0.03,0.1,0.3,1,3],'yticklabel',[0.03,0.1,0.3,1,3])
    xlabel(panel0.(alphabet(epochIdx)).xlabel)
    ylabel({'Normalized' 'FR (%)'})
%     ylabel(panel0.(alphabet(epochIdx)).ylabel)
    
    
    set(gca,'xticklabel','')
    xlim(panel0.(alphabet(epochIdx)).xValue{idx}([1,end]))
    title(panel0.(alphabet(epochIdx)).title)
    panelLetter(xPos-letterGapX,yPos-letterGapY,alphabet(epochIdx+1,isPanelLetterCapital),panelLetterSize)
    
end

for epochIdx=1:length(fieldnames(panel2))
    
    xPos=origX+(epochIdx-1)*(width+marginX);
    yPos=origY+1*(height+innerMarginY);
    xPos=xPos+totalGapX;
    yPos=yPos+totalGapY;
    
    subplotInMM(xPos,yPos,width,height,true)
    restoreGraph(panel2.(alphabet(epochIdx)))
    colormap(gca,jet)
    plotIdentityLine(gca,{'color',0.99*[1,1,1]})
    set(gca,'clim',cLim)
    title('')

    
    fr=[cat(1,panel1.(alphabet(epochIdx)).xValue{:}),cat(1,panel1.(alphabet(epochIdx)).yValue{:})];
    fr(any(fr==0,2),:)=[];
    fr(any(isnan(fr),2),:)=[];
    fr=log10(fr);    
    hold on
    plot(mean(fr(:,1)),mean(fr(:,2)),'kx','markersize',3)
    
    subplotInMM(xPos+width+1,yPos,1,height,true)
    imagescXY([0,1],cLim,linspace(cLim(1),cLim(2),128))
    box off
    colormap(gca,jet)
    set(gca,'clim',cLim)
    set(gca,'yAxisLocation','right')
    set(gca,'xtick',[])
%     ylabel('%')
%     set(get(gca,'ylabel'),'rotation',-90,'position',get(get(gca,'ylabel'),'position')+[10,0,0])
    ax=fixAxis;
    text2(2.5,1.15,'%',ax,{'verticalAlign','bottom'})
    
end    
   
for offsetType=1:2
for epochIdx=1:length(fieldnames(panel3))
    if offsetType==1
        target=panel3.(alphabet(epochIdx))
        targetB=panel3b.(alphabet(epochIdx))
    else
        target=panel4.(alphabet(epochIdx))
        targetB=panel4b.(alphabet(epochIdx))
    end
    
    xPos=origX+(epochIdx-1)*(width+marginX);
    yPos=origY+(offsetType+1)*(height+innerMarginY);
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
    title('');
    if offsetType==2
        for idx=1:length(target.xValue)
            if target.yValue(idx)>0
                text(target.xValue(idx),target.yValue(idx)+target.error(idx),...
                    getSigText(target.legend.p(idx)),'horizontalAlign','center','verticalAlign','middle')
            else
                text(target.xValue(idx),target.yValue(idx)-target.error(idx),...
                    getSigText(target.legend.p(idx)),'horizontalAlign','center','verticalAlign','top')
            end
        end
        if targetB.yValue>0
            text(targetB.xValue,targetB.yValue+targetB.error,...
                getSigText(targetB.legend.p),'horizontalAlign','center','verticalAlign','middle')
        else
            text(targetB.xValue,targetB.yValue-targetB.error,...
                getSigText(targetB.legend.p),'horizontalAlign','center','verticalAlign','top')
        end        
    end
end
end    
    %%
% for epochIdx=1:length(fieldnames(panel5))
%     totalGapX=(epochIdx-1)*1*(width+marginX);
%     totalGapY=0*(3*height+2*innerMarginY+marginY);
%     
%     xPos=origX;
%     yPos=origY+3*(height+innerMarginY);
%     xPos=xPos+totalGapX;
%     yPos=yPos+totalGapY;
%     
%     subplotInMM(xPos,yPos,width,height,true)
%     restoreGraph(panel5.(alphabet(epochIdx)))
%     ax=fixAxis;
%     text2(0.9,1,{['\color[rgb]{' num2str(panel5.(alphabet(epochIdx)).color(1,:)) '}First 1/3'],
%                  ['\color[rgb]{' num2str(panel5.(alphabet(epochIdx)).color(2,:)) '}Last 1/3']},...
%                  ax,{'horizontalALign','left','verticalAlign','top'})
% end

%%
figNum=['1' postFix];

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

% print(fh,[saveDir '/eps/' 'QuantileFig' figNum '.eps'],'-depsc')
% print(fh,[saveDir '/pdf/' 'QuantileFig' figNum '.pdf'],'-dpdf')



    
    
    
    
    
    
    
    
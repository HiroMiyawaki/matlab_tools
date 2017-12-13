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

% quantile_zScore_nremRemTransient20s

% quantile4_sleep2Wake1min20s
% quantile4_wakePrePostSleep20s
% quantile4_stableWake20s
%%
clearvars -except AddLabelFlag

showMI=true; %for delta log(Hz), set false

exLow=false;

if exLow
    postFix='exLow';
else
    postFix='';
end


% 1,2: log Hz
% 3,4: z-score
% 6,7: nrem/rem/nrem, rem/nrem/rem 1/3 vs 1/3
% 8,9: nrem/rem/nrem, rem/nrem/rem, mean vs mean

toUse=[8,9];
panelIdxList=1:2
for epochIdx=1:length(toUse)
    panelIdx=panelIdxList(epochIdx);
    panel1.(alphabet(panelIdx))=loadGraph('quantile20s3', [alphabet(toUse(panelIdx)) '1' postFix]);
    panel1b.(alphabet(panelIdx))=loadGraph('quantile20s3', [alphabet(toUse(panelIdx)) '1' 'Inh' postFix]);
    panel2.(alphabet(panelIdx))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '2' postFix]);
    
    if showMI
        panel3.(alphabet(panelIdx))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '3a' postFix]);
        panel4.(alphabet(panelIdx))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '4a' postFix]);

        panel3b.(alphabet(panelIdx))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '3a' 'Inh' postFix]);
        panel4b.(alphabet(panelIdx))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '4a' 'Inh' postFix]);
    else
        panel3.(alphabet(panelIdx))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '3b' postFix]);
        panel4.(alphabet(panelIdx))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '4b' postFix]);

        panel3b.(alphabet(panelIdx))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '3b' 'Inh' postFix]);
        panel4b.(alphabet(panelIdx))=loadGraph('quantile20s3', [alphabet(toUse(epochIdx)) '4b' 'Inh' postFix]);
    end
    panel3.(alphabet(panelIdx)).type='multiColorBar';
    panel4.(alphabet(panelIdx)).type='multiColorBar';

    panel5.(alphabet(panelIdx))=loadGraph('quantile20s3', ['e' num2str(toUse(epochIdx)-(toUse(epochIdx)>4)) postFix]);

    panel3b.(alphabet(panelIdx)).xValue=max(panel3.(alphabet(panelIdx)).xValue)+1;
    panel4b.(alphabet(panelIdx)).xValue=max(panel4.(alphabet(panelIdx)).xValue)+1;

    panel2.(alphabet(panelIdx)).yValue=panel2.(alphabet(panelIdx)).yValue/sum(sum(panel2.(alphabet(panelIdx)).yValue))*100;
    
    if ismember(toUse(epochIdx),3:4)
        unit='(z)';
    else
        unit='(Hz)';
    end
    
    if toUse(epochIdx)<5
        if mod(panelIdx,2)==1                                        
            panel1.(alphabet(panelIdx)).xlabel={'FR in last 1/3'
                                                ['of non-REM ' unit]};
                                            
            panel1.(alphabet(panelIdx)).ylabel={'FR in first 1/3'
                                                ['of REM ' unit]};
        else
            panel1.(alphabet(panelIdx)).xlabel={'FR in last 1/3'
                                                ['of REM ' unit]};

            panel1.(alphabet(panelIdx)).ylabel={'FR in first 1/3'
                                                ['of non-REM ' unit]};
        end   
    else
        if mod(panelIdx,2)==1                                        
            panel1.(alphabet(panelIdx)).xlabel={['FR in non-REM_i ' unit]};
                                            
            panel1.(alphabet(panelIdx)).ylabel={['FR in non-REM_{i+1} ' unit]};
        else
            panel1.(alphabet(panelIdx)).xlabel={['FR in REM_i ' unit]};

            panel1.(alphabet(panelIdx)).ylabel={['FR in REM_{i+1} ' unit]};
        end          
    end
    panel2.(alphabet(panelIdx)).xlabel=panel1.(alphabet(panelIdx)).xlabel;
    panel2.(alphabet(panelIdx)).ylabel=panel1.(alphabet(panelIdx)).ylabel;
    
    panel3.(alphabet(panelIdx)).ylabel='CI';
    panel4.(alphabet(panelIdx)).ylabel='DI';

    
    panel2.(alphabet(panelIdx)).title=panel5.(alphabet(panelIdx)).title;
%     panel5.(alphabet(epochIdx)).title='';
%     panel5.(alphabet(epochIdx)).xlabel='FR (Hz)';
end


% panel4.b.info.YLim=[-0.15,0.31];
colError=0.5*[1,1,1];
%%
% 1: within wake, 1min vs 1min
% 2: wake to nrem, 1/3 vs 1/3
% 3: nrem to wake, 1/3 vs 1/3
% 4: rem to wake, 1/3 vs 1/3
% 6: wake to nrem, 0.5min vs 1/3
% 7: nrem to wake, 1/3 vs 1min
% 8: rem to wake, 1/3 vs 1min
% 9: wake before and after sleep, 1min vs 1min
toUse=[9,7,8,1,6];
panelIdxList=3:7;
for epochIdx=1:length(toUse)
    panelIdx=panelIdxList(epochIdx)
    if ismember(toUse(epochIdx),[2,3,10,11]) && exLow
        postFix='exLow';        
    else
        postFix='';        
    end
    
    panel1.(alphabet(panelIdx))=loadGraph('quantile20s4', [alphabet(toUse(epochIdx)) '1' postFix]);
    panel1b.(alphabet(panelIdx))=loadGraph('quantile20s4', [alphabet(toUse(epochIdx)) '1' 'Inh' postFix]);
    panel2.(alphabet(panelIdx))=loadGraph('quantile20s4', [alphabet(toUse(epochIdx)) '2' postFix]);
    
    if showMI
        panel3.(alphabet(panelIdx))=loadGraph('quantile20s4', [alphabet(toUse(epochIdx)) '3a' postFix]);
        panel4.(alphabet(panelIdx))=loadGraph('quantile20s4', [alphabet(toUse(epochIdx)) '4a' postFix]);
        panel3b.(alphabet(panelIdx))=loadGraph('quantile20s4', [alphabet(toUse(epochIdx)) '3a' 'Inh' postFix]);
        panel4b.(alphabet(panelIdx))=loadGraph('quantile20s4', [alphabet(toUse(epochIdx)) '4a' 'Inh' postFix]);
    else
        panel3.(alphabet(panelIdx))=loadGraph('quantile20s4', [alphabet(toUse(epochIdx)) '3b' postFix]);
        panel4.(alphabet(panelIdx))=loadGraph('quantile20s4', [alphabet(toUse(epochIdx)) '4b' postFix]);
        panel3b.(alphabet(panelIdx))=loadGraph('quantile20s4', [alphabet(toUse(epochIdx)) '3b' 'Inh' postFix]);
        panel4b.(alphabet(panelIdx))=loadGraph('quantile20s4', [alphabet(toUse(epochIdx)) '4b' 'Inh' postFix]);
    end
    panel3.(alphabet(panelIdx)).type='multiColorBar';
    panel4.(alphabet(panelIdx)).type='multiColorBar';
    
    panel5.(alphabet(panelIdx))=loadGraph('quantile20s4', ['e' num2str(toUse(epochIdx)) postFix]);
    
    panel3b.(alphabet(panelIdx)).xValue=max(panel3.(alphabet(panelIdx)).xValue)+1;
    panel4b.(alphabet(panelIdx)).xValue=max(panel4.(alphabet(panelIdx)).xValue)+1;

    panel3.(alphabet(panelIdx)).ylabel='CI';
    panel4.(alphabet(panelIdx)).ylabel='DI';
    
    
    panel2.(alphabet(panelIdx)).yValue=panel2.(alphabet(panelIdx)).yValue/sum(sum(panel2.(alphabet(panelIdx)).yValue))*100;           
    panel5.(alphabet(panelIdx)).xlabel='FR (Hz)';
end

panel1.(alphabet(panelIdxList(3))).info.XLim=10.^[-3,2];
panel1.(alphabet(panelIdxList(3))).info.YLim=10.^[-3,2];
colError=0.5*[1,1,1];

panel2.(alphabet(panelIdxList(4))).title='Within waking';
panel2.(alphabet(panelIdxList(4))).xlabel={'FR in first min' 'of wake (Hz)'};
panel2.(alphabet(panelIdxList(4))).ylabel={'FR in last min' 'of wake (Hz)'};

panel2.(alphabet(panelIdxList(5))).title='Wake to non-REM';
% panel2.(alphabet(panelIdxList(5))).xlabel={'FR in last 1/3' 'of resting wake (Hz)'};
panel2.(alphabet(panelIdxList(5))).xlabel={'FR in last min' 'of wake (Hz)'};
panel2.(alphabet(panelIdxList(5))).ylabel={'FR in first 1/3' 'of non-REM (Hz)'};


panel2.(alphabet(panelIdxList(2))).title='Non-REM to wake';
panel2.(alphabet(panelIdxList(2))).xlabel={'FR in last 1/3' 'of non-REM (Hz)'};
% panel2.(alphabet(panelIdxList(2))).ylabel={'FR in first 1/3' 'of resting wake (Hz)'};
panel2.(alphabet(panelIdxList(2))).ylabel={'FR in first min' 'of wake (Hz)'};

panel2.(alphabet(panelIdxList(3))).title='REM to wake';
panel2.(alphabet(panelIdxList(3))).xlabel={'FR in last 1/3' 'of REM (Hz)'};
% panel2.(alphabet(panelIdxList(3))).ylabel={'FR in first 1/3' 'of resting wake (Hz)'};
panel2.(alphabet(panelIdxList(3))).ylabel={'FR in first min' 'of wake (Hz)'};


panel5.(alphabet(panelIdxList(4))).legend.stateName={{'First' 'min'},{'Last' 'min'}};


panel2.(alphabet(panelIdxList(1))).xlabel={'FR in last min ' 'of wake_i (Hz)'};
panel2.(alphabet(panelIdxList(1))).ylabel={'FR in first min' 'of wake_{i+1} (Hz)'};
panel2.(alphabet(panelIdxList(1))).title='Wake_i/sleep/wake_{i+1}';

if exLow
    postFix='exLow';
else
    postFix='';
end

panel3.a.info.YTick=-0.1:0.1:0.1;
panel3.a.info.YLim=[-0.1,0.1];
panel3.b.info.YLim=[-0.2,0.3];
panel3.b.info.YTick=-0.2:0.2:0.2;
panel3.c.info.YTick=-0.4:0.4:0.4;
panel3.d.info.YLim=[-0.5,0.75];
panel3.e.info.YLim=[-0.5,0.75];
panel3.f.info.YLim=[-0.25,0.5];
panel3.f.info.YTick=-0.2:0.2:0.4;
panel3.g.info.YLim=[-0.25,0.75];

panel4.a.info.YLim=[-0.175,0.02];
panel4.a.info.YTick=-0.15:0.05:0;
panel4.b.info.YLim=[-0.12,0.05];
panel4.b.info.YTick=-0.1:0.05:0.05;
panel4.f.info.YTick=-0.1:0.1:0.2;
panel4.g.info.YTick=-0.2:0.2:0.4;

panel4.d.info.YLim=[-1.1,0.25];
panel4.e.info.YLim=[-0.6,0.1];
panel4.e.info.YTick=-0.6:0.3:0.3;
panel4.c.info.YLim=[-0.4,0.05];
panel4.g.info.YTick=-0.4:0.2:0.2;

    
for n=1:length(fieldnames(panel3))
    panel2.(alphabet(n)).info.YTick=[-2,0];
    panel2.(alphabet(n)).info.XTick=[-2,0];
    panel2.(alphabet(n)).info.YTickLabel={'10^{-2}','10^{0}'};
    panel2.(alphabet(n)).info.XTickLabel={'10^{-2}','10^{0}'};

    panel3.(alphabet(n)).info.YTickLabel=panel3.(alphabet(n)).info.YTick;
    panel4.(alphabet(n)).info.YTickLabel=panel4.(alphabet(n)).info.YTick;
    
    panel2.(alphabet(n)).title=strrep(panel2.(alphabet(n)).title,'non-REM','NREM');
    panel2.(alphabet(n)).title=strrep(panel2.(alphabet(n)).title,'Non-REM','NREM');

    panel2.(alphabet(n)).xlabel=strrep(panel2.(alphabet(n)).xlabel,'non-REM','NREM');
    panel2.(alphabet(n)).xlabel=strrep(panel2.(alphabet(n)).xlabel,'Non-REM','NREM');
    
    panel2.(alphabet(n)).ylabel=strrep(panel2.(alphabet(n)).ylabel,'non-REM','NREM');
    panel2.(alphabet(n)).ylabel=strrep(panel2.(alphabet(n)).ylabel,'Non-REM','NREM');
end
%%
close all
origX=18;
origY=13;
panelLetterSize=12;
letterGapX=10;
letterGapY=10;
marginX=26;
marginY=28;
innerMarginY=18;
innerMarginX=18;
width=24;
height=width*2/3;


% fh=initFig4JNeuro(2);
fh=initFig4SleepSup(2);
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
%%
% for idx=1:7
%     oldPanel1.(alphabet(idx))=panel1.(alphabet(idx));
%     oldPanel1b.(alphabet(idx))=panel1b.(alphabet(idx));
%     oldPanel2.(alphabet(idx))=panel2.(alphabet(idx));
%     oldPanel3.(alphabet(idx))=panel3.(alphabet(idx));
%     oldPanel3b.(alphabet(idx))=panel3b.(alphabet(idx));
%     oldPanel4.(alphabet(idx))=panel4.(alphabet(idx));
%     oldPanel4b.(alphabet(idx))=panel4b.(alphabet(idx));
% end
% 
% reorder='fgdeacb'
% 
% for idx=1:7
%     panel1.(alphabet(idx))=oldPanel1.(reorder(idx));
%     panel1b.(alphabet(idx))=oldPanel1b.(reorder(idx));
%     panel2.(alphabet(idx))=oldPanel2.(reorder(idx));
%     panel3.(alphabet(idx))=oldPanel3.(reorder(idx));
%     panel3b.(alphabet(idx))=oldPanel3b.(reorder(idx));
%     panel4.(alphabet(idx))=oldPanel4.(reorder(idx));
%     panel4b.(alphabet(idx))=oldPanel4b.(reorder(idx));
% 
% end
%%
panelBlockX=[0,1,2,3,0,1,2];
panelBlockY=[0,0,0,0,1,1,1];

for panelIdx=1:length(fieldnames(panel2))
    totalGapX=panelBlockX(panelIdx)*(width+marginX);
    totalGapY=panelBlockY(panelIdx)*(3*height+2*innerMarginY+marginY);
    
    xPos=origX;
    yPos=origY+0*(height+innerMarginY);
    xPos=xPos+totalGapX;
    yPos=yPos+totalGapY;
    
    subplotInMM(xPos,yPos,width,height,true)
    restoreGraph(panel2.(alphabet(panelIdx)))
    colormap(gca,jet)
    set(gca,'clim',cLim)
    plotIdentityLine(gca,{'color',0.99*[1,1,1]})
%     title('');   
    
    fr=[cat(1,panel1.(alphabet(panelIdx)).xValue{:}),cat(1,panel1.(alphabet(panelIdx)).yValue{:})];
    fr(any(fr==0,2),:)=[];
    fr(any(isnan(fr),2),:)=[];
    fr=log10(fr);    
    hold on
    plot(mean(fr(:,1)),mean(fr(:,2)),'kx','markersize',3)
    
    panelLetter(xPos-letterGapX,yPos-letterGapY,alphabet(panelIdx,isPanelLetterCapital),panelLetterSize)
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
    
    
   
for offsetType=1:2

    if offsetType==1
        target=panel3.(alphabet(panelIdx))
        targetB=panel3b.(alphabet(panelIdx))
    else
        target=panel4.(alphabet(panelIdx))
        targetB=panel4b.(alphabet(panelIdx))
    end
    
    xPos=origX;
    yPos=origY+(offsetType)*(height+innerMarginY);
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
end    
  
%%
% 
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
%     text2(0.9,1,{['\color[rgb]{' num2str(panel5.(alphabet(epochIdx)).color(1,:)) '}' panel5.(alphabet(epochIdx)).legend.stateName{1}{1}]
%                   panel5.(alphabet(epochIdx)).legend.stateName{1}{2}
%                  ['\color[rgb]{' num2str(panel5.(alphabet(epochIdx)).color(2,:)) '}' panel5.(alphabet(epochIdx)).legend.stateName{2}{1}]
%                   panel5.(alphabet(epochIdx)).legend.stateName{2}{2}},...
%                  ax,{'horizontalALign','left','verticalAlign','top'})
% end

%%
figNum=['S4' postFix];

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
print(fh,[saveDir '/eps/' 'QuantileFig' figNum '.eps'],'-depsc')
print(fh,[saveDir '/pdf/' 'QuantileFig' figNum '.pdf'],'-dpdf')
% % 


    
    
    
    
    
    
    
    
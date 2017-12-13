% quantile5_nremLOWnrem20s
% quantile5_LOWnremLOW20s
% quantile5_zscore_nremLOWnrem20s
% quintile5_distribution20s

% quantile5_LOWnremLOWInh20s
% quantile5_nremLOWnremInh20s

% quantile_excludeLow20s
% quantile_excludeLowInh20s

% quantile5_MaNremMa20s
% quantile5_MaNremMaInh20s

% quantile5_NremMaNrem20s
% quantile5_NremMaNremInh20s

%%
%%
clearvars -except AddLabelFlag

showMI=true;

% a 1 NREM-LOW-NREM
% b 2 within NREM excluding LOW
% c 3
% d 4 LOW-NREM-LOW
% e 5
% f 6 MA-NREM-MA
% g 7 NREM-MA-NREM

toUse=[1,4,6,7];
for epochIdx=1:length(toUse)
    panel1.(alphabet(epochIdx))=loadGraph('quantile20s5', [alphabet(toUse(epochIdx)) '1']);
    panel2.(alphabet(epochIdx))=loadGraph('quantile20s5', [alphabet(toUse(epochIdx)) '2']);
    panel2b.(alphabet(epochIdx))=loadGraph('quantile20s5', [alphabet(toUse(epochIdx)) '2' 'Inh']);
    
    if showMI
        panel3.(alphabet(epochIdx))=loadGraph('quantile20s5', [alphabet(toUse(epochIdx)) '3a']);
        panel4.(alphabet(epochIdx))=loadGraph('quantile20s5', [alphabet(toUse(epochIdx)) '4a']);
        panel3b.(alphabet(epochIdx))=loadGraph('quantile20s5', [alphabet(toUse(epochIdx)) '3a' 'Inh']);
        panel4b.(alphabet(epochIdx))=loadGraph('quantile20s5', [alphabet(toUse(epochIdx)) '4a' 'Inh']);
    else
        panel3.(alphabet(epochIdx))=loadGraph('quantile20s5', [alphabet(toUse(epochIdx)) '3b']);
        panel4.(alphabet(epochIdx))=loadGraph('quantile20s5', [alphabet(toUse(epochIdx)) '4b']);
        panel3b.(alphabet(epochIdx))=loadGraph('quantile20s5', [alphabet(toUse(epochIdx)) '3b' 'Inh']);
        panel4b.(alphabet(epochIdx))=loadGraph('quantile20s5', [alphabet(toUse(epochIdx)) '4b' 'Inh']);
    end
    panel3.(alphabet(epochIdx)).type='multiColorBar';
    panel4.(alphabet(epochIdx)).type='multiColorBar';

    panel3b.(alphabet(epochIdx)).xValue=max(panel3.(alphabet(epochIdx)).xValue)+1;
    panel4b.(alphabet(epochIdx)).xValue=max(panel4.(alphabet(epochIdx)).xValue)+1;

    panel3.(alphabet(epochIdx)).ylabel='CI';
    panel4.(alphabet(epochIdx)).ylabel='DI';
    
    
%     panel5.(alphabet(epochIdx))=loadGraph('quantile20s5', ['e' num2str(toUse(epochIdx))]);
    
%     panel5.(alphabet(epochIdx)).xlabel='FR (Hz)';
%     panel2.(alphabet(epochIdx)).yValue=panel2.(alphabet(epochIdx)).yValue/sum(sum(panel2.(alphabet(epochIdx)).yValue))*100;
    
end

panel2.a.title='Pre vs post LOW';
panel2.b.title='LOW_i vs LOW_{i+1}';
panel2.c.title='MA_i vs MA_{i+1}';
panel2.d.title='Pre vs post MA';

panel1.a.xlabel={'Firing rate in NREM' 'pre-LOW (Hz)'};
panel1.a.ylabel={'Firing rate in NREM' 'post-LOW (Hz)'};


panel1.d.xlabel={'Firing rate in MA' 'pre-NREM (Hz)'};
panel1.d.ylabel={'Firing rate in MA' 'post-NREM (Hz)'};


panel1.a.info.XLim=10.^[-3,2];
panel1.a.info.YLim=10.^[-3,2];

panel2.a.xlabel=panel1.a.xlabel;
panel2.a.ylabel=panel1.a.ylabel;
panel2.d.xlabel=panel1.d.xlabel;
panel2.d.ylabel=panel1.d.ylabel;

panel4.a.info.YLim=[-0.03,0.03];
panel4.a.info.YTick=-0.03:0.03:0.03;
panel4.a.info.YTickLabel=panel4.a.info.YTick;

panel4.d.info.YLim=[-0.075,0.05];

colNrem=hsv2rgb([7/12*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colMA=hsv2rgb([11/12*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
panel3.c.color=colMA;
panel4.c.color=colMA;
panel3.d.color=colNrem;
panel4.d.color=colNrem;


colError=0.5*[1,1,1];

for epochIdx=1:length(fieldnames(panel2))
    panel2.(alphabet(epochIdx)).xlabel=strrep(panel2.(alphabet(epochIdx)).xlabel,'Firing rate','FR');
    panel2.(alphabet(epochIdx)).ylabel=strrep(panel2.(alphabet(epochIdx)).ylabel,'Firing rate','FR');
end
%%
origX=18;
origY=10;
panelLetterSize=12;
letterGapX=6;
letterGapY=7;
marginX=22;
marginY=26;
innerMarginY=13;
innerMarginX=6;
width=20;
height=width*2/3;

isPanelLetterCapital=true;
cLim=[0,0.3];


%%
% panel1.a.image=scatter2pixcel(panel1.a,width,height,1);
% panel1.a.type='none';
% panel1.a.info.XLim=log10(panel1.a.info.XLim);
% panel1.a.info.YLim=log10(panel1.a.info.YLim);
% panel1.a.info.XTick=log10(panel1.a.info.XTick);
% panel1.a.info.YTick=log10(panel1.a.info.YTick);
% panel1.a.info.XScale='linear';
% panel1.a.info.YScale='linear';
% 
% panel1.b.image=scatter2pixcel(panel1.b,width,height,1);
% panel1.b.type='none';
% panel1.b.info.XScale='linear';
% panel1.b.info.YScale='linear';

%%
close all

fh=initFig4Sleep2(2);
set(fh,'defaultLineMarkerSize',1)


%%
% 
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
%     if isfield(panel1.(alphabet(epochIdx)),'image')
%         image(panel1.(alphabet(epochIdx)).info.XLim,...
%             panel1.(alphabet(epochIdx)).info.YLim,...
%             panel1.(alphabet(epochIdx)).image)
%         set(gca,'ydir','normal')
%     end
%     restoreGraph(panel1.(alphabet(epochIdx)))
%     plotIdentityLine(gca,{'color',[0,1,1]})
%     
%     panelLetter(xPos-letterGapX,yPos-letterGapY,alphabet(epochIdx,isPanelLetterCapital),panelLetterSize)
% end
    
for epochIdx=1:length(fieldnames(panel2))
    totalGapX=(epochIdx-1)*(width+marginX);
    totalGapY=0*(3*height+2*innerMarginY+marginY);
    
    xPos=origX;
    yPos=origY+0*(height+innerMarginY);
    xPos=xPos+totalGapX;
    yPos=yPos+totalGapY;
    
    subplotInMM(xPos,yPos,width,height,true)
    restoreGraph(panel2.(alphabet(epochIdx)))
    colormap(gca,jet)
    set(gca,'clim',cLim)
    plotIdentityLine(gca,{'color',0.99*[1,1,1]})
%     title('');   
 
    fr=[cat(1,panel1.(alphabet(epochIdx)).xValue{:}),cat(1,panel1.(alphabet(epochIdx)).yValue{:})];
    fr(any(fr==0,2),:)=[];
    fr(any(isnan(fr),2),:)=[];
    fr=log10(fr);    
    hold on
    plot(mean(fr(:,1)),mean(fr(:,2)),'kx','markersize',3)
    
    panelLetter(xPos-letterGapX,yPos-letterGapY,alphabet(epochIdx,isPanelLetterCapital),panelLetterSize)

    subplotInMM(xPos+width+1,yPos,1,height,true)
    imagescXY([0,1],cLim,linspace(cLim(1),cLim(2),128))
    box off
    colormap(gca,jet)
    set(gca,'clim',cLim)
    set(gca,'yAxisLocation','right')
    set(gca,'xtick',[])
    ylabel('%')
    set(get(gca,'ylabel'),'rotation',-90,'position',get(get(gca,'ylabel'),'position')+[10,0,0])
    
    
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
    totalGapX=(epochIdx-1)*(width+marginX);
    totalGapY=0*(3*height+2*innerMarginY+marginY);
    
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
    xlim([0,6.5])
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
%     text2(0.9,1,{['\color[rgb]{' num2str(panel5.(alphabet(epochIdx)).color(1,:)) '}' panel5.(alphabet(epochIdx)).legend.stateName{1}]
%                  ['\color[rgb]{' num2str(panel5.(alphabet(epochIdx)).color(2,:)) '}' panel5.(alphabet(epochIdx)).legend.stateName{2}]
%                  },ax,{'horizontalALign','left','verticalAlign','top'})
% end

%%
for n=1:length(fieldnames(panel2))
    fprintf('%d pyr, %d inf in %d epochs\n',...
        sum(panel2.(alphabet(n)).legend.nCell),...
        sum(panel2b.(alphabet(n)).legend.nCell),...
        panel2.(alphabet(n)).legend.nEpoch)
end
%%
figNum='3';

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

print(fh,[saveDir '/eps/' 'QuantileFig' figNum '.eps'],'-depsc')
print(fh,[saveDir '/pdf/' 'QuantileFig' figNum '.pdf'],'-dpdf')


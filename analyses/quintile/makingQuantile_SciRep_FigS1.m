% simultionLogNormalFRChange
% shuffledFRchange
%%
clearvars -except AddLabelFlag

% colShuffle=hsv2rgb([0*ones(1,5);zeros(1,5);linspace(0.8,0,5);]');
% colMI=hsv2rgb([0*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
% colDLog=hsv2rgb([2/3*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colShuffle=hsv2rgb([1/12*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]')
colDLog=hsv2rgb([0/12*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');
colMI=hsv2rgb([5/12*ones(1,5);linspace(0.5,1,5);linspace(1,0.5,5);]');

colSimulate=colShuffle;

colError=0.5*[1,1,1];
% colErrorMI=hsv2rgb([2/3,1,0.5]);
% colErrorDLog=hsv2rgb([2/3,1,0.5]);
colErrorMI=colError;
colErrorDLog=colError;


changeTypeLabel{1}='No change';
changeTypeLabel{2}='Multiplicative decrease';
changeTypeLabel{3}='Additive decrease';
changeTypeLabel{4}='Both decrease';

changeType=1; % 1: no change 2:multiplicative 3:subtractive change, change 4:both changes
%1:shuffling, 2:additive noise, 3:multiplicative noise 4:both noises
rangeList(changeType).yRatioRaw(1,:)=[-1,2];
rangeList(changeType).yAmpRaw(1,:)=[0.05,0.1];
rangeList(changeType).yRatioDef(1,:)=[-1,1];
rangeList(changeType).yAmpDef(1,:)=[0.02,0.04];

rangeList(changeType).yRatioRaw(2,:)=[-1,2];
rangeList(changeType).yAmpRaw(2,:)=[0.2,0.5];
rangeList(changeType).yRatioDef(2,:)=[-1,1];
rangeList(changeType).yAmpDef(2,:)=[0.03,0.08];

rangeList(changeType).yRatioRaw(3,:)=[-1,2];
rangeList(changeType).yAmpRaw(3,:)=[0.2,0.5];
rangeList(changeType).yRatioDef(3,:)=[-1,1];
rangeList(changeType).yAmpDef(3,:)=[0.03,0.1];

rangeList(changeType).yRatioRaw(4,:)=[-1,2];
rangeList(changeType).yAmpRaw(4,:)=[0.2,0.4];
rangeList(changeType).yRatioDef(4,:)=[-1,1];
rangeList(changeType).yAmpDef(4,:)=[0.04,0.08];

changeType=2; % 1: no change 2:multiplicative 3:subtractive change, change 4:both changes
%1:NA, 2:additive noise, 3:multiplicative noise 4:both noises
rangeList(changeType).yRatioRaw(2,:)=[-2,3];
rangeList(changeType).yAmpRaw(2,:)=[0.1,0.3];
rangeList(changeType).yRatioDef(2,:)=[-2,1];
rangeList(changeType).yAmpDef(2,:)=[0.04,0.085];

rangeList(changeType).yRatioRaw(3,:)=[-1,1];
rangeList(changeType).yAmpRaw(3,:)=[0.3,0.8];
rangeList(changeType).yRatioDef(3,:)=[-2,1];
rangeList(changeType).yAmpDef(3,:)=[0.04,0.15];

rangeList(changeType).yRatioRaw(4,:)=[-2,3];
rangeList(changeType).yAmpRaw(4,:)=[0.1,0.2];
rangeList(changeType).yRatioDef(4,:)=[-3,2];
rangeList(changeType).yAmpDef(4,:)=[0.02,0.04];

changeType=3;% 1: no change 2:multiplicative 3:subtractive change, change 4:both changes
%1:NA, 2:additive noise, 3:multiplicative noise 4:both noises
rangeList(changeType).yRatioRaw(2,:)=[-2.5,3.5];
rangeList(changeType).yAmpRaw(2,:)=[0.1,0.22];
rangeList(changeType).yRatioDef(2,:)=[-2,0.8];
rangeList(changeType).yAmpDef(2,:)=[0.05,0.15];

rangeList(changeType).yRatioRaw(3,:)=[-3,4];
rangeList(changeType).yAmpRaw(3,:)=[0.1,0.3];
rangeList(changeType).yRatioDef(3,:)=[-8,1];
rangeList(changeType).yAmpDef(3,:)=[0.05,0.12];

rangeList(changeType).yRatioRaw(4,:)=[-2,3];
rangeList(changeType).yAmpRaw(4,:)=[0.1,0.1];
rangeList(changeType).yRatioDef(4,:)=[-3,1];
rangeList(changeType).yAmpDef(4,:)=[0.05,0.12];

changeType=4; % 1: no change 2:subtractive change, 3:multiplicative change 4:both changes
%1:NA, 2:additive noise, 3:multiplicative noise 4:both noises
rangeList(changeType).yRatioRaw(2,:)=[-2,3];
rangeList(changeType).yAmpRaw(2,:)=[0.1,0.2];
rangeList(changeType).yRatioDef(2,:)=[-4,1];
rangeList(changeType).yAmpDef(2,:)=[0.04,0.08];

rangeList(changeType).yRatioRaw(3,:)=[-2,3];
rangeList(changeType).yAmpRaw(3,:)=[0.1,0.2];
rangeList(changeType).yRatioDef(3,:)=[-5,1];
rangeList(changeType).yAmpDef(3,:)=[0.02,0.04];

rangeList(changeType).yRatioRaw(4,:)=[-2,3];
rangeList(changeType).yAmpRaw(4,:)=[0.1,0.2];
rangeList(changeType).yRatioDef(4,:)=[-3,2];
rangeList(changeType).yAmpDef(4,:)=[0.02,0.045];

noiseName={'shuff' 'add' 'mult' 'both'};
noisetype=[2,3];%1:shuffling, 2:additive noise, 3:multiplicative noise 4:both noises
for changeType=1:3; % 1: no change 2:subtractive change, 3:multiplicative change 4:both changes
    for n=1:length(noisetype)
        if noisetype(n)==1 & changeType==1
            panel1.(alphabet(changeType)){n}=loadGraph('quantile1',['a0' alphabet(noisetype(n))]);
            panel1.(alphabet(changeType)){n}.color=colSimulate;
            panel2.(alphabet(changeType)){n}=loadGraph('quantile1',['b0' alphabet(noisetype(n))]);
            panel3.(alphabet(changeType)){n}=loadGraph('quantile1',['c0' alphabet(noisetype(n))]);
            panel4.(alphabet(changeType)){n}=loadGraph('quantile1',['d0' alphabet(noisetype(n))]);
            panel5.(alphabet(changeType)){n}=loadGraph('quantile1',['e0' alphabet(noisetype(n))]);
            panel6.(alphabet(changeType)){n}=loadGraph('quantile1',['f0' alphabet(noisetype(n)) '1']);
            %     a6b{n}=loadGraph('quantile1',['f0' alphabet(n+1) '2']); %median
            panel7.(alphabet(changeType)){n}=loadGraph('quantile1',['g0' alphabet(noisetype(n)) '1']);
            %     a7b{n}=loadGraph('quantile1',['g1' alphabet(n+1) '2']); %median
            panel8.(alphabet(changeType)){n}=loadGraph('quantile1',['h0' alphabet(noisetype(n)) '1']);
            %     a8b{n}=loadGraph('quantile1',['h1' alphabet(n+1) '2']); %median
            panel9.(alphabet(changeType)){n}=loadGraph('quantile1',['i0' alphabet(noisetype(n)) '1']);
            %     a9b{n}=loadGraph('quantile1',['i1' alphabet(n+1) '2']); %median
        else
            panel1.(alphabet(changeType)){n}=loadGraph('quantile1',['a' num2str(changeType) alphabet(noisetype(n))]);
            panel1.(alphabet(changeType)){n}.color=colSimulate;
            panel2.(alphabet(changeType)){n}=loadGraph('quantile1',['b' num2str(changeType)  alphabet(noisetype(n))]);
            panel3.(alphabet(changeType)){n}=loadGraph('quantile1',['c' num2str(changeType)  alphabet(noisetype(n))]);
            panel4.(alphabet(changeType)){n}=loadGraph('quantile1',['d' num2str(changeType)  alphabet(noisetype(n))]);
            panel5.(alphabet(changeType)){n}=loadGraph('quantile1',['e' num2str(changeType)  alphabet(noisetype(n))]);
            panel6.(alphabet(changeType)){n}=loadGraph('quantile1',['f' num2str(changeType)  alphabet(noisetype(n)) '1']);
            %     a6b{n}=loadGraph('quantile1',['f1' alphabet(n+1) '2']); %median
            panel7.(alphabet(changeType)){n}=loadGraph('quantile1',['g' num2str(changeType)  alphabet(noisetype(n)) '1']);
            %     a7b{n}=loadGraph('quantile1',['g1' alphabet(n+1) '2']); %median
            panel8.(alphabet(changeType)){n}=loadGraph('quantile1',['h' num2str(changeType)  alphabet(noisetype(n)) '1']);
            %     a8b{n}=loadGraph('quantile1',['h1' alphabet(n+1) '2']); %median
            panel9.(alphabet(changeType)){n}=loadGraph('quantile1',['i' num2str(changeType)  alphabet(noisetype(n)) '1']);
            %     a9b{n}=loadGraph('quantile1',['i1' alphabet(n+1) '2']); %median
        end
        panel1.(alphabet(changeType)){n}.xlabel='FR_1 (Hz)';
        panel1.(alphabet(changeType)){n}.ylabel='FR_2 (Hz)';
        panel1.(alphabet(changeType)){n}.title=['Noise_{' noiseName{noisetype(n)} '}'];
                
        panel6.(alphabet(changeType)){n}.ylabel='CI';
        panel7.(alphabet(changeType)){n}.ylabel='\DeltalogFR';
        panel6.(alphabet(changeType)){n}.info.YLim=rangeList(changeType).yRatioRaw(noisetype(n),:)*rangeList(changeType).yAmpRaw(noisetype(n),1);
        panel7.(alphabet(changeType)){n}.info.YLim=rangeList(changeType).yRatioRaw(noisetype(n),:)*rangeList(changeType).yAmpRaw(noisetype(n),2);
        panel6.(alphabet(changeType)){n}.title='';
        panel7.(alphabet(changeType)){n}.title='';        
        
        panel8.(alphabet(changeType)){n}.ylabel={'DI'};
        panel9.(alphabet(changeType)){n}.ylabel={'Def. \DeltalogFR'};
        panel8.(alphabet(changeType)){n}.title='';
        panel9.(alphabet(changeType)){n}.title='';
        panel8.(alphabet(changeType)){n}.info.YLim=rangeList(changeType).yRatioDef(noisetype(n),:)*rangeList(changeType).yAmpDef(noisetype(n),1);
        panel9.(alphabet(changeType)){n}.info.YLim=rangeList(changeType).yRatioDef(noisetype(n),:)*rangeList(changeType).yAmpDef(noisetype(n),2);
    
    end
    
    
    
end


showMI=true;
densityRange=10.^[-2,1];
densityTick=[-2,0];
densityTickLabel={'10^{-2}','10^{0}'};
%%
close all
origX=16;
origY=13;
panelLetterSize=12;
letterGapX=10;
letterGapY=10;
marginX=24;
marginY=26;
innerMarginY=10;
innerMarginX=10;
width=16;
height=width*2/3;


% fh=initFig4JNeuro(2);
fh=initFig4SleepSup(2);
set(fh,'defaultLineMarkerSize',1)
isPanelLetterCapital=true;

cLim=[0,0.5];
%%
for changeType=1:3
    totalGapX=(changeType-1)*(2*width+marginX+innerMarginX);
    totalGapY=0;
    
    for n=1:length(panel1.(alphabet(changeType)))
        xPos=origX+(n-1)*(width+innerMarginX);
        yPos=origY+0*(height+marginY);
        xPos=xPos+totalGapX;
        yPos=yPos+totalGapY;
        subplotInMM(xPos,yPos,width,height,true)
        
        fr=[cat(1,panel1.(alphabet(changeType)){n}.xValue{:}),...
            cat(1,panel1.(alphabet(changeType)){n}.yValue{:})];
        fr=log10(fr);
        logXrange=log10(densityRange);
        logYrange=log10(densityRange);
        xbin=linspace(logXrange(1),logXrange(2),50);
        ybin=linspace(logYrange(1),logYrange(2),50);
        densMap=hist2(fr,xbin,ybin);
        
        mu = [0 0];
        Sigma = [1 0; 0 1];
        smoothCoreBin = -3:3; smoothCoreBin = -3:3;
        [smoothCoreBin,smoothCoreBin] = meshgrid(smoothCoreBin,smoothCoreBin);
        smoothCore = mvnpdf([smoothCoreBin(:) smoothCoreBin(:)],mu,Sigma);
        smoothCore = reshape(smoothCore,length(smoothCoreBin),length(smoothCoreBin));
        smoothCore=smoothCore/sum(sum(smoothCore));
        
        densMap=conv2(densMap,smoothCore,'same');
        densMap=densMap/sum(sum(densMap))*100;
        imagescXY(logXrange,logYrange,(densMap))
        set(gca,'clim',cLim)
        xlim([-2,1])
        ylim([-2,1])
        
        set(gca,'xtick',densityTick,...
            'xtickLabel',densityTickLabel,...
            'ytick',densityTick,...
            'ytickLabel',densityTickLabel)
        box off
        xlabel(panel1.(alphabet(changeType)){n}.xlabel)
        ylabel(panel1.(alphabet(changeType)){n}.ylabel)
        colormap(gca,jet)
        plotIdentityLine(gca,{'color',0.99*[1,1,1]})
        if n>1
            ylabel('')
        end
        hold on
        plot(mean(fr(:,1)),mean(fr(:,2)),'kx','markersize',4)

        title(panel1.(alphabet(changeType)){n}.title,'fontweight','normal')
        if n==length(panel1.(alphabet(changeType)))
            subplotInMM(xPos+width+1,yPos,1,height,true)
            imagescXY([0,1],cLim,linspace(cLim(1),cLim(2),128))
            box off
            colormap(gca,jet)
            set(gca,'clim',cLim)
            set(gca,'yAxisLocation','right')
            set(gca,'xtick',[])
            ax=fixAxis;
            text2(2,1.05,'%',ax,{'fontsize',9,'verticalAlign','bottom'})
%             ylabel('%')
%             set(get(gca,'ylabel'),'rotation',-90,'position',get(get(gca,'ylabel'),'position')+[6,0,0])
        end
        
        if n==1
            panelLetter(xPos-letterGapX,yPos-letterGapY,alphabet(changeType,isPanelLetterCapital),panelLetterSize)
        end
        
    end
    
    
    xPos=origX+width+innerMarginX/2;
    yPos=origY-letterGapY*0.7;
    xPos=xPos+totalGapX;
    yPos=yPos+totalGapY;
    subplotInMM(xPos,yPos,1,1)
    xlim([0,1]);ylim([0,1]);
    text(0,0,changeTypeLabel{changeType},'horizontalAlign','center','verticalALign','bottom','fontsize',9,'fontweight','bold');
    axis off
    
    for mm=1:2%4
        for n=1:length(panel1.(alphabet(changeType)))
            xPos=origX+(n-1)*(width+innerMarginX);
            yPos=origY+(mm)*(height+innerMarginY);
            xPos=xPos+totalGapX;
            yPos=yPos+totalGapY;
            subplotInMM(xPos,yPos,width,height,true)
            
            target1=panel6.(alphabet(changeType)){n};
            target2=panel7.(alphabet(changeType)){n};
            
            ref1=panel8.(alphabet(changeType)){n};
            ref2=panel9.(alphabet(changeType)){n};
            
            offset1=mod(mm-1,2)*target1.legend.shuffle.mean;
            offset2=mod(mm-1,2)*target2.legend.shuffle.mean;
            %     target1=eval(['a' num2str(4+2*mm) '{n};'])
            %     target2=eval(['a' num2str(5+2*mm) '{n};'])
            
            if mm<3
                fill([target1.xValue,fliplr(target1.xValue)],...
                    [target1.legend.shuffle.confInt(1,:)-offset1,fliplr(target1.legend.shuffle.confInt(2,:)-offset1)],...
                    colErrorMI,'faceAlpha',0.5,'linestyle','none')
                xlim(target1.info.XLim)
                if mm==1
                    ylim(target1.info.YLim)
                else
                    ylim(ref1.info.YLim)
                end
                hold on
                plot(target1.info.XLim,[0,0],'k-')
                for noisetype=1:length(target1.xValue)
                    plot((target1.xValue(noisetype))*[1,1],...
                        target1.yValue(noisetype)-offset1(noisetype)+target1.legend.real.ste(noisetype)*[0,2*(target1.yValue(noisetype)>offset1(noisetype))-1],...
                        'color',colMI(noisetype,:))
                    barHandle=bar(target1.xValue(noisetype),target1.yValue(noisetype)-offset1(noisetype),0.8,...
                        'linestyle','none','facecolor',colMI(noisetype,:),'linestyle','none')
                    barHandle.BaseLine.Visible='off';
                end
                
                xlabel(target1.xlabel)
                xlim(target1.info.XLim)
                if mm==1
                    ylabel(target1.ylabel)
                    ylim(target1.info.YLim)
                else
                    ylabel(ref1.ylabel)
                    ylim(ref1.info.YLim)
                end
                
                if mm==2 && changeType==2
                    set(gca,'ytick',-0.08:0.04:0,'yticklabel',-0.08:0.04:0)
                end
                
            else
                fill([target2.xValue,fliplr(target2.xValue)],...
                    [target2.legend.shuffle.confInt(1,:)-offset2,fliplr(target2.legend.shuffle.confInt(2,:)-offset2)],...
                    colErrorDLog,'faceAlpha',0.5,'linestyle','none')
                hold on
                plot(target2.info.XLim,[0,0],'k-')
                xlim(target2.info.XLim)
                if mod(mm,2)==1
                    ylim(target2.info.YLim)
                else
                    ylim(ref2.info.YLim)
                end
                hold on
                for noisetype=1:length(target2.xValue)
                    plot((target2.xValue(noisetype))*[1,1],...
                        target2.yValue(noisetype)-offset2(noisetype)+target2.legend.real.ste(noisetype)*[0,2*(target2.yValue(noisetype)>offset2(noisetype))-1],...
                        'color',colDLog(noisetype,:))
                    %         bar(target.xValue(m)+0.25,target.yValue(m),0.4,...
                    %             'edgecolor',colDLog(m,:),'facecolor',0.99*[1,1,1])
                    barHandle=bar(target2.xValue(noisetype),target2.yValue(noisetype)-offset2(noisetype),0.8,...
                        'facecolor',colDLog(noisetype,:),'linestyle','none');
                    barHandle.BaseLine.Visible='off';
                end
                ylabel(target2.ylabel)
                xlabel(target2.xlabel)
                if mod(mm,2)==1
                    ylabel(target2.ylabel)
                    ylim(target2.info.YLim)
                else
                    ylabel(ref2.ylabel)
                    ylim(ref2.info.YLim)
                end
            end
            box off
            if mm==2
                title(ref2.title)
            end
            if n>1
                ylabel('')
            end
        end
    end
end
%%
totalGapX=0;
totalGapY=4*(height+innerMarginY)+height+innerMarginY*1.8;




% 
% frList=0.1:0.1:0.5;
% for measureType=1:2
%     if measureType==1
%         measure=@(x,y) (x-y)./(x+y);
%         measureName='CI';
%         col=colMI;
%         yRange=[-1.1,1];
%     else
%         measure=@(x,y) log(x./y);
%         measureName='\DeltalogFR';
%         col=colDLog;
%         yRange=[-4,1];
%     end
%     xPos=origX+(measureType-1)*(width+1.5*marginX);
%     yPos=origY;
% 
%     xPos=xPos+totalGapX;
%     yPos=yPos+totalGapY;
%     subplotInMM(xPos,yPos,width*1.5,height*1.5,true)
% 
%     fr2=0:0.001:0.31;
%     
%     hold on
%     legend={'FR_1'};
%     for n=1:length(frList)
%         plot(fr2,measure(fr2,frList(n)),'color',col(n,:))
%         legend{n+1}=['\color[rgb]{' num2str(col(n,:)) '}' num2str(frList(n)) ' Hz'];
%     end
%     ylim(yRange)
%     xlim([0,0.3])
%     set(gca,'xtick',0:0.1:0.3)
%     xlabel('FR_2 (Hz)')
%     ylabel(measureName)
%     ax=fixAxis;
%     text2(1.03,0,legend,ax,{'horizontalALign','left','verticalAlign','bottom'})
%     if measureType==1
%         panelLetter(xPos-letterGapX,yPos-letterGapY,alphabet(4,isPanelLetterCapital),panelLetterSize)
%     end
% end


%%
figNum='S1';

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


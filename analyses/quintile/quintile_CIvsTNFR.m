% timeNorm_stateTrans
clear
baseDir='~/data/sleep/pooled_withCohEMG/';
coreName='sleep';

load([baseDir coreName '-' 'timeNorm_stateChange_fineBins' '.mat'])


%%
close all
origX=13;
origY=13;
panelLetterSize=12;
letterGapX=10;
letterGapY=5;
marginX=15;
marginY=20;
timeNormWidth=40;
height=18;
ciWidth=13;

innerMarginX=(3*timeNormWidth+2*marginX-marginX-2*(timeNormWidth+ciWidth))/2;
innerMarginY=12;

% fh=initFig4JNeuro(2);
isPanelLetterCapital=true;


totalGapX=0;
totalGapY=0;

% stateList={'nrem2rem','rem2nrem','nrem','rem'};
stateList={'nrem2rem','rem2nrem'};

basePyrCol=rgb2hsv([1,0.4,0]);

nDiv=real.param.(stateList{1}).both.nDiv;

col=[hsv2rgb([basePyrCol(1)*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,1,nDiv)']);
    [0,0.6,1]];
titleText.quiet2nrem='Wake to NREM';
titleText.nrem2quiet='NREM to Wake';
titleText.rem2quiet='REM to Wake';
titleText.rem2nrem='REM to NREM';
titleText.nrem2rem='NREM to REM';

titleText.nrem='Within NREM';
titleText.rem='Within REM';


orderTypeText.mean='mean within state';
orderTypeText.both='mean across states';
orderTypeText.onset='first 5th of state 2';
orderTypeText.offset='last 5th of state 1';
orderTypeText.prev='mean within state 1';
orderTypeText.next='mean within state 2';

doAppend='';
psFileName='~/Dropbox/Quantile/preliminary/timenormalizedFR.ps'

for stateIdx=1:length(stateList)
    state=stateList{stateIdx};
    fh=initFig4Sleep2(2);
    set(fh,'defaultLineMarkerSize',1)

    
    for orderTypeIdx=1:5
        switch orderTypeIdx
            case 1
                if ~contains(state,'2')
                    orderType='mean';
                else
                    orderType='both';
                end
            case 2
                orderType='onset';
            case 3
                orderType='offset';
            case 4
                if ~contains(state,'2')
                    continue
                else
                    orderType='prev';
                end
            case 5
                if ~contains(state,'2')
                    continue
                else
                    orderType='next';
                end
            otherwise
                continue
        end
        
        nBin=real.param.(state).(orderType).nBin;
        baseBin=real.param.(state).(orderType).orderBin;
        nDiv=real.param.(state).(orderType).nDiv;
        
        for useHz=0:2
            xPos=origX+useHz*(timeNormWidth+marginX)+totalGapX;
            yPos=origY+(height+marginY)*(orderTypeIdx-1)+totalGapY;
            subplotInMM(xPos,yPos,timeNormWidth,height,true)
            
            
            hold on
            if useHz==0
                for qIdx=1:nDiv+1
                    plot(real.fr.(state).(orderType).mean(qIdx,:),'color',col(qIdx,:))
                end
                set(gca,'yscale','log')
                set(gca,'ytick',10.^[-2:2:0])
                ylabel('FR (Hz)')
                ylim(10.^[-3,1.5])
            elseif useHz==1
                for qIdx=1:nDiv
                    plot(real.percent.(state).(orderType).mean(qIdx,:),'color',col(qIdx,:))
                end
                    plot(real.percent.(state).(orderType).mean(6,:),'color',col(6,:))
                ylabel('FR (%)')
                axis tight
            else
                for qIdx=1:nDiv+1
                    plot(real.z.(state).(orderType).mean(qIdx,:),'color',col(qIdx,:))
                end
                ylabel('FR (Z)')
            end
            
            
            xlim([1,sum(nBin)])
            ax=fixAxis;
            plot(nBin(1)+0.5*[1,1],ax(3:4),'-','color',0.5*[1,1,1])
            xlabel('Normalized time')
            set(gca,'xtick',[])
            if ~useHz
                title(['ordered by ' orderTypeText.(orderType)])
                if orderTypeIdx==1
                    text2(-0.1,6,titleText.(state),ax,{'horizontalAlign','left','verticalALign','bottom','fontsize',10})
                end
            end

            
            %     for ciType=1:2
            %
            %
            %             if length(nBin)>1
            %                 if ciType==1
            %                     orderType='offset';
            %                 else
            %                     orderType='onset';
            %                 end
            %             else
            %                 if ciType==1
            %                     orderType='onset';
            %                 else
            %                     orderType='offset';
            %                 end
            %             end
            
%             for avgType=1:2
%                 nShuffle=shuffle.param.(state).(orderType).nShuffle;
%                 
%                 xPos=origX+3*(timeNormWidth+marginX)+(avgType-1)*(ciWidth+marginX)+totalGapX;
%                 yPos=origY+(height+marginY)*(orderTypeIdx-1)+totalGapY;
%                 
%                 subplotInMM(xPos,yPos,ciWidth,height,true)
%                 
%                 hold on
%                 clear temp;
%                 chanceLevel=sort(shuffle.ci.(state).(orderType),2);
%                 
%                 if avgType==1
%                     avg=zeros(nDiv+1,1);
%                     yText='CI';
%                 else
%                     avg=mean(chanceLevel,2);
%                     yText='DI';
%                 end
%                 chanceLevel=chanceLevel(:,[ceil(nShuffle*0.975),max([1,floor(nShuffle*0.025)])])-repmat(avg,1,2);
%                 
%                 
%                 for qIdx=1:nDiv+1
%                     bar(qIdx,real.ci.(state).(orderType).mean(qIdx)-avg(qIdx),'facecolor',col(qIdx,:),'linestyle','none')
%                 end
%                 fill([1:nDiv+1,nDiv+1:-1:1],[chanceLevel(:,1);chanceLevel(end:-1:1,2)],0.5*[1,1,1],'linestyle','none','facealpha',0.5);
%                 
%                 xlim([0,nDiv+2])
%                 ylabel(yText)
%                 set(gca,'xtick',[1:2:5,6],'xticklabel',{'L','M','H','I'})
%                 
%                 xlabel('Quintile')
% %                 title('Btw last and first bins')
%             end
        end
    end
    addScriptName(mfilename);
    print(psFileName,'-dpsc','-painters',doAppend)
    doAppend='-append';
end
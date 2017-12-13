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
marginX=17;
marginY=20;
timeNormWidth=40;
height=17;
ciWidth=16;

innerMarginX=(3*timeNormWidth+2*marginX-marginX-2*(timeNormWidth+ciWidth))/2;
innerMarginY=12;

% fh=initFig4JNeuro(2);
fh=initFig4Sleep2(2);
set(fh,'defaultLineMarkerSize',1)
isPanelLetterCapital=true;


totalGapX=0;
totalGapY=0;

stateList={'nrem2rem','rem2nrem','nrem','rem'};

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

useHz=false;

for stateIdx=1:length(stateList)
    state=stateList{stateIdx}; 
    
    if isempty(strfind(state,'2'))
        orderType='mean';
    else        
        orderType='both';
    end
    
    nBin=real.param.(state).(orderType).nBin;
    baseBin=real.param.(state).(orderType).orderBin;
    nDiv=real.param.(state).(orderType).nDiv;
    

    
    
    xPos=origX+mod(stateIdx-1,2)*(timeNormWidth+marginX)+totalGapX;
    yPos=origY+ceil(stateIdx/2-1)*(3*height+marginY+2*innerMarginY)+totalGapY;
    subplotInMM(xPos,yPos,timeNormWidth,height,true)
    

    hold on
    if useHz
        for qIdx=1:nDiv+1
            plot(real.fr.(state).(orderType).mean(qIdx,:),'color',col(qIdx,:))
        end
        set(gca,'yscale','log')
        set(gca,'ytick',10.^[-2:2:0])
        ylabel('FR (Hz)')
        ylim(10.^[-3,1.5])
    else
        for qIdx=1:nDiv+1
            base=mean(real.fr.(state).(orderType).mean(qIdx,real.param.(state).(orderType).orderBin))
            plot(real.fr.(state).(orderType).mean(qIdx,:)/base*100,'color',col(qIdx,:))
        end
        ylabel('FR (%)')
    end
    
    title(titleText.(state))
    xlim([1,sum(nBin)])
    ax=fixAxis;
    plot(nBin(1)+0.5*[1,1],ax(3:4),'-','color',0.5*[1,1,1])
    xlabel('Normalized time')
    set(gca,'xtick',[])


        
    panelLetter(xPos-letterGapX,yPos-letterGapY,alphabet(stateIdx,true),panelLetterSize)

    
    for ciType=1:2
        for avgType=1:2
            
            if length(nBin)>1        
                if ciType==1
                    orderType='offset';
                else
                    orderType='onset';
                end
            else
                if ciType==1
                    orderType='onset';
                else
                    orderType='offset';
                end
            end

            nShuffle=shuffle.param.(state).(orderType).nShuffle;

            xPos=origX++mod(stateIdx-1,2)*(timeNormWidth+marginX)+(ciType-1)*(timeNormWidth-ciWidth)+totalGapX;
            yPos=origY+avgType*(height+innerMarginY)+ceil(stateIdx/2-1)*(3*height+marginY+2*innerMarginY)+totalGapY;
            subplotInMM(xPos,yPos,ciWidth,height,true)

            hold on 
            clear temp;
            chanceLevel=sort(shuffle.ci.(state).(orderType),2);
            
            if avgType==1
                avg=zeros(nDiv+1,1);
                yText='CI';
            else
                avg=mean(chanceLevel,2);
                yText='DI';
            end
            chanceLevel=chanceLevel(:,[ceil(nShuffle*0.975),max([1,floor(nShuffle*0.025)])])-repmat(avg,1,2);
            

            for qIdx=1:nDiv+1
               bar(qIdx,real.ci.(state).(orderType).mean(qIdx)-avg(qIdx),'facecolor',col(qIdx,:),'linestyle','none')
            end
            fill([1:nDiv+1,nDiv+1:-1:1],[chanceLevel(:,1);chanceLevel(end:-1:1,2)],0.5*[1,1,1],'linestyle','none','facealpha',0.5);

            xlim([0,nDiv+2])
            if ciType==1
                ylabel(yText)
            else
                ylabel('')
            end
        %         xlabel('Quintile')
            set(gca,'xtick',[1:2:5,6],'xticklabel',{'L','M','H','I'})
            if avgType==1
                title({'Ordered' ['at ' orderType]})
                xlabel('')
            else
                xlabel('Quintile')
            end
            
        end
        
        
    end


end
    
%%
    
figNum='2';

if ~exist('AddLabelFlag','var') || AddLabelFlag
    addFigureLabel(['Figure ' figNum])
end
saveDir='~/Dropbox/Quantile/newFig/';


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
% 
    
    
    
    
    
    
    
    
    
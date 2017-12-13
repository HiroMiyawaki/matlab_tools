clear
baseDir='~/data/sleep/pooled_withCohEMG/';
coreName='sleep';

load([baseDir coreName '-' 'timeNorm_stateChange_fineBins' '.mat'])
load([baseDir coreName '-' 'timeNormFR' '.mat'])
load([baseDir coreName '-' 'stateChange20s' '.mat'])
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

basePyrCol=rgb2hsv([1,0.4,0]);

nDiv=real.param.nrem2quiet.both.nDiv;

col=[hsv2rgb([basePyrCol(1)*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,1,nDiv)']);
     [0,0.6,1]];
 
ci=@(x) diff(x,1,2)./sum(x,2);
 
dName='RoySleep0';
% tIdx=5;
% tIdx=27
tIdx=32;

idx=stateChange.(dName).quiet2nrem(tIdx,:);


pyr=[timeNormFR.(dName).offset.pyr{idx(1)},timeNormFR.(dName).onset.pyr{idx(2)}];
inh=[timeNormFR.(dName).offset.inh{idx(1)},timeNormFR.(dName).onset.inh{idx(2)}];

orderBin{1}=1:size(timeNormFR.(dName).offset.pyr{idx(1)},2);
orderBin{2}=(1:size(timeNormFR.(dName).offset.pyr{idx(2)},2))+size(timeNormFR.(dName).offset.pyr{idx(1)},2);
tText={'wake','sleep'}

surrPyr=zeros([size(pyr),2000]);
surrInh=zeros([size(inh),2000]);
for ite=1:2000
    rIdx=zeros(size(pyr));
    for cIdx=1:size(pyr,1)
        rIdx(cIdx,:)=cIdx+(randperm(size(pyr,2))-1)*size(pyr,1);
    end
    surrPyr(:,:,ite)=pyr(rIdx);

    rIdx=zeros(size(inh));
    for cIdx=1:size(inh,1)
        rIdx(cIdx,:)=cIdx+(randperm(size(inh,2))-1)*size(inh,1);
    end
    surrInh(:,:,ite)=inh(rIdx);    
end

for n=1:2
    ranking=ceil(tiedrank(mean(pyr(:,orderBin{n}),2))/size(pyr,1)*nDiv);

    xPos=origX+(n-1)*(timeNormWidth+ciWidth+marginX+innerMarginX)+totalGapX;
    yPos=origY+0*(height+marginY)+totalGapY;

    subplotInMM(xPos,yPos,timeNormWidth,height,true)

    title(['Ordered by ' tText{n}])
        
    hold on
    for m=1:nDiv
%         baseLine=mean(mean(pyr(ranking==m,orderBin{n})));
%         baseLine=mean(mean(pyr(ranking==m,:)));
            baseLine=100;
        
        plot(1:size(pyr,2),mean(pyr(ranking==m,:),1)/baseLine*100,'-','color',col(m,:))
        
        realCI(m)=nanmean(ci(pyr(ranking==m,5:6)));
    end
%     baseLine=mean(mean(inh(:,orderBin{n})));
%     baseLine=mean(mean(inh(:,:)));
    plot(1:size(inh,2),mean(inh,1)/baseLine*100,'-','color',col(nDiv+1,:))
    realCI(nDiv+1)=nanmean(ci(inh(:,5:6)));
     
    ylabel('FR (Hz)')
    set(gca,'XTick',[])
    xlabel('Normalized time')
    
    set(gca,'yscale','log')
    set(gca,'ytick',10.^[-4:2:2])
    ylim(10.^[-4,1.5])
    
    xlim([1,size(pyr,2)])
    ax=fixAxis;
    plot((size(timeNormFR.(dName).offset.pyr{idx(1)},2)+0.5)*[1,1],ax(3:4),'-','color',0.5*[1,1,1])
    
    if n==1
        panelLetter(xPos-letterGapX,yPos-letterGapY,alphabet(1,isPanelLetterCapital),panelLetterSize)
    end
    
    xPos=origX+(n-1)*(timeNormWidth+ciWidth+2*marginX)+timeNormWidth+innerMarginX+totalGapX;
    subplotInMM(xPos,yPos,ciWidth,height,true)
    
    ranking=ceil(tiedrank(mean(surrPyr(:,orderBin{n},:),2))/size(surrPyr,1)*nDiv);
    
    for ite=1:size(surrPyr,3)
        for m=1:nDiv
            ciChance(m,ite)=nanmean(ci(surrPyr(ranking(:,ite)==m,5:6,ite)));
        end
            ciChance(nDiv+1,ite)=nanmean(ci(surrInh(:,5:6,ite)));
    end
    ciChance=sort(ciChance,2);
    
    chanceLevel=ciChance(:,[floor(2000*0.025),ceil(2000*0.975)]);
    
    hold on
    for m=1:nDiv+1
       bar(m,realCI(m),'facecolor',col(m,:),'linestyle','none')
    end
    fill([1:nDiv+1,nDiv+1:-1:1],[chanceLevel(:,1);chanceLevel(end:-1:1,2)],0.5*[1,1,1],'linestyle','none','facealpha',0.5);

    xlim([0,nDiv+2])
%     ylim([-0.6,1])
    ylabel('CI')
    set(gca,'xtick',[1:2:5,6],'xticklabel',{'L','M','H','I'})
    
end

% xPos=origX+1*(timeNormWidth+ciWidth+marginX+innerMarginX)+totalGapX;
% yPos=origY+0*(height+marginY)+totalGapY;
% 
% subplotInMM(xPos,yPos,timeNormWidth,height,true)
% title('Example, ordered by sleep')
% 
% xPos=origX+1*(timeNormWidth+ciWidth+innerMarginX+marginX)+timeNormWidth+innerMarginX+totalGapX;
% subplotInMM(xPos,yPos,ciWidth,height,true)
% title('CI with shuffling')
% 
%%
stateList={'quiet2nrem','nrem2quiet','rem2quiet'};

totalGapX=0;
totalGapY=height+marginY;

basePyrCol=rgb2hsv([1,0.4,0]);

nDiv=real.param.(stateList{1}).both.nDiv;

col=[hsv2rgb([basePyrCol(1)*ones(nDiv,1),linspace(0.5,1,nDiv)',linspace(1,1,nDiv)']);
     [0,0.6,1]];
titleText.quiet2nrem='Wake to NREM';
titleText.nrem2quiet='NREM to Wake';
titleText.rem2quiet='REM to Wake';
titleText.rem2nrem='REM to NREM';
titleText.nrem2rem='NREM to REM';
    

useHz=false;

for stateIdx=1:length(stateList)
    state=stateList{stateIdx}; 
    orderType='both';

    nBin=real.param.(state).(orderType).nBin;
    baseBin=real.param.(state).(orderType).orderBin;
    nDiv=real.param.(state).(orderType).nDiv;
    
    
    xPos=origX+(stateIdx-1)*(timeNormWidth+marginX)+totalGapX;
    yPos=origY+0*(height+marginY)+totalGapY;
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

        
    panelLetter(xPos-letterGapX,yPos-letterGapY,alphabet(1+stateIdx,true),panelLetterSize)

    
    for ciType=1:2
        for avgType=1:2
        
            if ciType==1
                orderType='offset';
            else
                orderType='onset';
            end

            nShuffle=shuffle.param.(state).(orderType).nShuffle;

            xPos=origX+(stateIdx-1)*(timeNormWidth+marginX)+(ciType-1)*(timeNormWidth-ciWidth)+totalGapX;
            yPos=origY+avgType*(height+innerMarginY)+totalGapY;
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
    
figNum='1';

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

print(fh,[saveDir '/eps/' 'QuantileFig' figNum '.eps'],'-depsc')
print(fh,[saveDir '/pdf/' 'QuantileFig' figNum '.pdf'],'-dpdf')

    
    
    
    
    
    
    
    
    
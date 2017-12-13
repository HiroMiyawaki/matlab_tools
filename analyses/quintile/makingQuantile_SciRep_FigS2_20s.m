% 
% Quantile_pyr_inh

%%
clearvars -except AddLabelFlag

close all
origX=20;
origY=20;
panelLetterSize=12;
letterGapX=10;
letterGapY=6;
marginX=30;
marginY=22;
innerMarginY=10;
innerMarginX=18;
exampleWidth=25;
exampleHeight=exampleWidth;
plotWidth=60;
plotHeight=60;

% fh=initFig4JNeuro(2);
fh=initFig4SleepSup(2);
set(fh,'defaultLineMarkerSize',1)
isPanelLetterCapital=true;

baseDir='~/data/sleep/pooled_withCohEMG/';
coreName='sleep';

load([baseDir coreName '-' 'waveProperty' '.mat']);
load([baseDir coreName '-' 'basics' '.mat']);
%%
col=[1,0.6,0;0,0.4,1];

totalGapX=0;
totalGapY=0;
clf
% n=0
%  n=n+1
for idx=1:2
    if idx==1
        dName='RoySleep0';
        unit=23 %215 75 52 23 22 15 93 79 34 2 9 18
        tText='Pyramidal cell';
    else
        dName='RoySleep0';
        unit=193; %74 66 72 63 64 137 146
        tText='Interneuron';
    end
    xPos=origX+(idx-1)*(exampleWidth+innerMarginX)+totalGapX;
    yPos=origY+totalGapY;
    
    subplotInMM(xPos,yPos,exampleWidth,exampleHeight,true);
    hold on
    plot([1,54]/basics.(dName).SampleRate*1e3,[0,0],'-','color',0.8*[1,1,1])
    plot(waveProperty.(dName).aPos(unit)*[1,1]/basics.(dName).SampleRate*1e3,[0,waveProperty.(dName).a(unit)],'k-')
    plot(waveProperty.(dName).bPos(unit)*[1,1]/basics.(dName).SampleRate*1e3,[0,waveProperty.(dName).b(unit)],'k-')

    plot(waveProperty.(dName).half(unit,:)/basics.(dName).SampleRate*1e3,waveProperty.(dName).amp(unit)/2*[1,1],'k-')
    
    plot((1:54)/basics.(dName).SampleRate*1e3,waveProperty.(dName).form(unit,:),'color',col(idx,:))
    axis tight
    ax=fixAxis;
    xlim([0.1,1.8])
    ylim([ax(3),ax(4)+diff(ax(3:4))*0.2])

    text(waveProperty.(dName).aPos(unit)/basics.(dName).SampleRate*1e3,waveProperty.(dName).a(unit)+0.05*diff(ax(3:4)),'a','verticalAlign','bottom')
    text(waveProperty.(dName).bPos(unit)/basics.(dName).SampleRate*1e3,waveProperty.(dName).b(unit)+0.05*diff(ax(3:4)),'b','verticalAlign','bottom')

    text(waveProperty.(dName).half(unit,2)/basics.(dName).SampleRate*1e3+0.1,...
         waveProperty.(dName).amp(unit)/2,{'Width',['(' num2str(waveProperty.(dName).c(unit),'%.2f') ' ms)']},'horizontalAlign','left')

    box off
    title(tText)
    
    if idx==1
        ax=fixAxis;
        panelLetter(xPos-letterGapX,yPos-letterGapY,'A',panelLetterSize);
    else
        
        plot([0.1,0.6],ax(3:4)*[0.8;0.2]*[1,1],'k-')
        text(mean([0.1,0.6]),ax(3:4)*[0.8;0.2],'0.5 ms','horizontalAlign','center','verticalAlign','bottom')
        
    end
    
    axis off
    xPos=origX+(idx-1)*(exampleWidth+innerMarginX);
    yPos=origY+exampleHeight+innerMarginY;    
    subplotInMM(xPos,yPos,exampleWidth,exampleHeight,true);
    bar(waveProperty.(dName).acgT,waveProperty.(dName).acg(unit,:),1,'facecolor',col(idx,:),'linestyle','none')
    axis tight
    ax=fixAxis;
    box off
    hold on
    plot(waveProperty.(dName).mode(unit)*[1,1],ax(3:4),'k-')
    xlim(50*[-1,1])
    xlabel('Time (ms)')
    ylabel('Count')
    text(waveProperty.(dName).mode(unit)+2,ax(4)+0.1*diff(ax(3:4)),{'Mean' ['(' num2str(waveProperty.(dName).mode(unit),'%.1f') ' ms)']},'verticalAlign','top','horizontalAlign','left')
end
%%
totalGapX=exampleWidth*2+innerMarginX+marginX;
totalGapY=0;

xPos=origX+totalGapX;
yPos=origY+totalGapY;

panelLetter(xPos-letterGapX,yPos-letterGapY,'B',panelLetterSize)


dList=fieldnames(waveProperty);
subplotInMM(xPos,yPos,plotWidth,plotHeight,true)
    func{1}=@(x) x.mode;
    func{2}=@(x) x.c;
    func{3}=@(x) (x.b-x.a)./(x.a+x.b);
    labTxt{1}='Mean ISI (ms)';
    labTxt{2}='Spike width (ms)';
    labTxt{3}='(b-a)/(b+a)';
    val={[],[];[],[];[],[]};
    for dIdx=1:length(dList)
        dName=dList{dIdx};
        for axIdx=1:length(func)
            temp=func{axIdx}(waveProperty.(dName));
            for cType=1:2
                if cType==1
%                    target=find(waveProperty.(dName).quality<4  & waveProperty.(dName).isoDist>15);
                   target=find(waveProperty.(dName).quality<4  & waveProperty.(dName).isStable==1);
                else
%                    target=find(waveProperty.(dName).quality==8 & waveProperty.(dName).isoDist>15);
                   target=find(waveProperty.(dName).quality==8  & waveProperty.(dName).isStable==1);
                end

                val{axIdx,cType}=[val{axIdx,cType},temp(target)];
            end
        end
    end
    for cType=1:2
        hold on
    plot3(val{1,cType},val{2,cType},val{3,cType},'.','markersize',6,'color',col(cType,:))
    box on
    grid on
    view([-30,21])
    xlabel(labTxt{1})
    ylabel(labTxt{2})
    zlabel(labTxt{3}) 
    set(gca,'ytick',0:0.2:0.4)
    ylim([0,0.4])
    end



%%
figNum=['S2'];

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


    
    
    
    
    
    
    
    
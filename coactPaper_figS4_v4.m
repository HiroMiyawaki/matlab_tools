function coactPaper_figS4_v4()
labelWeight=true;
labelCase=false;
labelSize=8;
letGapX=5;
letGapY=6;

close all
fh=initFig4Nature('height',10);

x=19;y=5;
panel_01(x,y);
panelLetter2(x-letGapX,y-letGapY+2,alphabet(1,labelCase),'fontSize',labelSize,'isBold',labelWeight)
drawnow();

x=19;y=49;
panel_02(x,y);
panelLetter2(x-letGapX,y-letGapY+2,alphabet(2,labelCase),'fontSize',labelSize,'isBold',labelWeight)
drawnow();

x=66;y=49;
panel_03(x,y);
panelLetter2(x-letGapX,y-letGapY+2,alphabet(3,labelCase),'fontSize',labelSize,'isBold',labelWeight)
drawnow();

x=113;y=49;
panel_04(x,y);
panelLetter2(x-letGapX,y-letGapY+2,alphabet(4,labelCase),'fontSize',labelSize,'isBold',labelWeight)
drawnow();

x=164;y=49;
panel_05(x,y);
panelLetter2(x-letGapX-4,y-letGapY+2,alphabet(5,labelCase),'fontSize',labelSize,'isBold',labelWeight)
drawnow();


% addFigureLabel('Extended Data Figure 4')

if ~exist('~/Dropbox/FearAnalyses/paper/figure','dir')
    mkdir('~/Dropbox/FearAnalyses/paper/figure')
end
print(fh,'~/Dropbox/FearAnalyses/paper/figure/exfig04.pdf','-dpdf','-painters','-r300')
%
end

%%
function panel_01(x,y)
xGap=3;
width=(162-xGap)/2;
height=32;
doUpdate=false;

col=setCoactColor;
behList=fieldnames(col.state);
for n=1:3
    beh=behList{n};
    legSlp{n}=sprintf('\\color[rgb]{%f %f %f}%s',col.state.(beh),upper(beh))
end

if ~doUpdate &&...
        exist('~/Dropbox/FearAnalyses/png/example-coac-pre.png','file') && ...
        exist('~/Dropbox/FearAnalyses/png/example-coac-pre-info.mat','file')&& ...
        exist('~/Dropbox/FearAnalyses/png/example-coac-post.png','file') && ...
        exist('~/Dropbox/FearAnalyses/png/example-coac-post-info.mat','file')
else
    %%
    basename='~/data/Fear/triple/hoegaarden181115/hoegaarden181115';
    
    load([basename '.basicMetaData.mat'])
    load([basicMetaData.Basename '.sleepstate.states.mat'])
    load([basicMetaData.Basename '.sessions.events.mat'])
    load([basicMetaData.AnalysesName '-icaReac.mat'])
    load([basicMetaData.AnalysesName '-icaCoactTimeCondHT.mat'])
    load([basicMetaData.AnalysesName '-icaReacZNCCG_sig.mat'])
    
    %%
    slp=relabel_ma2sleep(SleepState.MECE.timestamps);
    slp(:,3)=(slp(:,3)+1)/2;
    slp(:,1:2)=slp(:,1:2)/60;
    slpCol=[1,0.5,0.5;
        0.5,0.5,1;
        0.7,0.7,1];
    %%
    tempSes=icaCoactTimeCond.param.templateIdx;
    tBin=(1:size(icaReac(tempSes).strength,2))*20e-3/60;
    
    withSlpState=true;
    %%
    % 137   vCA1(6)-BLA(10)
    % 191   vCA1(8)-BLA(10)
    % 234   BLA(10)-PrL(33)
    
    % 141   vCA1(6)-BLA(14)
    % 152** vCA1(6)-BLA(25)
    % 155   vCA1(6)-PrL(28)
    % 160   vCA1(6)-PrL(33)
    % 195   vCA1(8)-BLA(14)
    % 206*  vCA1(8)-BLA(25)
    % 209   vCA1(8)-PrL(28)
    % 214** vCA1(8)-PrL(33)
    % 269   BLA(14)-PrL(28)
    % 274   BLA(14)-PrL(33)
    % 379** BLA(25)-PrL(28)
    % 384   BLA(25)-PrL(33)
    %
    exID=[6,8,14,25,28,33];
    regName=icaReac(tempSes).region(exID);
    regList=unique(regName);
    num=zeros(size(regList))
    for regID=1:length(regName)
        idx=find(strcmp(regName{regID},regList));
        num(idx)=num(idx)+1;
        enName{regID}=[regName{regID} '_{En' num2str(num(idx)) '}'];
    end
    
    % % tRange=[250;475]+[0,90];
    % % tRange=[253;438]+[0,15];
    dur=12;
    tRange=[287;471]+[0,dur];
    
    reac=zscore(icaReac(tempSes).strength(exID,:),[],2);
    
    yGapUit=ceil(diff(prctile(reac(:),[0.01,99.99]))/10)*10;
    
    % % yGapStep=[0,-1,-2.5,-3.5,-5,-6];
    % yGapStep=[0:-1:-length(exID)+1];
    % clf
    %
    % [ytick,order]=sort(yGapStep)
    % ytickLabel=enName(order);
    %
    % tTxt={'Reactivation in Pre-conditioning sleep','Reactivation in Post-conditioning sleep'};
    %
    % for prePost=1:2
    %     subplot(3,2,prePost)
    %     subSlp=slp(slp(:,2)>tRange(prePost,1)&slp(:,1)<tRange(prePost,2),:);
    %     if subSlp(1,1)<tRange(prePost,1);subSlp(1,1)=tRange(prePost,1);end
    %     if subSlp(end,2)>tRange(prePost,2);subSlp(end,2)=tRange(prePost,2);end
    %     subSlp(:,1:2)=subSlp(:,1:2)-tRange(prePost,1);
    %     if withSlpState
    %         for sIdx=1:size(subSlp,1)
    %             rectangle('Position',[subSlp(sIdx,1),yGapUit*(min(yGapStep)-2),diff(subSlp(sIdx,1:2)),yGapUit*(-min(yGapStep)+4)],'LineStyle','none','FaceColor',slpCol(subSlp(sIdx,3),:))
    %         end
    %     end
    %     toShow=(tBin>=tRange(prePost,1)&tBin<=tRange(prePost,2));
    %     hold on
    %     plot(tBin(toShow)-tRange(prePost,1), reac(:,toShow)+yGapUit*yGapStep','k-','linewidth',1)
    %     ylim(yGapUit*[min(yGapStep)-2,2])
    %     set(gca,'YTick',yGapUit*ytick,'YTickLabel',ytickLabel)
    %
    %     plot(dur*0.8+[0,1],yGapUit*(min(yGapStep)-1.3)+[0,0],'k-','LineWidth',2)
    %     text(dur*0.8+0.5,yGapUit*(min(yGapStep)-1.3),'1 min','horizontalAlign','center','verticalAlign','top')
    %     plot(dur*0.8+1.05+[0,0],yGapUit*(min(yGapStep)-1.3)+[0,30],'k-','LineWidth',2)
    %     text(dur*0.8+1.05,yGapUit*(min(yGapStep)-1.3)+15,' 30 z','horizontalAlign','left','verticalAlign','middle')
    %     set(gca,'XTick',[])
    %     title(tTxt{prePost})
    % end
    
    coact=[];
    cnt=0;
    for n=1:length(exID)-1
        for m=n+1:length(exID)
            if strcmp(regName{n},regName{m})
                continue
            end
            pId=find(any((icaCoactTimeCond.reacID==exID(n)),2)&any((icaCoactTimeCond.reacID==exID(m)),2));
            gap=icaCoactTimeCond.tGap(pId);
            if gap<0
                yVal=[reac(m,1-gap:end),zeros(1,-gap)];
            else
                yVal=[zeros(1,gap),reac(m,1:end-gap)];
            end
            cnt=cnt+1;
            coact(cnt,:)=reac(n,:).*yVal;
            pName{cnt}=[enName{n} ' - ' enName{m}];
        end
    end
    
    tTxt={'Pre-conditioning homecage session','Post-conditioning homecage session'};
    
    yGapUit=ceil(diff(prctile(coact(:),[0.01,99.99]))/10)*10;
    yGapStep=0:-1:-size(coact,1)+1
    
    [ytick,order]=sort(yGapStep);
    ytickLabel=pName(order);
    
    for prePost=1:2
        fhTemp=figure();
        set(fhTemp, 'paperUnit','centimeters','Units','centimeters')
        set(fhTemp,'position',[0,20,width/10,height/10])
        set(fhTemp, 'Units','centimeters')
        % set(fh,'PaperType','a4')
        set(fhTemp,'PaperSize',[width/10,height/10])
        % set(fh,'paperPosition',[param.margin,param.margin,width-param.margin,height-param.margin])
        set(fhTemp,'paperPosition',[0,0,width/10,height/10])
        
        set(fhTemp,'defaultAxesFontName','Helvetica')
        set(fhTemp,'defaultTextFontName','Helvetica')
        
        set(fhTemp,'defaultAxesXColor',[0,0,0]); % factory is [0.15,0.15,0.15]
        set(fhTemp,'defaultAxesYColor',[0,0,0]);
        set(fhTemp,'defaultAxesZColor',[0,0,0]);
        
        set(fhTemp,'defaultAxesFontSize',5);
        set(fhTemp,'defaultTextFontSize',5);
        set(fhTemp,'defaultAxesLineWidth', 0.5);
        subplot('Position',[0,0,1,1]);
        
        subSlp=slp(slp(:,2)>tRange(prePost,1)&slp(:,1)<tRange(prePost,2),:);
        if subSlp(1,1)<tRange(prePost,1);subSlp(1,1)=tRange(prePost,1);end
        if subSlp(end,2)>tRange(prePost,2);subSlp(end,2)=tRange(prePost,2);end
        subSlp(:,1:2)=subSlp(:,1:2)-tRange(prePost,1);
        if withSlpState
            for sIdx=1:size(subSlp,1)
                rectangle('Position',[subSlp(sIdx,1),yGapUit*(min(yGapStep)-2),diff(subSlp(sIdx,1:2)),yGapUit*(-min(yGapStep)+4)],'LineStyle','none','FaceColor',slpCol(subSlp(sIdx,3),:))
            end
        end
        toShow=(tBin>=tRange(prePost,1)&tBin<=tRange(prePost,2));
        hold on
        plot(tBin(toShow)-tRange(prePost,1), coact(:,toShow)+yGapUit*yGapStep','k-','linewidth',0.25)
        ylim(yGapUit*[min(yGapStep)-2,2])
        
        axis off
        %         ax=fixAxis;
        xRange=get(gca,'XLim');
        yRange=get(gca,'YLim');
        tText=tTxt{prePost};
        if prePost==1
            fName='pre'
        else
            fName='post'
        end
        
        print(fhTemp,['~/Dropbox/FearAnalyses/png/example-coac-' fName '.png'],'-dpng','-r600')
        save(['~/Dropbox/FearAnalyses/png/example-coac-' fName '-info.mat'],...
            'xRange','yRange','tText','dur','ytickLabel','ytick','yGapUit')
        close(fhTemp)
    end
end
im{1}=imread('~/Dropbox/FearAnalyses/png/example-coac-pre.png');
info{1}=load('~/Dropbox/FearAnalyses/png/example-coac-pre-info.mat');
im{2}=imread('~/Dropbox/FearAnalyses/png/example-coac-post.png');
info{2}=load('~/Dropbox/FearAnalyses/png/example-coac-post-info.mat');

ytick=info{1}.ytick;
yGapUit=info{1}.yGapUit;
scalePos=1.1;
for prePost=1:2
    subplotInMM(x+(prePost-1)*(width+xGap),y,width,height)
    
    image(info{prePost}.xRange,info{prePost}.yRange,flipud(im{prePost}))
    set(gca,'YDir','normal')
    hold on
    plot(info{prePost}.dur*0.8+[0,1],yGapUit*(min(ytick)-scalePos)+[0,0],'k-','LineWidth',1)
    text(info{prePost}.dur*0.8+0.5,yGapUit*(min(ytick)-scalePos),'1 min','horizontalAlign','center','verticalAlign','top')
    plot(info{prePost}.dur*0.8+1.05+[0,0],yGapUit*(min(ytick)-scalePos)+[0,50],'k-','LineWidth',1)
    text(info{prePost}.dur*0.8+1.05,yGapUit*(min(ytick)-scalePos)+25,' 50 z^2','horizontalAlign','left','verticalAlign','middle')
    
    if prePost==1
        for n=1:length(info{prePost}.ytickLabel)
            text(info{prePost}.xRange(1)-diff(info{prePost}.xRange)*0.01,yGapUit*ytick(n),info{prePost}.ytickLabel{n},'horizontalAlign','right','fontsize',5)
        end
    end
    axis off
    title(info{prePost}.tText)
    ax=fixAxis;
%     if prePost==2
        text2(0.98,-0.01,join(legSlp, ' '),ax,'verticalAlign','top','horizontalAlign','right','fontsize',5)
%     end
    
end

end
%%
%%
function panel_02(x,y)

width=15-1;
totalHeigh=38;

gapY=1;
gapX=3.5;
%     eachHight=0.4/10;%cm
smSigma=20; %in ms
cLim=0.01*[-1,1];
nShowBin=21;
ccg=poolVar('icaReacZNCCG.mat');
ccgSig=poolVar('icaReacCCG_sig.mat');

% ccgAll=poolVar('icaReacZNCCG.mat');
ccgAll=ccg;

col=setCoactColor;

ratList=fieldnames(ccg);

reg={};
% peakVal=[];
sig=[];
ccgVal=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    reg=[reg;ccg.(rat)(2).region(ccg.(rat)(2).pairID)];
%     peakVal=[peakVal;ccgSig.(rat)(2).nrem.peakValue(:,[2,3])];
    sig=[sig;ccgSig.(rat)(2).nrem.significance(:,[2,3])];
    ccgVal=cat(1,ccgVal,ccg.(rat)(2).nrem.real.ccg(:,:,2:3));
end

tBinSize=ccg.(ratList{1})(2).tBinSize*1e3;

nSm=ceil(smSigma/tBinSize);
xSm=(-nSm*4:nSm*4)*tBinSize;
smCore=normpdf(xSm,0,smSigma);
smCore=smCore/sum(smCore);

cBin=(size(ccgVal,2)+1)/2;

tBin=(-nShowBin:nShowBin)*tBinSize;

for n=1:2
    ccgVal(:,:,n)=Filter0(smCore,ccgVal(:,:,n));
end

ccgVal=ccgVal(:,cBin+(-nShowBin:nShowBin),:);



ccgValAll=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    ccgValAll=cat(1,ccgValAll,ccgAll.(rat)(2).nrem.real.ccg(:,:,2:3));
end

for n=1:2
    ccgValAll(:,:,n)=Filter0(smCore,ccgValAll(:,:,n));
end

ccgValAll=ccgValAll(:,cBin+(-nShowBin:nShowBin),:);
peakVal=mean(ccgValAll(:,nShowBin+1+(-3:3),2),2);


nPair=0;
for n=1:3
    switch n
        case 1
            target={'BLA','PrL L5'};
        case 2
            target={'vCA1','PrL L5'};
        case 3
            target={'vCA1','BLA'};
        otherwise
    end
    nPair=nPair+sum(strcmp(reg(:,1),target{1})&strcmp(reg(:,2),target{2}));
end

eachHight=(totalHeigh-gapY*2)/nPair;
%%
totalY=0;
for n=1:3
    switch n
        case 1
            target={'BLA','PrL L5'};
        case 2
            target={'vCA1','PrL L5'};
        case 3
            target={'vCA1','BLA'};
        otherwise
            continue
    end
    
    idx=find(strcmp(reg(:,1),target{1})&strcmp(reg(:,2),target{2}));
    subSig=sig(idx,:);
    subPeak=peakVal(idx);
    
    %         [~,order]=sortrows([subSig(:,2),subPeak(:,2)],'descend');
    %         [~,order]=sort(subPeak(:,2),'descend');
%     [~,order]=sort(mean(ccgVal(idx,nShowBin+1+(-3:3),2),2),'descend');
    [~,order]=sort(subPeak,'descend');
    idx=idx(order);
    subSig=subSig(order,:);
    
    height=length(idx)*eachHight;% cm
    for m=0:1
        subplotInMM(x+(width+gapX)*m,y+totalY,width,height,true)
        imagesc(tBin,1:length(idx),ccgVal(idx,:,1+m))
        box off
        set(gca,'ytick',[])
        if n~=3
            set(gca,'xtick',[])
        else
            set(gca,'xtick',-400:400:400)
        end
        xlim(400*[-1,1])
        set(gca,'clim',cLim)
        colormap(gca,col.coact.map)
        
        if n==1
            if m==0
                title({'Pre-conditioning'},'fontweight','normal','fontsize',5)
                textInMM(x+(width+gapX/2),y-4,'Entire NREM','fontsize',5,'horizontalAlign','center')
            else
                title({'Post-conditioning'},'fontweight','normal','fontsize',5)
            end
        end
        if n==3
            xlabel('\Deltatime (ms)','fontsize',5)
        end
        if m==0
            ylabel(join(target, ' - '),'fontsize',5)
        end
        if m==1 & n==2
            ps=get(gcf,'PaperSize')*10;
            xMM=x+(width+gapX)*m+width/2+[-1,0]-1.5;
            yMM=y+totalY+[2,1]+1;
            annotation('arrow',xMM/ps(1),1-yMM/ps(2),'color','w','HeadWidth',4,'HeadLength',4,...
            'LineWidth',1,'LineStyle','none')
        end
        if m==1 & n==1
            ps=get(gcf,'PaperSize')*10;
            xMM=x+(width+gapX)*m+width/2+[-2,0]-1.5;
            yMM=y+totalY+[4,2]+0.5;
            annotation('arrow',xMM/ps(1),1-yMM/ps(2),'color','w','HeadWidth',4,'HeadLength',4,...
            'LineWidth',1,'LineStyle','-')
        end        
    end
    subplotInMM(x+width+0.5,y+totalY,2.5,height)
    imagesc([subSig(:,1),-2*ones(size(subSig(:,1))),subSig(:,2)])
    set(gca,'clim',[-2,1])
    colormap(gca,[1,1,1;flipud(col.pVal)])
    box off
    axis off
    %         subplotInMM(x+width+0.5,y+totalY,1,height,true)
    %         imagesc(subSig(:,1));
    %         set(gca,'clim',[-1,1])
    %         colormap(gca,flipud(col.pVal))
    %         box off
    %         axis off
    %
    %         subplotInMM(x+width+2,y+totalY,1,height,true)
    %         imagesc(subSig(:,2));
    %         set(gca,'clim',[-1,1])
    %         colormap(gca,flipud(col.pVal))
    %         box off
    %         axis off
    
    totalY=totalY+height+gapY;
end

subplotInMM(x+width*2+gapX+0.5,y,1,totalY-gapY)
imagescXY([],cLim,linspace(cLim(1),cLim(2),512));
set(gca,'clim',cLim)
colormap(gca,col.coact.map)
box off
set(gca,'XTick',[])
set(gca,'YAxisLocation','right')
%     set(gca,'YTick',[cLim(1),0,cLim(2)],'YTickLabel',{['< ',num2str(cLim(1))],0,['> ',num2str(cLim(2))]})
set(gca,'YTick',[cLim(1),cLim(1)/2,0,cLim(2)/2,cLim(2)])
ax=fixAxis;
text2(7,0.5,'Correlation',ax,'horizontalALign','center','Rotation',-90)

end

%%
function panel_03(x,y)

width=15-1;
totalHeigh=38;

gapY=1;
gapX=3.5;
%     eachHight=0.4/10;%cm
smSigma=20; %in ms
cLim=0.01*[-1,1];
nShowBin=21;

ccg=poolVar('icaReacZNCCG_exSWR.mat');
ccgSig=poolVar('icaReacZNCCG_exSWR_sig.mat');
ccgAll=poolVar('icaReacZNCCG.mat');

col=setCoactColor;

ratList=fieldnames(ccg);

reg={};
% peakVal=[];
sig=[];
ccgVal=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    reg=[reg;ccg.(rat)(2).region(ccg.(rat)(2).pairID)];
%     peakVal=[peakVal;ccgSig.(rat)(2).exRipple.peakValue(:,[2,3])];
    sig=[sig;ccgSig.(rat)(2).exRipple.significance(:,[2,3])];
    ccgVal=cat(1,ccgVal,ccg.(rat)(2).exRipple.real.ccg(:,:,2:3));
end

tBinSize=ccg.(ratList{1})(2).tBinSize*1e3;

nSm=ceil(smSigma/tBinSize);
xSm=(-nSm*4:nSm*4)*tBinSize;
smCore=normpdf(xSm,0,smSigma);
smCore=smCore/sum(smCore);

cBin=(size(ccgVal,2)+1)/2;

tBin=(-nShowBin:nShowBin)*tBinSize;

for n=1:2
    ccgVal(:,:,n)=Filter0(smCore,ccgVal(:,:,n));
end

ccgValAll=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    ccgValAll=cat(1,ccgValAll,ccgAll.(rat)(2).nrem.real.ccg(:,:,2:3));
end

for n=1:2
    ccgValAll(:,:,n)=Filter0(smCore,ccgValAll(:,:,n));
end

ccgValAll=ccgValAll(:,cBin+(-nShowBin:nShowBin),:);
peakVal=mean(ccgValAll(:,nShowBin+1+(-3:3),2),2);

ccgVal=ccgVal(:,cBin+(-nShowBin:nShowBin),:);
nPair=0;
for n=1:3
    switch n
        case 1
            target={'BLA','PrL L5'};
        case 2
            target={'vCA1','PrL L5'};
        case 3
            target={'vCA1','BLA'};
        otherwise
    end
    nPair=nPair+sum(strcmp(reg(:,1),target{1})&strcmp(reg(:,2),target{2}));
end

eachHight=(totalHeigh-gapY*2)/nPair;
%%
totalY=0;
for n=1:3
    switch n
        case 1
            target={'BLA','PrL L5'};
        case 2
            target={'vCA1','PrL L5'};
        case 3
            target={'vCA1','BLA'};
        otherwise
            continue
    end
    
    idx=find(strcmp(reg(:,1),target{1})&strcmp(reg(:,2),target{2}));
    subSig=sig(idx,:);
    subPeak=peakVal(idx);
    
    %         [~,order]=sortrows([subSig(:,2),subPeak(:,2)],'descend');
    %         [~,order]=sort(subPeak(:,2),'descend');
%     [~,order]=sort(mean(ccgVal(idx,nShowBin+1+(-3:3),2),2),'descend');
    [~,order]=sort(subPeak,'descend');
    idx=idx(order);
    subSig=subSig(order,:);
    
    height=length(idx)*eachHight;% cm
    for m=0:1
        subplotInMM(x+(width+gapX)*m,y+totalY,width,height,true)
        imagesc(tBin,1:length(idx),ccgVal(idx,:,1+m))
        box off
        set(gca,'ytick',[])
        if n~=3
            set(gca,'xtick',[])
        else
            set(gca,'xtick',-400:400:400)
        end
        xlim(400*[-1,1])
        set(gca,'clim',cLim)
        colormap(gca,col.coact.map)
        
        if n==1
            if m==0
                title({'Pre-conditioning'},'fontweight','normal','fontsize',5)
                textInMM(x+(width+gapX/2),y-4,'NREM excluding SWR','fontsize',5,'horizontalAlign','center')
            else
                title({'Post-conditioning'},'fontweight','normal','fontsize',5)
            end
        end
        if n==3
            xlabel('\Deltatime (ms)','fontsize',5)
        end
        if m==0
            ylabel(join(target, ' - '),'fontsize',5)
        end
        if m==1 & n==2
            ps=get(gcf,'PaperSize')*10;
            xMM=x+(width+gapX)*m+width/2+[-1,0]-1.5;
            yMM=y+totalY+[2,1]+1;
            annotation('arrow',xMM/ps(1),1-yMM/ps(2),'color','w','HeadWidth',4,'HeadLength',4,...
            'LineWidth',1,'LineStyle','none')
        end
        
    end
    subplotInMM(x+width+0.5,y+totalY,2.5,height)
    imagesc([subSig(:,1),-2*ones(size(subSig(:,1))),subSig(:,2)])
    set(gca,'clim',[-2,1])
    colormap(gca,[1,1,1;flipud(col.pVal)])
    box off
    axis off
%     subplotInMM(x+width+0.5,y+totalY,1,height,true)
%     imagesc(subSig(:,1));
%     set(gca,'clim',[-1,1])
%     colormap(gca,flipud(col.pVal))
%     box off
%     axis off
%     
%     subplotInMM(x+width+2,y+totalY,1,height,true)
%     imagesc(subSig(:,2));
%     set(gca,'clim',[-1,1])
%     colormap(gca,flipud(col.pVal))
%     box off
%     axis off
    
    totalY=totalY+height+gapY;
end

subplotInMM(x+width*2+gapX+0.5,y,1,totalY-gapY)
imagescXY([],cLim,linspace(cLim(1),cLim(2),512));
set(gca,'clim',cLim)
colormap(gca,col.coact.map)
box off
set(gca,'XTick',[])
set(gca,'YAxisLocation','right')
%     set(gca,'YTick',[cLim(1),0,cLim(2)],'YTickLabel',{['< ',num2str(cLim(1))],0,['> ',num2str(cLim(2))]})
set(gca,'YTick',[cLim(1),cLim(1)/2,0,cLim(2)/2,cLim(2)])
ax=fixAxis;
text2(7,0.5,'Correlation',ax,'horizontalALign','center','Rotation',-90)

end
%%
function panel_04(x,y)

width=15-1;
totalHeigh=38;

gapY=1;
gapX=3.5;
%     eachHight=0.4/10;%cm
smSigma=20; %in ms
cLim=0.01*[-1,1];
nShowBin=21;

ccg=poolVar('icaReacZNCCG_exHFObaseCond.mat');
ccgSig=poolVar('icaReacZNCCG_exHFObaseCond_sig.mat');
ccgAll=poolVar('icaReacZNCCG.mat');

col=setCoactColor;

ratList=fieldnames(ccg);

reg={};
% peakVal=[];
sig=[];
ccgVal=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    reg=[reg;ccg.(rat)(2).region(ccg.(rat)(2).pairID)];
%     peakVal=[peakVal;ccgSig.(rat)(2).exHFO.peakValue(:,[2,3])];
    sig=[sig;ccgSig.(rat)(2).exHFO.significance(:,[2,3])];
    ccgVal=cat(1,ccgVal,ccg.(rat)(2).exHFO.real.ccg(:,:,2:3));
end

tBinSize=ccg.(ratList{1})(2).tBinSize*1e3;

nSm=ceil(smSigma/tBinSize);
xSm=(-nSm*4:nSm*4)*tBinSize;
smCore=normpdf(xSm,0,smSigma);
smCore=smCore/sum(smCore);

cBin=(size(ccgVal,2)+1)/2;

tBin=(-nShowBin:nShowBin)*tBinSize;

for n=1:2
    ccgVal(:,:,n)=Filter0(smCore,ccgVal(:,:,n));
end
ccgVal=ccgVal(:,cBin+(-nShowBin:nShowBin),:);


ccgValAll=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    ccgValAll=cat(1,ccgValAll,ccgAll.(rat)(2).nrem.real.ccg(:,:,2:3));
end

for n=1:2
    ccgValAll(:,:,n)=Filter0(smCore,ccgValAll(:,:,n));
end

ccgValAll=ccgValAll(:,cBin+(-nShowBin:nShowBin),:);
peakVal=mean(ccgValAll(:,nShowBin+1+(-3:3),2),2);

nPair=0;
for n=1:3
    switch n
        case 1
            target={'BLA','PrL L5'};
        case 2
            target={'vCA1','PrL L5'};
        case 3
            target={'vCA1','BLA'};
        otherwise
    end
    nPair=nPair+sum(strcmp(reg(:,1),target{1})&strcmp(reg(:,2),target{2}));
end

eachHight=(totalHeigh-gapY*2)/nPair;
%%
totalY=0;
for n=1:3
    switch n
        case 1
            target={'BLA','PrL L5'};
        case 2
            target={'vCA1','PrL L5'};
        case 3
            target={'vCA1','BLA'};
        otherwise
            continue
    end
    
    idx=find(strcmp(reg(:,1),target{1})&strcmp(reg(:,2),target{2}));
    subSig=sig(idx,:);
    subPeak=peakVal(idx);
    
    %         [~,order]=sortrows([subSig(:,2),subPeak(:,2)],'descend');
    %         [~,order]=sort(subPeak(:,2),'descend');
%     [~,order]=sort(mean(ccgVal(idx,nShowBin+1+(-3:3),2),2),'descend');
    [~,order]=sort(subPeak,'descend');
    idx=idx(order);
    subSig=subSig(order,:);
    
    height=length(idx)*eachHight;% cm
    for m=0:1
        subplotInMM(x+(width+gapX)*m,y+totalY,width,height,true)
        imagesc(tBin,1:length(idx),ccgVal(idx,:,1+m))
        box off
        set(gca,'ytick',[])
        if n~=3
            set(gca,'xtick',[])
        else
            set(gca,'xtick',-400:400:400)
        end
        xlim(400*[-1,1])
        set(gca,'clim',cLim)
        colormap(gca,col.coact.map)
        
        if n==1
            if m==0
                title({'Pre-conditioning'},'fontweight','normal','fontsize',5)
                textInMM(x+(width+gapX/2),y-4,'NREM excluding HFO','fontsize',5,'horizontalAlign','center')
            else
                title({'Post-conditioning'},'fontweight','normal','fontsize',5)
            end
        end
        if n==3
            xlabel('\Deltatime (ms)','fontsize',5)
        end
        if m==0
            ylabel(join(target, ' - '),'fontsize',5)
        end
        if m==1 & n==1
            ps=get(gcf,'PaperSize')*10;
            xMM=x+(width+gapX)*m+width/2+[-2,0]-1.5;
            yMM=y+totalY+[4,2]+0.5;
            annotation('arrow',xMM/ps(1),1-yMM/ps(2),'color','w','HeadWidth',4,'HeadLength',4,...
            'LineWidth',1,'LineStyle','-')
        end
    end
%     subplotInMM(x+width+0.5,y+totalY,1,height,true)
%     imagesc(subSig(:,1));
%     set(gca,'clim',[-1,1])
%     colormap(gca,flipud(col.pVal))
%     box off
%     axis off
%     
%     subplotInMM(x+width+2,y+totalY,1,height,true)
%     imagesc(subSig(:,2));
%     set(gca,'clim',[-1,1])
%     colormap(gca,flipud(col.pVal))
%     box off
%     axis off
%     
    subplotInMM(x+width+0.5,y+totalY,2.5,height)
    imagesc([subSig(:,1),-2*ones(size(subSig(:,1))),subSig(:,2)])
    set(gca,'clim',[-2,1])
    colormap(gca,[1,1,1;flipud(col.pVal)])
    box off
    axis off
    totalY=totalY+height+gapY;
end

subplotInMM(x+width*2+gapX+0.5,y,1,totalY-gapY)
imagescXY([],cLim,linspace(cLim(1),cLim(2),512));
set(gca,'clim',cLim)
colormap(gca,col.coact.map)
box off
set(gca,'XTick',[])
set(gca,'YAxisLocation','right')
%     set(gca,'YTick',[cLim(1),0,cLim(2)],'YTickLabel',{['< ',num2str(cLim(1))],0,['> ',num2str(cLim(2))]})
set(gca,'YTick',[cLim(1),cLim(1)/2,0,cLim(2)/2,cLim(2)])
ax=fixAxis;
text2(7,0.5,'Correlation',ax,'horizontalALign','center','Rotation',-90)

end
%%
function panel_05(x,y)
width=17;
hGap=11;
height=9;

hfoDrop=poolVar('icaReacCCG_dropHFO_baseCond_sh.mat');
sig=poolVar('icaReacZNCCG_sig.mat');
hfoSig=poolVar('icaReacZNCCG_exHFObaseCond_sig.mat');

swrDrop=poolVar('icaReacCCG_dropSWR_sh.mat');
swrSig=poolVar('icaReacCCG_exSWR_sig.mat');


ratList=fieldnames(swrDrop);
%%
tempIdx=2; %conditioning
targetIdx=3; %homecage3: after conditioning
dropTypeList={'exRipple','exHFO','exSpindle'};


isSigAll=[];
regAll={};
for dIdx=1:length(dropTypeList)
    dropType=dropTypeList{dIdx};
    pAll.(dropType)=[];
    isExSigAll.(dropType)=[];
end

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    for dIdx=1:length(dropTypeList)
        dropType=dropTypeList{dIdx};
        if strcmp(dropType,'exHFO')
            shPeak=hfoDrop.(rat)(tempIdx).(dropType).shuffle.peak(:,:,targetIdx);
            realPeak=max(hfoDrop.(rat)(tempIdx).(dropType).real.ccg(:,:,targetIdx),[],2);
            isExSigAll.(dropType)=[isExSigAll.(dropType);hfoSig.(rat)(tempIdx).(dropType).significance(:,targetIdx)>0];
        else
            shPeak=swrDrop.(rat)(tempIdx).(dropType).shuffle.peak(:,:,targetIdx);
            realPeak=max(swrDrop.(rat)(tempIdx).(dropType).real.ccg(:,:,targetIdx),[],2);
            isExSigAll.(dropType)=[isExSigAll.(dropType);swrSig.(rat)(tempIdx).(dropType).significance(:,targetIdx)>0];
        end
        
        temp=zeros(size(realPeak));
        for n=1:size(shPeak,1)
            temp(n)=sum(shPeak(n,:)<realPeak(n))/500;
        end
        pAll.(dropType)=[pAll.(dropType);temp];
    end
    isSigAll=[isSigAll;sig.(rat)(tempIdx).nrem.significance(:,targetIdx)>0];
    regAll=[regAll;hfoDrop.(rat)(tempIdx).region(hfoDrop.(rat)(tempIdx).pairID)];
end

[pairListAll,~,pairIDall]=uniqueCellRows(regAll);
interRegAll=ismember(pairIDall,find(~strcmp(pairListAll(:,1),pairListAll(:,2))));

isSig=isSigAll(interRegAll);
reg=regAll(interRegAll,:);
for dIdx=1:length(dropTypeList)
    dropType=dropTypeList{dIdx};
    p.(dropType)=pAll.(dropType)(interRegAll);
    isExSig.(dropType)=isExSigAll.(dropType)(interRegAll);
    
end

[pairList,~,pairID]=uniqueCellRows(reg);
%%
dropName={'SWR','HFO','Spindle'};
targetPairList={'vCA1' 'BLA' };

temp=setCoactColor;
col=temp.pair.vCA1BLA;

legTxt={};
for n=1:size(targetPairList,1)
    legTxt{n}=sprintf('\\color[rgb]{%f %f %f}%s - %s',col(n,:), targetPairList{n,:})
end

for pairIdx=1:size(targetPairList,1)
    targePairtIdx=find(strcmp(pairList(:,1),targetPairList{pairIdx,1})& strcmp(pairList(:,2),targetPairList{pairIdx,2}));
    tarSig=isSig(pairID==targePairtIdx,:)
    for dIdx=1:length(dropTypeList)
        dropType=dropTypeList{dIdx};
        xx=isExSig.(dropType)(pairID==targePairtIdx)==1;
        yy=tarSig==1;
        ct=[sum(xx&yy)  sum(xx&~yy)
            sum(~xx&yy) sum(~xx&~yy)];
        
        frac=(ct(1,:)./sum(ct,1)*100)
        exEvent(pairIdx,dIdx)=100-frac(1);
        
        tarP=p.(dropType)(pairID==targePairtIdx);
        %         ct=crosstab( ~(tarP<(0.01/2)),~(tarSig==1));
        xx=tarP<(0.01/2);
        yy=tarSig==1;
        ct=[sum(xx&yy)  sum(xx&~yy)
            sum(~xx&yy) sum(~xx&~yy)];
        %         [~,ftP(dIdx)]=fishertest(ct)
        
        num=sum(ct,1);
        frac=(ct(1,:)./sum(ct,1)*100);
        jitEvent(pairIdx,dIdx)=frac(1);
        
    end
end

for n=1:2
    %     subplotInMM(x+(width+wGap)*(n-1),y,width,height)
    subplotInMM(x,y+(height+hGap)*(n-1),width,height)
    hold on
    if n==1
        val=jitEvent;
        yTxt={'Pair with' 'sig. drop (%)'};
        xTxt='Excluded Events';
    else
        val=exEvent;
        yTxt={'Pair lost' 'sig. peak (%)'};
        xTxt='Excluded Events';
    end
    for m=1
        %         bar((1:3)+0.15*(2*m-3),val(m,:),0.2,'FaceColor',col(m,:),'linestyle','none')
        bar((1:3)+0*(2*m-3),val(m,:),0.2,'FaceColor',col(m,:),'linestyle','none')
    end
    set(gca,'xtick',1:3,'XTickLabel',dropName)
    xlim([0.5,3.5])
    ylim([0,100])
    ylabel(yTxt,'fontsize',5,'fontweight','normal')
    xlabel(xTxt,'fontsize',5,'fontweight','normal')
    ax=fixAxis;
    %     if n==2
    text2(0.5,1.15,legTxt{1},ax,'fontsize',5)
    %         text2(0.5,1,legTxt{2},ax,'fontsize',5)
    %     end
end



end
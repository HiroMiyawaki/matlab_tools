function coactPaper_figS7_v4()
labelWeight=true;
labelCase=false;
labelSize=8;
letGapX=5;
letGapY=5;

close all
fh=initFig4Nature('height',24.7);

x=11;y=6;
panel_01_to_05_withRanksum(x,y);
% panelLetter2(x-letGapX-2,y-letGapY+2,alphabet(1,labelCase),'fontSize',labelSize,'isBold',labelWeight)
drawnow();

x=11;y=6+170;
panel_06(x,y);
panelLetter2(x-letGapX,y-letGapY,alphabet(6,labelCase),'fontSize',labelSize,'isBold',labelWeight)
drawnow();

x=71;y=6+170;
panel_07(x,y);
panelLetter2(x-letGapX,y-letGapY,alphabet(7,labelCase),'fontSize',labelSize,'isBold',labelWeight)
drawnow();

x=100;y=6+170;
panel_08(x,y);
panelLetter2(x-letGapX,y-letGapY,alphabet(8,labelCase),'fontSize',labelSize,'isBold',labelWeight)
drawnow();


% addFigureLabel('Extended Data Figure 7')

if ~exist('~/Dropbox/FearAnalyses/paper/figure','dir')
    mkdir('~/Dropbox/FearAnalyses/paper/figure')
end
% print(fh,'~/Dropbox/FearAnalyses/paper/figure/exfig07.pdf','-dpdf','-painters','-r300')

end
%%
%%
function panel_01_to_05_withRanksum(x,y)
% coact=poolVar('coactCompCell_LT.mat');
coact=poolVar('coactCompCell.mat');
meanFR=poolVar('meanFR.mat');
info=poolVar('okUnit.cellinfo.mat');
frz=poolVar('frzFRmod.mat');


ratList=fieldnames(coact);

tempSes=2;
sigHC=3;
%% get partners
partner={};

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    
    region=relabel_region(coact.(rat).region,'minCellNum',0);
    
    temp=cell(size(info.(rat).channel));
    
    [cIdx,rIdx]=find(coact.(rat).ica(tempSes).homecage(sigHC).nrem);
    cList=unique(cIdx)';
    for cc=cList
        temp{cc}={region{ rIdx(cIdx==cc)}};
    end
    
    partner=[partner,temp];
end

for cIdx=1:length(partner)
    if isempty(partner{cIdx})
        continue
    end
    partner{cIdx}(~ismember(partner{cIdx},{'BLA','vCA1','PrL L5'}))=[];
    partner{cIdx}=unique(partner{cIdx});
end



%% get cellinfo
cellType=[];
reg=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    cellType=[cellType;info.(rat).cellType.type'];
    reg=[reg,info.(rat).region];
end

[reg,regList]=relabel_region(reg,'minCellNum',0);
reg=reg';
% %%
% frMean=[];
% frStd=[];
%
% for ratIdx=1:length(ratList)
%     rat=ratList{ratIdx};
%
%     frMean=[frMean;fr.(rat).overall.mean'];
%     frStd=[frStd;fr.(rat).overall.std'];
% end
%%
frzMod=[]
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    frzMod=[frzMod;squeeze(frz.(rat).modIdx(:,[1,2,3,4,8]))];
        
end
%% getFR in HC
nremFR=[];

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    %homecage 2 & 3;
    slp='nrem';
    %homecage 2 & 3, sepalate in half
    nremFR=[nremFR;meanFR.(rat).Hz.(slp)([4:5,7:8],:)'];
    
end
%%
hcIdx=[1,3,5,10,12];
behList={'wake','nrem','rem'};
for behIdx=1:3
    beh=behList{behIdx};
    behFR.(beh)=[];
    for ratIdx=1:length(ratList)
        rat=ratList{ratIdx};
        
        temp=meanFR.(rat).noDiv.Hz.(beh)(hcIdx,:);
        temp(isnan(temp))=0;
        dur=meanFR.(rat).noDiv.duration.(beh)(hcIdx);
        
        behFR.(beh)=[behFR.(beh),sum(temp.*dur',1)/sum(dur)];
    end
end
%%
clf
colTemp=setCoactColor()

piCol=[colTemp.cellType.inh;
       colTemp.cellType.nc;
       colTemp.cellType.ex];

targetReg={'PrL L5','BLA','vCA1'};
behList={'wake','nrem','rem'};
cellTypeList={'excitatory cells','inhibitory cells'};

% pieWidth=10;
% pieHeigth=15;
% pieGap=5;

tableGapX=2;
tableWidth=76-tableGapX;

nCellWidth=18;
nCellHeight=15;
nCellGapX=15;
nCellGapXintra=(tableWidth-nCellWidth*3)/2;

behWidth=28;
behHeight=nCellHeight;
behGapXinter=14;
behGapXintra=5;

yGapIntraTop=10;
yGapIntraBottom=14.5;
yGapInter=13.5;

tableHight=nCellHeight*2+yGapIntraTop;

wTotal=tableWidth+tableGapX+behWidth*2+behGapXinter+behGapXintra;

nremFRwidth=26;
nremFRheigth=15;
nremFRGapX=5;

frzModwidth=31;
frzModheigth=nremFRheigth;
frzModGapXIntra=5;
frzModGapXinter=wTotal-frzModwidth*2-frzModGapXIntra-nremFRwidth*2-nremFRGapX;

labelWeight=true;
labelCase=false;
labelSize=8;
letGapX=5;
letGapY=6;

pCnt=0;
sesName={'Baseline','Conditioning','Context','Cue ses. before first tone','Cue ses. after first tone'};

eiLeg{1}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.ex, 'Excitatory');
eiLeg{2}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.inh, 'Inhibitory');
eiLeg{3}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.nc, 'Not classified');


for n=1:2
    yTickPos.beh.PrLL5{n}=[];
    yTickPos.beh.vCA1{n}=[];
    yTickPos.beh.BLA{n}=[];

    yTickPos.nrem.PrLL5{n}=[];
    yTickPos.nrem.vCA1{n}=[];
    yTickPos.nrem.BLA{n}=[];
end

yTickPos.beh.BLA{1}=[0.5,1,2,5];
yTickPos.beh.vCA1{1}=[0.5,1,2,5];

yTickPos.nrem.vCA1{2}=[2,5,10,20];
%%
yShift=0;
xShift=0;
yTop=y;
clf
subplotInMM(x+xShift,y+yShift,tableWidth,tableHight,tableWidth)
set(gca,'YDir','reverse')
xlim([0,tableWidth])
ylim([0,tableHight])
hold on
xMargin=2;
yMargin=0;
cellWidth=(tableWidth-xMargin*2)/4.7
cellHight=(tableHight-yMargin*2)/4.5;
lineGap=0
rowIdx=0;
plot([0,tableWidth],(rowIdx+lineGap)*cellHight+yMargin+[0,0],'k-','LineWidth',0.5)
rowIdx=rowIdx+1;
for colIdx=1:4
    if colIdx<=length(targetReg)
    text((colIdx)*cellWidth+xMargin,(rowIdx-0.5)*cellHight+yMargin,{'Coupled ' ['with ' targetReg{colIdx}]},'fontsize',5,...
        'horizontalAlign','left','verticalALign','middle')
    else
    text((colIdx)*cellWidth+xMargin,(rowIdx-0.5)*cellHight+yMargin,'Other cells','fontsize',5,...
        'horizontalAlign','left','verticalALign','middle')
    end
end
plot([0,tableWidth],(rowIdx+lineGap)*cellHight+yMargin+[0,0],'k-','LineWidth',0.5)
for idx=1:length(targetReg)
    rowIdx=rowIdx+1;        
    target=find(strcmp(reg,targetReg{idx}));

    
    for colIdx=0:4;
        interpreter='tex';
        if colIdx==0
            txt={'Cells' ['in ' targetReg{idx}]};
        elseif colIdx==idx
            txt='N.A.';
        else
            if colIdx==4
                id=target(cellfun(@isempty,partner(target)));            
            else
                id=target(cellfun(@(x) any(strcmp(x,targetReg{colIdx})), partner(target)));
            end
            cnt=histcounts(cellType(id),-1.5:1.5);
            txt=sprintf('%d / %d / %d',cnt(3),cnt(1),cnt(2));
        end
        text((colIdx)*cellWidth+xMargin,(rowIdx-0.5)*cellHight+yMargin,txt,'fontsize',5,...
            'horizontalAlign','left','verticalALign','middle','Interpreter',interpreter)
    end
    
end
plot([0,tableWidth],(rowIdx+lineGap)*cellHight+yMargin+[0,0],'k-','LineWidth',0.5)
axis off
%%
pCnt=pCnt+1;
panelLetter2(x+xShift-letGapX,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)

for targetIdx=1:length(targetReg)
    yTop=y;%+(targetIdx-1)*(nCellHeight+yGapInter+nremFRheigth+yGapInterReg);
    yShift=0;
    xShift=0;
    target=find(strcmp(reg,targetReg{targetIdx}));
    partnerList=targetReg;
    partnerList(strcmp(partnerList,targetReg{targetIdx}))=[]
    
    eiRatio=zeros(length(partnerList)+1,3);
    eiFR.mean=zeros(length(partnerList)+1,length(behList),2);
    eiFR.ste=zeros(length(partnerList)+1,length(behList),2);
    eiFR.raw=cell(length(partnerList)+1,length(behList),2);
    eiNrem.mean=zeros(length(partnerList)+1,4,2);
    eiNrem.ste=zeros(length(partnerList)+1,4,2);
    eiNrem.raw=cell(length(partnerList)+1,4,2);
    eiFrzMod.mean=zeros(length(partnerList)+1,size(frzMod,2),2);
    eiFrzMod.ste=zeros(length(partnerList)+1,size(frzMod,2),2);
    eiFrzMod.raw=cell(length(partnerList)+1,size(frzMod,2),2);
    
    partnerName={};
    partnerNameCore={};
    pairCol=[];
    for n=1:length(partnerList)+1
        if n>length(partnerList)
            id=target(cellfun(@isempty,partner(target)));
            partnerName{n}='Othres';
            partnerNameCore{n}='Othres';
            pairCol(n,:)=colTemp.region.others;
        else
            id=target(cellfun(@(x) any(strcmp(x,partnerList{n})), partner(target)));
            partnerName{n}=['Coupled with ' partnerList{n}];
            partnerNameCore{n}=partnerList{n};
            pairCol(n,:)=colTemp.pair.(strrep(strrep([targetReg{targetIdx} partnerList{n}],' ',''),'/',''));
        end
        pairLeg{n+1}=sprintf('\\color[rgb]{%f %f %f}%s',pairCol(n,:),partnerName{n});
        eiId{1}=id(cellType(id)==1);
        eiId{2}=id(cellType(id)==-1);
        
        cnt=histcounts(cellType(id),-1.5:1.5);
        eiRatio(n,:)=cnt/sum(cnt)*100;

        fprintf('in %s, %s cells : n=%d\n',targetReg{targetIdx},partnerNameCore{n},sum(cnt))
        
        for eiIdx=1:2           
            for behIdx=1:3
                beh=behList{behIdx};
                eiFR.mean(n,behIdx,eiIdx)=nanmean(log10(behFR.(beh)(eiId{eiIdx})));
                eiFR.ste(n,behIdx,eiIdx)=nanste(log10(behFR.(beh)(eiId{eiIdx})));
                eiFR.raw{n,behIdx,eiIdx}=(behFR.(beh)(eiId{eiIdx}));
            end
            
            val=log10(nremFR(eiId{eiIdx},:));
%             val(any(isnan(val),2),:)=[];
%             val(any(isinf(val),2),:)=[];
            val(isinf(val))=nan;
            eiNrem.mean(n,:,eiIdx)=nanmean(val,1);
            eiNrem.ste(n,:,eiIdx)=nanste(val,[],1);
            for nremIdx=1:4
                eiNrem.raw{n,nremIdx,eiIdx}=nremFR(eiId{eiIdx},nremIdx)';
            end
            
            eiFrzMod.mean(n,:,eiIdx)=nanmean(frzMod(eiId{eiIdx},:));
            eiFrzMod.ste(n,:,eiIdx)=nanste(frzMod(eiId{eiIdx},:));
            for sesIdx=1:size(frzMod,2)
                eiFrzMod.raw{n,sesIdx,eiIdx}=frzMod(eiId{eiIdx},sesIdx)';
            end
        end
    end
    
    eiFR.p.all=ones(3,2);
    eiFR.p.each=ones(3,2,3,3);
    for behIdx=1:3
        for eiIdx=1:2
            temp=cellfun(@(x) ones(size(x)),eiFR.raw(:,behIdx,eiIdx),'UniformOutput',false);
            grp=[];
            for regIdx=1:size(temp,1)
                grp=[grp,regIdx*temp{regIdx}]
            end
            val=cat(2,eiFR.raw{:,behIdx,eiIdx});
            [p,~,s]=kruskalwallis(val,grp,'off');
%             c=multcompare(s,'display','off');
            eiFR.p.all(behIdx,eiIdx)=p;
%             eiFR.p.each(behIdx,eiIdx,:,:)=c;            
            idx=0;
            nGrp=3;
            for n=1:nGrp-1
                for m=n+1:nGrp
                    idx=idx+1;
                    p=ranksum(eiFR.raw{n,behIdx,eiIdx},eiFR.raw{m,behIdx,eiIdx});
                    p=p*nGrp*(nGrp-1)/2;
                    eiFR.p.each(behIdx,eiIdx,idx,:)=[n,m,p];
                end
            end

        end
    end
    
    eiNrem.p.all=ones(4,2);
    eiNrem.p.each=ones(4,2,3,3);
    for nremIdx=1:4
        for eiIdx=1:2
            temp=cellfun(@(x) ones(size(x)),eiNrem.raw(:,nremIdx,eiIdx),'UniformOutput',false);
            grp=[];
            for regIdx=1:size(temp,1)
                grp=[grp,regIdx*temp{regIdx}]
            end
            val=cat(2,eiNrem.raw{:,nremIdx,eiIdx});
            [p,~,s]=kruskalwallis(val,grp,'off');
%             c=multcompare(s,'display','off');
            eiNrem.p.all(nremIdx,eiIdx)=p;
%             eiNrem.p.each(nremIdx,eiIdx,:,:)=c;
            idx=0;
            nGrp=3;
            for n=1:nGrp-1
                for m=n+1:nGrp
                    idx=idx+1;
                    p=ranksum(eiNrem.raw{n,nremIdx,eiIdx},eiNrem.raw{m,nremIdx,eiIdx});
                    p=p*nGrp*(nGrp-1)/2;
                    eiNrem.p.each(nremIdx,eiIdx,idx,:)=[n,m,p];
                end
            end
        end
    end    

    eiFrzMod.p.all=ones(size(frzMod,2),2);
    eiFrzMod.p.each=ones(size(frzMod,2),2,3,3);
    for sesIdx=1:size(frzMod,2)
        for eiIdx=1:2
            temp=cellfun(@(x) ones(size(x)),eiFrzMod.raw(:,sesIdx,eiIdx),'UniformOutput',false);
            grp=[];
            for regIdx=1:size(temp,1)
                grp=[grp,regIdx*temp{regIdx}]
            end
            val=cat(2,eiFrzMod.raw{:,sesIdx,eiIdx});
            [p,~,s]=kruskalwallis(val,grp,'off');
%             c=multcompare(s,'display','off');
            eiFrzMod.p.all(sesIdx,eiIdx)=p;
%             eiFrzMod.p.each(sesIdx,eiIdx,:,:)=c;            
            idx=0;
            nGrp=3;
            for n=1:nGrp-1
                for m=n+1:nGrp
                    idx=idx+1;
                    p=ranksum(eiFrzMod.raw{n,sesIdx,eiIdx},eiFrzMod.raw{m,sesIdx,eiIdx});
                    p=p*nGrp*(nGrp-1)/2;
                    eiFrzMod.p.each(sesIdx,eiIdx,idx,:)=[n,m,p];
                end
            end
        end
    end    
    
    regRatio=zeros(2,3);
    for eiIdx=1:2
        id=target(cellType(target)==3-eiIdx*2);
        cnt=histcounts(cellfun(@length,partner(id)),-0.5:2.5);
        regRatio(eiIdx,:)=cnt/sum(cnt)*100;
    end

    % # partner regions
    xShift=(targetIdx-1)*(nCellWidth+nCellGapXintra);
    yShift=tableHight+yGapIntraTop;
    subplotInMM(x+xShift,yTop+yShift,nCellWidth,nCellHeight)

    bar(0:2,regRatio','linestyle','none')
    colormap(gca,piCol([3,1],:))
    box off
    xlabel('# partner region')
    if targetIdx==1
        ylabel({'Fraction of' 'cells (%)'})
    end
    xlim([-0.5,2.5])
    title(targetReg{targetIdx},'fontsize',5,'fontweight','normal')
    ax=fixAxis;
    text2(0.7,1,eiLeg(1:2),ax,'verticalAlign','top')
    
    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
    % FR for each state
    yShift=(targetIdx-1)*(nCellHeight+yGapIntraTop);
    xShift=tableWidth+tableGapX+behGapXinter;
    for eiIdx=1:2
        subplotInMM(x+xShift+(behWidth+behGapXintra)*(eiIdx-1),yTop+yShift,behWidth,behHeight)

        hold on
        posPool=[];
        poolAvg=[];
        for n=1:length(partnerName)
%             bar((1:3)+(n-2)*0.3,squeeze(eiFR.mean(n,:,eiIdx))',0.1,'LineStyle','none','FaceColor',pairCol(n,:))
            avg=10.^eiFR.mean(n,:,eiIdx);
            pos=10.^(eiFR.mean(n,:,eiIdx)+eiFR.ste(n,:,eiIdx))-avg;
            neg=avg-10.^(eiFR.mean(n,:,eiIdx)-eiFR.ste(n,:,eiIdx));
            errorbar((1:3)+(n-2)*0.1,avg,neg,pos,...
                'linestyle','none','color',pairCol(n,:),'CapSize',0,'Marker','.','MarkerSize',4,'linewidth',0.5)
            posPool(n,:)=avg+pos;
            poolAvg(n,:)=avg;
        end
        for behIdx=1:3
            if eiFR.p.all(behIdx,eiIdx)<0.001
                sigTxt='###';
            elseif eiFR.p.all(behIdx,eiIdx)<0.01
                sigTxt='##';
            elseif eiFR.p.all(behIdx,eiIdx)<0.05
                sigTxt='#';
            else
                sigTxt='';
            end
            
            if ~isempty(sigTxt)
%                 plot(behIdx+0.1*[-1,1],max(posPool(:,behIdx))*1.1+[0,0],'k-','linewidth',0.5)
                text(behIdx+0.02,max(posPool(:,behIdx))*1.15,sigTxt,'horizontalAlign','center','fontsize',5,'verticalAlign','middle')
                
                if any(eiFR.p.each(behIdx,eiIdx,:,3)<0.05)
                    [sigPos,sigTxt]=findSig(squeeze(eiFR.p.each(behIdx,eiIdx,:,:)),poolAvg(:,behIdx));           
                    
                    for sigIdx=1:size(sigPos,1)
                        if sigPos(sigIdx,1)<0
                            sigX=[-0.18,-0.22,-0.22,-0.18];
                            sigTxtX=-0.23;
                            vAlign='middle';
                        else
                            sigX=[0.18,0.22,0.22,0.18];
                            sigTxtX=0.22;
                            vAlign='top';
                        end
                        sigY=sort(sigPos(sigIdx,3:4)).*[1.00,1.00];
                        
                        plot(behIdx+sigX,sigY([1,1,2,2]),'k-','linewidth',0.5)
                        text(behIdx+sigTxtX,geomean(sigPos(sigIdx,3:4)),sigTxt{sigIdx},'fontsize',6,...
                            'Rotation',90,'VerticalAlignment',vAlign,'HorizontalAlignment','center')
                    end
                    
                end
                
            
            end
        end
        
        set(gca,'YScale','log')
        set(gca,'XTick',1:3,'XTickLabel',upper(behList))
        axis tight
        xlim([0.5,3.5])
        ax=fixAxis;
        ylim(exp(log(ax(3:4))+diff(log(ax(3:4)))*[-1,1]/10))
        ax=fixAxis;

        tempTick=yTickPos.beh.(strrep(targetReg{targetIdx},' ','')){eiIdx};
        if ~isempty(tempTick)
            set(gca,'YTick',tempTick)
        end   
        
        title({targetReg{targetIdx},cellTypeList{eiIdx}},'fontsize',5,'fontweight','normal')
%         set(gca,'YTick',log10([(1:9)/100,(1:9)/10,1:9,(1:9)*10]),'YTickLabel',[(1:9)/100,(1:9)/10,1:9,(1:9)*10])
        if eiIdx==1
            ylabel('Firing rate (Hz)')
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end
    end
    
    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX-2,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
    % FR within NREM
    xShift=0;
    yShift=(targetIdx-1)*(frzModheigth+yGapIntraBottom)+(3*behHeight+2*yGapIntraTop)+yGapInter;
    for eiIdx=1:2
        subplotInMM(x+xShift+(nremFRwidth+nremFRGapX)*(eiIdx-1),yTop+yShift,nremFRwidth,nremFRheigth)
        hold on
        posPool=[];
        poolAvg=[];
        for n=1:length(partnerName)
%             errorbar((1:4)+(2-n)*0.05,eiNrem.mean(n,:,eiIdx),eiNrem.ste(n,:,eiIdx),...
%                 'color',pairCol(n,:),'CapSize',1,'linewidth',0.5)
            avg=10.^eiNrem.mean(n,:,eiIdx);
            pos=10.^(eiNrem.mean(n,:,eiIdx)+eiNrem.ste(n,:,eiIdx))-avg;
            neg=avg-10.^(eiNrem.mean(n,:,eiIdx)-eiNrem.ste(n,:,eiIdx));
            errorbar(([1:2,3.5:4.5])+(n-2)*0.1,avg,neg,pos,...
                'color',pairCol(n,:),'CapSize',0,'Marker','.','MarkerSize',4,'linewidth',0.5,...
                'linestyle','none')
            posPool(n,:)=pos+avg;
            poolAvg(n,:)=avg;
        end
        
        for nremIdx=1:4
            if eiNrem.p.all(nremIdx,eiIdx)<0.001
                sigTxt='###';
            elseif eiNrem.p.all(nremIdx,eiIdx)<0.01
                sigTxt='##';
            elseif eiNrem.p.all(nremIdx,eiIdx)<0.05
                sigTxt='#';
            else
                sigTxt='';
            end
            
            if ~isempty(sigTxt)
                text(nremIdx+(nremIdx>2)*0.5,max(posPool(:,nremIdx))*1.1,sigTxt,'horizontalAlign','center','fontsize',5,'verticalAlign','middle')

            
                if any(eiNrem.p.each(nremIdx,eiIdx,:,3)<0.05)
                 [sigPos,sigTxt]=findSig(squeeze(eiNrem.p.each(nremIdx,eiIdx,:,:)),poolAvg(:,nremIdx));   
                 
                    for sigIdx=1:size(sigPos,1)
                        if sigPos(sigIdx,1)<0
                            sigX=[-0.22,-0.28,-0.28,-0.222];
                            sigTxtX=-0.31;
                            vAlign='middle';
                        else
                            sigX=[0.22,0.28,0.28,0.22];
                            sigTxtX=0.28;
                            vAlign='top';
                        end
                        sigY=sort(sigPos(sigIdx,3:4)).*[1.00,1.00];
                        
                        plot(nremIdx+(nremIdx>2)*0.5+sigX,sigY([1,1,2,2]),'k-','linewidth',0.5)
                        text(nremIdx+(nremIdx>2)*0.5+sigTxtX,geomean(sigPos(sigIdx,3:4)),sigTxt{sigIdx},'fontsize',6,...
                            'Rotation',90,'VerticalAlignment',vAlign,'HorizontalAlignment','center')
                    end
                    
                end
            end
                
        end
        
        set(gca,'XTick',[1:2,3.5:4.5],'XTickLabel',{'First','Last'},'XTickLabelRotation',0)
        set(gca,'YScale','log')
        title({targetReg{targetIdx},cellTypeList{eiIdx}},'fontsize',5,'fontweight','normal')
        axis tight
        xlim([0.5,5])
        ax=fixAxis;
        ylim(exp(log(ax(3:4))+diff(log(ax(3:4)))*[-1,1]/10))
        ax=fixAxis;             

        tempTick=yTickPos.nrem.(strrep(targetReg{targetIdx},' ','')){eiIdx};
        if ~isempty(tempTick)
            set(gca,'YTick',tempTick)
        end        
        
        if eiIdx==1
            ylabel('Firing rate (Hz)')
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end
        text2(1/4.5,-0.25,'Pre-cond.',ax,'horizontalAlign','center','verticalALign','top')
        text2(1/5,-0.37,'NREM',ax,'horizontalAlign','center','verticalALign','top')
        text2(4/5,-0.25,'Post-cond.',ax,'horizontalAlign','center','verticalALign','top')
        text2(4/5,-0.37,'NREM',ax,'horizontalAlign','center','verticalALign','top')
        
    end

    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
    % Freeze modulation
    xShift=2*nremFRwidth+nremFRGapX+frzModGapXinter;
    yShift=(targetIdx-1)*(frzModheigth+yGapIntraBottom)+(3*behHeight+2*yGapIntraTop)+yGapInter;

    for eiIdx=1:2
        subplotInMM(x+xShift+(frzModwidth+frzModGapXIntra)*(eiIdx-1),yTop+yShift,frzModwidth,frzModheigth)
        
        hold on
        posPool=[];
        poolAvg=[];

        for n=1:length(partnerName)
            errorbar((1:size(frzMod,2))+(2-n)*0.1,eiFrzMod.mean(n,:,eiIdx),eiFrzMod.ste(n,:,eiIdx),...
                'color',pairCol(n,:),'CapSize',0,'linewidth',0.5,'Marker','.','MarkerSize',4,'linestyle','none')

            posPool(n,:)=eiFrzMod.mean(n,:,eiIdx)+eiFrzMod.ste(n,:,eiIdx);
            poolAvg(n,:)=eiFrzMod.mean(n,:,eiIdx);
        end
     
        
        title([targetReg{targetIdx} ' ' cellTypeList{eiIdx}],'fontsize',5,'fontweight','normal')
        xlim([0.5,size(frzMod,2)+0.5])
        ax=fixAxis;
        for sesIdx=1:size(frzMod,2)
            if eiFrzMod.p.all(sesIdx,eiIdx)<0.001
                sigTxt='###';
            elseif eiFrzMod.p.all(sesIdx,eiIdx)<0.01
                sigTxt='##';
            elseif eiFrzMod.p.all(sesIdx,eiIdx)<0.05
                sigTxt='#';
            else
                sigTxt='';
            end
            
            if ~isempty(sigTxt)
                text(sesIdx,max(posPool(:,sesIdx))+diff(ax(3:4))*0.05,sigTxt,'horizontalAlign','center','fontsize',5,'verticalAlign','middle')

                if any(eiFrzMod.p.each(sesIdx,eiIdx,:,3)<0.05)
                    [sigPos,sigTxt]=findSig(squeeze(eiFrzMod.p.each(sesIdx,eiIdx,:,:)),poolAvg(:,sesIdx));      
                    
                    for sigIdx=1:size(sigPos,1)
                        if sigPos(sigIdx,1)<0
                            sigX=[-0.18,-0.22,-0.22,-0.18];
                            sigTxtX=-0.24;
                            vAlign='middle';
                        else
                            sigX=[0.18,0.22,0.22,0.18];
                            sigTxtX=0.22;
                            vAlign='top';
                        end
                        sigY=sort(sigPos(sigIdx,3:4)).*[1.00,1.00];
                        
                        plot(sesIdx+sigX,sigY([1,1,2,2]),'k-','linewidth',0.5)
                        text(sesIdx+sigTxtX,mean(sigPos(sigIdx,3:4)),sigTxt{sigIdx},'fontsize',6,...
                            'Rotation',90,'VerticalAlignment',vAlign,'HorizontalAlignment','center')
                    end                   
                    
                end            
            end
                
        end           
        if eiIdx==1
            ylabel({'Freeze' 'modulation index'})
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end        
        set(gca,'xtick',1:size(frzMod,2),'XTickLabel',sesName,'XTickLabelRotation',20)
    end
    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX-6,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
end
end

function panel_01_to_05_withoutRanksum(x,y)
% coact=poolVar('coactCompCell_LT.mat');
coact=poolVar('coactCompCell.mat');
meanFR=poolVar('meanFR.mat');
info=poolVar('okUnit.cellinfo.mat');
frz=poolVar('frzFRmod.mat');


ratList=fieldnames(coact);

tempSes=2;
sigHC=3;
%% get partners
partner={};

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    
    region=relabel_region(coact.(rat).region,'minCellNum',0);
    
    temp=cell(size(info.(rat).channel));
    
    [cIdx,rIdx]=find(coact.(rat).ica(tempSes).homecage(sigHC).nrem);
    cList=unique(cIdx)';
    for cc=cList
        temp{cc}={region{ rIdx(cIdx==cc)}};
    end
    
    partner=[partner,temp];
end

for cIdx=1:length(partner)
    if isempty(partner{cIdx})
        continue
    end
    partner{cIdx}(~ismember(partner{cIdx},{'BLA','vCA1','PrL L5'}))=[];
    partner{cIdx}=unique(partner{cIdx});
end



%% get cellinfo
cellType=[];
reg=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    cellType=[cellType;info.(rat).cellType.type'];
    reg=[reg,info.(rat).region];
end

[reg,regList]=relabel_region(reg,'minCellNum',0);
reg=reg';
% %%
% frMean=[];
% frStd=[];
%
% for ratIdx=1:length(ratList)
%     rat=ratList{ratIdx};
%
%     frMean=[frMean;fr.(rat).overall.mean'];
%     frStd=[frStd;fr.(rat).overall.std'];
% end
%%
frzMod=[]
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    frzMod=[frzMod;squeeze(frz.(rat).modIdx(:,[1,2,3,4,8]))];
        
end
%% getFR in HC
nremFR=[];

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    %homecage 2 & 3;
    slp='nrem';
    %homecage 2 & 3, sepalate in half
    nremFR=[nremFR;meanFR.(rat).Hz.(slp)([4:5,7:8],:)'];
    
end
%%
hcIdx=[1,3,5,10,12];
behList={'wake','nrem','rem'};
for behIdx=1:3
    beh=behList{behIdx};
    behFR.(beh)=[];
    for ratIdx=1:length(ratList)
        rat=ratList{ratIdx};
        
        temp=meanFR.(rat).noDiv.Hz.(beh)(hcIdx,:);
        temp(isnan(temp))=0;
        dur=meanFR.(rat).noDiv.duration.(beh)(hcIdx);
        
        behFR.(beh)=[behFR.(beh),sum(temp.*dur',1)/sum(dur)];
    end
end
%%
clf
colTemp=setCoactColor()

piCol=[colTemp.cellType.inh;
       colTemp.cellType.nc;
       colTemp.cellType.ex];

targetReg={'PrL L5','BLA','vCA1'};
behList={'wake','nrem','rem'};
cellTypeList={'excitatory cells','inhibitory cells'};

% pieWidth=10;
% pieHeigth=15;
% pieGap=5;

tableGapX=2;
tableWidth=76-tableGapX;

nCellWidth=18;
nCellHeight=15;
nCellGapX=15;
nCellGapXintra=(tableWidth-nCellWidth*3)/2;

behWidth=28;
behHeight=nCellHeight;
behGapXinter=14;
behGapXintra=5;

yGapIntraTop=10;
yGapIntraBottom=14.5;
yGapInter=13.5;

tableHight=nCellHeight*2+yGapIntraTop;

wTotal=tableWidth+tableGapX+behWidth*2+behGapXinter+behGapXintra;

nremFRwidth=(21+36)*5/11;
nremFRheigth=15;
nremFRGapX=5;

frzModwidth=(21+36)*6/11;
frzModheigth=nremFRheigth;
frzModGapXIntra=5;
frzModGapXinter=wTotal-frzModwidth*2-frzModGapXIntra-nremFRwidth*2-nremFRGapX;

labelWeight=true;
labelCase=false;
labelSize=8;
letGapX=5;
letGapY=6;

pCnt=0;
sesName={'Baseline','Conditioning','Context','Cue ses. before first tone','Cue ses. after first tone'};

eiLeg{1}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.ex, 'Excitatory');
eiLeg{2}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.inh, 'Inhibitory');
eiLeg{3}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.nc, 'Not classified');


for n=1:2
    yTickPos.beh.PrLL5{n}=[];
    yTickPos.beh.vCA1{n}=[];
    yTickPos.beh.BLA{n}=[];

    yTickPos.nrem.PrLL5{n}=[];
    yTickPos.nrem.vCA1{n}=[];
    yTickPos.nrem.BLA{n}=[];
end

yTickPos.beh.BLA{1}=[0.5,1,2,5];
yTickPos.beh.vCA1{1}=[0.5,1,2,5];

yTickPos.nrem.vCA1{2}=[2,5,10,20];
%%
yShift=0;
xShift=0;
yTop=y;
clf
subplotInMM(x+xShift,y+yShift,tableWidth,tableHight,tableWidth)
set(gca,'YDir','reverse')
xlim([0,tableWidth])
ylim([0,tableHight])
hold on
xMargin=2;
yMargin=0;
cellWidth=(tableWidth-xMargin*2)/4.7
cellHight=(tableHight-yMargin*2)/4.5;
lineGap=0
rowIdx=0;
plot([0,tableWidth],(rowIdx+lineGap)*cellHight+yMargin+[0,0],'k-','LineWidth',0.5)
rowIdx=rowIdx+1;
for colIdx=1:4
    if colIdx<=length(targetReg)
    text((colIdx)*cellWidth+xMargin,(rowIdx-0.5)*cellHight+yMargin,{'Coupled ' ['with ' targetReg{colIdx}]},'fontsize',5,...
        'horizontalAlign','left','verticalALign','middle')
    else
    text((colIdx)*cellWidth+xMargin,(rowIdx-0.5)*cellHight+yMargin,'Other cells','fontsize',5,...
        'horizontalAlign','left','verticalALign','middle')
    end
end
plot([0,tableWidth],(rowIdx+lineGap)*cellHight+yMargin+[0,0],'k-','LineWidth',0.5)
for idx=1:length(targetReg)
    rowIdx=rowIdx+1;        
    target=find(strcmp(reg,targetReg{idx}));

    
    for colIdx=0:4;
        interpreter='tex';
        if colIdx==0
            txt={'Cells' ['in ' targetReg{idx}]};
        elseif colIdx==idx
            txt='N.A.';
        else
            if colIdx==4
                id=target(cellfun(@isempty,partner(target)));            
            else
                id=target(cellfun(@(x) any(strcmp(x,targetReg{colIdx})), partner(target)));
            end
            cnt=histcounts(cellType(id),-1.5:1.5);
            txt=sprintf('%d / %d / %d',cnt(3),cnt(1),cnt(2));
        end
        text((colIdx)*cellWidth+xMargin,(rowIdx-0.5)*cellHight+yMargin,txt,'fontsize',5,...
            'horizontalAlign','left','verticalALign','middle','Interpreter',interpreter)
    end
    
end
plot([0,tableWidth],(rowIdx+lineGap)*cellHight+yMargin+[0,0],'k-','LineWidth',0.5)
axis off
%%
pCnt=pCnt+1;
panelLetter2(x+xShift-letGapX,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)

for targetIdx=1:length(targetReg)
    yTop=y;%+(targetIdx-1)*(nCellHeight+yGapInter+nremFRheigth+yGapInterReg);
    yShift=0;
    xShift=0;
    target=find(strcmp(reg,targetReg{targetIdx}));
    partnerList=targetReg;
    partnerList(strcmp(partnerList,targetReg{targetIdx}))=[]
    
    eiRatio=zeros(length(partnerList)+1,3);
    eiFR.mean=zeros(length(partnerList)+1,length(behList),2);
    eiFR.ste=zeros(length(partnerList)+1,length(behList),2);
    eiFR.raw=cell(length(partnerList)+1,length(behList),2);
    eiNrem.mean=zeros(length(partnerList)+1,4,2);
    eiNrem.ste=zeros(length(partnerList)+1,4,2);
    eiNrem.raw=cell(length(partnerList)+1,4,2);
    eiFrzMod.mean=zeros(length(partnerList)+1,size(frzMod,2),2);
    eiFrzMod.ste=zeros(length(partnerList)+1,size(frzMod,2),2);
    eiFrzMod.raw=cell(length(partnerList)+1,size(frzMod,2),2);
    
    partnerName={};
    partnerNameCore={};
    pairCol=[];
    for n=1:length(partnerList)+1
        if n>length(partnerList)
            id=target(cellfun(@isempty,partner(target)));
            partnerName{n}='Othres';
            partnerNameCore{n}='Othres';
            pairCol(n,:)=colTemp.region.others;
        else
            id=target(cellfun(@(x) any(strcmp(x,partnerList{n})), partner(target)));
            partnerName{n}=['Coupled with ' partnerList{n}];
            partnerNameCore{n}=partnerList{n};
            pairCol(n,:)=colTemp.pair.(strrep(strrep([targetReg{targetIdx} partnerList{n}],' ',''),'/',''));
        end
        pairLeg{n+1}=sprintf('\\color[rgb]{%f %f %f}%s',pairCol(n,:),partnerName{n});
        eiId{1}=id(cellType(id)==1);
        eiId{2}=id(cellType(id)==-1);
        
        cnt=histcounts(cellType(id),-1.5:1.5);
        eiRatio(n,:)=cnt/sum(cnt)*100;

        fprintf('in %s, %s cells : n=%d\n',targetReg{targetIdx},partnerNameCore{n},sum(cnt))
        
        for eiIdx=1:2           
            for behIdx=1:3
                beh=behList{behIdx};
                eiFR.mean(n,behIdx,eiIdx)=nanmean(log10(behFR.(beh)(eiId{eiIdx})));
                eiFR.ste(n,behIdx,eiIdx)=nanste(log10(behFR.(beh)(eiId{eiIdx})));
                eiFR.raw{n,behIdx,eiIdx}=(behFR.(beh)(eiId{eiIdx}));
            end
            
            val=log10(nremFR(eiId{eiIdx},:));
%             val(any(isnan(val),2),:)=[];
%             val(any(isinf(val),2),:)=[];
            val(isinf(val))=nan;
            eiNrem.mean(n,:,eiIdx)=nanmean(val,1);
            eiNrem.ste(n,:,eiIdx)=nanste(val,[],1);
            for nremIdx=1:4
                eiNrem.raw{n,nremIdx,eiIdx}=nremFR(eiId{eiIdx},nremIdx)';
            end
            
            eiFrzMod.mean(n,:,eiIdx)=nanmean(frzMod(eiId{eiIdx},:));
            eiFrzMod.ste(n,:,eiIdx)=nanste(frzMod(eiId{eiIdx},:));
            for sesIdx=1:size(frzMod,2)
                eiFrzMod.raw{n,sesIdx,eiIdx}=frzMod(eiId{eiIdx},sesIdx)';
            end
        end
    end
    
    eiFR.p.all=ones(3,2);
    eiFR.p.each=ones(3,2,3,3);
    for behIdx=1:3
        for eiIdx=1:2
            temp=cellfun(@(x) ones(size(x)),eiFR.raw(:,behIdx,eiIdx),'UniformOutput',false);
            grp=[];
            for regIdx=1:size(temp,1)
                grp=[grp,regIdx*temp{regIdx}]
            end
            val=cat(2,eiFR.raw{:,behIdx,eiIdx});
            [p,~,s]=kruskalwallis(val,grp,'off');
%             c=multcompare(s,'display','off');
            eiFR.p.all(behIdx,eiIdx)=p;
%             eiFR.p.each(behIdx,eiIdx,:,:)=c;            
            idx=0;
            nGrp=3;
            for n=1:nGrp-1
                for m=n+1:nGrp
                    idx=idx+1;
                    p=ranksum(eiFR.raw{n,behIdx,eiIdx},eiFR.raw{m,behIdx,eiIdx});
                    p=p*nGrp*(nGrp-1)/2;
                    eiFR.p.each(behIdx,eiIdx,idx,:)=[n,m,p];
                end
            end

        end
    end
    
    eiNrem.p.all=ones(4,2);
    eiNrem.p.each=ones(4,2,3,3);
    for nremIdx=1:4
        for eiIdx=1:2
            temp=cellfun(@(x) ones(size(x)),eiNrem.raw(:,nremIdx,eiIdx),'UniformOutput',false);
            grp=[];
            for regIdx=1:size(temp,1)
                grp=[grp,regIdx*temp{regIdx}]
            end
            val=cat(2,eiNrem.raw{:,nremIdx,eiIdx});
            [p,~,s]=kruskalwallis(val,grp,'off');
%             c=multcompare(s,'display','off');
            eiNrem.p.all(nremIdx,eiIdx)=p;
%             eiNrem.p.each(nremIdx,eiIdx,:,:)=c;
            idx=0;
            nGrp=3;
            for n=1:nGrp-1
                for m=n+1:nGrp
                    idx=idx+1;
                    p=ranksum(eiNrem.raw{n,nremIdx,eiIdx},eiNrem.raw{m,nremIdx,eiIdx});
                    p=p*nGrp*(nGrp-1)/2;
                    eiNrem.p.each(nremIdx,eiIdx,idx,:)=[n,m,p];
                end
            end
        end
    end    

    eiFrzMod.p.all=ones(size(frzMod,2),2);
    eiFrzMod.p.each=ones(size(frzMod,2),2,3,3);
    for sesIdx=1:size(frzMod,2)
        for eiIdx=1:2
            temp=cellfun(@(x) ones(size(x)),eiFrzMod.raw(:,sesIdx,eiIdx),'UniformOutput',false);
            grp=[];
            for regIdx=1:size(temp,1)
                grp=[grp,regIdx*temp{regIdx}]
            end
            val=cat(2,eiFrzMod.raw{:,sesIdx,eiIdx});
            [p,~,s]=kruskalwallis(val,grp,'off');
%             c=multcompare(s,'display','off');
            eiFrzMod.p.all(sesIdx,eiIdx)=p;
%             eiFrzMod.p.each(sesIdx,eiIdx,:,:)=c;            
            idx=0;
            nGrp=3;
            for n=1:nGrp-1
                for m=n+1:nGrp
                    idx=idx+1;
                    p=ranksum(eiFrzMod.raw{n,sesIdx,eiIdx},eiFrzMod.raw{m,sesIdx,eiIdx});
                    p=p*nGrp*(nGrp-1)/2;
                    eiFrzMod.p.each(sesIdx,eiIdx,idx,:)=[n,m,p];
                end
            end
        end
    end    
    
    regRatio=zeros(2,3);
    for eiIdx=1:2
        id=target(cellType(target)==3-eiIdx*2);
        cnt=histcounts(cellfun(@length,partner(id)),-0.5:2.5);
        regRatio(eiIdx,:)=cnt/sum(cnt)*100;
    end
    % pie chart for each partner
%     yShift=(targetIdx-1)*(nCellHeight+yGapIntraTop);
%     for n=1:length(partnerName)
%         subplotInMM(x+(pieWidth+pieGap)*(n-1),yTop+yShift+1,pieWidth,pieHeigth)
%         
%         temp=eiRatio(n,:);
%         picolTemp=piCol;
%         picolTemp(temp==0,:)=[];
%         temp(temp==0)=[];
%         empChar={'','',''};
%         h=pie(temp,empChar(1:length(temp)));
%         for hIdx=1:length(h)
%             if strcmpi(h(hIdx).Type,'patch')
%                 h(hIdx).LineStyle='none';
%             end
%         end
%         colormap(gca,picolTemp)
%         if n~=length(partnerNameCore)
%             title({'Coupled with',partnerNameCore{n}},'fontsize',5,'fontweight','normal')
%         else
%             title({partnerNameCore{n}},'fontsize',5,'fontweight','normal')
%         end
%         ax=fixAxis;
%         if n==2
%             text2(0.5,1.7,sprintf('Cells in %s',targetReg{targetIdx}),ax,'horizontalAlign','center')
%         end
%         if n==3
%             text2(1,-0.2,join(eiLeg,'  '),ax,'horizontalAlign','right')
%         end        
%     end
%     if targetIdx==1
%         pCnt=pCnt+1;
%         panelLetter2(x+xShift-letGapX,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
%     end
    % # partner regions
    xShift=(targetIdx-1)*(nCellWidth+nCellGapXintra);
    yShift=tableHight+yGapIntraTop;
    subplotInMM(x+xShift,yTop+yShift,nCellWidth,nCellHeight)

    bar(0:2,regRatio','linestyle','none')
    colormap(gca,piCol([3,1],:))
    box off
    xlabel('# partner region')
    if targetIdx==1
        ylabel({'Fraction of' 'cells (%)'})
    end
    xlim([-0.5,2.5])
    title(targetReg{targetIdx},'fontsize',5,'fontweight','normal')
    ax=fixAxis;
    text2(0.7,1,eiLeg(1:2),ax,'verticalAlign','top')
    
    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
    % FR for each state
    yShift=(targetIdx-1)*(nCellHeight+yGapIntraTop);
    xShift=tableWidth+tableGapX+behGapXinter;
    for eiIdx=1:2
        subplotInMM(x+xShift+(behWidth+behGapXintra)*(eiIdx-1),yTop+yShift,behWidth,behHeight)

        hold on
        posPool=[];
        for n=1:length(partnerName)
%             bar((1:3)+(n-2)*0.3,squeeze(eiFR.mean(n,:,eiIdx))',0.1,'LineStyle','none','FaceColor',pairCol(n,:))
            avg=10.^eiFR.mean(n,:,eiIdx);
            pos=10.^(eiFR.mean(n,:,eiIdx)+eiFR.ste(n,:,eiIdx))-avg;
            neg=avg-10.^(eiFR.mean(n,:,eiIdx)-eiFR.ste(n,:,eiIdx));
            errorbar((1:3)+(n-2)*0.1,avg,neg,pos,...
                'linestyle','none','color',pairCol(n,:),'CapSize',0,'Marker','.','MarkerSize',4,'linewidth',0.5)
            posPool(n,:)=avg+pos;
        end
        for behIdx=1:3
            if eiFR.p.all(behIdx,eiIdx)<0.001
                sigTxt='***'
            elseif eiFR.p.all(behIdx,eiIdx)<0.01
                sigTxt='**'
            elseif eiFR.p.all(behIdx,eiIdx)<0.05
                sigTxt='*'
            else
                sigTxt=''
            end
            
            if ~isempty(sigTxt)
                plot(behIdx+0.1*[-1,1],max(posPool(:,behIdx))*1.1+[0,0],'k-','linewidth',0.5)
                text(behIdx+0.02,max(posPool(:,behIdx))*1.15,sigTxt,'horizontalAlign','center','fontsize',6,'verticalAlign','middle')
            end
                
        end
        
        set(gca,'YScale','log')
        set(gca,'XTick',1:3,'XTickLabel',upper(behList))
        axis tight
        xlim([0.5,3.5])
        ax=fixAxis;
        ylim(exp(log(ax(3:4))+diff(log(ax(3:4)))*[-1,1]/10))
        ax=fixAxis;

        tempTick=yTickPos.beh.(strrep(targetReg{targetIdx},' ','')){eiIdx};
        if ~isempty(tempTick)
            set(gca,'YTick',tempTick)
        end   
        
        title({targetReg{targetIdx},cellTypeList{eiIdx}},'fontsize',5,'fontweight','normal')
%         set(gca,'YTick',log10([(1:9)/100,(1:9)/10,1:9,(1:9)*10]),'YTickLabel',[(1:9)/100,(1:9)/10,1:9,(1:9)*10])
        if eiIdx==1
            ylabel('Firing rate (Hz)')
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end
    end
    
    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX-2,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
    % FR within NREM
    xShift=0;
    yShift=(targetIdx-1)*(frzModheigth+yGapIntraBottom)+(3*behHeight+2*yGapIntraTop)+yGapInter;
    for eiIdx=1:2
        subplotInMM(x+xShift+(nremFRwidth+nremFRGapX)*(eiIdx-1),yTop+yShift,nremFRwidth,nremFRheigth)
        hold on
        posPool=[];
        for n=1:length(partnerName)
%             errorbar((1:4)+(2-n)*0.05,eiNrem.mean(n,:,eiIdx),eiNrem.ste(n,:,eiIdx),...
%                 'color',pairCol(n,:),'CapSize',1,'linewidth',0.5)
            avg=10.^eiNrem.mean(n,:,eiIdx);
            pos=10.^(eiNrem.mean(n,:,eiIdx)+eiNrem.ste(n,:,eiIdx))-avg;
            neg=avg-10.^(eiNrem.mean(n,:,eiIdx)-eiNrem.ste(n,:,eiIdx));
            errorbar(([1:2,3.5:4.5])+(n-2)*0.1,avg,neg,pos,...
                'color',pairCol(n,:),'CapSize',0,'Marker','.','MarkerSize',4,'linewidth',0.5)
            posPool(n,:)=pos+avg;
        end
        
        for nremIdx=1:4
            if eiNrem.p.all(nremIdx,eiIdx)<0.001
                sigTxt='***'
            elseif eiNrem.p.all(nremIdx,eiIdx)<0.01
                sigTxt='**'
            elseif eiNrem.p.all(nremIdx,eiIdx)<0.05
                sigTxt='*'
            else
                sigTxt=''
            end
            
            if ~isempty(sigTxt)
                text(nremIdx+(nremIdx>2)*0.5,max(posPool(:,nremIdx))*1.1,sigTxt,'horizontalAlign','center','fontsize',6,'verticalAlign','middle')
            end
                
        end
        
        set(gca,'XTick',[1:2,3.5:4.5],'XTickLabel',{'First','Last'},'XTickLabelRotation',0)
        set(gca,'YScale','log')
        title({targetReg{targetIdx},cellTypeList{eiIdx}},'fontsize',5,'fontweight','normal')
        axis tight
        xlim([0.5,5])
        ax=fixAxis;
        ylim(exp(log(ax(3:4))+diff(log(ax(3:4)))*[-1,1]/10))
        ax=fixAxis;             

        tempTick=yTickPos.nrem.(strrep(targetReg{targetIdx},' ','')){eiIdx};
        if ~isempty(tempTick)
            set(gca,'YTick',tempTick)
        end        
        
        if eiIdx==1
            ylabel('Firing rate (Hz)')
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end
        text2(1/4.5,-0.25,'Pre-cond.',ax,'horizontalAlign','center','verticalALign','top')
        text2(1/5,-0.37,'NREM',ax,'horizontalAlign','center','verticalALign','top')
        text2(4/5,-0.25,'Post-cond.',ax,'horizontalAlign','center','verticalALign','top')
        text2(4/5,-0.37,'NREM',ax,'horizontalAlign','center','verticalALign','top')
        
    end

    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
    % Freeze modulation
    xShift=2*nremFRwidth+nremFRGapX+frzModGapXinter;
    yShift=(targetIdx-1)*(frzModheigth+yGapIntraBottom)+(3*behHeight+2*yGapIntraTop)+yGapInter;

    for eiIdx=1:2
        subplotInMM(x+xShift+(frzModwidth+frzModGapXIntra)*(eiIdx-1),yTop+yShift,frzModwidth,frzModheigth)
        
        hold on
        posPool=[];
        for n=1:length(partnerName)
            errorbar((1:size(frzMod,2))+(2-n)*0.05,eiFrzMod.mean(n,:,eiIdx),eiFrzMod.ste(n,:,eiIdx),...
                'color',pairCol(n,:),'CapSize',0,'linewidth',0.5,'Marker','.','MarkerSize',4)

            posPool(n,:)=eiFrzMod.mean(n,:,eiIdx)+eiFrzMod.ste(n,:,eiIdx);
        end
     
        
        title([targetReg{targetIdx} ' ' cellTypeList{eiIdx}],'fontsize',5,'fontweight','normal')
        xlim([0.5,size(frzMod,2)+0.5])
        ax=fixAxis;
        for sesIdx=1:size(frzMod,2)
            if eiFrzMod.p.all(sesIdx,eiIdx)<0.001
                sigTxt='***';
            elseif eiFrzMod.p.all(sesIdx,eiIdx)<0.01
                sigTxt='**';
            elseif eiFrzMod.p.all(sesIdx,eiIdx)<0.05
                sigTxt='*';
            else
                sigTxt='';
            end
            
            if ~isempty(sigTxt)
                text(sesIdx,max(posPool(:,sesIdx))+diff(ax(3:4))*0.05,sigTxt,'horizontalAlign','center','fontsize',6,'verticalAlign','middle')
            end
                
        end           
        if eiIdx==1
            ylabel({'Freeze' 'modulation index'})
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end        
        set(gca,'xtick',1:size(frzMod,2),'XTickLabel',sesName,'XTickLabelRotation',20)
    end
    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX-6,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
end
end
%%
function OLD_panel_01_to_05(x,y)
% coact=poolVar('coactCompCell_LT.mat');
coact=poolVar('coactCompCell.mat');
meanFR=poolVar('meanFR.mat');
info=poolVar('okUnit.cellinfo.mat');
frz=poolVar('frzFRmod.mat');


ratList=fieldnames(coact);

tempSes=2;
sigHC=3;
%% get partners
partner={};

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    
    region=relabel_region(coact.(rat).region,'minCellNum',0);
    
    temp=cell(size(info.(rat).channel));
    
    [cIdx,rIdx]=find(coact.(rat).ica(tempSes).homecage(sigHC).nrem);
    cList=unique(cIdx)';
    for cc=cList
        temp{cc}={region{ rIdx(cIdx==cc)}};
    end
    
    partner=[partner,temp];
end

for cIdx=1:length(partner)
    if isempty(partner{cIdx})
        continue
    end
    partner{cIdx}(~ismember(partner{cIdx},{'BLA','vCA1','PrL L5'}))=[];
    partner{cIdx}=unique(partner{cIdx});
end



%% get cellinfo
cellType=[];
reg=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    cellType=[cellType;info.(rat).cellType.type'];
    reg=[reg,info.(rat).region];
end

[reg,regList]=relabel_region(reg,'minCellNum',0);
reg=reg';
% %%
% frMean=[];
% frStd=[];
%
% for ratIdx=1:length(ratList)
%     rat=ratList{ratIdx};
%
%     frMean=[frMean;fr.(rat).overall.mean'];
%     frStd=[frStd;fr.(rat).overall.std'];
% end
%%
frzMod=[]
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    frzMod=[frzMod;squeeze(frz.(rat).modIdx(:,[1,2,3:6,7]))];
        
end
%% getFR in HC
nremFR=[];

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    %homecage 2 & 3;
    slp='nrem';
    %homecage 2 & 3, sepalate in half
    nremFR=[nremFR;meanFR.(rat).Hz.(slp)([4:5,7:8],:)'];
    
end
%%
hcIdx=[1,3,5,10,12];
behList={'wake','nrem','rem'};
for behIdx=1:3
    beh=behList{behIdx};
    behFR.(beh)=[];
    for ratIdx=1:length(ratList)
        rat=ratList{ratIdx};
        
        temp=meanFR.(rat).noDiv.Hz.(beh)(hcIdx,:);
        temp(isnan(temp))=0;
        dur=meanFR.(rat).noDiv.duration.(beh)(hcIdx);
        
        behFR.(beh)=[behFR.(beh),sum(temp.*dur',1)/sum(dur)];
    end
end
%%
clf
colTemp=setCoactColor()

piCol=[colTemp.cellType.inh;
       colTemp.cellType.nc;
       colTemp.cellType.ex];

targetReg={'PrL L5','BLA','vCA1'};
behList={'wake','nrem','rem'};
cellTypeList={'excitatory cells','inhibitory cells'};

pieWidth=10;
pieHeigth=15;
pieGap=5;

nCellWidth=16;
nCellHeight=15;
nCellGapX=15;

behWidth=28;
behHeight=nCellHeight;
behGapXinter=14;
behGapXintra=5;

yGapIntraTop=10;
yGapIntraBottom=14.5;
yGapInter=13.5;


wTotal=pieWidth*3+pieGap*3+nCellWidth+nCellGapX+behWidth*2+behGapXinter+behGapXintra;

nremFRwidth=21;
nremFRheigth=15;
nremFRGapX=5;

frzModwidth=34;
frzModheigth=nremFRheigth;
frzModGapXIntra=5;
frzModGapXinter=wTotal-frzModwidth*2-frzModGapXIntra-nremFRwidth*2-nremFRGapX;

labelWeight=true;
labelCase=false;
labelSize=8;
letGapX=5;
letGapY=6;

pCnt=0;
sesName={'Baseline','Conditioning','Context','Cue - before tone','Cue - first 8 tones', 'Cue - last 32 tones','Retention of extinction'};

eiLeg{1}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.ex, 'Excitatory');
eiLeg{2}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.inh, 'Inhibitory');
eiLeg{3}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.nc, 'Not classified');

for n=1:2
    yTickPos.beh.PrLL5{n}=[];
    yTickPos.beh.vCA1{n}=[];
    yTickPos.beh.BLA{n}=[];

    yTickPos.nrem.PrLL5{n}=[];
    yTickPos.nrem.vCA1{n}=[];
    yTickPos.nrem.BLA{n}=[];
end

yTickPos.beh.BLA{1}=[0.5,1,2,5];
yTickPos.beh.vCA1{1}=[0.5,1,2,5];

yTickPos.nrem.vCA1{2}=[2,5,10,20];


for targetIdx=1:length(targetReg)
    yTop=y;%+(targetIdx-1)*(nCellHeight+yGapInter+nremFRheigth+yGapInterReg);
    yShift=0;
    xShift=0;
    target=find(strcmp(reg,targetReg{targetIdx}));
    partnerList=targetReg;
    partnerList(strcmp(partnerList,targetReg{targetIdx}))=[]
    
    eiRatio=zeros(length(partnerList)+1,3);
    eiFR.mean=zeros(length(partnerList)+1,length(behList),2);
    eiFR.ste=zeros(length(partnerList)+1,length(behList),2);
    eiNrem.mean=zeros(length(partnerList)+1,4,2);
    eiNrem.ste=zeros(length(partnerList)+1,4,2);
    eiFrzMod.mean=zeros(length(partnerList)+1,7,2);
    eiFrzMod.ste=zeros(length(partnerList)+1,7,2);
    
    partnerName={};
    partnerNameCore={};
    pairCol=[];
    for n=1:length(partnerList)+1
        if n>length(partnerList)
            id=target(cellfun(@isempty,partner(target)));
            partnerName{n}='Othres';
            partnerNameCore{n}='Othres';
            pairCol(n,:)=colTemp.region.others;
        else
            id=target(cellfun(@(x) any(strcmp(x,partnerList{n})), partner(target)));
            partnerName{n}=['Coupled with ' partnerList{n}];
            partnerNameCore{n}=partnerList{n};
            pairCol(n,:)=colTemp.pair.(strrep(strrep([targetReg{targetIdx} partnerList{n}],' ',''),'/',''));
        end
        pairLeg{n+1}=sprintf('\\color[rgb]{%f %f %f}%s',pairCol(n,:),partnerName{n});
        eiId{1}=id(cellType(id)==1);
        eiId{2}=id(cellType(id)==-1);
        
        cnt=histcounts(cellType(id),-1.5:1.5);
        eiRatio(n,:)=cnt/sum(cnt)*100;

        fprintf('in %s, %s cells : n=%d\n',targetReg{targetIdx},partnerNameCore{n},sum(cnt))
        
        for eiIdx=1:2           
            for behIdx=1:3
                beh=behList{behIdx};
                eiFR.mean(n,behIdx,eiIdx)=nanmean(log10(behFR.(beh)(eiId{eiIdx})));
                eiFR.ste(n,behIdx,eiIdx)=nanste(log10(behFR.(beh)(eiId{eiIdx})));
            end
            val=log10(nremFR(eiId{eiIdx},:));
%             val(any(isnan(val),2),:)=[];
%             val(any(isinf(val),2),:)=[];
            val(isinf(val))=nan;
            eiNrem.mean(n,:,eiIdx)=nanmean(val,1);
            eiNrem.ste(n,:,eiIdx)=nanste(val,[],1);
            
            eiFrzMod.mean(n,:,eiIdx)=nanmean(frzMod(eiId{eiIdx},:));
            eiFrzMod.ste(n,:,eiIdx)=nanste(frzMod(eiId{eiIdx},:));

        end
    end
    regRatio=zeros(2,3);
    for eiIdx=1:2
        id=target(cellType(target)==3-eiIdx*2);
        cnt=histcounts(cellfun(@length,partner(id)),-0.5:2.5);
        regRatio(eiIdx,:)=cnt/sum(cnt)*100;
    end

    % pie chart for each partner
    yShift=(targetIdx-1)*(nCellHeight+yGapIntraTop);
    for n=1:length(partnerName)
        subplotInMM(x+(pieWidth+pieGap)*(n-1),yTop+yShift+1,pieWidth,pieHeigth)
        
        temp=eiRatio(n,:);
        picolTemp=piCol;
        picolTemp(temp==0,:)=[];
        temp(temp==0)=[];
        empChar={'','',''};
        h=pie(temp,empChar(1:length(temp)));
        for hIdx=1:length(h)
            if strcmpi(h(hIdx).Type,'patch')
                h(hIdx).LineStyle='none';
            end
        end
        colormap(gca,picolTemp)
        if n~=length(partnerNameCore)
            title({'Coupled with',partnerNameCore{n}},'fontsize',5,'fontweight','normal')
        else
            title({partnerNameCore{n}},'fontsize',5,'fontweight','normal')
        end
        ax=fixAxis;
        if n==2
            text2(0.5,1.7,sprintf('Cells in %s',targetReg{targetIdx}),ax,'horizontalAlign','center')
        end
        if n==3
            text2(1,-0.2,join(eiLeg,'  '),ax,'horizontalAlign','right')
        end        
    end
    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
    % # partner regions
    xShift=(pieWidth+pieGap)*3+nCellGapX;
    yShift=(targetIdx-1)*(nCellHeight+yGapIntraTop);
    subplotInMM(x+xShift,yTop+yShift,nCellWidth,nCellHeight)

    bar(0:2,regRatio','linestyle','none')
    colormap(gca,piCol([3,1],:))
    box off
    xlabel('# partner region')
    ylabel({'Fraction of' 'cells (%)'})
    xlim([-0.5,2.5])
    title(targetReg{targetIdx},'fontsize',5,'fontweight','normal')
    ax=fixAxis;
    text2(0.7,1,eiLeg(1:2),ax,'verticalAlign','top')
    
    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX-4,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
    % FR for each state
    yShift=(targetIdx-1)*(nCellHeight+yGapIntraTop);
    xShift=(pieWidth+pieGap)*3+nCellGapX+nCellWidth+behGapXinter;
    for eiIdx=1:2
        subplotInMM(x+xShift+(behWidth+behGapXintra)*(eiIdx-1),yTop+yShift,behWidth,behHeight)

        hold on
        for n=1:length(partnerName)
%             bar((1:3)+(n-2)*0.3,squeeze(eiFR.mean(n,:,eiIdx))',0.1,'LineStyle','none','FaceColor',pairCol(n,:))
            avg=10.^eiFR.mean(n,:,eiIdx);
            pos=10.^(eiFR.mean(n,:,eiIdx)+eiFR.ste(n,:,eiIdx))-avg;
            neg=avg-10.^(eiFR.mean(n,:,eiIdx)-eiFR.ste(n,:,eiIdx));
            errorbar((1:3)+(n-2)*0.1,avg,neg,pos,...
                'linestyle','none','color',pairCol(n,:),'CapSize',0,'Marker','.','MarkerSize',4,'linewidth',0.5)
        end
        set(gca,'YScale','log')
        set(gca,'XTick',1:3,'XTickLabel',upper(behList))
        axis tight
        xlim([0.5,3.5])
        ax=fixAxis;
        ylim(exp(log(ax(3:4))+diff(log(ax(3:4)))*[-1,1]/10))
        ax=fixAxis;

        tempTick=yTickPos.beh.(strrep(targetReg{targetIdx},' ','')){eiIdx};
        if ~isempty(tempTick)
            set(gca,'YTick',tempTick)
        end   
        
        title({targetReg{targetIdx},cellTypeList{eiIdx}},'fontsize',5,'fontweight','normal')
%         set(gca,'YTick',log10([(1:9)/100,(1:9)/10,1:9,(1:9)*10]),'YTickLabel',[(1:9)/100,(1:9)/10,1:9,(1:9)*10])
        if eiIdx==1
            ylabel('Firing rate (Hz)')
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end
    end
    
    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX-2,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
    % FR within NREM
    xShift=0;
    yShift=(targetIdx-1)*(frzModheigth+yGapIntraBottom)+(3*behHeight+2*yGapIntraTop)+yGapInter;
    for eiIdx=1:2
        subplotInMM(x+xShift+(nremFRwidth+nremFRGapX)*(eiIdx-1),yTop+yShift,nremFRwidth,nremFRheigth)
        hold on
        for n=1:length(partnerName)
%             errorbar((1:4)+(2-n)*0.05,eiNrem.mean(n,:,eiIdx),eiNrem.ste(n,:,eiIdx),...
%                 'color',pairCol(n,:),'CapSize',1,'linewidth',0.5)
            avg=10.^eiNrem.mean(n,:,eiIdx);
            pos=10.^(eiNrem.mean(n,:,eiIdx)+eiNrem.ste(n,:,eiIdx))-avg;
            neg=avg-10.^(eiNrem.mean(n,:,eiIdx)-eiNrem.ste(n,:,eiIdx));
            errorbar(([1:2,3.5:4.5])+(n-2)*0.1,avg,neg,pos,...
                'color',pairCol(n,:),'CapSize',0,'Marker','.','MarkerSize',4,'linewidth',0.5)
         end
        set(gca,'XTick',[1:2,3.5:4.5],'XTickLabel',{'First','Last'},'XTickLabelRotation',0)
        set(gca,'YScale','log')
        title({targetReg{targetIdx},cellTypeList{eiIdx}},'fontsize',5,'fontweight','normal')
        axis tight
        xlim([0.5,5])
        ax=fixAxis;
        ylim(exp(log(ax(3:4))+diff(log(ax(3:4)))*[-1,1]/10))
        ax=fixAxis;             

        tempTick=yTickPos.nrem.(strrep(targetReg{targetIdx},' ','')){eiIdx};
        if ~isempty(tempTick)
            set(gca,'YTick',tempTick)
        end        
        
        if eiIdx==1
            ylabel('Firing rate (Hz)')
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end
        text2(1/4.5,-0.25,'Pre-cond.',ax,'horizontalAlign','center','verticalALign','top')
        text2(1/5,-0.37,'NREM',ax,'horizontalAlign','center','verticalALign','top')
        text2(4/5,-0.25,'Post-cond.',ax,'horizontalAlign','center','verticalALign','top')
        text2(4/5,-0.37,'NREM',ax,'horizontalAlign','center','verticalALign','top')
        
    end

    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
    % Freeze modulation
    xShift=2*nremFRwidth+nremFRGapX+frzModGapXinter;
    yShift=(targetIdx-1)*(frzModheigth+yGapIntraBottom)+(3*behHeight+2*yGapIntraTop)+yGapInter;

    for eiIdx=1:2
        subplotInMM(x+xShift+(frzModwidth+frzModGapXIntra)*(eiIdx-1),yTop+yShift,frzModwidth,frzModheigth)
        
        hold on
        for n=1:length(partnerName)
            errorbar((1:7)+(2-n)*0.05,eiFrzMod.mean(n,:,eiIdx),eiFrzMod.ste(n,:,eiIdx),...
                'color',pairCol(n,:),'CapSize',0,'linewidth',0.5,'Marker','.','MarkerSize',4)
        end
        title([targetReg{targetIdx} ' ' cellTypeList{eiIdx}],'fontsize',5,'fontweight','normal')
        xlim([0.5,7.5])
        ax=fixAxis;
        if eiIdx==1
            ylabel({'Freeze' 'modulation index'})
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end        
        set(gca,'xtick',1:7,'XTickLabel',sesName,'XTickLabelRotation',20)
    end
    if targetIdx==1
        pCnt=pCnt+1;
        panelLetter2(x+xShift-letGapX-6,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    end
end
end

%%

function OLD_panel_01(x,y)
% coact=poolVar('coactCompCell_LT.mat');
coact=poolVar('coactCompCell.mat');
meanFR=poolVar('meanFR.mat');
info=poolVar('okUnit.cellinfo.mat');
frz=poolVar('frzFRmod.mat');


ratList=fieldnames(coact);

tempSes=2;
sigHC=3;
%% get partners
partner={};

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    
    region=relabel_region(coact.(rat).region,'minCellNum',0);
    
    temp=cell(size(info.(rat).channel));
    
    [cIdx,rIdx]=find(coact.(rat).ica(tempSes).homecage(sigHC).nrem);
    cList=unique(cIdx)';
    for cc=cList
        temp{cc}={region{ rIdx(cIdx==cc)}};
    end
    
    partner=[partner,temp];
end

for cIdx=1:length(partner)
    if isempty(partner{cIdx})
        continue
    end
    partner{cIdx}(~ismember(partner{cIdx},{'BLA','vCA1','PrL L5'}))=[];
    partner{cIdx}=unique(partner{cIdx});
end



%% get cellinfo
cellType=[];
reg=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    cellType=[cellType;info.(rat).cellType.type'];
    reg=[reg,info.(rat).region];
end

[reg,regList]=relabel_region(reg,'minCellNum',0);
reg=reg';
% %%
% frMean=[];
% frStd=[];
%
% for ratIdx=1:length(ratList)
%     rat=ratList{ratIdx};
%
%     frMean=[frMean;fr.(rat).overall.mean'];
%     frStd=[frStd;fr.(rat).overall.std'];
% end
%%
frzMod=[]
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    frzMod=[frzMod;squeeze(frz.(rat).modIdx(:,[1,2,3:6,7]))];
        
end
%% getFR in HC
nremFR=[];

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    %homecage 2 & 3;
    slp='nrem';
    %homecage 2 & 3, sepalate in half
    nremFR=[nremFR;meanFR.(rat).Hz.(slp)([4:5,7:8],:)'];
    
end
%%
hcIdx=[1,3,5,10,12];
behList={'wake','nrem','rem'};
for behIdx=1:3
    beh=behList{behIdx};
    behFR.(beh)=[];
    for ratIdx=1:length(ratList)
        rat=ratList{ratIdx};
        
        temp=meanFR.(rat).noDiv.Hz.(beh)(hcIdx,:);
        temp(isnan(temp))=0;
        dur=meanFR.(rat).noDiv.duration.(beh)(hcIdx);
        
        behFR.(beh)=[behFR.(beh),sum(temp.*dur',1)/sum(dur)];
    end
end
%%
clf
colTemp=setCoactColor()

piCol=[colTemp.cellType.inh;
       colTemp.cellType.nc;
       colTemp.cellType.ex];

targetReg={'PrL L5','BLA','vCA1'};
behList={'wake','nrem','rem'};
cellTypeList={'excitatory cells','inhibitory cells'};

pieWidth=10;
pieHeigth=15;
pieGap=5;

nCellWidth=15;
nCellHeight=15;
nCellGapX=16;

behWidth=24;
behHeight=nCellHeight;
behGapXinter=18;
behGapXintra=5;

yGapInter=13;
yGapInterReg=16;


wTotal=pieWidth*3+pieGap*3+nCellWidth+nCellGapX+behWidth*2+behGapXinter+behGapXintra;

nremFRwidth=20;
nremFRheigth=15;
nremFRGapX=5;

frzModwidth=30;
frzModheigth=nremFRheigth;
frzModGapXIntra=5;
frzModGapXinter=wTotal-frzModwidth*2-frzModGapXIntra-nremFRwidth*2-nremFRGapX;

labelWeight=true;
labelCase=false;
labelSize=8;
letGapX=5;
letGapY=6;

pCnt=0;
sesName={'Baseline','Conditioning','Context','Cue - before tone','Cue - first 8 tones', 'Cue - last 32 tones','Retention of extinction'};

eiLeg{1}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.ex, 'Excitatory');
eiLeg{2}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.inh, 'Inhibitory');
eiLeg{3}=sprintf('\\color[rgb]{%f %f %f}%s',colTemp.cellType.nc, 'Not classified');

for n=1:2
    yTickPos.beh.PrLL5{n}=[];
    yTickPos.beh.vCA1{n}=[];
    yTickPos.beh.BLA{n}=[];

    yTickPos.nrem.PrLL5{n}=[];
    yTickPos.nrem.vCA1{n}=[];
    yTickPos.nrem.BLA{n}=[];
end

yTickPos.beh.BLA{1}=[0.5,1,2,5];
yTickPos.beh.vCA1{1}=[0.5,1,2,5];

yTickPos.nrem.vCA1{2}=[2,5,10,20];


for targetIdx=1:length(targetReg)
    yTop=y+(targetIdx-1)*(nCellHeight+yGapInter+nremFRheigth+yGapInterReg);
    yShift=0;
    xShift=0;
    target=find(strcmp(reg,targetReg{targetIdx}));
    partnerList=targetReg;
    partnerList(strcmp(partnerList,targetReg{targetIdx}))=[]
    
    eiRatio=zeros(length(partnerList)+1,3);
    eiFR.mean=zeros(length(partnerList)+1,length(behList),2);
    eiFR.ste=zeros(length(partnerList)+1,length(behList),2);
    eiNrem.mean=zeros(length(partnerList)+1,4,2);
    eiNrem.ste=zeros(length(partnerList)+1,4,2);
    eiFrzMod.mean=zeros(length(partnerList)+1,7,2);
    eiFrzMod.ste=zeros(length(partnerList)+1,7,2);
    
    partnerName={};
    partnerNameCore={};
    pairCol=[];
    for n=1:length(partnerList)+1
        if n>length(partnerList)
            id=target(cellfun(@isempty,partner(target)));
            partnerName{n}='Othres';
            partnerNameCore{n}='Othres';
            pairCol(n,:)=colTemp.region.others;
        else
            id=target(cellfun(@(x) any(strcmp(x,partnerList{n})), partner(target)));
            partnerName{n}=['Coupled with ' partnerList{n}];
            partnerNameCore{n}=partnerList{n};
            pairCol(n,:)=colTemp.pair.(strrep(strrep([targetReg{targetIdx} partnerList{n}],' ',''),'/',''));
        end
        pairLeg{n+1}=sprintf('\\color[rgb]{%f %f %f}%s',pairCol(n,:),partnerName{n});
        eiId{1}=id(cellType(id)==1);
        eiId{2}=id(cellType(id)==-1);
        
        cnt=histcounts(cellType(id),-1.5:1.5);
        eiRatio(n,:)=cnt/sum(cnt)*100;
        
        for eiIdx=1:2           
            for behIdx=1:3
                beh=behList{behIdx};
                eiFR.mean(n,behIdx,eiIdx)=nanmean(log10(behFR.(beh)(eiId{eiIdx})));
                eiFR.ste(n,behIdx,eiIdx)=nanste(log10(behFR.(beh)(eiId{eiIdx})));
            end
            val=log10(nremFR(eiId{eiIdx},:));
%             val(any(isnan(val),2),:)=[];
%             val(any(isinf(val),2),:)=[];
            val(isinf(val))=nan;
            eiNrem.mean(n,:,eiIdx)=nanmean(val,1);
            eiNrem.ste(n,:,eiIdx)=nanste(val,[],1);
            
            eiFrzMod.mean(n,:,eiIdx)=nanmean(frzMod(eiId{eiIdx},:));
            eiFrzMod.ste(n,:,eiIdx)=nanste(frzMod(eiId{eiIdx},:));

        end
    end
    regRatio=zeros(2,3);
    for eiIdx=1:2
        id=target(cellType(target)==3-eiIdx*2);
        cnt=histcounts(cellfun(@length,partner(id)),-0.5:2.5);
        regRatio(eiIdx,:)=cnt/sum(cnt)*100;
    end

    % pie chart for each partner
    for n=1:length(partnerName)
        subplotInMM(x+(pieWidth+pieGap)*(n-1),yTop+1,pieWidth,pieHeigth)
        
        temp=eiRatio(n,:);
        picolTemp=piCol;
        picolTemp(temp==0,:)=[];
        temp(temp==0)=[];
        empChar={'','',''};
        pie(temp,empChar(1:length(temp)))
        colormap(gca,picolTemp)
        if n~=length(partnerNameCore)
            title({'Coupled with',partnerNameCore{n}},'fontsize',5,'fontweight','normal')
        else
            title({partnerNameCore{n}},'fontsize',5,'fontweight','normal')
        end
        ax=fixAxis;
        if n==2
            text2(0.5,1.7,sprintf('Cells in %s',targetReg{targetIdx}),ax,'horizontalAlign','center')
        end
        if n==3
            text2(1,-0.2,join(eiLeg,'  '),ax,'horizontalAlign','right')
        end        
    end
    pCnt=pCnt+1;
    panelLetter2(x+xShift-letGapX,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)

    % # partner regions
    xShift=(pieWidth+pieGap)*3+nCellGapX;
    subplotInMM(x+xShift,yTop,nCellWidth,nCellHeight)

    bar(0:2,regRatio','linestyle','none')
    colormap(gca,piCol([3,1],:))
    box off
    xlabel('# partner region')
    ylabel({'Fraction of' 'cells (%)'})
    xlim([-0.5,2.5])
    title(targetReg{targetIdx},'fontsize',5,'fontweight','normal')
    ax=fixAxis;
    text2(0.7,1,eiLeg(1:2),ax,'verticalAlign','top')
    pCnt=pCnt+1;
    panelLetter2(x+xShift-letGapX-4,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    
    % FR for each state
    xShift=(pieWidth+pieGap)*3+nCellGapX+nCellWidth+behGapXinter;
    for eiIdx=1:2
        subplotInMM(x+xShift+(behWidth+behGapXintra)*(eiIdx-1),yTop,behWidth,behHeight)

        hold on
        for n=1:length(partnerName)
%             bar((1:3)+(n-2)*0.3,squeeze(eiFR.mean(n,:,eiIdx))',0.1,'LineStyle','none','FaceColor',pairCol(n,:))
            avg=10.^eiFR.mean(n,:,eiIdx);
            pos=10.^(eiFR.mean(n,:,eiIdx)+eiFR.ste(n,:,eiIdx))-avg;
            neg=avg-10.^(eiFR.mean(n,:,eiIdx)-eiFR.ste(n,:,eiIdx));
            errorbar((1:3)+(n-2)*0.1,avg,neg,pos,...
                'linestyle','none','color',pairCol(n,:),'CapSize',0,'Marker','.','MarkerSize',4,'linewidth',0.5)
        end
        set(gca,'YScale','log')
        set(gca,'XTick',1:3,'XTickLabel',upper(behList))
        axis tight
        xlim([0.5,3.5])
        ax=fixAxis;
        ylim(exp(log(ax(3:4))+diff(log(ax(3:4)))*[-1,1]/10))
        ax=fixAxis;

        tempTick=yTickPos.beh.(strrep(targetReg{targetIdx},' ','')){eiIdx};
        if ~isempty(tempTick)
            set(gca,'YTick',tempTick)
        end   
        
        title({targetReg{targetIdx},cellTypeList{eiIdx}},'fontsize',5,'fontweight','normal')
%         set(gca,'YTick',log10([(1:9)/100,(1:9)/10,1:9,(1:9)*10]),'YTickLabel',[(1:9)/100,(1:9)/10,1:9,(1:9)*10])
        if eiIdx==1
            ylabel('Firing rate (Hz)')
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end
    end
    pCnt=pCnt+1;
    panelLetter2(x+xShift-letGapX-2,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
    % FR within NREM
    xShift=0;
    yShift=behHeight+yGapInter;
    for eiIdx=1:2
        subplotInMM(x+xShift+(nremFRwidth+nremFRGapX)*(eiIdx-1),yTop+yShift,nremFRwidth,nremFRheigth)
        hold on
        for n=1:length(partnerName)
%             errorbar((1:4)+(2-n)*0.05,eiNrem.mean(n,:,eiIdx),eiNrem.ste(n,:,eiIdx),...
%                 'color',pairCol(n,:),'CapSize',1,'linewidth',0.5)
            avg=10.^eiNrem.mean(n,:,eiIdx);
            pos=10.^(eiNrem.mean(n,:,eiIdx)+eiNrem.ste(n,:,eiIdx))-avg;
            neg=avg-10.^(eiNrem.mean(n,:,eiIdx)-eiNrem.ste(n,:,eiIdx));
            errorbar(([1:2,3.5:4.5])+(n-2)*0.1,avg,neg,pos,...
                'color',pairCol(n,:),'CapSize',0,'Marker','.','MarkerSize',4,'linewidth',0.5)
         end
        set(gca,'XTick',[1:2,3.5:4.5],'XTickLabel',{'First','Last'},'XTickLabelRotation',0)
        set(gca,'YScale','log')
        title({targetReg{targetIdx},cellTypeList{eiIdx}},'fontsize',5,'fontweight','normal')
        axis tight
        xlim([0.5,5])
        ax=fixAxis;
        ylim(exp(log(ax(3:4))+diff(log(ax(3:4)))*[-1,1]/10))
        ax=fixAxis;             

        tempTick=yTickPos.nrem.(strrep(targetReg{targetIdx},' ','')){eiIdx};
        if ~isempty(tempTick)
            set(gca,'YTick',tempTick)
        end        
        
        if eiIdx==1
            ylabel('Firing rate (Hz)')
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end
        text2(1/4.5,-0.25,'Pre-cond.',ax,'horizontalAlign','center','verticalALign','top')
        text2(1/5,-0.37,'NREM',ax,'horizontalAlign','center','verticalALign','top')
        text2(4/5,-0.25,'Post-cond.',ax,'horizontalAlign','center','verticalALign','top')
        text2(4/5,-0.37,'NREM',ax,'horizontalAlign','center','verticalALign','top')
        
    end
    pCnt=pCnt+1;
    panelLetter2(x+xShift-letGapX,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)

    % Freeze modulation
    xShift=2*nremFRwidth+nremFRGapX+frzModGapXinter;
    yShift=behHeight+yGapInter;
    
    for eiIdx=1:2
        subplotInMM(x+xShift+(frzModwidth+frzModGapXIntra)*(eiIdx-1),yTop+yShift,frzModwidth,frzModheigth)
        
        hold on
        for n=1:length(partnerName)
            errorbar((1:7)+(2-n)*0.05,eiFrzMod.mean(n,:,eiIdx),eiFrzMod.ste(n,:,eiIdx),...
                'color',pairCol(n,:),'CapSize',0,'linewidth',0.5,'Marker','.','MarkerSize',4)
        end
        title({targetReg{targetIdx},cellTypeList{eiIdx}},'fontsize',5,'fontweight','normal')
        xlim([0.5,7.5])
        ax=fixAxis;
        if eiIdx==1
            ylabel({'Freeze' 'modulation index'})
        else
            text2(1,1,pairLeg,ax,'verticalALign','top')
        end        
        set(gca,'xtick',1:7,'XTickLabel',sesName,'XTickLabelRotation',25)
    end
    pCnt=pCnt+1;
    panelLetter2(x+xShift-letGapX-6,yTop+yShift-letGapY+2,alphabet(pCnt,labelCase),'fontSize',labelSize,'isBold',labelWeight)
end
end

function panel_06(x,y)
%%
width=17.5;
height=12;
yGap=10.5;
xGap=9;
%%
coact=poolVar('coactCompCell.mat');

info=poolVar('okUnit.cellinfo.mat');
rip=poolVar('ripFrMod.mat');
spdl=poolVar('spdlFrMod.mat');
delta=poolVar('deltaFrMod.mat');
hfo=poolVar('hfoFrMod.mat');

ratList=fieldnames(coact);


tempSes=2;
sigHC=3;

%% get partners
partner={};

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    
    region=relabel_region(coact.(rat).region,'minCellNum',0);
    
    temp=cell(size(info.(rat).channel));
    
    [cIdx,rIdx]=find(coact.(rat).ica(tempSes).homecage(sigHC).nrem);
    cList=unique(cIdx)';
    for cc=cList
        temp{cc}={region{ rIdx(cIdx==cc)}};
    end
    
    partner=[partner,temp];
    
end

%% get cellinfo
cellType=[];
reg=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    cellType=[cellType;info.(rat).cellType.type'];
    reg=[reg,info.(rat).region];
end

[reg,regList]=relabel_region(reg,'minCellNum',0);
reg=reg';

%% get param in HC

hc.nSwrPart=[];
hc.nSwrGain=[];
% hc.wSwrPart=[];
% hc.wSwrGain=[];

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    if isfield(rip,rat)
        hc.nSwrPart=[hc.nSwrPart;cat(1,rip.(rat).hcNrem(2:3).participation)'*100];
        hc.nSwrGain=[hc.nSwrGain;cat(1,rip.(rat).hcNrem(2:3).gain)'*100];
        
        %         hc.wSwrPart=[hc.wSwrPart;cat(1,rip.(rat).hcWake(2:3).participation)'*100];
        %         hc.wSwrGain=[hc.wSwrGain;cat(1,rip.(rat).hcWake(2:3).gain)'*100];
    else
        temp=nan(size(info.(rat).channel,2),2);
        hc.nSwrPart=[hc.nSwrPart;temp];
        hc.nSwrGain=[hc.nSwrGain;temp];
        %         hc.wSwrPart=[hc.wSwrPart;temp];
        %         hc.wSwrGain=[hc.wSwrGain;temp];
    end
end
%%
hc.hfoPart=[];
hc.hfoGain=[];

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    hc.hfoPart=[hc.hfoPart;cat(1,hfo.(rat).hcNrem(2:3).participation)'*100];
    hc.hfoGain=[hc.hfoGain;cat(1,hfo.(rat).hcNrem(2:3).gain)'*100];
end
%%

hc.spdlPart=[];
hc.spdlGain=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    hc.spdlPart=[hc.spdlPart;cat(1,spdl.(rat).pfc(2:3).participation)'*100];
    hc.spdlGain=[hc.spdlGain;cat(1,spdl.(rat).pfc(2:3).gain)'*100];
end

hc.preDelPart=[];
hc.preDelGain=[];
hc.postDelPart=[];
hc.postDelGain=[];
hc.delSpkPart=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    hc.delSpkPart=[hc.delSpkPart;cat(1,delta.(rat).pfc.deltaSpike(2:3).participation)'*100];
    hc.preDelPart=[hc.preDelPart;cat(1,delta.(rat).pfc.preDelta(2:3).participation)'*100];
    hc.postDelPart=[hc.postDelPart;cat(1,delta.(rat).pfc.postDelta(2:3).participation)'*100];
    hc.preDelGain=[hc.preDelGain;cat(1,delta.(rat).pfc.preDelta(2:3).gain)'*100];
    hc.postDelGain=[hc.postDelGain;cat(1,delta.(rat).pfc.postDelta(2:3).gain)'*100];
end

%%
colTemp=setCoactColor();

col=[colTemp.cellType.inh
    colTemp.cellType.nc
    colTemp.cellType.ex];
%%
CTname={'Inhibitory','Not classified','Excitatory'};

% mesList=fieldnames(hc);
% mesList={'nSwrGain','hfoGain','delSpkPart'};
mesList={'nSwrGain','hfoGain'};

mesNameList.nSwrPart={'SWR' 'participation (%)'};
mesNameList.nSwrGain={'FR modulation by SWRs (%)'};
mesNameList.wSwrPart={'Wake SWR' 'participation (%)'};
mesNameList.wSwrGain={'Wake SWR' 'gain (%)'};
mesNameList.hfoPart={'HFO' 'participation (%)'};
mesNameList.hfoGain={'FR modulation by HFOs (%)'};
mesNameList.spdlPart={'spindle' 'participation (%)'};
mesNameList.spdlGain={'spindle' 'gain (%)'};
mesNameList.delSpkPart={'Delta spike' 'participatio (%)'};
mesNameList.preDelPart={'Delta onset' 'participatio (%)'};
mesNameList.postDelPart={'Delta offset' 'participatio (%)'};
mesNameList.preDelGain={'Delta onset' 'gain (%)'};
mesNameList.postDelGain={'Delta offset' 'gain (%)'};

targetReg={'vCA1','BLA'};
partnerList={'PrL L5','BLA','vCA1'};

yRange.PrLL5.nSwrGain=[0,200];
yRange.PrLL5.hfoGain=[0,250];
yRange.PrLL5.delSpkPart=[0,4];

yRange.BLA.nSwrGain=[0,200];
yRange.BLA.hfoGain=[0,500];
yRange.BLA.delSpkPart=[0,4];

yRange.vCA1.nSwrGain=[0,700];
yRange.vCA1.hfoGain=[0,300];
yRange.vCA1.delSpkPart=[0,4];

yTick.PrLL5.nSwrGain=[];
yTick.PrLL5.hfoGain=[];
yTick.PrLL5.delSpkPart=[];

yTick.BLA.nSwrGain=[];
yTick.BLA.hfoGain=[0:200:400];
yTick.BLA.delSpkPart=[];

yTick.vCA1.nSwrGain=[0:300:600];
yTick.vCA1.hfoGain=[];
yTick.vCA1.delSpkPart=[];

cellLeg={};
for n=1:3
    cellLeg{n}=sprintf('\\color[rgb]{%f %f %f}%s',col(n,:),CTname{n})
end

for regIdx=1:length(targetReg)
    
    target=find(strcmp(reg,targetReg{regIdx}));
    %         nPat=cellfun(@length,partner(target));
    %         if max(nPat)<1
    %             continue
    %         end
    
    patList=partnerList;
    patList(strcmp(patList,targetReg{regIdx}))=[];
    cList={};
    
    for n=1:length(patList)
        cList{n}=target(cellfun(@(x) any(strcmp(patList{n},x)),partner(target)));
    end
    %         cList{end+1}=target(cellfun(@isempty,partner(target)));
    %         if isempty(patList)
    %             cName={};
    %         else
    cName=cellfun(@(x) ['' x], patList,'UniformOutput',false);
    %         end
    %         cName{end+1}='No pairs';
    
    
    for mesIdx=1:length(mesList)
        mesName=mesList{mesIdx};
        subplotInMM(x+(width+xGap)*(mesIdx-1),y+(height+yGap)*(regIdx-1),width,height)
        hold on
        for CTidx=0:1
            
            %                 set(gca,'xtick',1:length(cName),'XTickLabel',cName)
            avg=[];
            err=[];
            p=[];
            for n=1:length(cName)
                val=hc.(mesName)(cList{n},:);
                subCT=cellType(cList{n});
                subset=val(subCT==(1-2*CTidx),:);
                
                avg(n,:)=nanmean(subset,1);
                if size(subset,1)>1
                    err(n,:)=nanste(subset,[],1);
                    if any(all(~isnan(subset),2))
                        p(n)=signrank(subset(:,1),subset(:,2));
                    else
                        p(n)=nan;
                    end
                else
                    err(n,:)=[0,0];
                    p(n)=nan;
                end
            end
            hold on
            
            xVal{1}=(0:length(cName)-1)*(length(cName)+0.5)+1-0.2+CTidx;
            plot(xVal{1}+[0;0],(avg(:,1)+err(:,1).*[0,1])','Color',col(3-2*CTidx,:))
            bar(xVal{1},avg(:,1),0.1,'EdgeColor',col(3-2*CTidx,:),'facecolor',0.99*[1,1,1])
            
            xVal{2}=(0:length(cName)-1)*(length(cName)+0.5)+1+0.2+CTidx;
            plot(xVal{2}+[0;0],(avg(:,2)+err(:,2).*[0,1])','Color',col(3-2*CTidx,:))
            bar(xVal{2},avg(:,2),0.1,'EdgeColor',col(3-2*CTidx,:),'facecolor',col(3-2*CTidx,:))
            ax=fixAxis;
            for n=1:length(p)
                if p(n)<0.001
                    sig='***';
                    sigShift=0.02;
                elseif p(n)<0.01
                    sig='**';
                    sigShift=0;
                elseif p(n)<0.05
                    sig='*';
                    sigShift=0.02;
                else
                    continue
                end
                sigPosY=max((avg(n,:)+err(n,:)))+diff(yRange.(strrep(targetReg{regIdx},' ','')).(mesName))/20;
                plot((length(cName)+0.5)*(n-1)+CTidx+1+0.2*[-1,1],sigPosY+[0,0],'k-')
                text((length(cName)+0.5)*(n-1)+CTidx+1+sigShift,sigPosY,sig,'HorizontalAlignment','center','fontsize',7)
            end
            
            %                 xLeg={};
            %                 for cIdx=1:length(cName)
            %                     xLeg{cIdx}='With', cName{cIdx}};
            %                 end
            %                 set(gca,'XTick',[1:length(cName),(1:length(cName))+length(cName)+0.5],'XTickLabel',xLeg)
            
            
            %                 if mesIdx<3
            %                     title(CTname{3-2*CTidx})
            %                 end
            %                 if mesIdx>length(mesList)-2
            %                     xlabel('Coupled with')
            %                 end
        end
        
%         ylabel(mesNameList.(mesName))
        if regIdx==1
            textInMM(x+(width+xGap)*(mesIdx-1)-5,y+height+yGap/2,mesNameList.(mesName),'fontsize',5,'fontweight','normal',...
                'horizontalAlign','center','rotation',90)
        end
        set(gca,'XTick',[])
        xlim([0.5,length(cName)*2+0.5+0.5])
        ylim(yRange.(strrep(targetReg{regIdx},' ','')).(mesName))
        if ~isempty(yTick.(strrep(targetReg{regIdx},' ','')).(mesName))
            set(gca,'YTick',yTick.(strrep(targetReg{regIdx},' ','')).(mesName))
        end
        ax=fixAxis;
%         for cIdx=1:length(cName)
%             text((length(cName)+0.5)*(cIdx-1)+1+0.5,ax(3)-diff(ax(3:4))*0.01,...
%                 {'Coupled with' cName{cIdx}},'horizontalAlign','center','fontsize',5,'verticalAlign','top')
%         end
        for cIdx=1:length(cName)
            text((length(cName)+0.5)*(cIdx-1)+1+0.5,ax(3)-diff(ax(3:4))*0.075,...
                cName{cIdx},'horizontalAlign','center','fontsize',5,'verticalAlign','top')
        end
        text(mean([0.5,length(cName)*2+0.5+0.5]),ax(3)-diff(ax(3:4))*0.3,'Coupled with',...
            'horizontalAlign','center','fontsize',5,'verticalAlign','top')
        
        title(['Cells in ' targetReg{regIdx}],'fontsize',5,'fontweight','normal')

        
    end    
    subplotInMM(x+(width+xGap)*(length(mesList)-1)+width+1,y,5,height)
    xlim([0,5])
    ylim([0,height])
    text(0,height,cellLeg{3},'verticalAlign','middle','fontsize',5)
    text(0,height-2,cellLeg{1},'verticalAlign','middle','fontsize',5)
    
    rectangle('Position',[0,height-5.25,2,1],'linestyle','-','EdgeColor','k')
    text(2.5,height-4,'Pre-','verticalAlign','middle','fontsize',5)    
    text(2.5,height-5.5,'cond.','verticalAlign','middle','fontsize',5)    
    
    rectangle('Position',[0,height-8.75,2,1],'linestyle','-','EdgeColor','k','FaceColor','k')
    text(2.5,height-7.5,'Post-','verticalAlign','middle','fontsize',5)    
    text(2.5,height-9,'cond.','verticalAlign','middle','fontsize',5)   
    
    axis off
    
end

%%


end

%%
function panel_07(x,y)
width=14;
height=12;
yGap=10.5;
% xGap=13;
%%
coact=poolVar('coactCompCell.mat');
info=poolVar('okUnit.cellinfo.mat');
cue=poolVar('cueTrigSpk.mat');

ratList=fieldnames(coact);


tempSes=2;
sigHC=3;
%% get partners
partner={};

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};

        %         if any(sum(coact.(rat).(reac)(tempSes).homecage(sigHC).nrem>0,2)'>1)
        %             break
        %         end
        
        region=relabel_region(coact.(rat).region,'minCellNum',0);
        
        temp=cell(size(info.(rat).channel));
        
        [cIdx,rIdx]=find(coact.(rat).ica(tempSes).homecage(sigHC).nrem);
        cList=unique(cIdx)';
        for cc=cList
            temp{cc}={region{ rIdx(cIdx==cc)}};
        end
        
        partner=[partner,temp];
end

%% get cellinfo
cellType=[];
reg=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    cellType=[cellType;info.(rat).cellType.type'];
    reg=[reg,info.(rat).region];
end

[reg,regList]=relabel_region(reg,'minCellNum',0);
reg=reg';

%%
tBin=cue.(ratList{1}).tBin;

tWinShock=2;
tWinCue=2;

baseBin=find(tBin>-tWinCue&tBin<0);
onsetBin=find(tBin>0&tBin<tWinCue);

befShockBin=find(tBin>30-tWinShock&tBin<30);
aftShockBin=find(tBin>32&tBin<32+tWinShock);

for sesIdx=1:5
    cueFR{sesIdx}=[];
end
shockFR=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    for sesIdx=1:5
        cueFR{sesIdx}=[cueFR{sesIdx};
            [mean(cue.(rat).FR{sesIdx}(baseBin,:));mean(cue.(rat).FR{sesIdx}(onsetBin,:))]'];
    end
    shockFR=[shockFR;
        [mean(cue.(rat).FR{2}(befShockBin,:));mean(cue.(rat).FR{2}(aftShockBin,:))]'];
end


mi=@(x) diff(x,1,2)./sum(x,2);
cellRegList={'PrL L5','vCA1','BLA'};
chName={'Base','Cond','C-Tone','C-Ext','R-Ext'};

for cellRegIdx=1:length(cellRegList)
    cellReg=cellRegList{cellRegIdx};
    
    partnerRegList={};
    for partnerIdx=1:length(cellRegList)
        if ~strcmp(cellReg,cellRegList{partnerIdx})
            partnerRegList{end+1}=cellRegList{partnerIdx}
        end
    end
    
    for partnerIdx=1:2
        partnerReg=partnerRegList{partnerIdx};
        cIdx=find(strcmp(reg,cellReg)&cellfun(@(x) any(strcmp(x,partnerReg)),partner)');
        nonPartnerReg=partnerRegList(~ismember(partnerRegList,partnerReg));
% %         cIdx=find(strcmp(reg,cellReg)&cellfun(@(x) any(strcmp(x,partnerReg)),partner)' ...
%             &(~cellfun(@(x) isempty(x)|| any(ismember(x,nonPartnerReg)),partner)') );
        
        for sesIdx=1:6
            if sesIdx==6
                ciSub(cellRegIdx,sesIdx).ci{partnerIdx}=(mi(shockFR(cIdx,:)));
                ciSub(cellRegIdx,sesIdx).trigName='Shock';
            else
                ciSub(cellRegIdx,sesIdx).ci{partnerIdx}=(mi(cueFR{sesIdx}(cIdx,:)));
                ciSub(cellRegIdx,sesIdx).trigName=['Cue onset in ' chName{sesIdx}];
            end
            ciSub(cellRegIdx,sesIdx).cellReg=cellReg;
            ciSub(cellRegIdx,sesIdx).partner{partnerIdx}=partnerReg;
            ciSub(cellRegIdx,sesIdx).cType{partnerIdx}=cellType(cIdx);
        end
    end
end

%%
colTemp=setCoactColor();

col=[
    colTemp.cellType.ex
    colTemp.cellType.inh
    ];
CTname={'Excitatory','Inhibitory'};
cellLeg={};
for n=1:2
    cellLeg{n}=sprintf('\\color[rgb]{%f %f %f}%s',col(n,:),CTname{n})
end

ylimList=[-0.6,0.5;
          -1,0.5;
         0,0.4];

% for regIdx=1:3
%     for sesIdx=1:6
%         subplot2(4,6,regIdx,sesIdx)
for regIdx=2:3;
sesIdx=6;
subplotInMM(x,y+(height+yGap)*(regIdx-2),width,height)
        hold on
        for cType=1:2
            data={};
            for patIdx=1:2
                data{patIdx}=ciSub(regIdx,sesIdx).ci{patIdx}(ciSub(regIdx,sesIdx).cType{patIdx}==3-2*cType);
            end
            avg=cellfun(@nanmean,data);
            err=cellfun(@nanste,data);
            
            for n=1:length(data)
                if isempty(data{n})
                    pZero(n)=1;
                else
                    pZero(n)=signrank(data{n});
                end
            end
%             pZero=cellfun(@signrank,data);
            
            if all(cellfun(@(x) sum(~isnan(x)),data)>0)
                p=ranksum(data{:});
            else
                p=1;
            end
            
            xVal=(1:2)+(cType-1)*3;
            
            bar(xVal,avg,'LineStyle','none','FaceColor',col(cType,:))
            errBar=avg+(2*(avg>0)-1).*[0,0;err];
            
            for patIdx=1:2
                plot(xVal(patIdx)+[0,0],errBar(:,patIdx),'-','color',col(cType,:))
%                 
%                 if pZero(patIdx)<0.001
%                     sigTxt='***'
%                 elseif pZero(patIdx)<0.01
%                     sigTxt='**';
%                 elseif pZero(patIdx)<0.05
%                     sigTxt='*';
%                 else
%                     sigTxt='';
%                 end
%                 if ~isempty(sigTxt)
%                     text(x(patIdx),errBar(2,patIdx)-0.06*(errBar(2,patIdx)<0),sigTxt,'HorizontalAlignment','center','FontSize',12,'VerticalAlignment','middle')
%                 end
            end
            ylim(ylimList(regIdx,:))
            
            
            if p<0.001
                sigTxt='***';
            elseif p<0.01
                sigTxt='**';
            elseif p<0.05
                sigTxt='*';
            else
                sigTxt='';
            end
            if ~isempty(sigTxt)
                
                plot(xVal,max([0;errBar(:)])+diff(ylimList(regIdx,:))/20+[0,0],'k-')
                text(mean(xVal)+0.0375,max([0;errBar(:)])+diff(ylimList(regIdx,:))/20,sigTxt,'HorizontalAlignment','center','FontSize',6)
            end
            
        end
        xlim([0,6])
        ax=fixAxis;
%         title(ciSub(regIdx,sesIdx).trigName)
%         xTxt={};
%         for n=1:length(ciSub(regIdx,sesIdx).partner)
%           xTxt{n}=['Coupled with ' ciSub(regIdx,sesIdx).partner{n}];
%         end
%         set(gca,'XTick',[1,2,4,5],'XTickLabel',xTxt,'XTickLabelRotation',30)
%         set(gca,'XTick',[1,2,4,5],'XTickLabel',ciSub(regIdx,sesIdx).partner,'XTickLabelRotation',35)
        xTickPos=[1,2,4,5];
        set(gca,'XTick',xTickPos,'XTickLabel',[])
        for n=1:length(xTickPos)
            text(xTickPos(n),ax(3)-diff(ax(3:4))*0.025,ciSub(regIdx,sesIdx).partner{mod(n-1,2)+1},...
                'verticalAlign','top','horizontalAlign','right','rotation',40,'fontsize',5)
        end
%         ylabel({'Shock' 'modulation index'})
        text2(0.5,-0.4,'Coupled with',ax,'verticalAlign','top','horizontalAlign','center','fontsize',5)
        if regIdx==2
            text2(1.05,1,cellLeg,ax,'verticalAlign','top','fontsize',5)
            textInMM(x-6,y+height+yGap/2,'Shock modulation index','fontsize',5,'fontweight','normal',...
                'horizontalAlign','center','rotation',90)
        end
        title(['Cells in ' ciSub(regIdx,sesIdx).cellReg],'fontsize',5,'fontweight','normal')
%         ylabel(['MI of ' ciSub(regIdx,sesIdx).cellReg ' cells'])

    end
% end


end
%%
function panel_08(x,y)
width=14;
height=12;
yGap=10.5;
xGap=10;
%%
coact=poolVar('coactCompCell.mat');
info=poolVar('okUnit.cellinfo.mat');
cue=poolVar('cueTrigSpk.mat');

ratList=fieldnames(coact);


tempSes=2;
sigHC=3;
%% get partners
partner={};

for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};

        %         if any(sum(coact.(rat).(reac)(tempSes).homecage(sigHC).nrem>0,2)'>1)
        %             break
        %         end
        
        region=relabel_region(coact.(rat).region,'minCellNum',0);
        
        temp=cell(size(info.(rat).channel));
        
        [cIdx,rIdx]=find(coact.(rat).ica(tempSes).homecage(sigHC).nrem);
        cList=unique(cIdx)';
        for cc=cList
            temp{cc}={region{ rIdx(cIdx==cc)}};
        end
        
        partner=[partner,temp];
end

%% get cellinfo
cellType=[];
reg=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    
    cellType=[cellType;info.(rat).cellType.type'];
    reg=[reg,info.(rat).region];
end

[reg,regList]=relabel_region(reg,'minCellNum',0);
reg=reg';

%%
tBin=cue.(ratList{1}).tBin;

tWinShock=2;
tWinCue=2;

baseBin=find(tBin>-tWinCue&tBin<0);
onsetBin=find(tBin>0&tBin<tWinCue);

befShockBin=find(tBin>30-tWinShock&tBin<30);
aftShockBin=find(tBin>32&tBin<32+tWinShock);

for sesIdx=1:5
    cueFR{sesIdx}=[];
end
shockFR=[];
for ratIdx=1:length(ratList)
    rat=ratList{ratIdx};
    for sesIdx=1:5
        cueFR{sesIdx}=[cueFR{sesIdx};
            [mean(cue.(rat).FR{sesIdx}(baseBin,:));mean(cue.(rat).FR{sesIdx}(onsetBin,:))]'];
    end
    shockFR=[shockFR;
        [mean(cue.(rat).FR{2}(befShockBin,:));mean(cue.(rat).FR{2}(aftShockBin,:))]'];
end


mi=@(x) diff(x,1,2)./sum(x,2);
cellRegList={'PrL L5','vCA1','BLA'};
chName={'baseline','conditioning','cue retention','C-Ext','R-Ext'};

for cellRegIdx=1:length(cellRegList)
    cellReg=cellRegList{cellRegIdx};
    
    partnerRegList={};
    for partnerIdx=1:length(cellRegList)
        if ~strcmp(cellReg,cellRegList{partnerIdx})
            partnerRegList{end+1}=cellRegList{partnerIdx}
        end
    end
    
    for partnerIdx=1:2
        partnerReg=partnerRegList{partnerIdx};
        cIdx=find(strcmp(reg,cellReg)&cellfun(@(x) any(strcmp(x,partnerReg)),partner)');
        nonPartnerReg=partnerRegList(~ismember(partnerRegList,partnerReg));
% %         cIdx=find(strcmp(reg,cellReg)&cellfun(@(x) any(strcmp(x,partnerReg)),partner)' ...
%             &(~cellfun(@(x) isempty(x)|| any(ismember(x,nonPartnerReg)),partner)') );
        
        for sesIdx=1:6
            if sesIdx==6
                ciSub(cellRegIdx,sesIdx).ci{partnerIdx}=(mi(shockFR(cIdx,:)));
                ciSub(cellRegIdx,sesIdx).trigName='Shock';
            else
                ciSub(cellRegIdx,sesIdx).ci{partnerIdx}=(mi(cueFR{sesIdx}(cIdx,:)));
                ciSub(cellRegIdx,sesIdx).trigName=['Cue onset in ' chName{sesIdx}];
            end
            ciSub(cellRegIdx,sesIdx).cellReg=cellReg;
            ciSub(cellRegIdx,sesIdx).partner{partnerIdx}=partnerReg;
            ciSub(cellRegIdx,sesIdx).cType{partnerIdx}=cellType(cIdx);
        end
    end
end

%%
colTemp=setCoactColor();

col=[
    colTemp.cellType.ex
    colTemp.cellType.inh
    ];
CTname={'Excitatory','Inhibitory'};
cellLeg={};
for n=1:2
    cellLeg{n}=sprintf('\\color[rgb]{%f %f %f}%s',col(n,:),CTname{n})
end

ylimList=[-0.3,0.5;
          -0.2,0.5;
          -0.5,0.4];

% for regIdx=1:3
%     for sesIdx=1:6
%         subplot2(4,6,regIdx,sesIdx)
rowOrder=[3,1,2];
for regIdx=1:3;
for sesIdx=1:3;
subplotInMM(x+(width+xGap)*(sesIdx-1),y+(height+yGap)*(rowOrder(regIdx)-1),width,height)
        hold on
        for cType=1:2
            data={};
            for patIdx=1:2
                data{patIdx}=ciSub(regIdx,sesIdx).ci{patIdx}(ciSub(regIdx,sesIdx).cType{patIdx}==3-2*cType);
            end
            avg=cellfun(@nanmean,data);
            err=cellfun(@nanste,data);
            
            for n=1:length(data)
                if isempty(data{n})
                    pZero(n)=1;
                else
                    pZero(n)=signrank(data{n});
                end
            end
%             pZero=cellfun(@signrank,data);
            
            if all(cellfun(@(x) sum(~isnan(x)),data)>0)
                p=ranksum(data{:});
            else
                p=1;
            end
            
            xVal=(1:2)+(cType-1)*3;
            
            bar(xVal,avg,'LineStyle','none','FaceColor',col(cType,:))
            errBar=avg+(2*(avg>0)-1).*[0,0;err];
            
            for patIdx=1:2
                plot(xVal(patIdx)+[0,0],errBar(:,patIdx),'-','color',col(cType,:))
%                 
%                 if pZero(patIdx)<0.001
%                     sigTxt='***'
%                 elseif pZero(patIdx)<0.01
%                     sigTxt='**';
%                 elseif pZero(patIdx)<0.05
%                     sigTxt='*';
%                 else
%                     sigTxt='';
%                 end
%                 if ~isempty(sigTxt)
%                     text(x(patIdx),errBar(2,patIdx)-0.06*(errBar(2,patIdx)<0),sigTxt,'HorizontalAlignment','center','FontSize',12,'VerticalAlignment','middle')
%                 end
            end
            ylim(ylimList(regIdx,:))
            
            
            if p<0.001
                sigTxt='***';
            elseif p<0.01
                sigTxt='**';
            elseif p<0.05
                sigTxt='*';
            else
                sigTxt='';
            end
            if ~isempty(sigTxt)
                
                plot(xVal,max([0;errBar(:)])+diff(ylimList(regIdx,:))/20+[0,0],'k-')
                text(mean(xVal),max([0;errBar(:)])+diff(ylimList(regIdx,:))/20,sigTxt,'HorizontalAlignment','center','FontSize',7)
            end
            
        end
        xlim([0,6])
        ax=fixAxis;
%         title(ciSub(regIdx,sesIdx).trigName)
%         xTxt={};
%         for n=1:length(ciSub(regIdx,sesIdx).partner)
%           xTxt{n}=['Coupled with ' ciSub(regIdx,sesIdx).partner{n}];
%         end
%         set(gca,'XTick',[1,2,4,5],'XTickLabel',xTxt,'XTickLabelRotation',30)
%         set(gca,'XTick',[1,2,4,5],'XTickLabel',ciSub(regIdx,sesIdx).partner,'XTickLabelRotation',35)
        xTickPos=[1,2,4,5];
        set(gca,'XTick',xTickPos,'XTickLabel',[])
        for n=1:length(xTickPos)
            text(xTickPos(n),ax(3)-diff(ax(3:4))*0.025,ciSub(regIdx,sesIdx).partner{mod(n-1,2)+1},...
                'verticalAlign','top','horizontalAlign','right','rotation',40,'fontsize',5)
        end
        if  rowOrder(regIdx)==2
            ylabel(sprintf('Cue modulation index in %s session',chName{sesIdx}))
        end
        text2(0.5,-0.4,'Coupled with',ax,'verticalAlign','top','horizontalAlign','center','fontsize',5)
        if rowOrder(regIdx)==1&sesIdx==3
            text2(1,1,cellLeg,ax,'verticalAlign','top','fontsize',5)
        end
        title(['Cells in ' ciSub(regIdx,sesIdx).cellReg],'fontsize',5,'fontweight','normal')
%         ylabel(['MI of ' ciSub(regIdx,sesIdx).cellReg ' cells'])

    end
end


end

%%
function [sigPos,sigTxt]=findSig(pVal,pos)
    [sortedPos,posIdx]=sort(pos);
    posIdx(posIdx)=1:length(posIdx)
    
    sigPos=[];
    sigTxt={};
    tempPos=-1;
    sCnt=0;
    for n=1:3
        switch n
            case 1
                n=find(posIdx==1);
                m=find(posIdx==2);
            case 2
                n=find(posIdx==2);
                m=find(posIdx==3);
            case 3        
                n=find(posIdx==1);
                m=find(posIdx==3);
                if length(sigTxt)>0
                    tempPos=tempPos+2;
                end
        end
        idx=find((pVal(:,1)==n & pVal(:,2)==m) |  (pVal(:,1)==m & pVal(:,2)==n))
        if (pVal(idx,3)<0.05);
            sCnt=sCnt+1;
            sigPos(sCnt,:)=[tempPos,tempPos,pos(pVal(idx,1:2))'];
            sigTxt{sCnt}=getSigTxt(pVal(idx,3));
        end
    end    
end

function sigTxt=getSigTxt(p)
    if p<0.001
        sigTxt='***';
    elseif p<0.01
        sigTxt='**';
    elseif p<0.05
        sigTxt='*';
    else 
        sigTxt='';
    end
end

function [sigPos,sigTxt]=findSigPos(pVal)
    [~,order]=sort(diff(pVal(:,1:2),1,2));
    empty=true(1,max(max(pVal(:,1:2))));
    sCnt=0;
    sigPos=[];
    for n=order'
        if pVal(n,3)>=0.05
            continue
        end
         sCnt=sCnt+1;
         level=1;
         
         while ~all(empty(level,min(pVal(n,1:2)):max(pVal(n,1:2))))
             level=level+1;
             if size(empty,1)<level
                 empty(level,:)=true(1,max(max(pVal(:,1:2))));
                 break
             end
         end
         empty(level,min(pVal(n,1:2)):max(pVal(n,1:2)))=false;
         sigPos(sCnt,:)=[pVal(n,1:2),level*[1,1]];
         sigTxt{sCnt}=getSigTxt(pVal(n,3));
    end
end




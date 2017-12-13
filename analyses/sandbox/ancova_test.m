clear
baseDir='~/data/sleep/pooled_withCohEMG/';
coreName='sleep';

load([baseDir coreName '-' 'timeNorm_stateChange_fineBins' '.mat'])
load([baseDir coreName '-' 'timeNormFR' '.mat'])
load([baseDir coreName '-' 'stateChange20s' '.mat'])
% %%
% dList=fieldnames(timeNormFR);
% 
% quantile=[];
% frREM=[];
% frNREM=[];
% nDiv=5;
% for dIdx=1:length(dList)
%     dName=dList{dIdx};
%     
%     target=stateChange.(dName).rem2nrem;
%     
%     for idx=1:size(target,1)
%         quantile=[quantile;ceil(tiedrank(mean(timeNormFR.(dName).offset.pyr{target(idx,1)}(:,9:10),2))...
%             /size(timeNormFR.(dName).offset.pyr{target(idx,1)},1)*nDiv)];
%         frREM=[frREM;timeNormFR.(dName).offset.pyr{target(idx,1)}(:,end)];
%         frNREM=[frNREM;timeNormFR.(dName).onset.pyr{target(idx,2)}(:,1)];
%     end
% end
% 
% %%
% % close all 
% % hold on
% % for idx=1:5
% %     plot(log10(frREM(quantile==idx)),log10(frNREM(quantile==idx))-log10(frREM(quantile==idx)),'.')
% % end
% 
% % [h,atab,ctab,stats] =aoctool(log10(frREM(frNREM>0&frREM>0)),log10(frNREM(frNREM>0&frREM>0))-log10(frREM(frNREM>0&frREM>0)),quantile(frNREM>0&frREM>0));
% 
% 
% [h,atab,ctab,stats]=aoctool(log10(frREM(frNREM>0&frREM>0)),...
%                             log10(frNREM(frNREM>0&frREM>0))-log10(frREM(frNREM>0&frREM>0)),...
%                             quantile(frNREM>0&frREM>0),[],'FR','\deltaFR','quintile','off','parallel lines');
% 
% multcompare(stats)                        
%                         
% %%
% close all
% fh=initFig4Nature(2);
% 
% for typeIdx=1:2
%     if typeIdx==1
%         xlabelText='FR_{REM offset}';
%         ylabelText='FR_{NREM onset} - FR_{REM offset}';
%         xUnit='(log_{10}Hz)';
%         yUnit='(log_{10}Hz)';
%         titleText='Ordered by last fifth of REM';
%         xVal=log10(frREM);
%         yVal=log10(frNREM)-log10(frREM);
%     elseif typeIdx==2
%         xlabelText='FR_{REM offset}';
%         ylabelText='FR_{NREM onset}';
%         xUnit='(log_{10}Hz)';
%         yUnit='(log_{10}Hz)';
%         titleText='Ordered by last fifth of REM';
%         xVal=log10(frREM);
%         yVal=log10(frNREM);
%     else
%         continue
%     end
%     
%     okIdx=~isinf(xVal) & ~isinf(yVal) & ~isnan(xVal) & ~ isnan(yVal);
%     xVal=xVal(okIdx);
%     yVal=yVal(okIdx);
%     qVal=quantile(okIdx);
%     
%     [h,atab,ctab,stats] =aoctool(xVal,yVal,qVal,...
%         0.05,xlabelText,ylabelText,'Quintile','off');
% 
% subplot(4,2,2*typeIdx-1)
% hold on 
% col=jet(nDiv);
% for idx=1:nDiv
%     plot(xVal(qVal==idx),yVal(qVal==idx),'.','color',col(idx,:),'markersize',1)
% end
% ax=fixAxis;
% lTxt={};
% for idx=1:nDiv
%     temp=ctab{2,2}+ctab{idx+2,2}+(ctab{3+nDiv,2}+ctab{idx+3+nDiv,2}).*ax(1:2);
%     plot(ax(1:2),temp,'-','color',col(idx,:))
%     lTxt{idx}=num2str(idx);
% end
% legend(lTxt,'location','northeastOutside')
% xlabel([xlabelText ' ' xUnit])
% ylabel([ylabelText ' ' yUnit])
% title(titleText)
% 
% ctab{1,1}='Term';
% ctab{1,2}='Estimate';
% ctab{1,3}='Std. Err.';
% ctab{1,4}='T';
% ctab{1,5}='Prob>|T|';
% ctab{2,1}='Intercept';
% ctab{3+nDiv,1}='Slope';
% 
% atab{1,1}='Source';
% atab{1,2}='d.f.';
% atab{1,3}='Sum Sq';
% atab{1,4}='Mean Sq';
% atab{1,5}='F';
% atab{1,6}='Prob>F';
% 
% % atab{2,1}='Gr';
% % atab{3,1}='X';
% % atab{4,1}='Gr * X';
% atab{5,1}='Error';
% 
% subplot(4,3,(2:3)+(typeIdx-1)*3)
% xlim([0,1])
% ylim([0,3])
% axis off
% for n=1:size(ctab,1)
%     for m=1:size(ctab,2)
%         if n==1 || (n==2&&m==1) || (n==7&&m==1)
%             ch=ctab{n,m};
%         else
%             ch=num2str(ctab{n,m});
%         end
%         text(m/6,3-n/6,ch)
%     end
% end
% 
% 
% for n=1:size(atab,1)
%     for m=1:size(atab,2)
%         if n==1 || (n==2&&m==1) || (n==7&&m==1)
%             ch=atab{n,m};
%         else
%             ch=num2str(atab{n,m});
%         end
%         text(m/6,3-(n+size(ctab,1)+1)/6,ch)
%     end
% end
% end
% addScriptName(mfilename)
% 
% print(fh,'~/Dropbox/Quantile/preliminary/ancova-rem2nrem.pdf','-dpdf','-painters')

%%
%%
dList=fieldnames(timeNormFR);

nDiv=5;

close all
fh=initFig4Nature(2);

for typeIdx=1:5
    if typeIdx==1
        
        xlabelText='FR_{REM offset}';
        ylabelText='FR_{NREM onset}';
        xUnit='(log_{10}Hz)';
        yUnit='(log_{10}Hz)';
        titleText='Ordered by last fifth of REM';
        targetName='rem2nrem';
        
    elseif typeIdx==2
        xlabelText='FR_{NREM offset}';
        ylabelText='FR_{REM onset}';
        xUnit='(log_{10}Hz)';
        yUnit='(log_{10}Hz)';
        titleText='Ordered by last fifth of NREM';
        targetName='nrem2rem';
        
    elseif typeIdx==3
        xlabelText='FR_{Wake offset}';
        ylabelText='FR_{NREM onset}';
        xUnit='(log_{10}Hz)';
        yUnit='(log_{10}Hz)';
        titleText='Ordered by last 12s of Wake';
        targetName='quiet2nrem';

    elseif typeIdx==4
        xlabelText='FR_{NREM offset}';
        ylabelText='FR_{wake onset}';
        xUnit='(log_{10}Hz)';
        yUnit='(log_{10}Hz)';
        titleText='Ordered by last fifth of NREM';
        targetName='nrem2quiet';
        
    elseif typeIdx==5
        xlabelText='FR_{REM offset}';
        ylabelText='FR_{wake onset}';
        xUnit='(log_{10}Hz)';
        yUnit='(log_{10}Hz)';
        titleText='Ordered by last fifth of REM';
        targetName='rem2quiet';
    else
        continue
    end
    
    xVal=[];
    yVal=[];
    qVal=[];
    for dIdx=1:length(dList)
        dName=dList{dIdx};

        target=stateChange.(dName).(targetName);
        for idx=1:size(target,1)
            if isempty(timeNormFR.(dName).offset.pyr{target(idx,1)}) ||...
                isempty(timeNormFR.(dName).onset.pyr{target(idx,2)})
                continue
            end
            
            orderIdx=size(timeNormFR.(dName).offset.pyr{target(idx,1)},2);
            orderIdx=(-ceil(orderIdx/5):1:-1)+1+orderIdx;
            qVal=[qVal;ceil(tiedrank(mean(timeNormFR.(dName).offset.pyr{target(idx,1)}(:,orderIdx),2))...
                /size(timeNormFR.(dName).offset.pyr{target(idx,1)},1)*nDiv)];
            xVal=[xVal;timeNormFR.(dName).offset.pyr{target(idx,1)}(:,end)];
            yVal=[yVal;timeNormFR.(dName).onset.pyr{target(idx,2)}(:,1)];
        end
    end
    
    okIdx=xVal>0 & yVal>0;
    xVal=log10(xVal(okIdx));
    yVal=log10(yVal(okIdx));
    qVal=qVal(okIdx);
    
    yVal=yVal-xVal;
    ylabelText=[xlabelText '-' ylabelText];
    
    [h,atab,ctab,stats] =aoctool(xVal,yVal,qVal,...
        0.05,xlabelText,ylabelText,'Quintile','off','parallel lines');
    c=multcompare(stats,'estimate','intercept','display','off');
    sigPair=c(c(:,end)<0.05,[1,2,end]);

    subplot(5,4,4*(typeIdx-1)+1)
    hold on 
    col=jet(nDiv);
    for idx=1:nDiv
        plot(xVal(qVal==idx),yVal(qVal==idx),'.','color',col(idx,:),'markersize',1)
    end
    ax=fixAxis;
    lTxt={};
    for idx=1:nDiv
%         temp=ctab{2,2}+ctab{idx+2,2}+(ctab{3+nDiv,2}+ctab{idx+3+nDiv,2}).*ax(1:2);
        temp=ctab{2,2}+ctab{idx+2,2}+(ctab{3+nDiv,2}).*ax(1:2);
        plot(ax(1:2),temp,'-','color',col(idx,:))
        lTxt{idx}=num2str(idx);
    end
%     plotIdentityLine(gca,{'color','k'})
    plot(ax(1:2),[0,0],'k-')
    
    xlabel([xlabelText ' ' xUnit])
    ylabel([ylabelText ' ' yUnit])
    title(titleText)

    subplot(5,4,4*(typeIdx-1)+2)
    hold on
    avg=[];
    err=[];
    for idx=1:nDiv
        avg(idx)=0*ctab{2,2}+ctab{idx+2,2};
        err(idx)=0*ctab{2,3}+ctab{idx+2,3};
        plot(idx*[1,1],0*ctab{2,2}+ctab{idx+2,2}+(0*ctab{2,3}+ctab{idx+2,3})*[-1,1],'color',col(idx,:));
        bar(idx,0*ctab{2,2}+ctab{idx+2,2},'facecolor',col(idx,:),'linestyle','none')
    end
    
    range=[avg+err,avg-err];
    [~,idx]=max(abs(range));
    posOrig=range(idx);
    ax=axis;    
    step=diff(ax(3:4))/(1-0.05*(size(sigPair,1)+1))*0.05;
    if posOrig>=0;
        ylim([ax(3),ax(4)+step*(size(sigPair,1)+1)]);
    else
        step=-step;
        ylim([ax(3)+step*(size(sigPair,1)+1),ax(4)]);
    end
    
    [sigPos,p]=significanceBarPosition(sigPair(:,1:2));
    p=sigPair(p',end);
    
    for idx=1:size(sigPair,1)
        plot(sigPos(idx,1:2)+0.1*[1,-1],posOrig+step*idx*[1,1],'k-')
        text(mean(sigPos(idx,1:2)),posOrig+step*idx,getSigText(p(idx)),'horizontalALign','center','verticalAlign','middle')
    end
    
    
    ylabel('Intercept')
    
    

%     ctab{1,1}='Term';
%     ctab{1,2}='Estimate';
%     ctab{1,3}='Std. Err.';
%     ctab{1,4}='T';
%     ctab{1,5}='Prob>|T|';
%     ctab{2,1}='Intercept';
%     ctab{3+nDiv,1}='Slope';
% 
%     atab{1,1}='Source';
%     atab{1,2}='d.f.';
%     atab{1,3}='Sum Sq';
%     atab{1,4}='Mean Sq';
%     atab{1,5}='F';
%     atab{1,6}='Prob>F';

    % atab{2,1}='Gr';
    % atab{3,1}='X';
    % atab{4,1}='Gr * X';
%     atab{5,1}='Error';

    subplot(5,4,(3:4)+(typeIdx-1)*4)
    xlim([0,1])
    ylim([0,3])
    axis off
    for n=1:size(ctab,1)
        for m=1:size(ctab,2)
            if n==1 || (n==2&&m==1) || (n==7&&m==1)
                ch=ctab{n,m};
            else
                ch=num2str(ctab{n,m});
            end
            text((m-1)/6,3-n/6,ch,'fontsize',4)
        end
    end


    for n=1:size(atab,1)
        for m=1:size(atab,2)
            if n==1 || (n==2&&m==1) || (n==7&&m==1)
                ch=atab{n,m};
            else
                ch=num2str(atab{n,m});
            end
            text((m-1)/6,3-(n+size(ctab,1)+1)/6,ch,'fontsize',4)
        end
    end
end
addScriptName(mfilename)

print(fh,'~/Dropbox/Quantile/preliminary/ancova-transitions.pdf','-dpdf','-painters')


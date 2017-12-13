nCell=100;
nTrans=10;
nDiv=5;
sdNoise=0.3;
nIte=2000;

meanFR=1;
sdFR=3;
ci=@(x) diff(x,1,2)./sum(x,2);
trueFR=lognrnd2(meanFR,sdFR,nCell,1,1);
trueFR=repmat(trueFR,1,2,nTrans);

clear sh re
for fType=1:2
    fr=trueFR.*abs(normrnd(1,sdNoise,nCell,2,nTrans));
    
    if fType==1
        tText='No change';
    else
        fr=fr.*[ones(nCell,1,nTrans),normrnd(1.2,0.2,nCell,1,nTrans)];
        tText='Multiplicative increase (x 1.2 +/- 0.2)';        
    end

    %%
    for ite=1:nIte+1
        for sType=1:2
            for r=1:nDiv
                c{r}=[];
            end
            for t=1:nTrans
                if ite==1
                    temp=fr(:,:,t);
                else
                    if sType==1
                        temp=fr(:,:,t);
                    else
                        t2=randperm(nTrans-1,1);
                        if t2>=t; t2=t2+1; end

                        temp=[fr(:,1,t),fr(:,1,t2)];
                    end
                    idx=randi(2,nCell,1)-1;
                    idx=[idx,1-idx];
                    idx=idx*nCell+(1:nCell)';

                    temp=temp(idx);
                end
                q=ceil(tiedrank(temp(:,1))/nCell*nDiv);
                for r=1:nDiv
                    c{r}=[c{r};ci(temp(q==r,:))];
                end
            end
            if ite==1
                re{fType}=cellfun(@mean, c);
            else
                sh{fType}(ite-1,:,sType)=cellfun(@mean, c);
            end
        end
    end

    sh{fType}(:,:,1)=sort(sh{fType}(:,:,1));
    sh{fType}(:,:,2)=sort(sh{fType}(:,:,2));
end
%%
close all
fh=initFig4Nature(2);
for fType=1:2
    
    if fType==1
        tText='No change';
    else
        tText='Multiplicative increase (x 1.2 +/- 0.2)';        
    end
    
    subplot2(6,4,1,fType)
    plot(reshape(fr(:,1,:),1,[]),reshape(fr(:,2,:),1,[]),'k.','markersize',1)
    set(gca,'xscale','log','YScale','log')
    ax=fixAxis
    box off
    plotIdentityLine(gca,{'color','k'})
    xlabel('FR_1 (Hz)')
    ylabel('FR_2 (Hz)')
    title(tText)


    subplot2(6,4,2,fType)
    hold on
    bar(1:nDiv,re{fType},'k')
    col=[1,0,0;0,1,0]
    for n=1:2
        fill([1:nDiv,nDiv:-1:1],[sh{fType}(ceil(nIte*0.975),:,n),flip(sh{fType}(ceil(nIte*0.025),:,n))],col(n,:),'facealpha',0.5,'edgecolor','none')
    end
    box off
    ylabel('CI')
    xlim([0.5,nDiv+0.5])
end


ax=fixAxis;
text2(1.2,1,{sprintf('%d cells in %d transitions',nCell,nTrans)
            sprintf('True FR is in log-normal (mean =%0.2f,sd=%0.2f)',meanFR,sdFR)
            sprintf('multiplicative noise (sd=%0.2f)',sdNoise)
            sprintf('shuffling %d times, ordered based on first bin',nIte)})


    
    
    
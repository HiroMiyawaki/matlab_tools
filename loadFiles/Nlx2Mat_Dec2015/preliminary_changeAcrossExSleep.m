clear
baseDir='~/data/sleep/pooled/';
coreName='sleep';

varList={'basics'
    'behavior'
    ...'ripple'
    ...'spindle'
    ...'hpcSpindlePhase'
    ...'ctxSpindlePhase'
    ...'HLfine'
    ...'onOff'
    ...'hpcSWA'
    ...'pfcSWA'
    ...'recStart'
    ...'position'
    ...'speed'
    ...'spectrum'
    ...'spikes'
    ...'pairCorr'
    ...'modulatedCell'
    ...thetaPhase'
    ...'pfcEeg'
    ...'emg'
    'firing'
    ...'eventRate'
    ...'eventFiring'
    'stableSleep'
    'stableWake'
    'stateChange'
    ...'trisecFiring'
    ...'trisecEvent'
    ...'binnedFiring'
    ...'thetaBand'
    ...'sleepPeriod'
    ...'recStart'
    ...'deltaBand'
    ...'thetaBand'
    }';

for varName=varList
    load([baseDir coreName '-' varName{1} '.mat'])
end
dList=fieldnames(basics);

%%
behList=behavior.(dList{1}).name;
cycList={'light','dark'};

for cycIdx=1:2;
    cycName=cycList{cycIdx};
    for behIdx=1:length(behList)
        behName=behList{behIdx};
        
        each.(behName).(cycName).t=[];
        each.(behName).(cycName).z=[];
        avg.(behName).(cycName).t=[];
        avg.(behName).(cycName).z=[];
    end
end


for dIdx=1:length(dList)
    dName=dList{dIdx};
    if ~isempty(strfind(dName,'Sleep'))
        cycName=cycList{1};
    else
        cycName=cycList{2};
    end
    
    for behIdx=1:length(behList)
        behName=behList{behIdx};
        if ~isempty(strfind(behName,'rem'))
            stable=stableSleep.(dName);
        else
            stable=stableWake.(dName);
        end
        
        for sIdx=1:size(stable.time,1)
            evtList=stable.(behName){sIdx};
            
            if isempty(evtList)
                continue
            end
            if length(evtList)<2
                continue
            end
%             
            tempZ=cat(1,firing.(dName).pyr.zscore{evtList});
            tempZ=tempZ-repmat(tempZ(1,:),length(evtList),1);
            
            tempT=repmat(mean(behavior.(dName).list(evtList,1:2),2)-stable.time(sIdx,1),1,size(tempZ,2))/60e6;
            
            each.(behName).(cycName).t=[each.(behName).(cycName).t;reshape(tempT(2:end,:),[],1)];
            each.(behName).(cycName).z=[each.(behName).(cycName).z;reshape(tempZ(2:end,:),[],1)];
            avg.(behName).(cycName).t=[avg.(behName).(cycName).t;mean(tempT(2:end,:),2)];
            avg.(behName).(cycName).z=[avg.(behName).(cycName).z;mean(tempZ(2:end,:),2)];
%             each.(behName).(cycName).t=[each.(behName).(cycName).t;reshape(tempT,[],1)];
%             each.(behName).(cycName).z=[each.(behName).(cycName).z;reshape(tempZ,[],1)];
%             avg.(behName).(cycName).t=[avg.(behName).(cycName).t;mean(tempT,2)];
%             avg.(behName).(cycName).z=[avg.(behName).(cycName).z;mean(tempZ,2)];            
%             
        end
        
    end
    
end


%%
nCol=4;
nRow=8;

col.nrem=hsv2rgb([2/3,0.5,1]);
col.rem=hsv2rgb([2/3,0.3,1]);
col.quiet=hsv2rgb([0,0.5,1]);
col.active=hsv2rgb([0,0.3,1]);
dispBehName.nrem='non-REM';
dispBehName.rem='REM';
dispBehName.quiet='Resting';
dispBehName.active='Active';

close all
fh=initFig4Neuron(2)
nDiv=10;
for cycIdx=1:2;
    cycName=cycList{cycIdx};
    for behIdx=1:length(behList)
        behName=behList{behIdx};
        
        for statType=0:1
            if statType==0
                target=each;
                titleText=['Each cell, ', dispBehName.(behName) ', ' cycName];
            else
                target=avg;
                titleText=['Epoch mean, ', dispBehName.(behName) ', ' cycName];
            end
            yText='\DeltaFiring rates (z)';
            if ~isempty(strfind(behName,'rem'))
                xText='Time from onset of extended sleep (min)';
            else
                xText='Time from onset of stable waking (min)';
            end
                
            
        
            subplot2(nRow,nCol,1+2*(cycIdx-1)+4*statType,behIdx)           
            x=target.(behName).(cycName).t;
            y=target.(behName).(cycName).z;            
            plot(x,y,'.','color',col.(behName),'markersize',4)
            axis tight
            ax=fixAxis;
            xlim([0,ax(2)])
            ax=fixAxis;
            
            c=polyfit(x,y,1);
            [r,p]=corr(x,y);
            hold on
            plot(ax(1:2),polyval(c,ax(1:2)),'-','color',[0,0,0])
            text2(0.95,0.95,['\it{r} = ' num2str(r,'%0.2g') getSigText(p)],ax,...
                {'horizontalAlign','right','verticalAlign','top'})           
            box off
            xlabel(xText)
            ylabel(yText)
            title(titleText)
            rank=tiedrank(x)/length(x);
            
            clear xVal yVal eVal nPos
            for bIdx=1:nDiv
                idx=find(rank>(bIdx-1)/nDiv&rank<=bIdx/nDiv)     ;           
                xVal(bIdx)=mean(x(idx));
                yVal(bIdx)=mean(y(idx));
                eVal(bIdx)=ste(y(idx));
                nPos(bIdx)=length(idx)
            end
            subplot2(nRow,nCol,2+2*(cycIdx-1)+4*statType,behIdx)           
            errorbar(xVal,yVal,eVal,'.','color',col.(behName))
            xlabel(xText)
            ylabel(yText)
            axis tight
            ax=fixAxis;
            xlim([0,ax(2)])
            ax=fixAxis;   
            hold on
            plot(ax(1:2),polyval(c,ax(1:2)),'-','color',[0,0,0])
            text2(0.95,0.95,['\it{r} = ' num2str(r,'%0.2g') getSigText(p)],ax,...
                {'horizontalAlign','right','verticalAlign','top'})           
%             title(num2str(nPos))
            box off
        end
    end
end

ax=fixAxis;
text2(1,-0.5,['made by HM with ' mfilename '.m'],ax,...
    {'horizontalAlign','right','verticalAlign','top','fontsize',4,'interpreter','none'})


subplot2(nRow,nCol,1,1)
hold on
ax=fixAxis;

text2(0,1.5,['Difference from first epoch in extended sleep / stable waking'],ax,...
    {'horizontalAlign','left','verticalAlign','bottom','fontsize',7})
text2(0.25,1.5,['first epochs are excluded from regression analyses'],ax,...
    {'horizontalAlign','left','verticalAlign','top','fontsize',5})

print(fh,'~/Dropbox/figures/paper/addtionalAnalyses/changeAcrossExSleep.pdf','-dpdf')















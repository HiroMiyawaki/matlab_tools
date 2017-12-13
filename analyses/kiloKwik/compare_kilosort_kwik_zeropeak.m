clear
rootDir='~/data/OCU/implanted/magician/';
load(fullfile(rootDir,'unitInfo.mat'));

FileInfo=dir(fullfile('/Users/miyawaki/Desktop/removeNoise/','*dat'));
NChInDat=112;
dat = memmapfile(fullfile(FileInfo.folder,FileInfo.name), 'Format', {'int16', [NChInDat, (FileInfo.bytes/NChInDat/2)], 'data'});

for n=1:4
    chMap{n}=(1:8)+8*(n-1);
end
for n=5:10
    chMap{n}=(1:10)+32+10*(n-5);
end
%%
kiloTempID=npy2mat('/Users/miyawaki/Desktop/removeNoise/spike_templates.npy');
kiloClu=npy2mat('/Users/miyawaki/Desktop/removeNoise/spike_clusters.npy');
kiloTemp=npy2mat('/Users/miyawaki/Desktop/removeNoise/templates.npy');

%%
cluList=[1125 2 83
    1457 3 125
    1511 4 88
    1528 6 220
    1454 7 219
    1543 9 173];


close all
fh=initFig4Nature(2);
doAppend='-append';

typeList={'kwik','kilo'};

psFileName='~/data/OCU/implanted/magician/kilosort-doublets.ps';

for cluIdx=1:size(cluList,1)
    clf
    shank=cluList(cluIdx,2);
    cID.kilo=cluList(cluIdx,1);
    cID.kwik=cluList(cluIdx,3);
    
    for typeIdx=1:length(typeList)
        type=typeList{typeIdx}
        spk.(type)=load(fullfile(rootDir,sprintf('magician-%s_shank%02d.mat',type,shank)));
    end
    
    meanTraceWidth=10.25;
    height=20;
    marginX=20;
    marginY=20;
    interGapX=10;
    interGapY=9;
    acgWidth=20;
    
    tracePoints=[-10,40];
    nCol=7;
    nExample.kilo=nCol*4;
    nExample.kwik=nCol;
    
    isiThreshold=1;
    traceYlim=100*[-12,1];
    for typeIdx=1:length(typeList)
        type=typeList{typeIdx};
        res=spk.(type).res(spk.(type).clu==cID.(type));
        
        unitIDlist=cat(1,unitInfo.(type).id);
        switch type
            case 'kwik'
                uIdx=find(unitIDlist(:,1)==shank&unitIDlist(:,2)==cID.(type));
                
                tempIDlist=1;
                tempID=ones(size(res));
                
            case 'kilo'
                uIdx=find(unitIDlist(:,1)==cID.(type));
                tempID=kiloTempID(kiloClu==cID.(type))+1;
                [tempIDlist,~,tempID]=unique(tempID);
                tempForm=kiloTemp(:,chMap{shank},tempIDlist);
            otherwise
                continue
        end
        
        totalGapX=0;
        totalGapY=((height+interGapY)*2+interGapY)*(typeIdx-1);
        
        isi=diff(res);
        [cnt,t]=hist(isi(isi<10*20),0.5:10*20);
        
        doublet=(find(isi<isiThreshold*20));
        doubletTemp=[tempID(doublet),tempID(doublet+1)];
        doublet=[res(doublet),res(doublet+1)];
        
        xPos=marginX+totalGapX;
        yPos=marginY+totalGapY;
        subplotInMM(xPos,yPos,meanTraceWidth,height,true)
        plot((0:size(unitInfo.(type)(uIdx).wave.mean,1)-1)/20,...
            unitInfo.(type)(uIdx).wave.mean*0.195-100*(0:size(unitInfo.(type)(uIdx).wave.mean,2)-1),'k-','linewidth',1)
        axis tight
        ylim(traceYlim)
        axis off
        switch type
            case 'kilo'
                titleText=sprintf('%s cluster %d',type,cID.(type));
            case 'kwik'
                titleText=sprintf('%s shank %d cluster %d',type,shank,cID.(type));
        end
        ax=fixAxis;
        text2(-0.2,1.2,titleText,ax,{'horizontalAlign','left','verticalALign','bottom','fontsize',10})
        title('mean waveform')
        barX=ax(2)-0.1;
        barY=ax(3:4)*[0.9,0.1]';
        hold on
        plot(barX-[0,1], barY*[1,1],'k-')
        text(barX-0.5,barY,'1 ms','horizontalAlign','center','verticalALign','bottom')

        
        
        xPos=marginX+meanTraceWidth+interGapX+totalGapX;
        yPos=marginY+totalGapY;
        subplotInMM(xPos,yPos,acgWidth,height,true)
        bar(-30:30,unitInfo.(type)(uIdx).acg,1,'facecolor','k')
        title(sprintf('%d spikes',length(res)));
        axis tight
        xlabel('ms')
        ylabel('count')
        box off
        
        xPos=marginX+meanTraceWidth+interGapX+acgWidth+interGapX+totalGapX;
        yPos=marginY+totalGapY;
        subplotInMM(xPos,yPos,acgWidth,height,true)
        bar(t/20,cnt,1,'facecolor','k')
        axis tight
        xlim([-2,10])
        ax=fixAxis;
        hold on
        plot(isiThreshold*[1,1],ax(3:4),'r-','linewidth',0.5)
        xlabel('ISI (ms)')
        ylabel('Count')
        box off
        %     text2(1,1,sprintf('%d ISIs are < %d ms',size(doublet,1),isiThreshold),ax,...
        %         {'horizontalAlign','left','verticalAlign','top'})
        title(sprintf('%d ISIs are < %d ms',size(doublet,1),isiThreshold))
        traceWidth=meanTraceWidth/size(unitInfo.(type)(uIdx).wave.mean,1)*(diff(tracePoints)+1);
        
        tempCol=hsv(length(tempIDlist));
        if strcmpi(type,'kilo')

            xPos=marginX+meanTraceWidth+interGapX+2*(acgWidth+interGapX)+totalGapX;
            yPos=marginY+totalGapY;
            templateWidth=meanTraceWidth/size(unitInfo.(type)(uIdx).wave.mean,1)*size(tempForm,1);
            subplotInMM(xPos,yPos,templateWidth,height,true)
            
            for tIdx=1:length(tempIDlist)
                hold on
                plot((1:size(tempForm,1))/20,squeeze(tempForm(:,:,tIdx))-0.2*(0:length(chMap{shank})-1),'color',tempCol(tIdx,:),'linewidth',0.5)
            end
            axis tight
            ylim(0.2*[-11,1])
            title('Templates')
            axis off
            ax=fixAxis;

            barX=size(tempForm,1)/20-0.1;
            barY=ax(3:4)*[0.9,0.1]';
            plot(barX-[0,1], barY*[1,1],'k-')
            text(barX-0.5,barY,'1 ms','horizontalAlign','center','verticalALign','bottom')
            
            
            [ccgCnt,t]=CCG(res,tempID,20,30,20e3);
            
            xPos=marginX+meanTraceWidth+interGapX+2*(acgWidth+interGapX)+templateWidth+interGapX+totalGapX;
            yPos=marginY+totalGapY;
            
            for unit1=1:size(ccgCnt,2)
                for unit2=1:size(ccgCnt,3)
                    subplotInMM(xPos+(unit1-1)*acgWidth/size(ccgCnt,2),yPos+(unit2-1)*height/size(ccgCnt,3),...
                        acgWidth/size(ccgCnt,2)-0.5,height/size(ccgCnt,3)-0.5,true)
                    if unit1==unit2
                        col=tempCol(unit1,:)
                    else
                        col=[0,0,0];
                    end
                    bar(t,squeeze(ccgCnt(:,unit1,unit2)),1,'edgecolor','none','facecolor',col)
                    axis tight
                    axis off
                    
                end
            end
            
            
            
        end
        
        if size(doublet,1)>nExample.(type)
            toShowIdx=sort(randperm(size(doublet,1),nExample.(type)));
            doublet=doublet(toShowIdx,:);
            doubletTemp=doubletTemp(toShowIdx,:);
        end
        
        for n=1:size(doublet,1)
            xPos=marginX+mod(n-1,nCol)*(interGapX+traceWidth)+totalGapX;
            yPos=marginY+(ceil(n/nCol))*(height+interGapY)+totalGapY+interGapY/3;
            
            subplotInMM(xPos,yPos,traceWidth,height,true)
            
            
            wave=double(dat.Data.data(chMap{shank},doublet(n,1)+(tracePoints(1):tracePoints(2))))'*0.195;
            wave=wave-mean(wave)-100*(0:size(wave,2)-1);
            plot((tracePoints(1):tracePoints(2))/20,wave,'k-','linewidth',0.5)
            hold on
            plot([0,0],traceYlim+[50,0],'-','linewidth',0.5,'color',tempCol(doubletTemp(n,1),:))
            plot(diff(doublet(n,:))/20*[1,1],traceYlim-[0,50],'-','linewidth',0.5,'color',tempCol(doubletTemp(n,2),:))
            xlim(tracePoints/20)
            ylim(traceYlim)
            box off
            axis off
            if n==1
                ax=fixAxis;
                text2(-0.1,1.1,'Examples of doublets (raw traces)',ax,{'horizontalAlign','left','verticalALign','bottom','fontsize',7})
            end
        end
        barX=tracePoints(2)/20-0.1;
        barY=traceYlim*[0.9,0.1]';
        plot(barX-[0,1], barY*[1,1],'k-')
        text(barX-0.5,barY,'1 ms','horizontalAlign','center','verticalALign','bottom')
    end
    addScriptName(mfilename);
    print(fh,psFileName,'-dpsc','-painters',doAppend)
    doAppend='-append';
end

%%
[~,temp]=fileattrib(psFileName)
psFile=temp.Name;

eval(sprintf('! /usr/local/bin/ps2pdf %s %s && /bin/rm %s',psFile,[psFile(1:end-2) 'pdf'],psFile))

%%


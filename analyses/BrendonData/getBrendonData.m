clear
clc

rootDir='~/data/Brendon/';
coreName='Brendon';

dList=dir(rootDir);

dList={dList([dList.isdir]).name};

dList(strcmp(dList,'.') | strcmp(dList,'..') )=[];
%%
clear state spk basics
nrem=[];
rem=[];
wake=[];

for dIdx=1:length(dList)
    dataName=dList{dIdx};

    nameCore=['~/data/Brendon/' dataName '/' dataName];


    load([nameCore '_BasicMetaData.mat'])
    % 
    % 
    % load([nameCore '_GoodSleepInterval.mat'])
    load([nameCore '_SStable.mat'])
    load([nameCore '_CellIDs.mat'])
    load([nameCore '_WSRestrictedIntervals.mat'])

    temp=load([nameCore '-states.mat'])

    idx=find(diff(temp.states)~=0);
    
    state=[[1,idx+1]',[idx,length(temp.states)]']
   
    state=[state,temp.states(1,state(:,1))'];
    
    basics(dIdx).basename=bmd.basename;
    basics(dIdx).par=bmd.Par;
    basics(dIdx).goodshanks=bmd.goodshanks;
    basics(dIdx).goodeegchannel=bmd.goodeegchannel;

    basics(dIdx).madeby=mfilename;

    temp=mergePeriod(REMEpisodeTimePairFormat+0.5*[-1,1],SleepTimePairFormat+0.5*[-1,1]);
    
    
    
    % res{1,1} p1 off, p2 off;
    % res{1,2} p1 off p2 on;
    % res{2,1} p1 on p2 off;
    % res{2,2} p1 on p2 on;     
    
    state(dIdx).episodes=sortrows([temp{1,2},1*ones(size(temp{1,2},1),1);...
                    temp{2,2},2*ones(size(temp{2,2},1),1);...
                    WakeTimePairFormat,3*ones(size(WakeTimePairFormat,1),1)]);

    temp1=mergePeriod(SleepTimePairFormat+0.5*[-1,1], SWSPacketTimePairFormat+0.5*[-1,1]);
    temp2=mergePeriod(SleepTimePairFormat+0.5*[-1,1], MATimePairFormat+0.5*[-1,1]);
    temp3=mergePeriod(SleepTimePairFormat+0.5*[-1,1], WakeInterruptionTimePairFormat+0.5*[-1,1]);
    
    state(dIdx).packets=sortrows([temp1{2,2},4*ones(size(temp1{2,2},1),1);...
                    temp2{2,2},5*ones(size(temp2{2,2},1),1);...
                    temp3{2,2},6*ones(size(temp3{2,2},1),1)]);                
    state(dIdx).name={'nrem','rem','wake','nremPacket','ma','WakeInterruption'};
    
    state(dIdx).madeby=mfilename;
%     nrem=[nrem;diff(temp{1,2},1,2)];
%     rem=[rem;diff(temp{2,2},1,2)];
%     wake=[wake;diff(WakeTimePairFormat,1,2)];

    
    spk(dIdx).pyr=S_CellFormat(CellIDs.EAll);
    spk(dIdx).inh=S_CellFormat(CellIDs.IAll);
    spk(dIdx).madeby=mfilename;
end
%%
coreName='Brendon';
varList={'basics','state','spk'};
for varName=varList
    save(fullfile(rootDir, [coreName '-' varName{1} '.mat']), varName{1},'-v7.3')
end

%
varList={'basics','state','spk'};
for varName=varList
    load(fullfile(rootDir, [coreName '-' varName{1} '.mat']), varName{1})
end

nBin.rem=6;
nBin.nrem=30;

for dIdx=1:length(basics)

    for sIdx=1:size(state(dIdx).episodes,1)
        switch state(dIdx).episodes(sIdx,3)
            case 1
                type='nrem';
            case 2
                type='rem';
            otherwise
                continue
        end
        binSize=diff(state(dIdx).episodes(sIdx,1:2))/nBin.(type);
        tBin=state(dIdx).episodes(sIdx,1)-binSize/2:binSize:state(dIdx).episodes(sIdx,2)+binSize/2;
    
        temp=cellfun(@(x) hist(x,tBin)/binSize,spk(dIdx).pyr,'UniformOutput',false);
        temp=cat(1,temp{:});
        timeNormFR(dIdx).pyr{sIdx}=temp(:,2:end-1);

        temp=cellfun(@(x) hist(x,tBin)/binSize,spk(dIdx).inh,'UniformOutput',false);
        temp=cat(1,temp{:});
        timeNormFR(dIdx).inh{sIdx}=temp(:,2:end-1);
        timeNormFR(dIdx).madeby=mfilename;
    end
end
varList={'timeNormFR'};
for varName=varList
    save(fullfile(rootDir, [coreName '-' varName{1} '.mat']), varName{1},'-v7.3')
end
%
varList={'basics','state','spk','timeNormFR'};
for varName=varList
    load(fullfile(rootDir, [coreName '-' varName{1} '.mat']), varName{1})
end


sqList={'nrem','rem','nrem2rem','rem2nrem'};
sq.nrem=1;
sq.rem=2;
sq.nrem2rem=[1,2];
sq.rem2nrem=[2,1];

for dIdx=1:length(basics)

    for sqTypeIdx=1:length(sqList)
        sqName=sqList{sqTypeIdx};
        
        cand=find(state(dIdx).episodes(:,3)==sq.(sqName)(1));
        n=1;
        
        while n<length(sq.(sqName)) && ~isempty(cand)
            n=n+1;
            cand=cand+1;
            cand(cand>size(state(dIdx).episodes,1))=[];
            cand=cand(state(dIdx).episodes(cand,3)==sq.(sqName)(n));
            
            cand(state(dIdx).episodes(cand,1)~=state(dIdx).episodes(cand-1,2))=[];
        end
 
        if isempty(cand)
            stateTrans(dIdx).(sqName)=[];
        else
            stateTrans(dIdx).(sqName)=cand-(length(sq.(sqName))-1:-1:0);
        end
    end
    stateTrans(dIdx).madeby=mfilename;
end

varList={'stateTrans'}
for varName=varList
    save(fullfile(rootDir, [coreName '-' varName{1} '.mat']), varName{1},'-v7.3')
end

%
varList={'basics','state','spk','timeNormFR','stateTrans'};
for varName=varList
    load(fullfile(rootDir, [coreName '-' varName{1} '.mat']), varName{1})
end


nDiv=5;
nShuffle=2000;
stateList={'nrem','rem','rem2nrem','nrem2rem'};
funcCI=@(x) diff(x,1,2)./sum(x,2);

orderList={'mean','onset','offset'};
baseBin={[1,2],1,2};

for stateIdx=1:length(stateList)
    state=stateList{stateIdx};  
    display([datestr(now) ' started ' state])
    clear fr
    for dIdx=1:length(basics)
        targetIdx=stateTrans(dIdx).(state);

        fr(dIdx).pyr={};
        fr(dIdx).inh={};
        for tIdx=1:size(targetIdx,1)
            if size(targetIdx,2)==2
                if isempty(timeNormFR(dIdx).pyr{targetIdx(tIdx,1)})||...
                        isempty(timeNormFR(dIdx).pyr{targetIdx(tIdx,2)})
                    continue
                end
                    fr(dIdx).pyr{end+1}=[timeNormFR(dIdx).pyr{targetIdx(tIdx,1)}(:,end),timeNormFR(dIdx).pyr{targetIdx(tIdx,2)}(:,1)];
                    if ~isempty(timeNormFR(dIdx).inh{targetIdx(tIdx,1)})
                        fr(dIdx).inh{end+1}=[timeNormFR(dIdx).inh{targetIdx(tIdx,1)}(:,end),timeNormFR(dIdx).inh{targetIdx(tIdx,2)}(:,1)];  
                    else
                        fr(dIdx).inh{end+1}=[];
                    end
            elseif size(targetIdx,2)==1
                if isempty(timeNormFR(dIdx).pyr{targetIdx(tIdx)})
                     continue
                end

                fr(dIdx).pyr{end+1}=timeNormFR(dIdx).pyr{targetIdx(tIdx)}(:,[1,end]);
                if ~isempty(timeNormFR(dIdx).inh{targetIdx(tIdx,1)})
                    fr(dIdx).inh{end+1}=timeNormFR(dIdx).inh{targetIdx(tIdx)}(:,[1,end]);        
                else
                    fr(dIdx).inh{end+1}=[];
                end

            else
                continue
            end
        end
    end

    for shIdx=1:nShuffle+1
        if mod(shIdx,100)==0        
            display(['   ' datestr(now) ' shuffling ' num2str(shIdx) '/' num2str(nShuffle)])
        end
               
        temFR.firstBin.pyr={};
        temFR.firstBin.inh={};
        temFR.lastBin.pyr={};
        temFR.lastBin.inh={};
        for cTypeIdx=1:2
            switch cTypeIdx
                case 1
                    cType='pyr';
                case 2
                    cType='inh';
                otherwise
                    continue
            end
            
            for dIdx=1:length(fr)
                if length(fr(dIdx).pyr)<2
                    continue
                end
                surIdx=randi(length(fr(dIdx).pyr)-1,1,length(fr(dIdx).pyr));
                surIdx(surIdx-(1:length(fr(dIdx).pyr))>=0)=surIdx(surIdx-(1:length(fr(dIdx).pyr))>=0)+1;
                for tIdx=1:length(fr(dIdx).(cType))
                    if isempty(fr(dIdx).(cType){tIdx})
                        continue
                    end
                    if shIdx>1
                        %do shuffling
                        temp=[fr(dIdx).(cType){tIdx}(:,1),fr(dIdx).(cType){surIdx(tIdx)}(:,1)];
                        flipIdx=randi(2,size(temp,1),1)-1;
                        flipIdx=[flipIdx,1-flipIdx]*size(flipIdx,1)+(1:size(flipIdx,1))';
                        temFR.firstBin.(cType){end+1}=temp(flipIdx);
                        
                        temp=[fr(dIdx).(cType){tIdx}(:,2),fr(dIdx).(cType){surIdx(tIdx)}(:,2)];
                        flipIdx=randi(2,size(temp,1),1)-1;
                        flipIdx=[flipIdx,1-flipIdx]*size(flipIdx,1)+(1:size(flipIdx,1))';
                        temFR.lastBin.(cType){end+1}=temp(flipIdx);
                    else
                        temFR.firstBin.(cType){end+1}=fr(dIdx).(cType){surIdx(tIdx)};
                        temFR.lastBin.(cType){end+1}=fr(dIdx).(cType){surIdx(tIdx)};
                    end
                end
            end
        end
                
        for orderTypeIdx=1:length(baseBin)
            orderType=orderList{orderTypeIdx}; 
            
            for tPointIdx=1:2
                if tPointIdx==1
                    tPoint='firstBin';
                else
                    tPoint='lastBin';
                end
                quintile=cellfun(@(x) ceil(tiedrank(mean(x(:,baseBin{orderTypeIdx}),2))/length(x)*nDiv),temFR.(tPoint).pyr,'uniformOutput',false);
                
                for qIdx=1:nDiv
                    temp=cellfun(@(x,y) x(y==qIdx,:),temFR.(tPoint).pyr,quintile,'uniformOutput',false);
                    tempCI{qIdx}=funcCI(cat(1,temp{:}));
                end
                
                tempCI{nDiv+1}=funcCI(cat(1,temFR.(tPoint).inh{:}));
            

            if shIdx==1
                newCI.(state).(orderType).real.mean=cellfun(@nanmean,tempCI);
                newCI.(state).(orderType).real.ste=cellfun(@nanste,tempCI);
                newCI.(state).(orderType).real.n=cellfun(@(x) sum(~isnan(x)),tempCI);
                newCI.(state).(orderType).real.totalN=cellfun(@length,tempCI);
            else            
                newCI.(state).(orderType).shuffle.(tPoint)(shIdx-1,:)=cellfun(@nanmean,tempCI);
            end
            end
            newCI.(state).(orderType).param.orderBin=baseBin{orderTypeIdx};
            newCI.(state).(orderType).param.madeby=mfilename;
            newCI.(state).(orderType).param.nDiv=nDiv;
            newCI.(state).(orderType).param.nShuffle=nShuffle;          
        end   
    end
    
    for orderTypeIdx=1:length(baseBin)
        orderType=orderList{orderTypeIdx}; 
        for tPointIdx=1:2
            if tPointIdx==1
                tPoint='firstBin';
            else
                tPoint='lastBin';
            end
                   
            temp=sort(newCI.(state).(orderType).shuffle.(tPoint));
            
            realNum=newCI.(state).(orderType).real.mean;
            
            for qIdx=1:size(temp,2)
                n=find(temp(:,qIdx)<realNum(qIdx),1,'last');
                if isempty(n); n=0;
                elseif n>size(temp,1)/2; n=size(temp,1)-n;end
                p(qIdx)=n/size(temp,1)*2;
            end

            newDI.(state).(orderType).(tPoint).mean=newCI.(state).(orderType).real.mean-mean(temp);
            newDI.(state).(orderType).(tPoint).ste=newCI.(state).(orderType).real.ste;
            newDI.(state).(orderType).(tPoint).p=p;
            newDI.(state).(orderType).(tPoint).n=newCI.(state).(orderType).real.n;
            newDI.(state).(orderType).(tPoint).totalN=newCI.(state).(orderType).real.totalN;
            newDI.(state).(orderType).(tPoint).null=mean(temp);
            newDI.(state).(orderType).(tPoint).confInt=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);
    
        end
    end
end


save([rootDir coreName '-' 'newDI' '.mat'],'newDI','newCI','-v7.3')

varList={'basics','state','spk','timeNormFR','stateTrans','newDI'};
for varName=varList
    load(fullfile(rootDir, [coreName '-' varName{1} '.mat']))
end
%
origX=13;
origY=13;
panelLetterSize=12;
letterGapX=10;
letterGapY=5;
marginX=15;
marginY=12;
timeNormWidth=40;
height=22;
ciWidth=25;


stateList={'nrem2rem','rem2nrem','nrem','rem'};


close all
fh=initFig4Nature(2);

orderList={'mean','onset','offset'};
for sIdx=1:length(stateList);
    stateName=stateList{sIdx};
    
    sep=findstr(stateName,'2')
    
    if ~isempty(sep)
        orderText={'by mean',['at ' upper(stateName(1:sep-1)) ' offset'],['at ' upper(stateName(sep+1:end)) ' onset']}
        oldOrderTypeList={'both','offset','onset'}
    else
        orderText={'by mean',['at ' upper(stateName) ' onset'],['at ' upper(stateName) ' offset']};
        oldOrderTypeList={'mean','onset','offset'}
    end
    
    for oIdx=1:length(orderList)
        orderType=orderList{oIdx};
        oldOrderType=oldOrderTypeList{oIdx};
        
        xPos=origX+mod(sIdx-1,4)*(ciWidth+marginX);
        yPos=origY+(3.5*(sIdx>4)+(oIdx-1))*(height+marginY);
        
        subplotInMM(xPos,yPos,ciWidth,height,true);
        
        temp=sort(newCI.(stateName).(orderType).shuffle.firstBin);
        confInt.first=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);
        
        temp=sort(newCI.(stateName).(orderType).shuffle.lastBin);
        confInt.last=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);

        temp=sort(shuffle.ci.(stateName).(oldOrderType)');
        confInt.old=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:);
        
        
        hold on
        bar(1:5,newCI.(stateName).(orderType).real.mean(1:5),'faceColor',[0,0,0])
        bar(6,newCI.(stateName).(orderType).real.mean(6),'faceColor',[1,1,1])
        fill([1:6,6:-1:1],[confInt.first(1,:),fliplr(confInt.first(2,:))],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
        fill([1:6,6:-1:1],[confInt.last(1,:),fliplr(confInt.last(2,:))],[0,0,1],'faceAlpha',0.5,'edgeColor','none')
        fill([1:6,6:-1:1],[confInt.old(1,:),fliplr(confInt.old(2,:))],[0,0.8,0],'faceAlpha',0.5,'edgeColor','none')
        set(gca,'xtick',[1,3,5,6],'XTickLabel',{'L','M','H','I'})
        
        
        title({strrep(upper(stateName),'2',' to '),['Ordered ' orderText{oIdx}]})
        ylabel('CI')
        xlim([0.5,6.5])
        ax=fixAxis;
        if oIdx==1 &&sIdx==1
            textInMM(marginX/2,marginY/2,'On data of Brendon Watson',{'horizontalAlign','left','verticalAlign','bottom','fontsize',10})
        end
    end
end


subplotInMM(xPos,yPos+height+marginY*0.25,ciWidth,marginY,true);
xlim([0,1])
ylim([0,1])

hold on
rectangle('position',[0,0.7,0.2,0.1],'facecolor',[0,0,0])
text(0.22,0.75,'Pyramidal cell','horizontalAlign','left','verticalAlign','middle')

rectangle('position',[0,0.5,0.2,0.1],'facecolor',[1,1,1])
text(0.22,0.55,'Interneuron','horizontalAlign','left','verticalAlign','middle')

fill([0,0.2,0.2,0],[0.3,0.3,0.4,0.4],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
text(0.22,0.35,'95% CI of first bin shuffling','horizontalAlign','left','verticalAlign','middle')

fill([0,0.2,0.2,0],[0.1,0.1,0.2,0.2],[0,0,1],'faceAlpha',0.5,'edgeColor','none')
text(0.22,0.15,'95% CI of last bin shuffling','horizontalAlign','left','verticalAlign','middle')
axis off

fill([0,0.2,0.2,0],[0.0,0.0,0.1,0.1],[0,0.8,0],'faceAlpha',0.5,'edgeColor','none')
text(0.22,0.05,'95% CI of old shuffling method','horizontalAlign','left','verticalAlign','middle')
axis off


for sIdx=1:length(stateList)
    stateName=stateList{sIdx};
    
    sep=findstr(stateName,'2');
    
    if ~isempty(sep)
        orderText={'by mean',['at ' upper(stateName(1:sep-1)) ' offset'],['at ' upper(stateName(sep+1:end)) ' onset']}
        oldOrderTypeList={'both','offset','onset'}
    else
        orderText={'by mean',['at ' upper(stateName) ' onset'],['at ' upper(stateName) ' offset']};
        oldOrderTypeList={'mean','onset','offset'}
    end
    
    for oIdx=1:length(orderList)
        orderType=orderList{oIdx};
        oldOrderType=oldOrderTypeList{oIdx};
        
        xPos=origX+mod(sIdx-1,4)*(ciWidth+marginX);
        yPos=origY+(3.5+(oIdx-1))*(height+marginY);
        
        subplotInMM(xPos,yPos,ciWidth,height,true);
        
        hold on
        bar((1:5)-0.31,newDI.(stateName).(orderType).firstBin.mean(1:5),0.3,'facecolor',[0.8,0,0],'edgeColor','none');
        bar((1:5)+0,newDI.(stateName).(orderType).lastBin.mean(1:5),0.3,'facecolor',[0,0,0.8],'edgeColor','none');
        
        temp=sort(shuffle.ci.(stateName).(oldOrderType)');
        oldDInull=mean(temp);
        confInt.old=temp([max([floor(size(temp,1)*0.025),1]),ceil(size(temp,1)*0.975)],:)-oldDInull;
        bar((1:5)+0.31,real.ci.(stateName).(oldOrderType).mean(1:5)-oldDInull(1:5),0.3,'facecolor',[0,0.8,0],'edgeColor','none')
        
        bar(6-0.31,newDI.(stateName).(orderType).firstBin.mean(6),0.3,'facecolor',[1,1,1],'edgeColor',[0.8,0,0],'lineWidth',1);
        bar(6+0,newDI.(stateName).(orderType).lastBin.mean(6),0.3,'facecolor',[1,1,1],'edgeColor',[0,0,0.8],'lineWidth',1);
        bar(6+0.31,real.ci.(stateName).(oldOrderType).mean(6)-oldDInull(6),0.3,'facecolor',[1,1,1],'edgeColor',[0,0.8,0])
        confInt.first=newDI.(stateName).(orderType).firstBin.confInt-newDI.(stateName).(orderType).firstBin.null;
        confInt.last=newDI.(stateName).(orderType).lastBin.confInt-newDI.(stateName).(orderType).lastBin.null;
        
        fill([1:6,6:-1:1]-0.31,[confInt.first(1,:),fliplr(confInt.first(2,:))],[1,0,0],'faceAlpha',0.5,'edgeColor','none')
        fill([1:6,6:-1:1]+0,[confInt.last(1,:),fliplr(confInt.last(2,:))],[0,0,1],'faceAlpha',0.5,'edgeColor','none')
        fill([1:6,6:-1:1]+0.31,[confInt.old(1,:),fliplr(confInt.old(2,:))],[0,0.8,0],'faceAlpha',0.5,'edgeColor','none')
        set(gca,'xtick',[1,3,5,6],'XTickLabel',{'L','M','H','I'})
        
        
        title({strrep(upper(stateName),'2',' to '),['Ordered ' orderText{oIdx}]})
        ylabel('DI')
        xlim([0.5,6.5])
    end
end


addScriptName(mfilename)
figName='~/Dropbox/Quantile/preliminary/BrendonsData-DI.pdf';
print(figName,'-dpdf','-painters')
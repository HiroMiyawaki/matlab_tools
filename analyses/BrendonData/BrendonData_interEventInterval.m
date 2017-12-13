clear
clc

rootDir='~/data/Brendon/';
coreName='Brendon';

dList=dir(rootDir);

dList={dList([dList.isdir]).name};

dList(strcmp(dList,'.') | strcmp(dList,'..') )=[];
%%
close all
fh=initFig4Nature(2)
nRaw=8;
pdfFileName=fullfile(rootDir, 'tripletsDetection.pdf');
doAppend='';

totalCut=zeros(4,1);

% addpath(genpath('/Volumes/RAID_HDD/data/Dan_code/TStoolbox/'))
ipi=[];
iMi=[];
for dIdx=1:length(dList)
    cnt=zeros(4,1)
    
    %     if mod(dIdx,nRaw)==1
    %         if dIdx~=1
    %             addScriptName(mfilename)
    %             print(fh,psFileName,doAppend,'-painters','-dpsc')
    %             doAppend='-append';
    %         end
    %         fh=initFig4Nature(2);
    %     end
    %     subplot(nRaw,1,mod(dIdx-1,nRaw)+1)
    
    dataName=dList{dIdx};
    
    nameCore=['~/data/Brendon/' dataName '/' dataName];
    
    state=load([nameCore '_WSRestrictedIntervals.mat']);
    
    if strcmpi(dataName,'Splinter_020515')
       state.WakeTimePairFormat(2,1)=state.WakeSleepTimePairFormat{1}(end)+1;
    end
    
    idxSWS=1;
    idxREM=4;
    idxWI=5;
    idxWAKE=2;
    idxShortWAKE=6;
    idxMA=3;
    list=[];
    for n=1:5
        switch n
            case idxSWS
                temp=state.SWSPacketTimePairFormat;
            case idxREM
                temp=state.REMEpisodeTimePairFormat;
            case idxWI
                temp1=mergePeriod(state.WakeInterruptionTimePairFormat,state.REMEpisodeTimePairFormat);
                % res{1,1} p1 off, p2 off;
                % res{1,2} p1 off p2 on;
                % res{2,1} p1 on p2 off;
                % res{2,2} p1 on p2 on;
                temp=temp1{2,1};
            case idxWAKE
                temp=state.WakeTimePairFormat;
            case idxMA
                temp=state.MATimePairFormat;
%                 temp(diff(temp,1,2)<5,:)=[];
        end
        
        list=[list;[temp,n*ones(size(temp,1),1)]];
    end
    
    list=sortrows(list);
    within=zeros(size(list,1),1);
    for n=1:length(state.WakeSleepTimePairFormat)
        temp=find(...
            list(:,1)>=state.WakeSleepTimePairFormat{n}(1,1)&...
            list(:,1)<=state.WakeSleepTimePairFormat{n}(1,2));
        temp(list(temp,3)==5|list(temp,3)==3)=[];
        within(temp)=1;
        
        temp=find(...
            list(:,1)>=state.WakeSleepTimePairFormat{n}(2,1)&...
            list(:,1)<=state.WakeSleepTimePairFormat{n}(2,2));
        within(temp)=1;
    end
    list(within==0,:)=[];
    
        
%     wi=list(list(:,3)==5,:);
%     list(list(:,3)==idxWI&diff(list(:,1:2),1,2)>40,3)=idxShortWAKE;
    
    
    
%     %wi>rem
%     wiIdx=find(list(:,3)==idxWI);
%     wiIdx(wiIdx>size(list,1)-1|wiIdx<2)=[];
%     wi2rem=wiIdx(list(wiIdx-1,3)==idxSWS&list(wiIdx+1,3)==idxREM&diff(list(wiIdx,1:2),1,2)<=40)    
%     list(wi2rem+1,1)=list(wi2rem,1);
%     list(wi2rem,:)=[];
%                   
%     
%     wiIdx=find(list(:,3)==idxWI);
%     wiIdx(wiIdx>size(list,1)-1|wiIdx<2)=[];
%     %rem>wi
%     wi2rem=wiIdx(list(wiIdx-1,3)==idxREM&list(wiIdx+1,3)==idxSWS&diff(list(wiIdx,1:2),1,2)<=40)
%     list(wi2rem-1,2)=list(wi2rem,2);
%     list(wi2rem,:)=[];
%     
%     list(list(:,3)==idxWI&diff(list(:,1:2),1,2)<=40,3)=idxMA;
    
%     list(list(:,3)==5,:)=[];
%     alpha=zeros(size(list,1),1);
%     
%     %p-R-p
%     pIdx=find(list(:,3)==idxSWS);
%     for idx=1:length(pIdx)-1
%         btwStates=list(pIdx(idx)+1:pIdx(idx+1)-1,3);
%         if any(ismember(btwStates,[idxWAKE,idxSWS]))
%             continue
%         end
%         temp=find(btwStates==idxREM);
%         if isempty(temp)
%             continue
%         end
%         alpha(pIdx(idx)+temp)=1;
%         cnt(idxREM-1)=cnt(idxREM-1)+1;
%     end
% 
%     
    %p-MA-p
    pIdx=find(list(:,3)==idxSWS);
    for idx=1:length(pIdx)-1
%         if list(pIdx(idx+1),1)-list(pIdx(idx),2)>40
%             continue
%         end
        
%         if list(pIdx(idx+1),1)-list(pIdx(idx),2)<10
%             continue
%         end
                
        btwStates=list(pIdx(idx)+1:pIdx(idx+1)-1,3);
        if any(ismember(btwStates,[idxREM,idxSWS,idxWAKE]))
            continue
        end
        temp=find(btwStates==idxMA);
        if isempty(temp)
            continue
        end
        alpha(pIdx(idx)+temp)=1;
        cnt(idxMA-1)=cnt(idxMA-1)+1;
        ipi(end+1)=list(pIdx(idx+1),1)-list(pIdx(idx),2);
    end  
%     
%     %p-WAKE-p
%     pIdx=find(list(:,3)==idxSWS);
%     for idx=1:length(pIdx)-1
%         
%         btwStates=list(pIdx(idx)+1:pIdx(idx+1)-1,3);
%         
%         temp=find(btwStates==idxShortWAKE);
%         if ~isempty(temp) && ~any(ismember(btwStates,[idxREM]))
%             alpha(pIdx(idx)+temp)=1;
%             cnt(1)=cnt(1)+1;
%         else 
%             temp=find(btwStates==idxWAKE);
%             if isempty(temp)
%                 continue
%             end
%             alpha(pIdx(idx)+temp)=1;
%             cnt(1)=cnt(1)+1;
%         end
%     end
    
    %MA-p-MA
    pIdx=find(list(:,3)==idxMA);    
    for idx=1:length(pIdx)-1        
%         if list(pIdx(idx+1),1)-list(pIdx(idx),2)<60
%             continue
%         end
        
        btwStates=list(pIdx(idx)+1:pIdx(idx+1)-1,3);
        if any(ismember(btwStates,[idxWAKE]))
            continue
        end
        temp=find(btwStates==idxSWS);
        if isempty(temp)
            continue
        end
        alpha(pIdx(idx)+temp)=1;
        cnt(4)=cnt(4)+1;      
        iMi(end+1)=list(pIdx(idx+1),1)-list(pIdx(idx),2);
    end
    
%     for m=[idxMA,idxREM]
%         for idx=1:length(pIdx)-1
%             betStates=list(pIdx(idx)+1:pIdx(idx+1)-1,3);
%             if any(ismember(betStates,[idxWAKE,idxShortWAKE]))
%                 continue
%             end
%             temp=find(betStates==m);
%             if isempty(temp)
%                 continue
%             end
%             alpha(pIdx(idx)+temp)=1;
%             cnt(m-1)=cnt(m-1)+1;
%         end
%     end
% 
%     pIdx=find(list(:,3)==idxMA);
%     for m=[idxSWS]
%         for idx=1:length(pIdx)-1
%             betStates=list(pIdx(idx)+1:pIdx(idx+1)-1,3);
%             if any(ismember(betStates,[idxWAKE,idxShortWAKE]))
%                 continue
%             end
%             temp=find(betStates==m);
%             if isempty(temp)
%                 continue
%             end
%             alpha(pIdx(idx)+temp)=1;
%             cnt(4)=cnt(4)+1;
%         end
%     end    
    
%     pIdx=find(list(:,3)==idxSWS);
%     pIdx(pIdx>size(list,1)-2)=[];
%     temp=pIdx(list(pIdx+1,3)==1&list(pIdx+2,3)==3);
%     alpha(temp+1)=1;
%     cnt(4)=length(temp);
    
%     alpha=alpha*0.8+0.2;
%     
%     pos(idxSWS)=0; %SWS
%     pos(idxWAKE)=4; %WAKE
%     pos(idxMA)=1; %MA
%     pos(idxREM)=3; %REM
%     pos(idxWI)=2; %WI
%     pos(idxShortWAKE)=4; %WAKE
%     col(idxSWS,:)=[0,0,1]; %SWS
%     col(idxWAKE,:)=[0,0,0]; %WAKE
%     col(idxMA,:)=[ 1,0.8,0]; %MA
%     col(idxREM,:)=[ 1,0,0]; %REM
%     col(idxWI,:)=[0,0.8,0]; %WI
%     col(idxShortWAKE,:)=[0,0.8,0]; %WI
%     subplot(14,2,dIdx)
%     hold on
%     for n=1:size(list,1)
%         fill([list(n,1:2),list(n,2:-1:1)],pos(list(n,3))+[0,0,1,1],col(list(n,3),:),...
%             'edgecolor','none','facealpha',alpha(n))
%     end
%     axis tight
%     ax=fixAxis;
%     nText='n= ';
%     for m=1:4
%         nText=[nText '\color[rgb]{' num2str(col(mod(m,4)+1,:)) '}' num2str(cnt(m)) '\color[rgb]{0,0,0}, '];
%     end
%     nText(end-1:end)=[];
%     text2(1,1,nText,ax,{'horizontalALign','right','verticalAlign','bottom'})
%     text2(0,1,dataName,ax,{'horizontalALign','left','verticalAlign','bottom','interpreter','none'})
%     xlabel('time (s)')
%     set(gca,'ytick',0.5:5,'YTickLabel',{'SWSpacket','MA','wakeinterruption','REM','WAKE'})
%     totalCut=totalCut+cnt;
end

% subplot(14,2,28)
% axis off
% ax=fixAxis;
% nText='In total, n= ';
% pText='In the paper, ';
% pNum=[24,201,216,287];
% triName={'pWp','pMp','pRp','MpM'};
% for m=1:4
%     nText=[nText '\color[rgb]{' num2str(col(mod(m,4)+1,:)) '}' num2str(totalCut(m)) ' ' triName{m} '\color[rgb]{0,0,0}, '];
%     pText=[pText '\color[rgb]{' num2str(col(mod(m,4)+1,:)) '}' num2str(pNum(m)) ' ' triName{m} '\color[rgb]{0,0,0}, '];
% end
% nText(end-1:end)=[];
% pText(end-1:end)=[];
% text2(0,1,nText,ax,{'horizontalALign','left','verticalAlign','bottom','fontsize',7})
% text2(0,1,{pText
%              'Vivid colors indicate episodes/packets those are middle of triplets'
%              'States outside WAKESLEEP are removed'
%              'WI and MA within REM are removed'
%              'WI are ignored for triplet detection'
%              'Wake onset of Splinter\_020515 is adjusted'
%              'For pMp, p-p interval must be 10s-40s'
%              'For MpM, M-M interval must be >60s'},...
%              ax,{'horizontalALign','left','verticalAlign','top','fontsize',6})
% 
% 
% addScriptName(mfilename)

% print(fh,pdfFileName,'-dpdf','-painters')
%%
clf
subplot(5,3,1)
[cnt,bin]=hist(ipi(ipi<120),1:2:120)
bar(bin,cnt,1,'linestyle','none','facecolor',[0,0,1])
% xlim([0,41])
xlabel('Inter packet interval in triplets(s)')
ax=fixAxis;
hold on
plot(10*[1,1],ax(3:4),'r-')
plot(40*[1,1],ax(3:4),'r-')
box off
text2(1,1,sprintf('n = %d',length(ipi)),ax,{'horizontalAlign','right','verticalAlign','top'})
ylabel('Count')

subplot(5,3,2)
[cnt,bin]=hist(iMi(iMi<1500),15:30:1500)
% xlim([0,41])
bar(bin,cnt,1,'linestyle','none','facecolor',[1,0.8,0])
xlabel('Inter MA interval in triplets(s)')
ax=fixAxis;
hold on
plot(60*[1,1],ax(3:4),'r-')
box off
text2(1,1,sprintf('n = %d',length(iMi)),ax,{'horizontalAlign','right','verticalAlign','top'})
ylabel('Count')

addScriptName(mfilename)

print(gcf,fullfile(rootDir,'interEventIntervals.pdf'),'-dpdf','-painters')

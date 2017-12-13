rootDir='/Users/miyawaki/Desktop/magician_lam-15-40-40_Th-3-6-6_Nfilt-512/';
nBef=16;
nAft=24;
fCut=300;

nBasepoint=5;
nFet=3;

%%
xmlfile=dir(fullfile(rootDir,'*xml'))
xmlParam=LoadXml(fullfile(xmlfile.folder,xmlfile.name(1:end-4)));

nCh=xmlParam.nChannels;

datFile=dir(fullfile(rootDir,'*.dat'));
nSample=datFile.bytes/nCh/2;
dat=memmapfile(fullfile(datFile.folder,datFile.name),'Format', {'int16', [nCh, nSample], 'val'});


nFil=ceil(1/fCut*xmlParam.SampleRate);
nFil=2*floor(nFil/2)+1;

connectedCh=1:92;

%%
spikeTimes=npy2mat(fullfile(rootDir,'spike_times.npy'));
spikeClusters=npy2mat(fullfile(rootDir,'spike_clusters.npy'));
channelPosition=npy2mat(fullfile(rootDir,'channel_positions.npy'));
%%

basePoint=randperm(floor(nSample/xmlParam.SampleRate/60)-1,nBasepoint);

base=[];
for n=1:nBasepoint
    disp([datestr(now) ' reading baseline ' num2str(n) '/' num2str(nBasepoint)])
    temp=double(dat.Data.val(connectedCh,basePoint(n)*60*xmlParam.SampleRate+(-nFil:60*xmlParam.SampleRate+nFil)));
    temp=temp-medfilt1(temp,nFil,[],2);

    temp(:,[1:nFil,end-nFil+1:end])=[];
    base=[base,temp];
end

threshold=std(base,[],2)*3;

%%
cIdx=504;
targetSpk=spikeTimes(spikeClusters==cIdx);


subsample=sort(targetSpk(randperm(length(targetSpk),min([length(targetSpk),3000]))));

temp=dat.Data.val(connectedCh,subsample+[-nFil-nBef:nFil+nAft]);
temp=double(reshape(temp,size(temp,1),size(subsample,1),[]));

temp=temp-medfilt1(temp,nFil,[],3);
temp(:,:,[1:nFil,end-nFil+1:end])=[];

meanWave=squeeze(mean(temp,2));

ch=find(range(meanWave,2)>threshold);

wave=dat.Data.val(ch,targetSpk+[-nFil-nBef:nFil+nAft]);
wave=double(reshape(wave,size(wave,1),size(targetSpk,1),[]));

wave=wave-medfilt1(wave,nFil,[],3);
wave(:,:,[1:nFil,end-nFil+1:end])=[];

waveDev=wave-repmat(mean(wave,2),1,size(wave,2),1);
%%
clear score
for n=1:size(wave,1)
    [~,score(:,(1:nFet)+nFet*(n-1))]=pca(squeeze(waveDev(n,:,:)),'numComponents',nFet);
end
x=sum((score/cov(score)).*score,2);

p=chi2cdf(x,size(score,2),'upper');

isNoise=p<min([1/length(p),1e-5]);

%%
clear score
for n=1:size(wave,1)
    [~,score(:,(1:nFet)+nFet*(n-1))]=pca(squeeze(wave(n,:,:)),'numComponents',nFet);
end

x=sum((score/cov(score)).*score,2);

p=chi2cdf(x,size(score,2),'upper');

isNoise=p<min([1/length(p),1e-5]);

%%
totalWave=dat.Data.val(connectedCh,targetSpk+[-nFil-nBef:nFil+nAft]);
totalWave=double(reshape(totalWave,size(totalWave,1),size(targetSpk,1),[]));
totalWave=totalWave-medfilt1(totalWave,nFil,[],3);
totalWave(:,:,[1:nFil,end-nFil+1:end])=[];
%%
offset=0;
temp=totalWave-repmat(mean(totalWave,2),1,size(totalWave,2),1);


a=sum(sum(temp(ch,:,:).^2,1),3);

% okMean= squeeze(mean(totalWave(:,okID,:),2));
okMean= squeeze(mean(temp(:,okID,:),2));
%%
showCh=43:52;
noiseID=find(isNoise);

okID=find(~isNoise);
okMean= squeeze(mean(totalWave(:,okID,:),2));
%%
clf
offset=offset+20;

for m=1:20
    subplot(2,10,m)
    hold on
    for n=1:length(showCh)        
        if ismember(showCh(n),ch)
            col=[0,0,1];
        else
            col=0.5*[1,1,1];
        end
        plot(okMean(showCh(n),:)-1000*(n-1),'color',col)
        
        if isNoise(m+offset)
            col='r';
        else
            col='k';
        end
        
        plot(squeeze(totalWave(showCh(n),m+offset,:))-1000*(n-1),'color',col)
%         plot(squeeze(temp(showCh(n),m+offset,:))-1000*(n-1),'color',col)
    end
    xlim([1,41])
    ylim([-11000,500])
    title(p(m+offset))
end
%%



%%
% clear aveR
% toUse=double(~ismember(pos(:,1),unique(pos(ch,1))));
% (toUse*toUse').*tril(ones(length(toUse)),-1)
offset=offset+100
for n=1:100
    subplot(10,10,n)    
    r=corr(squeeze(totalWave(:,n+offset,:))');
    imagesc(r)
    set(gca,'clim',1*[-1,1])
    if p(n+offset)<1/length(p)
        title(['\color[rgb]{1,0,0}' num2str(p(n+offset))])
    else
        title(p(n+offset))
    end
end
%%
formatString = ['%d' repmat('\t%d',1,size(score,2)-1),'\n'];
UseFeatures=repmat('1',1,size(score,2));
     
tempFetFile=fullfile(rootDir,'temp.fet.1')
fh = fopen(tempFetFile,'w');
fprintf(fh, '%d\n',size(score,2));
fprintf(fh,formatString,round(score)');
fclose(fh);
        
kkpath='/usr/local/bin/klustakwik2';
    
eval(['! ' kkpath ' ' fullfile(rootDir,'temp') ' 1 -MinClusters 2 -MaxClusters 12 -Log 0 -UseDistributional 0  -UseFeatures ' UseFeatures]);

fh = fopen(fullfile(rootDir,'temp.clu.1'),'r');
newClu = textscan(fh,'%d');
fclose(fh);

newClu=newClu{1}(2:end);
%%
col=jet(10);
% for m=1:10
%     subplot(10,1,m)
%     hold on
%     for n=1:10
%         a=squeeze(mean(totalWave(showCh(m),newClu==n,:),2));
%         plot(a,'color',col(n,:))
%     end
% end

[~,order]=sort(std(score)./abs(mean(score)),'descend');

for n=1:4
subplot(2,2,n)
scatter3(score(:,order(3*n-2)),score(:,order(3*n-1)),score(:,order(3*n)),1,col(newClu,:))
end


%%
col=jet(10);
clf

for m=1:10
    subplot(1,10,m)
    hold on
    idx=find(newClu==m);
    idx=idx(randperm(length(idx),min([30,length(idx)])));
    
    for n=1:length(showCh)        
        
        plot(squeeze(totalWave(showCh(n),idx,:))'-1000*(n-1),'color',col(m,:))
%         plot(squeeze(temp(showCh(n),m+offset,:))-1000*(n-1),'color',col)
    end
    xlim([1,41])
    ylim([-11000,500])    
end


%%
nPlot=100;
clear manualJudge
close all
figure('position',[2400,1200,600,1500])


manualJudge=zeros(size(wave,2),1);

testCnt=1;
withinCnt=0;
nTotal=ceil(length(manualJudge)/nPlot);
while any(manualJudge<5)
    list=find(abs(manualJudge)<testCnt);
    if length(list)>nPlot
        if testCnt==1
            idx=list(1:nPlot);
        else
            idx=list(randperm(length(list),nPlot));
        end
    else
        withinCnt=0;
        idx=list;
        testCnt=testCnt+1;
        list=find(abs(manualJudge)<testCnt);
        idx=list(randperm(length(list),nPlot-length(idx)));
        
        nPlot=ceil(nPlot/3*2);
        nTotal=ceil(length(list)/nPlot);
    end
    
    withinCnt=withinCnt+1;
    
    clf
    hold on
    for n=1:length(showCh)      
        if ismember(showCh(n),ch)
            col=[1,0,0];
        else
            col=[0,0,1];
        end
        
        plot(squeeze(totalWave(showCh(n),idx,:))'-1750*(n-1),'k-')
        plot(okMean(showCh(n),:)-1750*(n-1),'color',col)
    end
    xlim([1,41])
    ylim([-17000,1000])
    title(sprintf('loop %d , part %d/%d- remain %d',testCnt,withinCnt,nTotal,length(list)))
    x=input('signal(s) or noise (n)?','s');
    if isempty(x)
        manualJudge(idx)=manualJudge(idx)+1;
    else
        manualJudge(idx)=inf;
    end
end
%%
for n=1:10
    [cnt,bin]=CCG(targetSpk,double(newClu),10,30,20e3,'count',n);
    subplot(3,4,n)
    title(n)
    bar(bin,cnt)
    xlim(15*[-1,1])
end

[cnt,bin]=CCG(targetSpk,1,20,30,20e3,'count');

subplot(3,4,11)
title(n)
bar(bin,cnt)
xlim(30*[-1,1])
%%
reClu=ismember(newClu,[1,4])+1;
CCG(targetSpk,reClu,20,30,20e3,'count');
%%
mean(aveR(noiseID))
mean(aveR(okID))

% % %%
% % pos=npy2mat(fullfile(rootDir,'channel_positions.npy'));
% % for n=1:size(meanWave,1)
% %     subplot2(10,10,pos(n,2)/8,pos(n,1))
% %     plot(meanWave(n,:),'k-')
% %     title(n)
% %     xlim([1,nBef+nAft+1])
% %     ylim([-1000,500])
% %     hold on
% %     plot([1,nBef+nAft+1],-threshold(n)*[1,1],'r-')
% % end







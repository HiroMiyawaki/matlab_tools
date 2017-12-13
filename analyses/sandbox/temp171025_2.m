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
cIdx=506;
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

%%
clear score
for n=1:size(wave,1)
    [~,score(:,(1:nFet)+nFet*(n-1))]=pca(squeeze(wave(n,:,:)),'numComponents',nFet);
end
%%

nSubset=round(size(score,1) /20000);

if nSubset >1
    optSubset=[' -Subset ' num2str(nSubset)];
else
    optSubset = 0;
end
formatString = ['%d' repmat('\t%d',1,size(score,2)-1),'\n'];
UseFeatures=repmat('1',1,size(score,2));
     
tempFetFile=fullfile(rootDir,'temp506.fet.1')
fh = fopen(tempFetFile,'w');
fprintf(fh, '%d\n',size(score,2));
fprintf(fh,formatString,round(score)');
fclose(fh);
        
kkpath='/usr/local/bin/klustakwik2';
    
tic;
disp([datestr(now)])
eval(['! ' kkpath ' ' fullfile(rootDir,'temp506') ' 1 -MinClusters 2 -MaxClusters 12 -MaxPossibleClusters 50 -Screen 0 -UseDistributional 0 -UseFeatures ' UseFeatures optSubset])
t=toc;
disp([datestr(now) t])

fh = fopen(fullfile(rootDir,'temp506.clu.1'),'r');
newClu = textscan(fh,'%d');
fclose(fh);

newClu=newClu{1}(2:end);

%%
totalWave=dat.Data.val(showCh,targetSpk+[-nFil-nBef:nFil+nAft]);
totalWave=double(reshape(totalWave,size(totalWave,1),size(targetSpk,1),[]));
totalWave=totalWave-medfilt1(totalWave,nFil,[],3);
totalWave(:,:,[1:nFil,end-nFil+1:end])=[];


%%

%%
col=[0,0,0;
     1,0,0;
     0,1,0;
     0,0,1];

 id=[];
 cIdx=[];
 nPoints=1400;
 subplot(2,2,1)
 
for n=1:4
    temp=find(newClu==n);
    nPoints=max([round(length(temp)*0.05),1400]);
    id=[id;temp(randperm(length(temp),nPoints))];
    cIdx=[cIdx;n*ones(nPoints,1)];
end
scatter3(score(id,1),score(id,2),score(id,3),1,col(cIdx,:))

subplot(1,2,2)
hold on
for n=1:4
    for m=1:length(showCh)
        plot(squeeze(mean(totalWave(m,newClu==n,:),2))-(m-1)*1500,'color',col(n,:))
    end    
end
xlim([1,41]);
ylim(1500*[-10,0.5]);
%%
% nSubSample=floor((sum(size(score))+1)/2);
% toUse=randperm(size(score,1),nSubSample)';
% 
% toUse=sort(toUse);
% 
% while 1
%     subScore=score(toUse,:);
%     if det(cov(subScore))==0
%         break
%     end
%     md=mahal(score,subScore);
%     [~,newUse]=sort(md);
%     newUse=sort(newUse(1:nSubSample));
%     nChangePos=sum(newUse~=toUse);
%     if nChangePos==0
%         disp([datestr(now) ' done'])
%         break
%     else
%         disp([datestr(now) ' ' num2str(nChangePos) ' points changed'])
%     end
%     toUse=newUse;
% end
% 
% p=chi2cdf(md.^2,size(score,2),'upper');


%%
col=[0,0,0;
     1,0,0;
     0,1,0;
     0,0,1];

 id=[];
 cIdx=[];
 nPoints=1400;
 subplot(2,2,1)
 
for n=1:4
    temp=find(newClu==n);
    nPoints=max([round(length(temp)*0.05),1400]);
    id=[id;temp(randperm(length(temp),nPoints))];
    cIdx=[cIdx;n*ones(nPoints,1)];
end
scatter3(score(id,1),score(id,2),score(id,3),1,col(cIdx,:))


 subplot(2,2,2)
fishy=find(p<max([1/length(p),1e-4]));
okish=find(p>max([1/length(p),1e-4]));
 id=[];
 cIdx=[];
for n=1%:2
    if n==1
        temp=fishy;
    else
        temp=okish;
    end
    nPoints=min([max([round(length(temp)*0.05),1400]),length(temp)]);
    id=[id;temp(randperm(length(temp),nPoints))];
    cIdx=[cIdx;n*ones(nPoints,1)];
end
scatter3(score(id,1),score(id,2),score(id,3),1,col(cIdx,:))

%%
clear scoreShank
for n=1:size(totalWave,1)
    [~,scoreShank(:,(1:nFet)+nFet*(n-1))]=pca(squeeze(totalWave(n,:,:)),'numComponents',nFet);
end
md=mahal(scoreShank,scoreShank);
p=chi2cdf(md,size(scoreShank,2),'upper');

for n=1:4
    mp(n)=mean(p(newClu==n));
end
%%





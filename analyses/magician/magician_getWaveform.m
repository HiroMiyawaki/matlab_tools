clear
load('~/data/OCU/implanted/magician/unitInfo.mat');

FileInfo=dir(fullfile('/Users/miyawaki/Desktop/removeNoise/','*dat'));
NChInDat=112;
dat = memmapfile(fullfile(FileInfo.folder,FileInfo.name), 'Format', {'int16', [NChInDat, (FileInfo.bytes/NChInDat/2)], 'data'});
for n=1:4
    chMap{n}=(1:8)+8*(n-1);
end
for n=5:10
    chMap{n}=(1:10)+32+10*(n-5);
end

nBef=16;
nAft=24;
nFil=33;
nFet=3;
%%
spk=double(npy2mat(fullfile(path,'spike_times.npy')));
clu=npy2mat(fullfile(path,'spike_clusters.npy'));

fh = fopen(fullfile(path,'cluster_groups.csv'),'r');
cluGrp = textscan(fh,'%s %s');
fclose(fh);

temp=cluGrp{1}(~strcmpi(cluGrp{2},'noise'));
cluList=cellfun(@str2num,temp(2:end));
cluGrp=cluGrp{2}(~strcmpi(cluGrp{2},'noise'))
cluGrp(1)=[];
%%
fileNameCore='~/data/OCU/implanted/magician/magician-kilo';

for n=1:length(chMap)
    
    fprintf('\n%s processing spikes on shanke %d\n',datestr(now),n);
    cID=[unitInfo.kilo(ismember([unitInfo.kilo.ch], chMap{n})).id];

    clu=kilo.clu(ismember(kilo.clu,cID));
    res=kilo.spk(ismember(kilo.clu,cID));

    clu(res<nBef+nFil | res>size(dat.Data.data,2)-nFil-nAft)=[];
    res(res<nBef+nFil | res>size(dat.Data.data,2)-nFil-nAft)=[];


    fprintf('    %s reading spikes (%d spikes)\n',datestr(now),length(clu));
    spk=dat.Data.data(chMap{n},res+(-nBef-nFil:nAft+nFil));
    spk=(reshape(spk,length(chMap{n}),size(res,1),nBef+nAft+2*nFil+1));
    fprintf('    %s filtering spikes\n',datestr(now));
    for m=1:size(spk,1)
        fsprintf('       %s %d/%d\n',datestr(now),m,size(spk,1));
        spk(m,:,:)=spk(m,:,:)-int16(medfilt1(double(spk(m,:,:)),nFil*2+1,[],3));
    end
    spk(:,:,[1:nFil,end-nFil+1:end])=[];

    fet=zeros(size(spk,2),nFet*length(chMap{n}));
    fsprintf('    %s getting PCA scores\n',datestr(now));
    for chCnt=1:size(spk,1)
        fprintf('       %s %d/%d\n',datestr(now),chCnt,size(spk,1));
        [~,fet(:,(1:nFet)+nFet*(chCnt-1))]=pca(double(squeeze(spk(chCnt,:,:))),'numComponents',nFet);
    end  

    fsprintf('    %s saving data\n',datestr(now));
    save(sprintf('%s_shank%02d.mat',fileNameCore,n),'clu','res','fet','-v7.3')
%     save(sprintf('%s_shank%02d-spk.mat',fileNameCore,n),'spk','-v7.3')
end

fprintf('\n%s done!\n\n',datestr(now));
%%
% filename='/Users/miyawaki/Desktop/kwik/magician_2017-09-19_06-10-17.kwx'
% 
% 
% fet=h5read(filename, sprintf('/channel_groups/%d/features_masks',shankIdx-1));



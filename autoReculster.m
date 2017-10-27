function threshold=autoReculster(path,varargin)
% recluster kilosort results with klustakwik
%
% threshold=autoReculster(path,[option])   
%
% Inputs
%   path: directory containing a dat file and its kilosort files.
%   option; various options, should be given as pair(s) of name and value
%           names are not case-sensitive.
% Outputs
%   threshold; threshold to determine channles with meaningful peaks
%
% Glossary of options and their default value
%   backup (true) :back up current rez.mat and *.npy files
%   update (true) :update rez.mat and *.npy files after processing
%   targetCluster ([]): list of cluster index to be reclustered. Do all when it's empty.
%   KKpath ('/usr/local/bin/klustakwik2') :path of Klustakwik
%   cutFreq (300) :cut-off frequency of median filter based high-pass filter
%   nBeforePeak (16) :number of points before spike peak 
%   nAfterPeak (24) :number of points after spike peak
%   nDeaturePerCh (3) :number of feature per channel
%   nbaseline (5) :number of baseline timepoints to get threshold. each baseline is 1-min duration.
%   threshold ([]) :list of thresholds (for each ch) to determine channles with meaningful peaks. when it's not given, decided base on dat.
%   nSubsetPercluster (3000) :number of spikes to determine on which channel a cluster is
%   nSpikeToUseRecluster (10000) :number of spikes used for KK (via Subset option)
%   getThresholdOnly (false)get threshold only. Do not do reclustering
%   maxNch (4): max number of channels used for re-clustering
%   doparallel (true) use parfor if possible
%
% Hiroyuki Miyawaki at Osaka City Univ, 2017 Oct.
%% inicialize parameters

    if mod(length(varargin),2)~=0
        error('Stopped due to wrong option')
    end
    
    backupNpy=true;
    updateNpy=true;
    kkpath='/usr/local/bin/klustakwik2';
    targetCluster=[];

    nBeforePeak=16;
    nAfterPeak=24;
    cutFreq=300;

    nBaseline=5;
    nFeaturePerCh=3;  
    nSubsetPerCluster=3000;
    nSpikeToUseRecluster=10000;
    
    threshold=[];
    getThresholdOnly=false;
    maxNCh=4;
    
    doParallel=true;
    
    
    for idx=1:length(varargin)/2
        name=lower(varargin{idx*2-1});
        val=varargin{idx*2};
        
        switch name
            case 'backup'
                %make backup
                backupNpy=val;
            case 'update'
                %update npy and rez.mat
                updateNpy=val;
            case 'targetcluster'
                %process all cluster when it's empty 
                targetCluster=val;
            case 'kkpath'
                %path of Klustakwik
                kkpath=val;
            case 'cutfreq'
                %cut-off frequency of median filter based high-pass filter
                cutFreq=val;
            case 'nbeforepeak'
                %number of points before spike peak 
                nBeforePeak=val;
            case 'nafterpeak'
                 %number of points after spike peak
                nAfterPeak=val;
            case 'nfeatureperch'
                 %number of feature per channel
                nFeaturePerCh=val;
            case 'nbaseline'
                %number of baseline timepoints to get threshold. 
                %each baseline is 1-min duration.
                %when threshold is given, it's ignored.
                nBaseline=val;
            case 'threshold'
                % threshold to determine channles with meaningful peaks
                % when it's not given, decided base on dat.
                threshold=val;  
            case 'nsubsetpercluster'
                % number of spikes to determine on which channel a cluster is
                nSubsetPerCluster=val;
            case 'nspiketouserecluster'
                % number of spikes used for KK (via Subset option)
                nSpikeToUseRecluster=val;
            case 'getthresholdonly'
                %get threshold only. Do not do reclustering
                getThresholdOnly=val;
            case 'maxnch'
                %max number of channels used for re-clustering
                maxNCh=val;
            case 'doparallel'
                %use parfor to filter waveforms
                doParallel=val;
            otherwise
            error(['Wrong option: ' name])
        end
    end    

    
    nFilHalf=ceil(1/cutFreq*rez.ops.fs);
    nFilHalf=floor(nFilHalf/2);
    
%% check files
    datFile=dir(fullfile(path,'*.dat'));
    
    switch length(datFile)
        case 0
            error('The directory does not have a dat file');
        case 1
            % only one dat file. 
        otherwise
            error('The directory has multiple dat files');
    end
    if ~getThresholdOnly
        if ~exist(fullfile(path,'rez.mat'),'file')
            error('The directory does not have rez.mat')
        end
        if ~exist(fullfile(path,'spike_clusters.npy'),'file')
            error('The directory does not have spike_clusters.npy')
        end
    end
    
%% back up files
    if backupNpy & ~getThresholdOnly
        backupDir=fullfile(path,'backup');
        nbackupDir=0;
        while exist(backupDir,'dir')
            nbackupDir=nbackupDir+1;
            backupDir=fullfile(path,['backup' num2str(nbackupDir)]);
        end
        mkdir(backupDir);
        
        backupFiles=dir(fullfile(path,'*.npy'));
        backupFiles={'rez.mat','cluster_groups.csv',backupFiles.name};

        for fIdx=1:length(backupFiles)
            disp([datestr(now) ' backing up ' backupFiles{fIdx}])
            status=copyfile(fullfile(path,backupFiles{fIdx}),...
                            fullfile(backupDir,backupFiles{fIdx}));
             if ~status
                 error(['Can not back up ' ,backupFiles{fIdx}])
             end             
        end
    else
            disp(['Npy files were NOT backed up'])
    end  

    disp([datestr(now) ' Loading rez.mat'])
    load(fullfile(path,'rez.mat'));

%     disp([datestr(now) 'Loading spike times'])
%     spk=npy2mat(fullfile(path,'spike_times.npy'));
%     spk=uint64(rez.st3(:,1));

    
    disp([datestr(now) ' Loading cluster ID'])
    spikeClusters=npy2mat(fullfile(path,'spike_clusters.npy'));

    spikeTimes = uint64(rez.st3(:,1));
    
%     spikeTemplates = uint32(rez.st3(:,2));
%     pcFeatureInds = uint32(rez.iNeighPC);
%     templateShank=rez.ops.kcoords(pcFeatureInds);
%     templateShank=templateShank(1,:);
    
%% mapping dat file

    nSample=datFile.bytes/rez.ops.NchanTOT/2;
    dat=memmapfile(fullfile(path,datFile.name),'Format', {'int16', [rez.ops.NchanTOT, nSample], 'val'});

%% threshold setting

if isempty(threshold) || getThresholdOnly
    baselineBegins=randperm(floor(nSample/rez.ops.fs/60)-1,nBaseline);
    base=[];
    disp('Getting thresholds')
    for baselineIdx=1:nBaseline
        disp(['    ' datestr(now) ' reading' num2str(baselineIdx) '/' num2str(nBaseline)])
        temp=double(dat.Data.val(rez.ops.chanMap,baselineBegins(baselineIdx)*60*rez.ops.fs+(-nFilHalf:60*rez.ops.fs+nFilHalf)));
        temp=temp-medfilt1(temp,nFilHalf*2+1,[],2);

        temp(:,[1:nFilHalf,end-nFilHalf+1:end])=[];
        base=[base,temp];
    end

    threshold=std(base,[],2)*3;
else
    disp('Given thresholds will be used')
end

if getThresholdOnly
    return
end

    %% check parallel computing toolbox
    if doParallel
        try
            parpool();
        catch
            disp('    Parallel Computing Toolbox is not avirable.')
            doParallel=false;
        end
    end
    
%%
    newSpikeCluster=zeros(size(spikeClusters));
    clusterCount=0;

    clusterList=unique(spikeClusters);
    
    if isempty(targetCluster)
        targetCluster=clusterList;
    end

    tempDir=fullfile(path,'temp');
    if ~exist(tempDir,'dir')    
        mkdir(tempDir);
    end
    
    
    targetCluIdx=0;
    for cluIdx=1:length(clusterList)    

        if ~ismember(clusterList(cluIdx),targetCluster)
            clusterCount=clusterCount+1;
            newSpikeCluster(idx)=clusterCount;
            disp([datestr(now) '  cluster ' num2str(clusterList(cluIdx)) ' was skipped (cluster index may be changed)'])
            continue
        end
        targetCluIdx=targetCluIdx+1;
        disp([datestr(now) ' start cluster ' num2str(clusterList(cluIdx)) ' (' num2str(targetCluIdx) '/' num2str(length(targetCluster)) ')'])
        idx=find(spikeClusters==clusterList(cluIdx));

        %read subset to determine which channels to be used 
        disp(['    ' datestr(now) ' deciding which chanels to be used '])
        
        subIdx=sort(idx(randperm(length(idx),min([length(idx),nSubsetPerCluster]))));   
        subIdx(spikeTimes(subIdx)<nBeforePeak+nFilHalf+1)=[];
        subIdx(spikeTimes(subIdx)>nSample-nAfterPeak-nFilHalf)=[];
        
        subWave=dat.Data.val(rez.ops.chanMap,double(spikeTimes(subIdx))+[-nFilHalf-nBeforePeak:nFilHalf+nAfterPeak]);
        subWave=double(reshape(subWave,size(subWave,1),size(subIdx,1),[]));
        subWave=subWave-medfilt1(subWave,nFilHalf*2+1,[],3);
        subWave(:,:,[1:nFilHalf,end-nFilHalf+1:end])=[];
        meanWave=squeeze(mean(subWave,2));

        amplitudes=range(meanWave,2);
        ch=find(amplitudes>threshold);              
        if isempty(ch)
            [~,ch]=max(range(meanWave,2));
            ch=rez.ops.chanMap(ch);
        elseif length(ch)>maxNCh
            [~,order]=sort(amplitudes(ch),'descend');
            disp(['    ' '    ' 'In total ' num2str(length(ch)) ' channels has significant amplitudes, but used top ' num2str(maxNCh) ' channels'])
            ch=ch(order(1:maxNCh));
        end

        disp(['    ' '    ' ' the following channels are used: ' num2str(ch')]);        
        disp(['    ' datestr(now) ' loading waveforms: ' num2str(length(ch)) 'ch x ' num2str(length(idx)) ' spikes']);
        
        onsetSpk=idx(spikeTimes(idx)<nBeforePeak+nFilHalf+1);
        offsetSpk=idx(spikeTimes(idx)>nSample-nAfterPeak-nFilHalf);
        okIdx=idx(spikeTimes(idx)>nBeforePeak+nFilHalf&spikeTimes(idx)<=nSample-nAfterPeak-nFilHalf);

        onsetWave=[];
        for n=1:length(onsetSpk)
            temp=dat.Data.val(ch,1:double(spikeTimes(onsetSpk(n)))+nFilHalf+nAfterPeak);            
            onsetWave(:,n,:)=[zeros(length(ch),nFilHalf+nBeforePeak+1+nAfterPeak+nFilHalf-size(temp,2)),temp];
        end
        
        
        offsetWave=[];
        for n=1:length(offsetSpk)
            temp=dat.Data.val(ch,double(spikeTimes(offsetSpk(n))):end);            
            offsetWave(:,n,:)=[temp,zeros(length(ch),nFilHalf+nBeforePeak+1+nAfterPeak+nFilHalf-size(temp,2))];
        end
        
        waveform=dat.Data.val(ch,double(spikeTimes(okIdx))+(-nFilHalf-nBeforePeak:nFilHalf+nAfterPeak));
        waveform=double(reshape(waveform,size(waveform,1),size(okIdx,1),nFilHalf+nBeforePeak+1+nAfterPeak+nFilHalf));
        
        waveform=cat(2,onsetWave,waveform,offsetWave);
        
        disp(['    ' datestr(now) ' filtering waveforms']);
        
        if doParallel
            nSpk=size(waveform,2);
            filteredWaveform=zeros(size(waveform));
            parfor n=1:nSpk
                filteredWaveform(:,n,:)=medfilt1(waveform(:,n,:),nFilHalf*2+1,[],3);
            end
        else
            filteredWaveform=medfilt1(waveform,nFilHalf*2+1,[],3);
        end
        waveform=waveform-filteredWaveform;
        waveform(:,:,[1:nFilHalf,end-nFilHalf+1:end])=[];


        disp(['    ' datestr(now) ' getting PCA score '])
        pcaScore=zeros(size(waveform,2),nFeaturePerCh*length(ch));
        for chCnt=1:size(waveform,1)
            [~,pcaScore(:,(1:nFeaturePerCh)+nFeaturePerCh*(chCnt-1))]=pca(squeeze(waveform(chCnt,:,:)),'numComponents',nFeaturePerCh);
        end     
        
        tempFileCore=fullfile(tempDir,['temp' num2str(clusterList(cluIdx))]);
        
        formatString = ['%d' repmat('\t%d',1,size(pcaScore,2)-1),'\n'];
        UseFeatures=repmat('1',1,size(pcaScore,2));

        fh = fopen([tempFileCore '.fet.1'],'w');
        fprintf(fh, '%d\n',size(pcaScore,2));
        fprintf(fh,formatString,round(pcaScore)');
        fclose(fh);
        
        nSubset=round(size(pcaScore,1) /nSpikeToUseRecluster);

        if nSubset >1
            optSubset=[' -Subset ' num2str(nSubset)];
        else
            optSubset = '';
            nSubset=1;
        end
        
        disp(sprintf(['    ' datestr(now) ' launch klustakwik for cluster %d (%d features x %d spikes, nSubset=%d)'],...
            clusterList(cluIdx),size(pcaScore,2),size(pcaScore,1),nSubset))
        tic
        eval(['! ' kkpath ' ' tempFileCore ' 1 -MinClusters 2 -MaxClusters 12 -Log 1 -MaxPossibleClusters 50 -Screen 0 -UseDistributional 0  -UseFeatures ' UseFeatures optSubset]);
        t=toc;
        
        fh = fopen([tempFileCore '.clu.1'],'r');
        newClu = textscan(fh,'%d');
        fclose(fh);
        
        
        disp(sprintf(['    ' datestr(now) ' finish klustakwik (took %f seconds, split into %d clusters)'],t,newClu{1}(1)))
        
        newSpikeCluster(idx)=newClu{1}(2:end)+clusterCount;
        clusterCount=clusterCount+double(newClu{1}(1));
    end
    
    if updateNpy
        rez.st3(:,5)=newSpikeCluster-1;
        disp([datestr(now) ' re-generating npy files'])
        rezToPhy(rez, path);
        
        if exist(fullfile(path,'cluster_groups.csv'),'file')
            delete(fullfile(path,'cluster_groups.csv'));
            disp([datestr(now) ' Delete cluster_groups.csv'])
        end
        
    else
        save(fullfile(path,'newSpikeCluster.mat'),'newSpikeCluster')
        disp('Npy files were NOT updated, but new clusers were saved in ')
        disp(fullfile(path,'newSpikeCluster.mat'))
    end
    
%     if exist(fullfile(path,'temp.fet.1'),'file')
%         delete(fullfile(path,'temp.fet.1'));
%     end
%     if exist(fullfile(path,'temp.clue.1'),'file')
%         delete(fullfile(path,'temp.clu.1'));
%     end
    
    disp('')
    disp([datestr(now) ' DONE!'])


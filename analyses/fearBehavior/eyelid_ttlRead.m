clear

for animalIdx=1
    switch animalIdx
        case 1
            dataRoot='~/data/OCU/eyelid_behavior/HR0019';
            dataName='experiment1_100_0';
            threshold=-2^14;

            nCh=8;
            evtCh=1:5;
            evtName={'tone1','tone2','shockTrigger','shockPulse','cameraTrigger'};
            cameraCh=6;
        case 2
            dataRoot='~/data/OCU/eyelid_behavior/HR0020';
            dataName='experiment1_100_0';
            threshold=-2^14;

            nCh=8;
            evtCh=1:5;
            evtName={'tone1','tone2','shockTrigger','shockPulse','cameraTrigger'};
            cameraCh=6;
        case 3
            dataRoot='~/data/OCU/eyelid_behavior/HR0021';
            dataName='experiment1_100_0';
            threshold=-2^14;

            nCh=8;
            evtCh=[1:6,8];
            evtName={'experiment','tone1','tone2','shockTrigger','shockPulse','cameraTrigger','led'};
            cameraCh=6;
    end

    clear temp
    temp=dir(dataRoot);
    
    dataDirList= {temp([temp.isdir]).name};
    dataDirList(isemptycell(regexp(dataDirList,'\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}')))=[];
    
    for dataIdx=1:length(dataDirList)
        dataDir=dataDirList{dataIdx};
        filename=fullfile(dataRoot,dataDir,[dataName '.dat']);
        fileInfo=dir(filename);
        
        dat = memmapfile(filename, 'Format', {'int16', [nCh, (fileInfo.bytes/nCh/2)], 'x'});
        
        clear temp
        for idx=1:length(evtCh)
            ch=evtCh(idx);
            temp=dat.Data.x(ch,:)>2^14;
            onset=find(diff(temp)==1)+1;
            offset=find(diff(temp)==-1);
            
            if isempty(onset)||isempty(offset); 
                onset=[];
                offset=[];
            else                
                if onset(1)>offset(1); offset(1)=[]; end
                if onset(end)>offset(end); onset(end)=[]; end
            end
            evt{idx}=[onset',offset'];
        end
        
        
        % sub=dat.Data.x(cameraCh,randperm(size(dat.Data.x,2),1e4));
        % for t=min(sub):300:max(sub)
        %     temp=sum(sub<t)*sum(sub>=t)*(mean(sub(sub<t))-mean(sub(sub>=t)))^2;
        %     if ~isnan(temp) && temp>maxVal; threshold=t; maxVal=temp; end
        % end
        % for t=threshold-300:threshold+300
        %     temp=sum(sub<t)*sum(sub>=t)*(mean(sub(sub<t))-mean(sub(sub>=t)))^2;
        %     if ~isnan(temp) && temp>maxVal; threshold=t; maxVal=temp; end
        % end
        temp=dat.Data.x(cameraCh,:)>threshold;
        onset=find(diff(temp)==1)+1;
        offset=find(diff(temp)==-1);
        if isempty(onset)||isempty(offset); 
            onset=[];
            offset=[];
        else          
            if onset(1)>offset(1); offset(1)=[]; end
            if onset(end)>offset(end); onset(end)=[]; end
        end
        
        if ~isempty(onset)
            if animalIdx==1
            ttlEvent.cameraShutter=removeTransient([onset',offset'],eps,0.5/1000*20e3,true);
            else
            ttlEvent.cameraShutter=removeTransient([onset',offset'],eps,5/1000*20e3,true);
            end
        else
            ttlEvent.cameraShutter=[];
        end
            
        for idx=1:length(evt)
            ttlEvent.(evtName{idx})=evt{idx};
        end
        param.madeby=mfilename;
        param.filename=filename;
        param.cameraThreshold=threshold;
        param.cameraCh=cameraCh;
        
        save([dataRoot '/' dataDir '-ttlEvent.mat'],'ttlEvent','param','-v7.3')
        
    end
end

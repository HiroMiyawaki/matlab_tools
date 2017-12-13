function mkCluFet(SpkFrame,SpkGrp,PeakPosList,FileName,CluNum)

    
    if length(unique(SpkGrp))~=length(PeakPosList)
        warnign('cluster number and peak number are not matched')
        exit
    end
    
    if length(SpkFrame)~=length(SpkGrp)
        warning('spike number and cluster number are not matched')
        exit
    end
    
    if size(SpkFrame,1)<size(SpkFrame,2)
        SpkFrame=SpkFrame';
    end
    
    if size(SpkGrp,1)<size(SpkGrp,2)
        SpkGrp=SpkGrp';
    end
    
    
    if size(PeakPosList,1)<size(PeakPosList,2)
        PeakPosList=PeakPosList';
    end
    
    PeakPosList = [PeakPosList,[1:size(PeakPosList,1)]'];

    [temp, idx] = sort(PeakPosList,1);
    
    PeakPosList = PeakPosList(idx(:,1),:);
    PeakPosList = [PeakPosList,[1:size(PeakPosList,1)]'];
    [temp, idx] = sort(PeakPosList,1);
    PeakPosList = PeakPosList(idx(:,2),:);
   
   
    
    SpkFrame = [SpkFrame,SpkGrp];
   [temp, idx] = sort(SpkFrame,1);
    
    SpkFrame = SpkFrame(idx(:,1),:);
    
    SpkFrame(:,2) = PeakPosList(SpkFrame(:,2),3);

   
     fh = fopen([FileName,'.',num2str(CluNum) '.clu'],'w');
     fprintf(fh,'%d\n',size(PeakPosList,2));
    fprintf(fh,'%d\n',SpkFrame(:,2));
    fclose(fh);
    
    fh = fopen([FileName,'.',num2str(CluNum) '.res'],'w');
    fprintf(fh,'%d\n',SpkFrame(:,1));
    fclose(fh);
    
end
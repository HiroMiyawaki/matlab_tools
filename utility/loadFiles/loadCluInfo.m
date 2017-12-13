function cluInfo=loadCluInfo(FileBase)
    rxml = xmltools([FileBase '.xml']);
    rxml = rxml.child(2);

    for n = 1:size(rxml.child,2)
        if strcmp(rxml.child(n).tag,'UNITS')
            rxml = rxml.child(n);
            break
        end
    end
    
        
    for n=1:length(rxml.child)
        group=0;
        cluster=0;
        quality=[];
        type=[];
        note=[];
        structure=[];
        isolation=[];
        for m=1:length(rxml.child(n).child)
            switch rxml.child(n).child(m).tag
            
                case 'GROUP'
                    group = str2double(rxml.child(n).child(m).value);
                    
                case 'CLUSTER'
                    cluster = str2double(rxml.child(n).child(m).value);
                
                case 'QUALITY'
                    quality = str2double(rxml.child(n).child(m).value);
                case 'TYPE'                    
                    type = str2double(rxml.child(n).child(m).value);                    
                case 'notes'
                    note = rxml.child(n).child(m).value;                    
                case 'structure'                    
                    structure = rxml.child(n).child(m).value;                    
                case 'isolationDistance'                    
                    structure = str2double(rxml.child(n).child(m).value);                                        
            end
        end
        
        if(group*cluster ~=0)
            if ~isempty(quality); cluInfo(group,cluster).quality=quality; end
            if ~isempty(group); cluInfo(group,cluster).group=group; end
            if ~isempty(cluster); cluInfo(group,cluster).cluster=cluster; end
            if ~isempty(type); cluInfo(group,cluster).type=type; end
            if ~isempty(note); cluInfo(group,cluster).note=note; end
            if ~isempty(structure); cluInfo(group,cluster).structure=structure; end
            if ~isempty(structure); cluInfo(group,cluster).structure=structure; end
        end
    end
end
      
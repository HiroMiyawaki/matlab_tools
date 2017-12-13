function units = LoadSpike2(FileBase,ShankList,SampleRate,Periods)
   %strcat(FileBase, '.res.' ,num2str(shank))
   %strcat(FileBase, '.clu.' ,num2str(shank))
   
   quality=loadQuality(FileBase);
   
   uNum=1;
   
   units=struct;
   
   for shank = ShankList
   
       resTemp = Loadres(strcat(FileBase, '.res.' ,num2str(shank)));
       cluTemp = LoadClu(strcat(FileBase, '.clu.' ,num2str(shank)));
       maxClu = max(cluTemp);
         if maxClu >0
             for(cluster = 1:maxClu)
                 index = find(cluTemp==cluster);
                 if ~isempty(index)
                     frame = [resTemp(index)];
                     
                     time = double(frame) *1e6/SampleRate+Periods(1,1);
                     for(p = 2:size(Periods,1))
                         time(time>Periods(p-1,2))=...
                             time(time>Periods(p-1,2)) + ...
                             (Periods(p,1) -Periods(p-1,2));
                     end
                     units(uNum).frame = frame';
                     units(uNum).time = time';
                     units(uNum).id=[shank,cluster];
                     if(cluster==1)
                        units(uNum).quality=9;
                     else
                         units(uNum).quality=quality(shank,cluster);
                     end
                     uNum=uNum+1;
                 end 
             end
        end
   end
end


function Quality = loadQuality(FileBase)
    rxml = xmltools([FileBase '.xml']);
    rxml = rxml.child(2);

    for n = 1:size(rxml.child,2)
        if strcmp(rxml.child(n).tag,'UNITS')
            rxml = rxml.child(n);
            break
        end
    end
    
    grp=0;
    clu=0;
    qua=0;
        
    for n=1:length(rxml.child)
        for m=1:length(rxml.child(n).child)
            switch rxml.child(n).child(m).tag
            
                case 'GROUP'
                    grp = str2num(rxml.child(n).child(m).value);
                    
                case 'CLUSTER'
                    clu = str2num(rxml.child(n).child(m).value);
                
                case 'QUALITY'
                    qua = str2num(rxml.child(n).child(m).value);
                    
%                 case 'notes'
%                 case 'structure'                    
%                 case 'type'                    
%                 case 'isolationDistance'                    
                    
            end
        end
        
        if(grp*clu*qua ~=0)
            Quality(grp,clu)=qua;
        end
        grp=0;
        clu=0;
        qua=0;
    end
end
            
                
           
  
function units = LoadSpike3(FileBase,ShankList,SampleRate,Periods)
   %strcat(FileBase, '.res.' ,num2str(shank))
   %strcat(FileBase, '.clu.' ,num2str(shank))
   
   quality=loadQuality(FileBase);
   
   uNum=1;
   
   units=struct;
   
   for shank = ShankList
   
       rest = Loadres(strcat(FileBase, '.res.' ,num2str(shank)));
       clut = LoadClu(strcat(FileBase, '.clu.' ,num2str(shank)));
       maxClu = max(clut);
         if maxClu >1
             for(cluster = 1:maxClu)
                 index = find(clut==cluster);
                 if ~isempty(index)
                     frame = [rest(index)];
                     
                     time = frame *1e6/SampleRate+Periods(1,1);
                     for(p = 2:size(Periods,1))
                         time(time>Periods(p-1,2))=...
                             time(time>Periods(p-1,2)) + ...
                             (Periods(p,1) -Periods(p-1,2));
                     end
                     
                     for p = 1:size(Periods,1)
                         idx = find(time>=Periods(p,1) & time <= Periods(p,2));
                        units(uNum,p).frame = frame(idx)';
                        units(uNum,p).time = time(idx)';
                        units(uNum,p).id=[shank,cluster];

                         if(cluster==1)
                            units(uNum,p).quality=9;
                         else
                             units(uNum,p).quality=quality(shank,cluster);
                         end
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
            
                
           
  
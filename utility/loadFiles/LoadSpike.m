function units = LoadSpike(FileBase,shank,sampleRate,tBegin,periods)
   %strcat(FileBase, '.res.' ,num2str(shank))
   %strcat(FileBase, '.clu.' ,num2str(shank))
   rest = Loadres(strcat(FileBase, '.res.' ,num2str(shank)));
   clut = LoadClu(strcat(FileBase, '.clu.' ,num2str(shank)));
   maxClu = max(clut);
   units={};
 	if maxClu >1
         for(k = 1:maxClu)
             index = find(clut==k);
             if ~isempty(index)
                 frame = [rest(index)];
                 units{k}.frame = frame;
                 frame = frame *1e6/sampleRate+tBegin;
                 for(p = 2:size(periods,1))
                     frame(frame>periods(p-1,2))=...
                         frame(frame>periods(p-1,2)) + ...
                         (periods(p,1) -periods(p-1,2));
                 end
                 units{k}.time = frame;
             end 
         end
    end
end
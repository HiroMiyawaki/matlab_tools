function removeXYfromFet(FileBase,ShankList)


    for n =1:length(ShankList)
        shank= ShankList(n);
        [Fet, nFeatures]=LoadFet([FileBase,'.fet.',num2str(shank)]);
    
         


        fh = fopen([FileBase,'.fet.',num2str(shank)],'w');
        fprintf(fh,'%d\n', nFeatures-2);
%        fprintf(fh,'%d\n', nFeatures);
        for m=1:size(Fet,1)
            fprintf(fh,'%d ', Fet(m,1:(nFeatures-3)));
            fprintf(fh,'%d\n', Fet(m,nFeatures));
        end

        fclose(fh);
    end
 
        
end
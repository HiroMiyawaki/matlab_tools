function Data=sortUnitsByPlace(Data,cellList,cluNum)

    [temp, indexies] = sort(cellList,1);

    newClu=[];
    newRes=[];
    k=2;
	for n = 1:size(cellList,1);
        newClu = [newClu;k*ones(size(Data.Spike{cellList(indexies(n,3),1)}{cellList(indexies(n,3),2)}.frame))];
        newRes = [newRes;Data.Spike{cellList(indexies(n,3),1)}{cellList(indexies(n,3),2)}.frame];
        k=k+1;
    end
   
    [newRes, indexies] = sort(newRes);
    newClu = newClu(indexies());
    
    fh = fopen([Data.FileBase,'.',num2str(cluNum) '.clu'],'w');
    fprintf(fh,'%d\n',size(cellList,1));
    fprintf(fh,'%d\n',newClu);
    fclose(fh);
    
    fh = fopen([Data.FileBase,'.',num2str(cluNum) '.res'],'w');
    fprintf(fh,'%d\n',newRes);
    fclose(fh);
    
end
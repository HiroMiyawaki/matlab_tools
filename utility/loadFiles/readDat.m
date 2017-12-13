function data = readDat(fileName,nCh) 
    fh = fopen(fileName);
    data = [fread(fh,[nCh,inf],'int16')]';
    fclose(fh);
end
    
function Periods=loadPeriods(FileName)

first=[];
last=[];

fh = fopen([FileName,'.dat.log']);
tline = fgetl(fh);
while ischar(tline)
    temp = sscanf(tline,'First timestamp written to dat : %lu us');
    if(~isempty(temp))
        first = [first;temp];
    end
    
    temp = sscanf(tline,'Last timestamp written to dat : %lu us');
    if(~isempty(temp))
        last = [last;temp];
    end
    
    tline = fgetl(fh);
end
fclose(fh);

Periods = [first,last];
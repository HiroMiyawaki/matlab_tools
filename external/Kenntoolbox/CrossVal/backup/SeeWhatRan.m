DataDir = '/u12/ken/data/pdata/no_spw/';
OutDir = '/u12/ken/data/pout/no_spw/';

DataFiles = SplitString(ls([DataDir '*.pdata'])); 

for i=1:length(DataFiles)
    df = DataFiles{i};
    LastSlash = max(find(df=='/'));
    LastDot = max(find(df=='.'));
    FileBase = df(LastSlash+1:LastDot-1);
    
    poutFile = [OutDir FileBase '.pout'];
    bpoutFile = [OutDir FileBase '.bpout'];
    
    fprintf('%d %d   :  %s\n', FileExists(poutFile), FileExists(bpoutFile), FileBase);
end
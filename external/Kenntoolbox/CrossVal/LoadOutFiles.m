% [pOut, pPar] LoadOutFiles(OutDir, FileBase)
%
% loads the first complete .pout or .bpout file in can find in 
% the specified directory OutDir, that comes from FileBase
% (/ will be replaced by _).

function [pOut, pPar] = LoadOutFiles(OutDir, FileBase)

FileBase2 = FileBase; 
FileBase2(find(FileBase2=='/'))='_';

% find all files in directory  
Files = dir([OutDir '/' FileBase2 '*out']);
    
% try all files, take the first one that loads
Loaded = 0;
for f=1:length(Files)
    try
        fprintf('Loading file %s\n', Files(f).name);
        [pOut pPar] = ReadPoutFile([OutDir '/' Files(f).name]);
        Loaded = 1;
        break;
    catch
        fprintf('Could not load file!\n');
    end
end

if Loaded==0
    pOut = [];
    pPar = [];
end
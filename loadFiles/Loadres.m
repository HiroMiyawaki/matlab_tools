% res = Loadres(FileName)
%
% A simple matlab function to load a .res file

function res = Loadres(FileName);

Fp = fopen(FileName, 'r');

if Fp==-1
    error(['Could not open file ' FileName]);
end

% nClusters = fscanf(Fp, '%d', 0);
% res = fscanf(Fp, '%d');
res = fscanf(Fp, '%ld');

fclose(Fp);
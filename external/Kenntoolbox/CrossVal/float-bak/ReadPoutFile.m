% [Out, Par] = ReadPoutFile(fName)
%
% reads a Assembly output file, which should end in 
% .pout (for little endian, linux format) or .bpout
% (for big endian sun format).
%
% This is a small function that determines which version and
% reads accoringly

function [Out, Par] = ReadPoutFile(fName)

fp = fopen(fName, 'r');
version = fread(fp, 'int');
fclose(fp);

if version==15
    [Out Par] = ReadPout15(fName);
elseif version==16
    [Out Par] = ReadPout15(fName);
else
    error('only can read version 15 or 16!');
end
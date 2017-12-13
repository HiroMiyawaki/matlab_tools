% [Out, Par] = ReadPoutFile(fName)
%
% reads a Assembly output file, which should end in 
% .pout (for little endian, linux format) or .bpout
% (for big endian sun format).
%
% This is a small function that determines which version and
% reads accoringly

function [Out, Par] = ReadPoutFile(fName)

AfterDot = fName(max(find(fName=='.')):end);
if strcmp(AfterDot, '.pout')
	fp = fopen(fName, 'r', 'ieee-le');
	version = fread(fp, 1, 'int');
	fclose(fp);
elseif strcmp(AfterDot, '.bpout')
  	fp = fopen(fName, 'r', 'ieee-be');
	version = fread(fp, 1, 'int');
	fclose(fp);
end  
    
if version==14
    [Out Par] = ReadPoutFile14(fName);
elseif version==15
    [Out Par] = ReadPoutFile15(fName);
elseif version==16
    [Out Par] = ReadPoutFile16(fName);
else
    error('only can read version 14 to 16!');
end
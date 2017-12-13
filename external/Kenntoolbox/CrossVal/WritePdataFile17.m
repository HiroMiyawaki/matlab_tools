% WritePdataFile(FileName, Data, Par)
% writes a .pdata file from structures Data and Par
% these should be the same format as would be produced
% by ReadPdataFile.
%
% FileName should end in .pdata or .bpdata ... which one 
% determines endianness

function WritePdataFile(DataFile, Data, Par)

% find out "endianness" from FileName

LastDot = max(find(DataFile=='.'));
Suffix = DataFile(LastDot+1:end);
if strcmp(Suffix, 'bpdata')
    fp = fopen([DataFile], 'w', 'ieee-be');
elseif strcmp(Suffix, 'pdata')
    fp = fopen([DataFile], 'w', 'ieee-le');
else
    error('DataFile must end in .pdata or .bpdata');
end

% diagnostics
if ~all(size(Par.CanPred)==size(Data.SpkCnt,2))
    error('length of Par.CanPred does not match SpkCnt');
end

% PARAMETER BLOCK
fwrite(fp, Par.VersionNumber, 'int');
fwrite(fp, Par.InternalFreq, 'double');
fwrite(fp, Par.SpaceGrid, 'int');
fwrite(fp, Par.Epsilon, 'double');
fwrite(fp, Par.EpsilonPh, 'double');
fwrite(fp, size(Data.SpkCnt,1), 'int');
fwrite(fp, size(Data.SpkCnt,2), 'int');
fwrite(fp, Par.nCrossVal, 'int');
fwrite(fp, length(Par.SpaceSm), 'int');
fwrite(fp, length(Par.TimeSm), 'int');
fwrite(fp, length(Par.PhSm), 'int');
fwrite(fp, Par.MaxIter, 'int'); % max iterations for poisson regression
fwrite(fp, Par.ConvergeThresh, 'double'); % will stop regression when deviance changes by no more than this
fwrite(fp, Par.DevUpThresh, 'double'); % deviance can increase this much without triggering add to hessian
fwrite(fp, Par.DevUpTerminateThresh, 'double');
fwrite(fp, Par.Ridge, 'double'); % ridge regression term (adds stability)
fwrite(fp, Par.MuCeiling, 'double'); % maximum value for predicted FR
fwrite(fp, Par.UnitAddMult, 'double'); % when adding to hessian, try this much each time
fwrite(fp, Par.UnitAddMaxSteps, 'int'); % up to this many times
fwrite(fp, Par.LinkFn, 'int'); % which link fn to use (0=Log)

% spatial smoothing values
fwrite(fp, Par.SpaceSm, 'double');
% temporal smoothing values
fwrite(fp, Par.TimeSm, 'double');
% phase smoothing values
fwrite(fp, Par.PhSm, 'double');
% tetrode IDs
fwrite(fp, Par.CanPred, 'int'); % this is the only change from version 16
fwrite(fp, 123456789, 'int');

% NOW DATA

% CV groups
fwrite(fp, Data.CVGroup, 'int');

% time 
fwrite(fp, Data.tReal, 'int');
% position
fwrite(fp, [Data.PosX Data.PosY Data.Ph]', 'double');

% theta phase 
% fwrite(fp, Data.ThPh, 'double');

% activity array
fwrite(fp, Data.SpkCnt', 'char');

fwrite(fp, 123456789, 'int');
fclose(fp);

return;


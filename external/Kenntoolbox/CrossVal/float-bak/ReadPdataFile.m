% [Data, Par] = ReadPDataFile(File)
%
% Data is a struct containing:
% CVGroup - which CV group each data point belongs to
% tReal - actual time of each point (in samples)
% PosX - rat x pos at each time
% PosY - rat y pos at each time
% SpkCnt - [nDataPoints x nCells] array giving spike counts in each segment


function [Data, Par] = ReadPDataFile(DataFile)


% if data file ends in .bpout, its big endian, if it ends in pout, it's little endian
LastDot = max(find(DataFile=='.'));
Suffix = DataFile(LastDot+1:end);
if strcmp(Suffix, 'bpdata')
    BigEnd=1;
elseif strcmp(Suffix, 'pdata')
    BigEnd=0;
else
    error('DataFile must end in .pdata or .bpdata');
end

if BigEnd
    fp = fopen([DataFile], 'r', 'ieee-be');
else
    fp = fopen([DataFile], 'r', 'ieee-le');
end

% PARAMETER BLOCK
Par.VersionNumber = fread(fp, 1, 'int');
Par.InternalFreq = fread(fp, 1, 'float');
Par.ExcludeSameTetrode = fread(fp, 1, 'int');
Par.SpaceGrid = fread(fp, 1, 'int');
Par.Epsilon = fread(fp, 1, 'float');
Par.EpsilonPh = fread(fp, 1, 'float');
Par.nData = fread(fp, 1, 'int');
Par.nCells = fread(fp, 1, 'int');
Par.nCrossVal = fread(fp, 1, 'int');
Par.nSpaceSm = fread(fp, 1, 'int');
Par.nTimeSm = fread(fp, 1, 'int');
Par.nPhSm = fread(fp, 1, 'int');
Par.MaxIter = fread(fp, 1, 'int'); % max iterations for poisson regression
Par.ConvergeThresh = fread(fp, 1, 'float'); % will stop regression when deviance changes by no more than this
Par.DevUpThresh = fread(fp, 1, 'float'); % deviance can increase this much without triggering add to hessian
Par.DevUpTerminateThresh = fread(fp, 1, 'float'); 
Par.Ridge = fread(fp, 1, 'float'); % ridge regression term (adds stability)
Par.MuCeiling = fread(fp, 1, 'float'); % maximum value for predicted FR
Par.UnitAddMult = fread(fp, 1, 'float'); % when adding to hessian, try this much each time
Par.UnitAddMaxSteps = fread(fp, 1,  'int'); % when adding to hessian, try this much each time
Par.LinkFn = fread(fp, 1, 'int');

% spatial smoothing values
Par.SpaceSm = fread(fp, Par.nSpaceSm, 'float');
% temporal smoothing values
Par.TimeSm = fread(fp, Par.nTimeSm, 'float');
% phase smoothing values
Par.PhSm = fread(fp, Par.nPhSm, 'float');
% tetrode IDs
Par.TetNo = fread(fp, Par.nCells, 'int');

Check = fread(fp, 1, 'int');
if Check~=123456789
    error(sprintf('Bad check value %d', Check));
end


% NOW DATA

% CV groups
Data.CVGroup = fread(fp, Par.nData, 'int');

% position
Data.tReal = fread(fp, Par.nData, 'int');
Pos = fread(fp, [3 Par.nData], 'float');
Data.PosX = Pos(1,:)';
Data.PosY = Pos(2,:)';
Data.Ph = Pos(3,:)';

% activity array
Data.SpkCnt = fread(fp, [Par.nCells Par.nData], 'char')';

Check = fread(fp, 1, 'int');
if Check~=123456789
    error(sprintf('Bad check value %d', Check));
end
fclose(fp);

return

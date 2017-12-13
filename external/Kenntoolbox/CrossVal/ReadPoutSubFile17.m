% [Out, Par] = ReadPoutSubFile17(fName)
%
% reads a single .pout.n file - given by fName
%
% returns a structure containing the file's info, which
% contains the following fields:
%
% Par contains parameters, named as in the README file
% SpaceSm, TimeSm, space and time smoothing parameter values
% CanPred, prediction matrix
%
% Out contains computation results:
% PlaceField(SpaceGrid,SpaceGrid,nCells,nCrossVal,nSpaceSm);
% Weight(nCells,nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm); indexed (From, To, ...)
% WeightSe(nCells,nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm); indexed (From, To, ...)
% fRate(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
% Status(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
% nIter(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
% LogL(nCells, nCrossVal, nTimeSm,nSpaceSm,nPhSm);
% BitsSec(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
% TotLogL(nCells,nTimeSm,nSpaceSm,nPhSm);
% TotBitsSec(nCells,nTimeSm,nSpaceSm,nPhSm);

function [Out, Par] = ReadPoutSubFile17(fName)

if ~FileExists(fName)
    error(sprintf('File %s not found!', fName));
end

DotPos = find(fName=='.');
nDots = length(DotPos);
if findstr(fName, '.temp')
    FileType = fName(DotPos(nDots-2)+1:DotPos(nDots-1)-1);
            fprintf('Loading temp file!\n');
else
    FileType  = fName(DotPos(nDots-1)+1:DotPos(nDots)-1);
end

if strcmp(FileType, 'pout')
    fp = fopen(fName, 'r', 'ieee-le');
elseif strcmp(FileType, 'bpout')
    fp = fopen(fName, 'r', 'ieee-be');
else
    error(sprintf('Unknown suffix %s on %s', FileType, fName));
end

% PARAMETER BLOCK
Par.VersionNumber = fread(fp, 1, 'int');
Par.InternalFreq = fread(fp, 1, 'double');
Par.SpaceGrid = fread(fp, 1, 'int');
Par.Epsilon  = fread(fp, 1, 'double');
Par.EpsilonPh  = fread(fp, 1, 'double');
Par.nDataPoints = fread(fp, 1, 'int');
Par.nCells = fread(fp, 1, 'int');
Par.nCrossVal = fread(fp, 1, 'int');
Par.nSpaceSm = fread(fp, 1, 'int');
Par.nTimeSm = fread(fp, 1, 'int');
Par.nPhSm = fread(fp, 1, 'int');
Par.MaxIter = fread(fp, 1,  'int'); % max iterations for poisson regression
Par.ConvergeThresh = fread(fp, 1,  'double'); % will stop regression when deviance changes by no more than this
Par.DevUpThresh = fread(fp, 1,  'double'); % deviance can increase this much without triggering add to hessian
Par.DevUpTerminateThresh = fread(fp, 1, 'double'); 
Par.Ridge = fread(fp, 1,  'double'); % ridge regression term (adds stability)
Par.MuCeiling = fread(fp, 1,  'double'); % maximum value for predicted FR
Par.UnitAddMult = fread(fp, 1,  'double'); % when adding to hessian, try this much each time
Par.UnitAddMaxSteps = fread(fp, 1,  'int'); % when adding to hessian, try this much each time
Par.LinkFn = fread(fp, 1, 'int');

Par.SpaceSm = fread(fp, Par.nSpaceSm, 'double');
Par.TimeSm = fread(fp, Par.nTimeSm, 'double');
Par.PhSm = fread(fp, Par.nPhSm, 'double');
Par.CanPred = fread(fp, Par.nCells*[1 1], 'int');

test = 0;
test = fread(fp, 1, 'int');
if test~=123456789
    error('Parameter block did not end correctly');
end

nCells = Par.nCells;
SpaceGrid = Par.SpaceGrid;
nCrossVal = Par.nCrossVal;

nSpaceSm = Par.nSpaceSm;
nTimeSm = Par.nTimeSm;
nPhSm = Par.nPhSm;

Out.PlaceField = zeros(SpaceGrid,SpaceGrid,1,nCrossVal,nSpaceSm);
Out.PhaseField = zeros(SpaceGrid,SpaceGrid,1,nCrossVal,nPhSm);
Out.kField = zeros(SpaceGrid,SpaceGrid,1,nCrossVal,nPhSm);
Out.Weight = zeros(nCells,1,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.WeightSe = zeros(nCells,1,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.fRate = zeros(1,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.Status = zeros(1,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.nIter = zeros(1,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.LogL = zeros(1, nCrossVal, nTimeSm,nSpaceSm,nPhSm);
Out.BitsSec = zeros(1,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.TotLogL = zeros(1,nTimeSm,nSpaceSm,nPhSm);
Out.TotBitsSec = zeros(1,nTimeSm,nSpaceSm,nPhSm);
Out.TotBitsSpike = zeros(1,nTimeSm,nSpaceSm,nPhSm);

c=1;
try            
   for ts=1:nTimeSm
% for ts = 8
        for ss=1:nSpaceSm
            for ps=1:nPhSm
                for cv=1:nCrossVal
                    if ts==1 & ps==1
                        Out.PlaceField(:,:,c,cv,ss) = fread(fp, [SpaceGrid SpaceGrid], 'double')';
                    end
                    if ts==1 & ss==1
                        Out.PhaseField(:,:,c,cv,ps) = fread(fp, [SpaceGrid SpaceGrid], 'double')';
                        Out.kField(:,:,c,cv,ps) = fread(fp, [SpaceGrid SpaceGrid], 'double')';
                    end
                    Out.Weight(:,c,cv,ts,ss,ps) = fread(fp, [nCells 1], 'double');
                    Out.WeightSe(:,c,cv,ts,ss,ps) = fread(fp, [nCells 1], 'double');
                    Out.fRate(c,cv,ts,ss,ps) = fread(fp, 1, 'double');
                    Out.Status(c,cv,ts,ss,ps) = fread(fp, 1, 'int');
                    Out.nIter(c,cv,ts,ss,ps) = fread(fp, 1, 'int');                
                    Out.LogL(c,cv,ts,ss,ps) = fread(fp, 1, 'double');                
                    Out.BitsSec(c,cv,ts,ss,ps) = fread(fp, 1, 'double');
                end
                Out.TotLogL(c,ts,ss,ps) = fread(fp, 1, 'double');
                Out.TotBitsSec(c,ts,ss,ps) = fread(fp, 1, 'double');
                Out.TotBitsSpike(c,ts,ss,ps) = fread(fp, 1, 'double');
            end
        end
    end
catch
    fprintf('Error %s while loading cell %d\n', lasterr, c);
%     keyboard
end

test = 0;
test = fread(fp, 1, 'int');
if test~=123456789
    error('Main block did not end correctly');
end
fclose(fp);
return

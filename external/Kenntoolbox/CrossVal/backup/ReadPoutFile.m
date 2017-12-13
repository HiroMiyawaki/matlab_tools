% [Out, Par] = ReadPoutFile(fName)
%
% reads a Assembly output file, which should end in 
% .pout (for little endian, linux format) or .bpout
% (for big endian sun format).
%
% returns a structure containing the file's info, which
% contains the following fields:
%
% Par contains parameters, named as in the README file
% SpaceSm, TimeSm, space and time smoothing parameter values
% TetNo, tetrode number assignments
%
% Out contains computation results:
% PlaceField(SpaceGrid,SpaceGrid,nCells,nCrossVal,nSpaceSm,nTimeSm);
% Weight(nCells,nCells,nCrossVal,nSpaceSm,nTimeSm); indexed (From, To, ...)
% Deriv(nCells,nCells,nCrossVal,nSpaceSm,nTimeSm); indexed (From, To, ...)
% Hess(nCells,nCells,nCells, nCrossVal,nSpaceSm,nTimeSm); indexed (From1, From2, To, ...)
% fRate(nCells,nCrossVal,nSpaceSm,nTimeSm);
% Status(nCells,nCrossVal,nSpaceSm,nTimeSm);
% nIter(nCells,nCrossVal,nSpaceSm,nTimeSm);
% LogL(nCells, nCrossVal, nSpaceSm,nTimeSm);
% BitsSec(nCells,nCrossVal,nSpaceSm,nTimeSm);
% TotLogL(nCells,nSpaceSm,nTimeSm);
% TotBitsSec(nCells,nSpaceSm,nTimeSm);

function [Out, Par] = ReadPoutFile(fName)

if ~FileExists(fName)
    error(sprintf('File %s not found!', fName));
end

if strcmp(fName(length(fName)-4:end), '.pout')
    fp = fopen(fName, 'r', 'ieee-le');
elseif strcmp(fName(length(fName)-5:end), '.bpout')
    fp = fopen(fName, 'r', 'ieee-be');
else
    error(sprintf('Unknown suffix on %s', fName));
end


% PARAMETER BLOCK
Par.VersionNumber = fread(fp, 1, 'int');
Par.InternalFreq = fread(fp, 1, 'float');
Par.ExcludeSameTetrode = fread(fp, 1, 'int');
Par.SpaceGrid = fread(fp, 1, 'int');
Par.Epsilon  = fread(fp, 1, 'float');
Par.nDataPoints = fread(fp, 1, 'int');
Par.nCells = fread(fp, 1, 'int');
Par.nCrossVal = fread(fp, 1, 'int');
Par.nSpaceSm = fread(fp, 1, 'int');
Par.nTimeSm = fread(fp, 1, 'int');
Par.MaxIter = fread(fp, 1,  'int'); % max iterations for poisson regression
Par.ConvergeThresh = fread(fp, 1,  'float'); % will stop regression when deviance changes by no more than this
Par.DevUpThresh = fread(fp, 1,  'float'); % deviance can increase this much without triggering add to hessian
Par.DevUpTerminateThresh = fread(fp, 1, 'float'); 
Par.Ridge = fread(fp, 1,  'float'); % ridge regression term (adds stability)
Par.MuCeiling = fread(fp, 1,  'float'); % maximum value for predicted FR
Par.UnitAddMult = fread(fp, 1,  'float'); % when adding to hessian, try this much each time
Par.LinkFn = fread(fp, 1, 'int');

Par.SpaceSm = fread(fp, Par.nSpaceSm, 'float');
Par.TimeSm = fread(fp, Par.nTimeSm, 'float');
Par.TetNo = fread(fp, Par.nCells, 'int');

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

Out.PlaceField = zeros(SpaceGrid,SpaceGrid,nCells,nCrossVal,nSpaceSm);
Out.Weight = zeros(nCells,nCells,nCrossVal,nSpaceSm,nTimeSm);
Out.Deriv = zeros(nCells,nCells,nCrossVal,nSpaceSm,nTimeSm);
Out.Hess = zeros(nCells,nCells,nCells,nCrossVal,nSpaceSm,nTimeSm);
Out.fRate = zeros(nCells,nCrossVal,nSpaceSm,nTimeSm);
Out.Status = zeros(nCells,nCrossVal,nSpaceSm,nTimeSm);
Out.nIter = zeros(nCells,nCrossVal,nSpaceSm,nTimeSm);
Out.LogL = zeros(nCells, nCrossVal, nSpaceSm,nTimeSm);
Out.BitsSec = zeros(nCells,nCrossVal,nSpaceSm,nTimeSm);
Out.TotLogL = zeros(nCells,nSpaceSm,nTimeSm);
Out.TotBitsSec = zeros(nCells,nSpaceSm,nTimeSm);
Out.TotBitsSpike = zeros(nCells,nSpaceSm,nTimeSm);

Predicted = find(Par.TetNo>0);
for c=Predicted(:)'
    for ts=1:nTimeSm
        for ss=1:nSpaceSm
            for cv=1:nCrossVal
                if ts==1
                    Out.PlaceField(:,:,c,cv,ss) = fread(fp, [SpaceGrid SpaceGrid], 'float')';
                end
                Out.Weight(:,c,cv,ss,ts) = fread(fp, [nCells 1], 'float');
                Out.Deriv(:,c,cv,ss,ts) = fread(fp, [nCells 1], 'float');
                Out.Hess(:,:,c,cv,ss,ts) = fread(fp, [nCells nCells], 'float');
                Out.fRate(c,cv,ss,ts) = fread(fp, 1, 'float');
                Out.Status(c,cv,ss,ts) = fread(fp, 1, 'int');
                Out.nIter(c,cv,ss,ts) = fread(fp, 1, 'int');                
                Out.LogL(c,cv,ss,ts) = fread(fp, 1, 'float');                
                Out.BitsSec(c,cv,ss,ts) = fread(fp, 1, 'float');
            end
            Out.TotLogL(c,ss,ts) = fread(fp, 1, 'float');
            Out.TotBitsSec(c,ss,ts) = fread(fp, 1, 'float');
            Out.TotBitsSpike(c,ss,ts) = fread(fp, 1, 'float');
        end
    end
end

test = 0;
test = fread(fp, 1, 'int');
if test~=123456789
    error('Main block did not end correctly');
end
fclose(fp);
return

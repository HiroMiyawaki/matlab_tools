% [Out, Par] = ReadPoutFile15(fName)
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
% PlaceField(SpaceGrid,SpaceGrid,nCells,nCrossVal,nSpaceSm);
% Weight(nCells,nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm); indexed (From, To, ...)
% Deriv(nCells,nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm); indexed (From, To, ...)
% Hess(nCells,nCells,nCells, nCrossVal,nTimeSm,nSpaceSm,nPhSm); indexed (From1, From2, To, ...)
% fRate(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
% Status(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
% nIter(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
% LogL(nCells, nCrossVal, nTimeSm,nSpaceSm,nPhSm);
% BitsSec(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
% TotLogL(nCells,nTimeSm,nSpaceSm,nPhSm);
% TotBitsSec(nCells,nTimeSm,nSpaceSm,nPhSm);

function [Out, Par] = ReadPoutFile15(fName)

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
Par.EpsilonPh  = fread(fp, 1, 'float');
Par.nDataPoints = fread(fp, 1, 'int');
Par.nCells = fread(fp, 1, 'int');
Par.nCrossVal = fread(fp, 1, 'int');
Par.nSpaceSm = fread(fp, 1, 'int');
Par.nTimeSm = fread(fp, 1, 'int');
Par.nPhSm = fread(fp, 1, 'int');
Par.MaxIter = fread(fp, 1,  'int'); % max iterations for poisson regression
Par.ConvergeThresh = fread(fp, 1,  'float'); % will stop regression when deviance changes by no more than this
Par.DevUpThresh = fread(fp, 1,  'float'); % deviance can increase this much without triggering add to hessian
Par.DevUpTerminateThresh = fread(fp, 1, 'float'); 
Par.Ridge = fread(fp, 1,  'float'); % ridge regression term (adds stability)
Par.MuCeiling = fread(fp, 1,  'float'); % maximum value for predicted FR
Par.UnitAddMult = fread(fp, 1,  'float'); % when adding to hessian, try this much each time
Par.UnitAddMaxSteps = fread(fp, 1,  'int'); % when adding to hessian, try this much each time
Par.LinkFn = fread(fp, 1, 'int');

Par.SpaceSm = fread(fp, Par.nSpaceSm, 'float');
Par.TimeSm = fread(fp, Par.nTimeSm, 'float');
Par.PhSm = fread(fp, Par.nPhSm, 'float');
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
nPhSm = Par.nPhSm;

Out.PlaceField = zeros(SpaceGrid,SpaceGrid,nCells,nCrossVal,nSpaceSm);
Out.PhaseField = zeros(SpaceGrid,SpaceGrid,nCells,nCrossVal,nPhSm);
Out.kField = zeros(SpaceGrid,SpaceGrid,nCells,nCrossVal,nPhSm);
Out.Weight = zeros(nCells,nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.Deriv = zeros(nCells,nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.Hess = zeros(nCells,nCells,nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.fRate = zeros(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.Status = zeros(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.nIter = zeros(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.LogL = zeros(nCells, nCrossVal, nTimeSm,nSpaceSm,nPhSm);
Out.BitsSec = zeros(nCells,nCrossVal,nTimeSm,nSpaceSm,nPhSm);
Out.TotLogL = zeros(nCells,nTimeSm,nSpaceSm,nPhSm);
Out.TotBitsSec = zeros(nCells,nTimeSm,nSpaceSm,nPhSm);
Out.TotBitsSpike = zeros(nCells,nTimeSm,nSpaceSm,nPhSm);

Predicted = find(Par.TetNo>0);
for c=Predicted(:)'
    try            
        for ts=1:nTimeSm
            for ss=1:nSpaceSm
                for ps=1:nPhSm
                    for cv=1:nCrossVal
                        if ts==1 & ps==1
                            Out.PlaceField(:,:,c,cv,ss) = fread(fp, [SpaceGrid SpaceGrid], 'float')';
                        end
                        if ts==1 & ss==1
                            Out.PhaseField(:,:,c,cv,ps) = fread(fp, [SpaceGrid SpaceGrid], 'float')';
                            Out.kField(:,:,c,cv,ps) = fread(fp, [SpaceGrid SpaceGrid], 'float')';
                        end
                        Out.Weight(:,c,cv,ts,ss,ps) = fread(fp, [nCells 1], 'float');
                        Out.Deriv(:,c,cv,ts,ss,ps) = fread(fp, [nCells 1], 'float');
                        Out.Hess(:,:,c,cv,ts,ss,ps) = fread(fp, [nCells nCells], 'float');
                        Out.fRate(c,cv,ts,ss,ps) = fread(fp, 1, 'float');
                        Out.Status(c,cv,ts,ss,ps) = fread(fp, 1, 'int');
                        Out.nIter(c,cv,ts,ss,ps) = fread(fp, 1, 'int');                
                        Out.LogL(c,cv,ts,ss,ps) = fread(fp, 1, 'float');                
                        Out.BitsSec(c,cv,ts,ss,ps) = fread(fp, 1, 'float');
                    end
                    Out.TotLogL(c,ts,ss,ps) = fread(fp, 1, 'float');
                    Out.TotBitsSec(c,ts,ss,ps) = fread(fp, 1, 'float');
                    Out.TotBitsSpike(c,ts,ss,ps) = fread(fp, 1, 'float');
                end
            end
        end
    catch
        fprintf('Error %s while loading cell %d\n', lasterr, c);
        keyboard
    end
end

test = 0;
test = fread(fp, 1, 'int');
if test~=123456789
    error('Main block did not end correctly');
end
fclose(fp);
return

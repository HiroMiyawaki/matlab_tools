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
if (length(Par.TetNo)~=size(Data.SpkCnt,2))
    error('length of Par.TetNo does not match SpkCnt');
end

% PARAMETER BLOCK
fwrite(fp, Par.VersionNumber, 'int');
fwrite(fp, Par.InternalFreq, 'double');
fwrite(fp, Par.ExcludeSameTetrode, 'int');
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
fwrite(fp, Par.TetNo, 'int');
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


return
% OLD VERSION

% WritePdataFile(DataFile, Res, Clu, Whl, TetNo, Par, SpaceSm, TimeSm, Epochs, InEpochs, OutEpochs)
%
% low level function called by CreatePdataFile
%
% will write a file FileBase.pdata from Res, Clu, Whl.
% optional last 3 arguments allow for subsetting for epochs (as got from db)
%
% SpaceSm is in 0..1 units
% TimeSm is in target samples (usually 1250Hz).
%
% don't forget that TetNo needs something for the unused cluster 1 (should be 0)
% since this becomes the constant term
%
% some of the arguments in Par will be ignored (ExcludeInterneurons and JustThisCell)
% - these are taken care of by CreatePdatafile
%
% DAMN ENDIANNESS!!!
% To make a file of big-endian format (for sun or ibm, etc), add final argument BigEnd as 1
% this will save the file as FileBase.bpdata.

function WritePdataFile(DataFile, Res, Clu, Whl, TetNo, Par, SpaceSm, TimeSm, Epochs, InEpochs, OutEpochs)

if nargin<9
    Epochs = [];
    InEpochs = {};
    OutEpochs = {};
end

% if data file ends in .bpdata, its big endian, if it ends in pdata, it's little endian
LastDot = max(find(DataFile=='.'));
Suffix = DataFile(LastDot+1:end);
if strcmp(Suffix, 'bpdata')
    BigEnd=1;
elseif strcmp(Suffix, 'pdata')
    BigEnd=0;
else
    error('DataFile must end in .pdata or .bpdata');
end
        
nWhl = size(Whl,1); 
nCells = max(Clu);

Whl = CleanWhl(Whl(:,1:2));

% some sanity checks
% check TetNo is right length
if length(TetNo)~= nCells
    error('TetNo is not right length');
end

% check .whl file is in range
if any(Whl(:)>=Par.MapSize)
    warning(sprintf('.whl file contains %d points larger than %d\n', Par.MapSize));
    Whl(find(Whl>=Par.MapSize)) = -1;
end

% Upsample .whl to 1250 Hz 
WhlRepeat = Par.InternalFreq/Par.WhlRate;
nData = nWhl*WhlRepeat;
tmp = repmat(Whl, [1 1 WhlRepeat]);
tmp2 = permute(tmp, [3 1 2]);
iWhl = reshape(tmp2, [nData, 2]); 

PosX = iWhl(:,1)/Par.MapSize;
PosY = iWhl(:,2)/Par.MapSize;

% Accumulate spike counts
SpkBin = 1+floor((Res-1)/Par.ResRate*Par.InternalFreq);
if any(SpkBin>nData)
    warning(sprintf('removing %d spikes that occurred beyond end of .whl file', sum(SpkBin>nData)));
    Clu(find(SpkBin>nData))=[];
    SpkBin(find(SpkBin>nData))=[];
end
if any(Clu==0)
    warning(sprintf('removing %d spikes of cluster 0', sum(Clu==0)));
    SpkBin(find(Clu==0)) = [];
    Clu(find(Clu==0)) = [];
end
SpkCnt = Accumulate([SpkBin, Clu], 1, [nData max(Clu)]);
SpkCnt(:,1) = 1; % overwrite cluster 1 with constant.


% which ones are in the correct epochs?

DatResTime = 1 + (0:nData-1)*Par.ResRate/Par.InternalFreq;
EpochOK = WithinEpochs(DatResTime, Epochs, InEpochs, OutEpochs);


% find good .whl entries
Good = find(PosX>=0 & PosY>=0 & EpochOK);
nGood = length(Good);

%%%
%%% write .pdata file
%%%

if BigEnd
    fp = fopen([DataFile], 'w', 'ieee-be');
else
    fp = fopen([DataFile], 'w', 'ieee-le');
end

% PARAMETER BLOCK
fwrite(fp, Par.VersionNumber, 'int');
fwrite(fp, Par.InternalFreq, 'double');
fwrite(fp, Par.ExcludeSameTetrode, 'int');
fwrite(fp, Par.SpaceGrid, 'int');
fwrite(fp, Par.Epsilon, 'double');
fwrite(fp, nGood, 'int');
fwrite(fp, nCells, 'int');
fwrite(fp, Par.nCrossVal, 'int');
fwrite(fp, length(SpaceSm), 'int');
fwrite(fp, length(TimeSm), 'int');
fwrite(fp, Par.MaxIter, 'int'); % max iterations for poisson regression
fwrite(fp, Par.ConvergeThresh, 'double'); % will stop regression when deviance changes by no more than this
fwrite(fp, Par.DevUpThresh, 'double'); % deviance can increase this much without triggering add to hessian
fwrite(fp, Par.DevUpTerminateThresh, 'double');
fwrite(fp, Par.Ridge, 'double'); % ridge regression term (adds stability)
fwrite(fp, Par.MuCeiling, 'double'); % maximum value for predicted FR
fwrite(fp, Par.UnitAddMult, 'double'); % when adding to hessian, try this much each time
fwrite(fp, Par.LinkFn, 'int'); % which link fn to use (0=Log)


% spatial smoothing values
fwrite(fp, SpaceSm, 'double');
% temporal smoothing values
fwrite(fp, TimeSm, 'double');
% tetrode IDs
fwrite(fp, TetNo, 'int');
fwrite(fp, 123456789, 'int');

% NOW DATA

% CV groups
CVGroup = -ones(1,nData);
CVGroup(Good) = floor((0:nGood-1)*Par.nCrossVal/nGood);
fwrite(fp, CVGroup(Good), 'int');

% time 
fwrite(fp, Good, 'int');
% position
fwrite(fp, [PosX(Good) PosY(Good)]', 'double');

% activity array
fwrite(fp, SpkCnt(Good,:)', 'char');

fwrite(fp, 123456789, 'int');
fclose(fp);
return
%keyboard
Whl = [PosX(Good) PosY(Good)];
PFPlus(ones(size(Whl))*.5, SpkCnt(Good,[1 3]), SpkCnt(Good,2), 1, 1);

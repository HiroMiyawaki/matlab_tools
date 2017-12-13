% [Data Par] = CreatePdataFile(FileBase, Par, InEpochs, OutEpochs)
%
% will create a file FileBase.pdata from a database entry (with res clu and whl files)
%
% Par should contain fields SpaceSm in 0..1 units, TimeSm is in target samples (1250Hz default).
% 
% this function will create Par.TetNo using Par fields ExcludeInterneurons, ExcludeSameTetrode
% and JustThisCell.  It will also create Par.nCells and Par.nData
%
% see also WritePdataFile, DefaultPPar

% example of use: 

function [Data, Par] = CreatePdataFile(FileBase, Par, InEpochs, OutEpochs)

if nargin<4
    InEpochs = {};
    OutEpochs = {};
end


% load res, clu, whl
Res = load([FileBase '.res']);
Clu = LoadClu([FileBase '.clu']);
Whl = load([FileBase '.whl']);
ThPh = bload([FileBase '.thph'], inf);
% get epochs
sql = sprintf('SELECT Type, Start, End FROM Epochs, Files WHERE Epochs.FileID=Files.FileID AND Files.FileBase = "%s";', FileBase);
[Epochs.Type, Epochs.Start, Epochs.End] = mysql(sql, 'extra', '%s %d %d');

% get cell types and tet numbers
Par.TetNo = [0;mysql(['select GpNo from View where FileBase = "' FileBase '"'], 'extra', '%d')];

% FINALLY REMEMBERED THIS LINE TO EXLUCDE INTERNEURONS
TypeAll = ['p';mysql(['select Type from View where FileBase = "' FileBase '"'], 'extra', '%c')];
if Par.ExcludeInterneurons
    Par.TetNo(find(TypeAll~='p')) = -1;
end

if Par.JustThisCell
    if ExcludeSameTetrode
        SameTet = find(Par.TetNo==Par.TetNo(JustThisCell));
        Par.TetNo = Par.TetNo*0;
        Par.TetNo(SameTet) = -1;
        Par.TetNo(JustThisCell)=1;
    else
        Par.TetNo = Par.TetNo*0;
        Par.TetNo(JustThisCell)=1;
    end
end

% WritePdataFile(DataFile, Res, Clu, Whl, TetNo, Par, SpaceSm, TimeSm, Epochs, InEpochs, OutEpochs)
nWhl = size(Whl,1); 
Par.nCells = max(Clu);

Whl = CleanWhl(Whl(:,1:2));
if length(Par.TetNo)~= Par.nCells
    error('TetNo is not right length');
end

% check .whl file is in range
BadPoints = find(any(Whl(:,1:2)>Par.MapSize,2));
if ~isempty(BadPoints)
    warning(sprintf('.whl file contains %d points larger than %d\n', ...
        length(BadPoints), sum(Par.MapSize)));
    Whl(BadPoints,:) = -1;
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
Par.nData = length(Good);

% create Data struct from Good entries
Data.PosX = PosX(Good);
Data.PosY = PosY(Good);
Data.SpkCnt = SpkCnt(Good,:);
Data.tReal = Good;
Data.CVGroup = floor((0:Par.nData-1)*Par.nCrossVal/Par.nData);

% theta phase
Data.Ph = ThPh(1+(Good-1)*Par.ThPhRate/Par.InternalFreq)*pi/2^15;

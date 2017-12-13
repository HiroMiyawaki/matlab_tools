% CreatePdataFile(FileBase, DataFile, Par, SpaceSm, TimeSm, InEpochs, OutEpochs)
%
% will create a file FileBase.pdata from a database entry (with res clu and whl files)
%
% SpaceSm is in 0..1 units
% TimeSm is in target samples (1250Hz default).
%
% don't forget that TetNo needs something for the unused cluster 1 (should be 0)
% since this becomes the constant term
%
% see also WritePdataFile, DefaultPPar

% example of use: 
% CreatePdataFile('/home/ken/Linkz/SRS/l12-B/l12-11/l12-11', 'l12-11Q.pdata', DefaultPPar, [-1 0.05], [-1 1], {'Theta'}, {});

function CeatePdataFile(FileBase, DataFile, Par, SpaceSm, TimeSm, InEpochs, OutEpochs)

if nargin<6
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

% load res, clu, whl
Res = load([FileBase '.res']);
Clu = LoadClu([FileBase '.clu']);
Whl = load([FileBase '.whl']);

% get epochs
sql = sprintf('SELECT Type, Start, End FROM Epochs, Files WHERE Epochs.FileID=Files.FileID AND Files.FileBase = "%s";', FileBase);
[Epochs.Type, Epochs.Start, Epochs.End] = mysql(sql, 'extra', '%s %d %d');

% get cell types and tet numbers
TetNo = [0;mysql(['select GpNo from View where FileBase = "' FileBase '"'], 'extra', '%d')];

% FINALLY REMEMBERED THIS LINE TO EXLUCDE INTERNEURONS
TypeAll = ['p';mysql(['select Type from View where FileBase = "' FileBase '"'], 'extra', '%c')];
if Par.ExcludeInterneurons
    TetNo(find(TypeAll~='p')) = -1;
end

if Par.JustThisCell
    if ExcludeSameTetrode
        SameTet = find(TetNo==TetNo(JustThisCell));
        TetNo = TetNo*0;
        TetNo(SameTet) = -1;
        TetNo(JustThisCell)=1;
    else
        TetNo = TetNo*0;
        TetNo(JustThisCell)=1;
    end
end

WritePdataFile(DataFile, Res, Clu, Whl, TetNo, Par, SpaceSm, TimeSm, Epochs, InEpochs, OutEpochs)

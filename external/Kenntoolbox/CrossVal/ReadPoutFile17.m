% [Out, Par] = ReadPoutFile17(FileBase)
%
% reads a set of Assembly output files, of the form
% FileBase.pout.n (for little endian, linux format) or 
% FileBase.bpout.n (for big endian sun format).
% there should be one file per target cell (that's n).
%
% returns a structure containing the file's info, which
% contains the following fields:
%
% Par contains parameters, named as in the README file
% SpaceSm, TimeSm, space and time smoothing parameter values
% Can, prediction matrix
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

function [Out, Par] = ReadPoutFile17(FileBase)

% find all subfiles
LsOut = ls([FileBase '*out.*']);
Files = SplitString(ls([FileBase '*out.*']));

if strcmp(Files{1}, 'ls:')
    fprintf('ReadPoutFile17: Nothing found for %s\n', FileBase);
    Out = [];
    Par = [];
    return;
end
    
fprintf('Reading filebase %s\n', FileBase);

% find cell numbers for those files
for i=1:length(Files)
    fName = Files{i};
    DotPos = find(fName=='.');
    nDots = length(DotPos);
    
    temppos = findstr(fName, '.temp');
    if ~isempty(temppos)
        CellNo(i) = str2num(fName(DotPos(nDots-1)+1:DotPos(nDots)-1));
    else  
        CellNo(i) = str2num(fName(DotPos(nDots)+1:end));
    end
end
[sorted order] = sort(CellNo);

% loop through subfiles
for i=fliplr(order(:)')
    c = CellNo(i);
    fprintf('Reading Cell %d\n', c);

    [SubOut SubPar] = ReadPoutSubFile17(Files{i});

    % first iteration, get Par, and size array sizes
    if i==order(end)
        Par = SubPar;
        
        Out.PlaceField = zeros(Par.SpaceGrid,Par.SpaceGrid,Par.nCells,Par.nCrossVal,Par.nSpaceSm);
		Out.PhaseField = zeros(Par.SpaceGrid,Par.SpaceGrid,Par.nCells,Par.nCrossVal,Par.nPhSm);
		Out.kField = zeros(Par.SpaceGrid,Par.SpaceGrid,Par.nCells,Par.nCrossVal,Par.nPhSm);
		Out.Weight = zeros(Par.nCells,Par.nCells,Par.nCrossVal,Par.nTimeSm,Par.nSpaceSm,Par.nPhSm);
		Out.WeightSe = zeros(Par.nCells,Par.nCells,Par.nCrossVal,Par.nTimeSm,Par.nSpaceSm,Par.nPhSm);
		Out.fRate = zeros(Par.nCells,Par.nCrossVal,Par.nTimeSm,Par.nSpaceSm,Par.nPhSm);
		Out.Status = zeros(Par.nCells,Par.nCrossVal,Par.nTimeSm,Par.nSpaceSm,Par.nPhSm);
		Out.nIter = zeros(Par.nCells,Par.nCrossVal,Par.nTimeSm,Par.nSpaceSm,Par.nPhSm);
		Out.LogL = zeros(Par.nCells, Par.nCrossVal, Par.nTimeSm,Par.nSpaceSm,Par.nPhSm);
		Out.BitsSec = zeros(Par.nCells,Par.nCrossVal,Par.nTimeSm,Par.nSpaceSm,Par.nPhSm);
		Out.TotLogL = zeros(Par.nCells,Par.nTimeSm,Par.nSpaceSm,Par.nPhSm);
		Out.TotBitsSec = zeros(Par.nCells,Par.nTimeSm,Par.nSpaceSm,Par.nPhSm);
		Out.TotBitsSpike = zeros(Par.nCells,Par.nTimeSm,Par.nSpaceSm,Par.nPhSm);

    elseif ~isequal(Par, SubPar)
        error(sprintf('Parameters for iteration %d different to iteration 1'), i);
    end

    Out.PlaceField(:,:,c,:,:) = SubOut.PlaceField;
    Out.PhaseField(:,:,c,:,:) = SubOut.PhaseField;
    Out.kField(:,:,c,:,:) = SubOut.kField;
    Out.Weight(:,c,:,:,:,:) = SubOut.Weight;
    Out.WeightSe(:,c,:,:,:,:) = SubOut.WeightSe;
    Out.fRate(c,:,:,:,:) = SubOut.fRate;
    Out.Status(c,:,:,:,:) = SubOut.Status;
    Out.nIter(c,:,:,:,:) = SubOut.nIter;
    Out.LogL(c,:,:,:,:) = SubOut.LogL;
    Out.BitsSec(c,:,:,:,:) = SubOut.BitsSec;
    Out.TotLogL(c,:,:,:) = SubOut.TotLogL;
    Out.TotBitsSec(c,:,:,:) = SubOut.TotBitsSec;
    Out.TotBitsSpike(c,:,:,:) = SubOut.TotBitsSpike;
%     keyboard
    
end

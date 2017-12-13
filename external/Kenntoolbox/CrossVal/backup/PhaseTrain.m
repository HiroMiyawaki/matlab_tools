% Params = PhaseTrain(Res, IndVars, TrainRange)
% training function for PhaseCrossVal
% IndVars should contain .t, .Whl, .Smooth, .Phase
% MapSize and Smooth are in UNSHRUNK coordinates - suggested vals
% 300 and ~8.  Maps are assumed square.
%
% Phase and Whl should have the same number of elements as t
% - so you need to upsample Whl to .eeg file frequency.
% Res should be in the same units as t
%
% .Whl and .PredArray are for all times.  TrainRange should keep occlusion times
% out of things ... this will be checked.

function Params = PhaseTrain(Res, IndVars, TrainRange)

t = IndVars.t;
Smooth = IndVars.Smooth; 
nGrid = 64;
%PredArray = IndVars.PredArray;
MapSize = IndVars.MapSize(1);
Phase = IndVars.Phase;

% check for even spacing
dt = t(2)-t(1);
if any(diff(t)~=dt)
	error('t must be equally spaced');
end

% bin spikes according to time
SpkCnt = histc(Res, [t(:); t(end)+dt]);

% find good time points and corresponding positions
Good = find(WithinRanges(t, TrainRange));

% divide Whl by MapSize to get Pos
Pos = IndVars.Whl(:,1:2)/MapSize;

% check .Pos is good
if any(Pos(Good,1)<0)
    error('TrainRange contains times where Pos<0!');
elseif any(~isfinite(Pos(Good,1)))
    error('TrainRange contains times where Pos is not finite!');
end


% make place map
if ~isempty(Phase)
	[Params.PlaceMap Params.Phi0 Params.k] = PFPhase(Pos(Good,:), Phase(Good), SpkCnt(Good), Smooth/MapSize, nGrid);
else
	[Params.PlaceMap Params.Phi0 Params.k] = PFPhase(Pos(Good,:), [], SpkCnt(Good), Smooth/MapSize, nGrid);
end
Params.PlaceMap = Params.PlaceMap/dt;
Params.x = MapSize*(1:nGrid)/(nGrid+1);
Params.y = MapSize*(1:nGrid)/(nGrid+1);
Params.fRate = mean(SpkCnt)/dt;

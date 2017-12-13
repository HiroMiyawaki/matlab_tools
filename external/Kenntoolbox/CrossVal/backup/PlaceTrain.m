% Params = PlaceTrain(Res, IndVars, TrainRange)
% training function for PlaceCrossVal - i.e. create a place field.
% IndVars should contain .t, .Whl, .MapSize, .Smooth, .Shrink
% MapSize and Smooth are in UNSHRUNK coordinates - suggested vals
% 300 and ~8.  Maps are assumed square.
function Params = PlaceTrain(Res, IndVars, TrainRange)

t = IndVars.t;
Whl = IndVars.Whl;
MapSize = IndVars.MapSize(1);
Smooth = IndVars.Smooth; 
nGrid = 64;
PFFn = IndVars.PFFn;

% check for even spacing
dt = t(2)-t(1);
if any(diff(t)~=dt)
	error('t must be equally spaced');
end

% bin spikes according to time
SpkCnt = histc(Res, [t(:); t(end)+dt]);

% find good time points and corresponding positions
Good = find(WithinRanges(t, TrainRange));

% make place map
Params.PlaceMap = feval(PFFn, Whl(Good,1:2)/MapSize, SpkCnt(Good), Smooth/MapSize, nGrid)/dt;
Params.x = MapSize*(1:nGrid)/(nGrid+1);
Params.y = MapSize*(1:nGrid)/(nGrid+1);
Params.fRate = mean(SpkCnt)/dt;

return

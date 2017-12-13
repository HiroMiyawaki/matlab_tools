% Params = PlacePhTrain(Res, IndVars, TrainRange)
% training function for PlaceCrossVal - i.e. create a place field.
% IndVars should contain .t, .Whl, .MapSize, .Smooth, .Shrink
%
% Smooth is in SHRUNK coordinates - NOT LIKE PlaceTrain!!!!!WATCH OUT! ACHTUNG ! 
% and should be nx2 i.e. [.1 .1 ; .1 .05]
function Params = PlacePhTrain(Res, IndVars, TrainRange)

t = IndVars.t;
Whl = IndVars.Whl;
ThPh = IndVars.ThPh;
MapSize = IndVars.MapSize(1);
Smooth = IndVars.Smooth; 
nGrid = [64 20];
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
Params.PlaceMap = feval(PFFn, Whl(Good,1:2)/MapSize, ThPh(Good), SpkCnt(Good), Smooth, nGrid)/dt;
Params.x = MapSize*(1:nGrid(1))/(nGrid(1)+1);
Params.y = MapSize*(1:nGrid(1))/(nGrid(1)+1);
%Params.ph = 2*pi*(1:nGrid(2))/(nGrid(2)+1);
Params.ph = 2*pi*(0:nGrid(2)-1)/(nGrid(2)-1); % naughty!
Params.fRate = mean(SpkCnt(Good))/dt;

return

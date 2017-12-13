% training function for BothCrossVal - i.e. create a place field with 
% IndVars should contain .t, .Whl, .Smooth, .PredArray
% MapSize and Smooth are in UNSHRUNK coordinates - suggested vals
% 300 and ~8.  Maps are assumed square.
%
% .Whl and .PredArray are for all times.  TrainRange should keep occlusion times
% out of things ... this will be checked.

function Params = BothTrain(Res, IndVars, TrainRange)

t = IndVars.t;
Smooth = IndVars.Smooth; 
nGrid = 64;
PredArray = IndVars.PredArray;
MapSize = IndVars.MapSize(1);

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
end


% make place map
[Params.PlaceMap Params.beta] = PFPlus(Pos(Good,:), PredArray(Good,:), SpkCnt(Good), Smooth, nGrid);
Params.x = MapSize*(1:nGrid)/(nGrid+1);
Params.y = MapSize*(1:nGrid)/(nGrid+1);
Params.fRate = mean(SpkCnt)/dt;

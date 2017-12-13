% test function for PlaceCrossVal
function [f, t] = PlaceTest(Params, IndVars, TestRange)

Good = find(WithinRanges(IndVars.t, TestRange));
t = IndVars.t(Good);
Pos = IndVars.Whl(Good,1:2);

% watch for out of range guys
Pos(find(Pos(:,1)<min(Params.x)),1) = min(Params.x);
Pos(find(Pos(:,1)>max(Params.x)),1) = max(Params.x);
Pos(find(Pos(:,2)<min(Params.y)),2) = min(Params.y);
Pos(find(Pos(:,2)>max(Params.y)),2) = max(Params.y);

% calculate positional factor
f = interp2(Params.x, Params.y, Params.PlaceMap', Pos(:,1), Pos(:,2));


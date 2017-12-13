% test function for PlaceCrossVal
function [f, t] = PlacePhTest(Params, IndVars, TestRange)

Good = find(WithinRanges(IndVars.t, TestRange));
t = IndVars.t(Good);
Pos = IndVars.Whl(Good,1:2);
ThPh = IndVars.ThPh(Good);

% watch for out of range guys
Pos(find(Pos(:,1)<min(Params.x)),1) = min(Params.x);
Pos(find(Pos(:,1)>max(Params.x)),1) = max(Params.x);
Pos(find(Pos(:,2)<min(Params.y)),2) = min(Params.y);
Pos(find(Pos(:,2)>max(Params.y)),2) = max(Params.y);

% calculate positional factor
f = interpn(Params.x, Params.y, Params.ph, Params.PlaceMap, Pos(:,1), Pos(:,2), mod(ThPh, 2*pi), 'nearest');

if any(~isfinite(f(:)))
    error('Could not interpolate place map');
end
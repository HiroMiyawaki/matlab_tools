function [f, t] = BothTest(Params, IndVars, TestRange)
% IndVars should have .PredArray and .t and .Whl
% Params should contain .beta

% find bins to test on
GoodBins = find(WithinRanges(IndVars.t, TestRange));
Pos = IndVars.Whl(GoodBins,1:2);

% watch for out of range guys
Pos(find(Pos(:,1)<min(Params.x)),1) = min(Params.x);
Pos(find(Pos(:,1)>max(Params.x)),1) = max(Params.x);
Pos(find(Pos(:,2)<min(Params.y)),2) = min(Params.y);
Pos(find(Pos(:,2)>max(Params.y)),2) = max(Params.y);

f = interp2(Params.x, Params.y, Params.PlaceMap', Pos(:,1), Pos(:,2)).* ...
    exp(IndVars.PredArray(GoodBins,:)*Params.beta)./IndVars.SampScl;
t = IndVars.t(GoodBins);
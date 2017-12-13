% [f, t] = PhaseTest(Params, IndVars, TestRange)
% test function for PhaseCrossVal
function [f, t] = PhaseTest(Params, IndVars, TestRange)

Good = find(WithinRanges(IndVars.t, TestRange));
t = IndVars.t(Good);
Pos = IndVars.Whl(Good,1:2);
if ~isempty(IndVars.Phase)
	Phase = IndVars.Phase(Good);
else
	Phase = zeros(size(Good));
end
	
% watch for out of range guys
Pos(find(Pos(:,1)<min(Params.x)),1) = min(Params.x);
Pos(find(Pos(:,1)>max(Params.x)),1) = max(Params.x);
Pos(find(Pos(:,2)<min(Params.y)),2) = min(Params.y);
Pos(find(Pos(:,2)>max(Params.y)),2) = max(Params.y);

% calculate positional factor
Positional = interp2(Params.x, Params.y, Params.PlaceMap', Pos(:,1), Pos(:,2));

% get von Mises parameters by interpolation
Phi0 = interp2(Params.x, Params.y, Params.Phi0', Pos(:,1), Pos(:,2));
k = interp2(Params.x, Params.y, Params.k', Pos(:,1), Pos(:,2));

% output is product.
f = Positional .* exp(k.*cos(Phase-Phi0)) ./ besseli(0,k);
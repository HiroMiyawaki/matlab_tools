function [f, t] = UnitTest(Params, IndVars, TestRange)
% IndVars should have .PredArray and .t
% Params should contain .beta

SampScl = 512;

% find bins to test on
GoodBins = find(WithinRanges(IndVars.t, TestRange));

f = exp(IndVars.PredArray(GoodBins,:)*Params.beta')./SampScl;
t = IndVars.t(GoodBins);

return
% OLD VERSION

tMin = min(TestRange(:,1));
tMax = max(TestRange(:,2));
BinSize = IndVars.BinSize;

% compute sub-bins
BinStarts = tMin:BinSize:tMax-BinSize;
BinEnds = tMin+BinSize-1:BinSize:tMax-1;

% use only those that lie wholly within a good section
GoodBins = [];
for i=1:length(BinStarts)
	if (any(BinStarts(i)>=TestRange(:,1) & BinEnds(i)<=TestRange(:,2)))
		GoodBins = [GoodBins i];
	end
end

% independent variables
[dummy bin] = histc(IndVars.Res, tMin:BinSize:tMax);
GoodSpk = find(bin~=0);
x = full(sparse(bin(GoodSpk), IndVars.Clu(GoodSpk), 1));

% compute estimated firing rate
f = exp(x(GoodBins,:)*Params.beta')./BinSize;

% compute center time for each bin
t = (BinStarts(GoodBins) + BinEnds(GoodBins))/2;

subplot(2,1,2)
plot(f);
drawnow
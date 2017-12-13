function Params = UnitTrain(Res, IndVars, TrainRange)
% IndVars should have .PredArray and .t

SampScl = 512;

% make spike count array for dependent variable
DepSpkCnt = full(sparse(1+floor((Res-1)/SampScl), 1, 1,size(IndVars.PredArray,1),1));

% find bins to train on
GoodBins = find(WithinRanges(IndVars.t, TrainRange));

% make target array
y = DepSpkCnt(GoodBins);

% make predictor array
x = IndVars.PredArray(GoodBins,:);

% find empty and non-empty rows of x (can't use empty ones in regression)
NotEmpty = find(any(x));
Empty = find(~any(x));

% do poisson regression
beta = poisson(y, x(:,NotEmpty));

% make output
Params.beta(NotEmpty) = beta;
Params.beta(Empty) = 0;

% evaluate likelihoods
mu = exp(x*Params.beta');
fRate = mean(y);

%l1 = sum(-mu + y.*log(mu))
%l2 = sum(-fRate + y.*log(fRate))

plot([y, exp(x*Params.beta')]);
%drawnow
return

% OLD VERSION
tMin = min(TrainRange(:,1));
tMax = max(TrainRange(:,2));
BinSize = IndVars.BinSize;

% compute sub-bins
BinStarts = tMin:BinSize:tMax-BinSize;
BinEnds = tMin+BinSize-1:BinSize:tMax-1;

% use only those that lie wholly within a good section
GoodBins = [];
for i=1:length(BinStarts)
	if (any(BinStarts(i)>=TrainRange(:,1) & BinEnds(i)<=TrainRange(:,2)))
		GoodBins = [GoodBins i];
	end
end

% dependent variable
y = histc(Res, tMin:BinSize:tMax);
y(end) = []; % lose final bin that contains ==tMax

% independent variables
[dummy bin] = histc(IndVars.Res, tMin:BinSize:tMax);
GoodSpk = find(bin~=0);
x = full(sparse(bin(GoodSpk), IndVars.Clu(GoodSpk), 1));

% can't use empty rows in x in regression
NotEmpty = find(any(x));
Empty = find(~any(x));

% do the poisson regression
beta = poisson(y(GoodBins), x(GoodBins,NotEmpty));
Params.beta(NotEmpty) = beta;
Params.beta(Empty) = 0;

subplot(2,1,1)
plot([y, exp(x*Params.beta')]);

% PlaceMap = PFpKernel(Pos, SpkCnt, Smooth, nGrid)
% Place field calculation by poisson-generalized kernel smoothing
%
% Pos is a nx2 array giving position in each epoch.  It should be in
% the range 0 to 1.  SpkCnt gives the number of spikes in each epoch.
%
% Smooth is the width of the Gaussian smoother to use (in 0...1 units).
%
% nGrid gives the grid spacing to evaluate on (should be larger than 1/Smooth)

function PlaceMap = PFpKernel(Pos, SpkCnt, Smooth, nGrid)

% integrized Pos (in the range 1...nGrid
iPos = 1+floor(nGrid*Pos/(1+eps));

% compute the smoothing filter
r = (-nGrid:nGrid)/nGrid;
Smoother = exp(-r.^2/Smooth^2/2);

% make initial estimate
eta = ones(size(SpkCnt))*log(mean(SpkCnt));

while 1
    mu = exp(eta);
    z = eta + (SpkCnt - mu)./mu;
    w = mu;
    
	% make unsmoothed arrays
	TimeSpent = full(sparse(iPos(:,1), iPos(:,2), w, nGrid, nGrid));
	Val = full(sparse(iPos(:,1), iPos(:,2), w.*z, nGrid, nGrid));
	
	sTimeSpent = conv2(Smoother, Smoother, TimeSpent, 'same');
	sVal = conv2(Smoother, Smoother, Val, 'same');
	
    logPlaceMap = sVal./sTimeSpent;
	PlaceMap = exp(logPlaceMap);
    
    eta1 = logPlaceMap(sub2ind([nGrid nGrid], iPos(:,1), iPos(:,2)));
    
    delta = sum(abs(eta-eta1));
    if (delta<1e-3) break; end;
    eta = eta1;

end

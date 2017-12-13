% PlaceMap = PFpLoess(Pos, SpkCnt, Smooth, nGrid)
% Place field calculation by poisson-generalized local regression
%
% Pos is a nx2 array giving position in each epoch.  It should be in
% the range 0 to 1.  SpkCnt gives the number of spikes in each epoch.
%
% Smooth is the width of the Gaussian smoother to use (in 0...1 units).
%
% nGrid gives the grid spacing to evaluate on (should be larger than 1/Smooth)

function PlaceMap = PFpLoess(Pos, SpkCnt, Smooth, nGrid)

n = size(Pos,1);

for xi=1:nGrid
    for yi=1:nGrid
        p0 = [xi yi]/(nGrid+1);
        
        % compute distances
        r2 = sum((Pos - p0(ones(n,1),:).^2,2);
        
        % compute Gaussian weights
        w = exp(-r2./Smooth^2/2);
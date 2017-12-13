% PlaceMap = PFTensor(Pos, SpkCnt, nKnots, nGrid)
% Place field calculation by tensor product splines
%
% Pos is a nx2 array giving position in each epoch.  It should be in
% the range 0 to 1.  SpkCnt gives the number of spikes in each epoch.
%
% nKnots = number of interior knots (>=0)
%
% nGrid gives the grid spacing to evaluate on (should be larger than 1/Smooth)

function PlaceMap = PFTensor(Pos, SpkCnt, nKnots, nGrid)

n = size(Pos,1);

Basis = [TensorBasis(Pos, nKnots), ones(n,1)];

% do a poisson regression
beta = poisson(SpkCnt, Basis,0,1);
%beta = glmfit(SpkCnt, Basis, 'poisson');

% now make evaluation grid

[gx, gy] = meshgrid((1:nGrid)/(nGrid+1), (1:nGrid)/(nGrid+1));
gGrid = [gx(:), gy(:)];

gBasis = [TensorBasis(gGrid, nKnots), ones(size(gGrid,1),1)];

PlaceMap = exp(reshape(gBasis*beta, [nGrid nGrid]))';

% PlaceMap = PFRBF(Pos, SpkCnt, Smooth, nGrid)
% Place field calculation by radial basis functions
%
% Pos is a nx2 array giving position in each epoch.  It should be in
% the range 0 to 1.  SpkCnt gives the number of spikes in each epoch.
%
% Smooth is 1 over the basis grid size.
%
% nGrid gives the grid spacing to evaluate on (should be larger than 1/Smooth)

function PlaceMap = PFRBF(Pos, SpkCnt, Smooth, nGrid)

% linear splines

% make grid of basis points
fn = inline('exp(-r.^2)');

n = size(Pos,1);

if 1    
    bGrid = Pos(1:n/Smooth:end,:);
else        
    bStep = 1/floor(1/Smooth);
    [bx, by] = meshgrid(0:bStep:1, 0:bStep:1);
    bGrid = [bx(:), by(:)];
end

Basis = [RadialBasis(bGrid, Pos, fn), ones(n,1)];

% do a poisson regression
%beta = poisson(SpkCnt, Basis,0,1);
beta = glmfit(SpkCnt, Basis, 'poisson');

% now make evaluation grid

[gx, gy] = meshgrid((1:nGrid)/(nGrid+1), (1:nGrid)/(nGrid+1));
gGrid = [gx(:), gy(:)];

gBasis = [RadialBasis(bGrid, gGrid, fn), ones(size(gGrid,1),1)];

PlaceMap = exp(reshape(gBasis*beta, [nGrid nGrid]))';

clf
imagesc(clip(PlaceMap,0,10));
colorbar
drawnow
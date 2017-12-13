% PlaceMap = PFNeural(Pos, SpkCnt, nHidden, nGrid)
% Place field calculation by neural network with a poisson output node
%
% Pos is a nx2 array giving position in each epoch.  It should be in
% the range 0 to 1.  SpkCnt gives the number of spikes in each epoch.
%
% nHidden = number of hidden nodes
%
% nGrid gives the grid spacing to evaluate on (should be larger than 1/Smooth)

function PlaceMap = PFClassic(Pos, SpkCnt, nHidden, nGrid)

% make net
net = mlp(2, nHidden, 1, 'poisson');

%[net error] = mlptrain(net, Pos, SpkCnt, 100);

options = zeros(1,18);
options(1) = 1;        % To prevent any messages at all
options(2) = 1;
options(3) = 1e-4;
options(9) = 0;
options(14) = 500;

[net, options] = netopt(net, options, Pos, SpkCnt, 'quasinew');
                                                        

% make grid
[gx, gy] = meshgrid((1:nGrid)/(nGrid+1), (1:nGrid)/(nGrid+1));
gGrid = [gx(:), gy(:)];

PlaceMap = reshape(mlpfwd(net, gGrid), [nGrid nGrid])';

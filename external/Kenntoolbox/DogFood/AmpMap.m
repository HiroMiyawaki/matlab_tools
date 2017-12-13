% [Amp Cnt] = PhaseMap(Pos, A, Smooth, nGrid)
% Makes an "amplitude map" from position Pos and amplitude  A of each spike
% works by dividing the smoothed amplitude sum by the smoothed occ. map
%
% Pos is a nx2 array giving position in each epoch.  It should be in
% the range 0 to 1.  SpkCnt gives the number of spikes in each epoch.
%
% Smooth is the width of the Gaussian smoother to use (in 0...1 units).
%
% nGrid gives the grid spacing to evaluate on (should be larger than 1/Smooth)
%
% output Amp is the mean amplitude Cnt is spike count (for PFPlot)


function [Amp, sn] = AmpMap(Pos, A, Smooth, nGrid)


% integrized Pos (in the range 1...nGrid
iPos = 1+floor(nGrid*Pos/(1+eps));

% make unsmoothed arrays
n = full(sparse(iPos(:,1), iPos(:,2), 1, nGrid, nGrid));
AVec = full(sparse(iPos(:,1), iPos(:,2), A, nGrid, nGrid));

% do the smoothing
r = (-nGrid:nGrid)/nGrid;
Smoother = exp(-r.^2/Smooth^2/2);

sn = conv2(Smoother, Smoother, n, 'same');
sA = conv2(Smoother, Smoother, AVec, 'same');

Amp = sA./(sn+eps);


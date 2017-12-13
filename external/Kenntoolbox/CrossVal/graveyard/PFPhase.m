% [PlaceMap Phi0 k] = PFPhase(Pos, Phase, SpkCnt, Smooth, nGrid)
% Place field calculation with help from phase.
%
% Pos is a nx2 array giving position in each epoch.  It should be in
% the range 0 to 1.  SpkCnt gives the number of spikes in each epoch.
%
% Phase gives the theta phase in radians for each epoch. (it's recommended that you
% use 800 us epochs, i.e. .eeg file - but you don't have to)
%
% Smooth is the width of the Gaussian smoother to use (in 0...1 units).
%
% nGrid gives the grid spacing to evaluate on (should be larger than 1/Smooth)
%
% Outputs - PlaceMap, Phi, and k give nGridxnGrid output arrays
% predicted # spikes per epoch is Poisson distributed with parameter
% mu = PlaceMap * exp(k*cos(Phase-Phi0))/besseli(0,k) % note no factor of 2*pi

function [PlaceMap, Phi0, k] = PFPhase(Pos, Phase, SpkCnt, Smooth, nGrid)

% integrized Pos (in the range 1...nGrid
iPos = 1+floor(nGrid*Pos/(1+eps));

% make unsmoothed arrays
TimeSpent = full(sparse(iPos(:,1), iPos(:,2), 1, nGrid, nGrid));
nSpikes = full(sparse(iPos(:,1), iPos(:,2), SpkCnt, nGrid, nGrid));

% do the smoothing
r = (-nGrid:nGrid)/nGrid;
Smoother = exp(-r.^2/Smooth^2/2);

sTimeSpent = conv2(Smoother, Smoother, TimeSpent, 'same');
snSpikes = conv2(Smoother, Smoother, nSpikes, 'same');

PlaceMap = snSpikes./(sTimeSpent+eps);

% now do phase, if specified
if isempty(Phase)
	k = zeros(nGrid);
	Phi0 = zeros(nGrid);
else
	ComplexVec = full(sparse(iPos(:,1), iPos(:,2), exp(i*Phase).*SpkCnt, nGrid, nGrid));
	sComplexVec = conv2(Smoother, Smoother, ComplexVec, 'same');
	EstComplex = sComplexVec./(snSpikes+1);

	% get parameters of Von Mises distribution
	Phi0 = angle(EstComplex);
	% need to do interpolation to find k parameter ...
	x = 0:.01:100;
	y = besseli(1,x)./besseli(0,x);
	k = interp1(y,x,abs(abs(EstComplex)));
end

%if nargout==0
	subplot(1,3,1)
	colormap jet;
   imagesc(PlaceMap);
   title('Firing Rate');
   subplot(1,3,2);
   imagesc(Phi0);
   colorbar
   subplot(1,3,3);
   imagesc(k);
   colorbar
   drawnow
%end

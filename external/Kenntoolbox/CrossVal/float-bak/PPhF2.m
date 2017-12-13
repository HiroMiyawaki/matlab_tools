% [PlaceMap, OccupancyMap] = PPhF(Pos, ThPh, SpkCnt, Smooth, nGrid, TopRate)
% (Place and phase) field calculation, by kernel in 3d.
%
% A spike count map over (Place x Phase) is constructed and divided by a smoothed
% occupancy map.
%
% Pos is a nx2 array giving position in each epoch.  It should be in
% the range 0 to 1.  SpkCnt gives the number of spikes in each epoch.
%
% ThPh gives theta phase at time of each Pos.  It will be modded by 2*pi - 
% - - - so you don't have to!
%
% Smooth is a 2x1 array giving the width of the Gaussian smoother to use
% in space (in 0...1 units) and the k of the Von Mises smoother to use in phase
%
% nGrid is a 2x1 array gives the grid spacing to evaluate on in space and phase
% (should be larger than 1/Smooth)
%
% TopRate is for the maximum firing rate on the color map (if you display it)
% if you don't specify this it will be the maximum value
%
% optional output OccupancyMap is a smoothed occupancy map

function [PlaceMap, sTimeSpent] = PPhF(Pos, ThPh, SpkCnt, Smooth, nGrid, Epsilon)

% when the rat spends less than this many time points near a place,
% start to dim the place field
TimeThresh = 4;

nG1 = nGrid(1); nG2 = nGrid(2);

% integrized Pos (in the range 1...nGrid
iPos = 1+floor(nG1*Pos/(1+eps));

iPh = 1+floor(nG2*mod(ThPh/2/pi, 1));

% make unsmoothed arrays
TimeSpent = Accumulate([iPos(:,1:2), iPh(:)], 1, nGrid([1 1 2]));
nSpikes = Accumulate([iPos(:,1:2), iPh(:)], SpkCnt, nGrid([1 1 2]));

% make place smoothers
r = (-nG1:nG1)'/nG1;
if Smooth(1)>0
    PosSmoother = exp(-r.^2/Smooth(1)^2/2);
else
    PosSmoother = ones(size(r));
end

% make phase smoothers - one cycle, exp(k*cos(th));
th = (0:(nG2-1))'*2*pi/nG2;
if Smooth(2)>0
    PhSmoother = exp(Smooth(2)*cos(th));
else
    PhSmoother = ones(nG2,1);
end

% do the smoothing - 1 dim at a time
sTimeSpent1 = convn(TimeSpent, PosSmoother, 'same');
sTimeSpent2 = convn(sTimeSpent1, shiftdim(PosSmoother,-1), 'same');
sTimeSpent3 = convn(sTimeSpent2, shiftdim(PhSmoother,-2));
% wrap it
sTimeSpent = sTimeSpent3(:,:,1:nG2);
sTimeSpent(:,:,1:nG2-1) = sTimeSpent(:,:,1:nG2-1) + sTimeSpent3(:,:,nG2+1:end);


% space dimensions
snSpikes1 = convn(nSpikes, PosSmoother, 'same');
snSpikes2 = convn(snSpikes1, shiftdim(PosSmoother,-1), 'same');

% phase dimension on a circle
snSpikes3 = convn(snSpikes2, shiftdim(PhSmoother,-2));
% wrap it
snSpikes = snSpikes3(:,:,1:nG2);
snSpikes(:,:,1:nG2-1) = snSpikes(:,:,1:nG2-1) + snSpikes3(:,:,nG2+1:end);



PlaceMap = (snSpikes+Epsilon)./(sTimeSpent+Epsilon);

if nargout==0
    FireRate = PlaceMap*312.5;
    TopRate = max(PlaceMap(:));
    for i=1:size(PlaceMap,3)
        subplot(1,size(PlaceMap,3), i)
    	PFPlot(PlaceMap(:,:,i), sTimeSpent(:,:,i), TopRate, TimeThresh);
        axis off
%        imagesc(PlaceMap(:,:,i)); colorbar;
    end
end

return
% test data
ParT = DefaultPPar;
n = 1e5;
DataT.PosX = rand(n,1);
DataT.PosY = rand(n,1);
DataT.Ph = mod((1:n)' * 8 * 2*pi / ParT.InternalFreq, 2*pi);
DataT.SpkCnt = rand(n,1)>.9 & DataT.Ph>pi;
DataT.CVGroup = floor((1:n)*10/n);
% PPhF([DataT.PosX DataT.PosY], DataT.Ph, DataT.SpkCnt, [1 .1], [64 16], 1e-12);

ParT.TimeSm = -1; ParT.SpaceSm = [-1 0.05]; ParT.PhSm = [-1 1];
ParT.TetNo = 1;
ParT.nCells = 1;
ParT.nData = length(DataT.Ph);

Data = DataT;
Par = ParT;
Assembly
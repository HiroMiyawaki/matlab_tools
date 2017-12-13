% [PlaceMap, OccupancyMap, PhaseMap, kMap] = PPhF(Pos, ThPh, SpkCnt, Smooth, nGrid, Epsilon)
% (Place and phase) field calculation, by local Von Mises fit
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

function [PlaceMap, sTimeSpent, PhaseMap, kMap] = PPhF(Pos, Ph, SpkCnt, Smooth, nGrid, Epsilon)

% when the rat spends less than this many time points near a place,
% start to dim the place field

% integrized Pos (in the range 1...nGrid
iPos = 1+floor(nGrid*Pos/(1+eps));

% make unsmoothed arrays
TimeSpent = Accumulate(iPos(:,1:2), 1, nGrid*[1 1]);
nSpikes = Accumulate(iPos(:,1:2), SpkCnt, nGrid*[1 1]);
PhSum = Accumulate(iPos(:,1:2), SpkCnt.*exp(i*Ph), nGrid*[1 1]);

% mean firing rate
fRate = mean(SpkCnt);

% compute place field
r = (-nGrid:nGrid)'/nGrid;
if Smooth(1)>0
    PosSmoother = exp(-r.^2/Smooth(1)^2/2);
    sTimeSpent = conv2(PosSmoother, PosSmoother, TimeSpent, 'same');
    snSpikes = conv2(PosSmoother, PosSmoother, nSpikes, 'same');
    PlaceMap = (snSpikes+Epsilon(1)*fRate)./(sTimeSpent+Epsilon(1));
else
    % Smooth<=0 means don't use space, just mean fire rate
    PlaceMap = ones(nGrid)*fRate;
    sTimeSpent = ones(nGrid)*sum(TimeSpent(:))/nGrid.^2;
end

% compute phase field
if Smooth(2)>0
    PhSmoother = exp(-r.^2/Smooth(2)^2/2);
    sPhSum = conv2(PhSmoother, PhSmoother, PhSum, 'same');
    sPhDenom = conv2(PhSmoother, PhSmoother, nSpikes, 'same');
    PhaseMap = angle(sPhSum);
    kMap = BesselRatInv(abs(sPhSum)./(sPhDenom+Epsilon(2)));
elseif Smooth(2)==0 
    % if smooth parameter is 0, use overall mean phase
    TotPh = sum(PhSum(:));
    PhaseMap = ones(nGrid)*angle(TotPh);
    kMap = BesselRatInv(abs(TotPh)/(sum(nSpikes(:))+Epsilon(2)))*ones(nGrid);
else
    % if smooth parameter is <0, don't use phase at all
    PhaseMap = zeros(nGrid);
    kMap = zeros(nGrid);
end

if 1
%if nargout==0
    FireRate = PlaceMap*312.5;
    TopRate = max(PlaceMap(:));
    subplot(2,2,1);
    imagesc(PlaceMap); colorbar; title('Place map');
    subplot(2,2,2);
    imagesc(sTimeSpent); colorbar; title('Occupancy map');
    subplot(2,2,3);
    imagesc(PhaseMap*180/pi); caxis([-180 180]); colorbar; title('Phase map');
    subplot(2,2,4);
    imagesc(kMap); colorbar; title('k map');
    drawnow
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

ParT.TimeSm = -1; ParT.SpaceSm = [-1 0.05]; ParT.PhSm = [-1 .05];
ParT.TetNo = 1;
ParT.nCells = 1;
ParT.nData = length(DataT.Ph);

Data = DataT;
Par = ParT;
Assembly
% [PlaceMap, OccupancyMap] = PPhF(Pos, ThPh, SpkCnt, Smooth, nGrid, TopRate)
% (Place and phase) field calculation.  
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
% in space (in 0...1 units) and in phase (also 0...1 units, with 1->2*pi).
%
% nGrid is a 2x1 array gives the grid spacing to evaluate on in space and phase
% (should be larger than 1/Smooth)
%
% TopRate is for the maximum firing rate on the color map (if you display it)
% if you don't specify this it will be the maximum value
%
% optional output OccupancyMap is a smoothed occupancy map

function [PlaceMap, sTimeSpent] = PPhF(Pos, ThPh, SpkCnt, Smooth, nGrid, TopRate)

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

% make smoothers
r = (-nGrid(1):nGrid(1))'/nG1;
PosSmoother = exp(-r.^2/Smooth(1)^2/2);
r = (-nGrid(2):nGrid(2))'/nG2;
PhSmoother = exp(-r.^2/Smooth(2)^2/2);

% do the smoothing - 1 dim at a time
sTimeSpent1 = convn(TimeSpent, PosSmoother, 'same');
sTimeSpent2 = convn(sTimeSpent1, shiftdim(PosSmoother,-1), 'same');
sTimeSpent3 = convn(sTimeSpent2, shiftdim(PhSmoother,-2));
% wrap it
sTimeSpent = sTimeSpent3(:,:,1:nG2) + sTimeSpent3(:,:,1+nG2:nG2*2) + sTimeSpent3(:,:,1+2*nG2:nG2*3);

snSpikes1 = convn(nSpikes, PosSmoother, 'same');
snSpikes2 = convn(snSpikes1, shiftdim(PosSmoother,-1), 'same');
snSpikes3 = convn(snSpikes2, shiftdim(PhSmoother,-2));
% wrap it
snSpikes = snSpikes3(:,:,1:nG2) + snSpikes3(:,:,1+nG2:nG2*2) + snSpikes3(:,:,1+2*nG2:nG2*3);



PlaceMap = snSpikes./(sTimeSpent+eps);


if nargout==0
    FireRate = PlaceMap*20000/512;
	if nargin<6
        TopRate = max(PlaceMap(:));
	end
    for i=1:size(PlaceMap,3)
        subplot(1,size(PlaceMap,3), i)
    	PFPlot(PlaceMap(:,:,i), sTimeSpent(:,:,i), TopRate, TimeThresh);
        axis off
%        imagesc(PlaceMap(:,:,i)); colorbar;
    end
end
%     if 0
%         colormap(gca, jet);
%         imagesc(PlaceMap);
%     else
%         FireRate = PlaceMap*20000/512;
%         %CoV = snSpikes.^-.5;
%         if nargin<5 | isempty(TopRate)
%             TopRate = max(FireRate(find(sTimeSpent>TimeThresh)));
%             if TopRate<1, TopRate=1; end;
%         end
%         if isempty(TopRate) TopRate = max(FireRate(:)); end;
%     	Hsv(:,:,1) = (2/3) - (2/3)*clip(FireRate'/TopRate,0,1);
%     	%Hsv(:,:,1) = (2/3) - (2/3)*FireRate'/MaxFireRate;
%     	%Hsv(:,:,3) = (sTimeSpent'/(max(sTimeSpent(:))+eps)).^.35;	
%         %Hsv(:,:,3) = 1./(1+CoV');
%         Hsv(:,:,3) = 1./(1+TimeThresh./sTimeSpent');
%     	Hsv(:,:,2) = ones(size(FireRate'));
%     	image(hsv2rgb(Hsv));
%         
%         % most annoying bit is colorbar
%         h = gca;
%         h2 = SideBar;
%         BarHsv(:,:,1) = (2/3) - (2/3)*(0:.01:1)';
%         BarHsv(:,:,2) = ones(101,1);
%         BarHsv(:,:,3) = ones(101,1);
%         image(0,(0:.01:1)*TopRate, hsv2rgb(BarHsv));
%         set(gca, 'ydir', 'normal');
%         set(gca, 'xtick', []);
%         set(gca, 'yaxislocation', 'right');
%         axes(h);
% %        keyboard
%     end
% end
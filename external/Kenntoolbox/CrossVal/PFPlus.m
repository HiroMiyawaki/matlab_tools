% [PlaceMap beta] = PFPlus(Pos, v, SpkCnt, Smooth, nGrid)
%
% Calculates a fit to firing rate as a function of space and an auxilliary
% variable v.
%
% Pos is a nx2 array giving position in each epoch.  It should be in
% the range 0 to 1.  SpkCnt gives the number of spikes in each epoch.
% v is an nxm array giving the m auxilliary variables in each epoch
%
% Smooth is the width of the Gaussian smoother to use (in 0...1 units).
%
% nGrid gives the grid spacing to evaluate on (should be larger than 1/Smooth)

function [PlaceMap, beta] = PFPlus(Pos, v, y, Smooth, nGrid)

persistent LASTBETA;
global CHUNK;

% integrized Pos (in the range 1...nGrid
iPos = 1+floor(nGrid*Pos/(1+eps));

% make smoother
r = (-nGrid:nGrid)/nGrid;
Smoother = exp(-r.^2/Smooth^2/2);

% variables for poisson regression
m = size(v,2);
n = size(v,1);
vt = v';

% initialize beta to zero (first chunk) or last value (all other chunks)
if CHUNK>1 & m>1
	if size(LASTBETA)==[m 1]
	    beta = LASTBETA;
	else
		warning('LASTBETA is the wrong size! resetting.');
        keyboard
        beta = zeros(m,1);
	end
else
    beta = zeros(m,1);
end

% value of ridge regression parameter
Ridge = 0.5;

figure(1)

devoldold = 1e21;
count = 0;

for iter =1
    
    % place field part
    % make unsmoothed arrays
    Denom = full(sparse(iPos(:,1), iPos(:,2), exp(v*beta), nGrid, nGrid));
    Num = full(sparse(iPos(:,1), iPos(:,2), y, nGrid, nGrid));

    sNum = conv2(Smoother, Smoother, Num, 'same');
    sDenom = conv2(Smoother, Smoother, Denom, 'same');

    PlaceMap = sNum./(sDenom+eps);
    if 0
%    if Srange(PlaceMap(:))>1e-3
    subplot(2,1,1)
        imagesc(PlaceMap');
        colorbar
        drawnow
    end
    
    % do we need to do poisson regression?
    
    if m==1
        beta = 0;
        return;
    end


	% poisson regression part
    devold = 1e20; dev=1e19;
    FullStep = 0; % FullStep is 1 for a normal step, 0 for a gradient step.
    while (abs(devold-dev)>1e-6 & count<100) | ~FullStep
    
        mu = exp(v*beta).*PlaceMap(sub2ind([nGrid, nGrid], iPos(:,1), iPos(:,2)));
        mu(find(mu>100)) = 100;
        % how well does it fit before adjusting?
        devold = -sum(-mu + y.*log(mu));

        % compute the derivative, including a weight-penalty (Ridge) term
        d = vt*(y-mu) - Ridge*beta;
        
        % and the hessian
        dd = vt*sparse(1:n,1:n,mu)*v + 2*Ridge*eye(m);
        
        
		dbeta = dd\d;
        
        beta = beta + dbeta;

        mu = exp(v*beta).*PlaceMap(sub2ind([nGrid, nGrid], iPos(:,1), iPos(:,2)));
        mu(find(mu>100)) = 100;
		
        % recalculate deviance
        dev = -sum(-mu + y.*log(mu));
        %disp(dev)

        % check it didn't go up
        UnitAdd = Ridge;
        FullStep = 1;
        while dev-devold>1
        	%warning('Deviance increased!');

        	beta = beta-dbeta;
        	dd = dd+eye(m).*UnitAdd;
        	dbeta = dd\d;
        	beta = beta+dbeta;	
        	mu = exp(v*beta).*PlaceMap(sub2ind([nGrid, nGrid], iPos(:,1), iPos(:,2)));
    	    mu(find(mu>100)) = 100;
    	    dev = -sum(-mu + y.*log(mu));
    	    %disp(dev)
    	    UnitAdd = UnitAdd*10;
    	    FullStep = 0;
        end


         subplot(2,1,2)
        bar(beta);
        ylim([-3 3]);
        drawnow
%         		fprintf('%f %d\n', dev, count); pause
		count = count+1;
	end

end

LASTBETA = beta;

if count==100
	warning('Maximum count exceeded');
	% reset beta so it doesn't mess up next time
	LASTBETA = zeros(m,1);
end

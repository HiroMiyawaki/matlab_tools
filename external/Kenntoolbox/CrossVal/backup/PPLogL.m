% [LogL Est] = PPLogL(SpikeTimes, f, t, Ranges)
%
% calculates the log likelihood of a spike train, given a predicted
% firing rate as a function of time.
%
% SpikeTimes is spike times in any units, does not have to be integers.
% However, f(t) has dimensions of inverse these units.  If f is a single
% number, a constant firing rate will be assumed, and t is ignored.
%
% f and t specify the predicted firing rate as a function of time.
%
% Ranges is an optional argument that will restrict the calculation to these
% time ranges.  It should be a nx2 giving minima and maxima.
%
% output given in bits
%
% Disp gives the mean dispersion.  If the spike train really is a poisson process


function [LogL, Disp] = PPLogL(SpikeTimes, f, t, Ranges)

% check for constant firing rate
if length(f)==1
	% make f and t arrays for each range
	t = sort(Ranges(:));
	f = f.*ones(size(t));
else
    % make f and t column vectors
    f = f(:);
    t = t(:);
end

% check f is positive
if any(~(f>0))
	warning('f must be positive');
end

nRanges = size(Ranges, 1);


fInt = 0; LogL = 0; Disp = 0; % zero accumulation values

for r=1:nRanges
	
	% find where t is in range
	
	tMin = Ranges(r,1); tMax = Ranges(r,2);
	InRange = find(t>=Ranges(r,1) & t<=Ranges(r,2));
	
	% extend t and f to full range if necessary
	t1 = t(InRange); f1 = f(InRange);
	if t1(1)>tMin
		t1 = [tMin; t1];
		f1 = [f1(1); f1];
	end
	if t1(end)<tMax	
		t1 = [t1; tMax];
		f1 = [f1; f1(end)];
	end
	
	% compute first term - integral, if range is at least 2 points.
	if length(t1)>1
		LogL = LogL - trapz(t1, f1);
        % calculate estimated value
        %Est = Est + trapz(t1,f1.*log(f1+eps));    	
        % and expected number of spikes
        fInt = fInt + trapz(t1,f1);
        
        % and dispersion factor
        Disp = Disp+sum(1./f1);
	end
	
	% find Spikes in range
	
	SpikesInRange = SpikeTimes(find(SpikeTimes>=Ranges(r,1) & SpikeTimes<=Ranges(r,2)));

	% probs are computed by linear interpolation
	
	%Probs = interp1(t(InRange), f(InRange), SpikesInRange, 'linear');
	if ~isempty(SpikesInRange)
        Probs = interp1(t1, f1, SpikesInRange, 'linear');
    else
        Probs = [];
    end;
	
	if any(isnan(Probs))
		error(sprintf('could not interpolate probabilities in range %d', r))
	end
			
	% compute second term - sum of log probs

	LogL = LogL + sum(log(Probs));
    
    
end

TotTime = sum(diff(Ranges, [], 2));

% Normalize dispersion
Disp = Disp/TotTime;

LogL = LogL / log(2); % convert to bits per time unit

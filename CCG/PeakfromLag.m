function [peak,diptopeak] = PeakfromLag(bigccg,t,lag,diplag,type_flag);
% function [peak,diptopeak] = PeakfromLag(bigccg,t,lag,diplag,type_flag);
% finds peak in bigccg in timebin that contains lag
% and relative peaksize to diplag
% type_flag indicates an alternate algorithm, whereby counts from 5 nearest
% bins are summed.

if nargin<5;
    type_flag = 0;
end

if type_flag
    if ~isnan(lag)
        nti = find(t==lag);
        peak = sum(bigccg(nti-2:nti+2));
        nti = find(t==diplag);
        diptopeak = peak - sum(bigccg(nti-2:nti+2));
    else
        peak = 0;diptopeak = 0;
    end
elseif ~isnan(lag)
    [nt, nti] = min(abs(t-lag));
    peak = bigccg(nti);
    [nt, nti] = min(abs(t-diplag));
    diptopeak = peak - bigccg(nti);
else
    peak = 0;diptopeak = 0;
end

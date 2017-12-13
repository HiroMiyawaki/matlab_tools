function [lag1,lag2,diplag1,diplag2] = LagnearCCG(runccg,t,CCGbinsize,nn,otherlag1,otherlag2)
% function [lag1,lag2,diplag1,diplag2] = LagnearCCG(runccg,t,CCGbinsize,nn,otherlag1,otherlag2)
% given a CCG, routine will find the lags and relative peak sizes in peaks 
% nearest to "otherlag1" and "otherlag2", and the relative peak sizes

direction = [1 -1 1 -1];
maxima_runccg = LocalMinima(max(runccg)-runccg,round(75/CCGbinsize),max(runccg));

if size(maxima_runccg,1)>=1
    % if info is missing
    if isnan(otherlag1)
        sign_ccg=mean(t(find(runccg==max(runccg))))>=0;
    else
    [minlag,czI1] = min(abs(t(maxima_runccg)-otherlag1));
    sign_ccg = t(maxima_runccg(czI1))>=0;
    end
    if sign_ccg
        czI1 = find(t(maxima_runccg)>=0,1,'first');
        czI2 = find(t(maxima_runccg)<0,1,'last');
    else
        czI1 = find(t(maxima_runccg)<0,1,'last');
        czI2 = find(t(maxima_runccg)>=0,1,'first');
    end
    if isempty(czI2);
        czI2 = czI1;
    end
    if ~isnan(otherlag2)
        [minlag,czI2] = min(abs(t(maxima_runccg)-otherlag2));
        sign_ccg = t(maxima_runccg(czI2))>=0;
        if sign_ccg
            czI2 = find(t(maxima_runccg)>=0,1,'first');
        else
            czI2 = find(t(maxima_runccg)<0,1,'last');
        end
    end
    
    peak = runccg(maxima_runccg(czI1));
    %%%%% check if there is a local minima near the peak, and record the
    %%%%% relative depth
    min_runccg = LocalMinima(runccg-runccg(maxima_runccg(czI1)),...
        round(150/CCGbinsize),runccg(maxima_runccg(czI1)));
    
    [nearest_min1, mzI1] = min(abs(t(min_runccg)-t(maxima_runccg(czI1))));
    if ~isempty(mzI1)
        diplag1 = t(min_runccg(mzI1));
    else
        diplag1 = NaN;
    end
    [nearest_min2, mzI2] = min(abs(t(min_runccg)-t(maxima_runccg(czI2))));
    if ~isempty(mzI2)
        diplag2 = t(min_runccg(mzI2));
    else
        diplag2 = NaN;
    end
    lag1 = t(maxima_runccg(czI1));
    lag2 = t(maxima_runccg(czI2));
else
    lag1 = NaN;
    lag2 = NaN;
    diplag1 = NaN;
    diplag2 = NaN;
end

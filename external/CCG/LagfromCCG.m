function [lag1,lag2,diplag1,diplag2,peak1,peak2] = LagfromCCG(runccg,t,CCGbinsize,nn,slag)
% function [lag1,lag2,diplag1,diplag2] = LagfromCCG(runccg,t,CCGbinsize,nn,slag)
%% input cross-correlogram and time-lag on the slow-timescale
%% routine will search for time-lag, and relative size of peak in the direction of
%% the slow-timelag

direction = [1 -1 1 -1];
maxima_runccg = LocalMinima(max(runccg)-runccg,round(75/CCGbinsize),max(runccg));

if size(maxima_runccg,1)>=1
    % in case slow time-lag is missing or invalid
    if nargin<5
        sign_ccg=mean(t(find(runccg==max(runccg))))>=0;
    elseif isnan(slag)
        sign_ccg=mean(t(find(runccg==max(runccg))))>=0;
    else
        sign_ccg = slag>=0;
    end
    % find t of first peak in the relevant direction
    if sign_ccg
        czI1 = find(t(maxima_runccg)>=0,1,'first');
        czI2 = find(t(maxima_runccg)<0,1,'last');
    else
        czI1 = find(t(maxima_runccg)<0,1,'last');
        czI2 = find(t(maxima_runccg)>=0,1,'first');
    end
    if isempty(czI1)
        czI1 = czI2;
    end
    if isempty(czI2);
        czI2 = czI1;
    end
    
    peak1 = runccg(maxima_runccg(czI1));
    peak2 = runccg(maxima_runccg(czI2));
%     if peak2>peak1
%         temp_swap = czI1;  
%         czI1 = czI2;
%         czI2 = temp_swap;
%     end
        
    %%%%% check if there is a local minima near the peak, and record the
    %%%%% relative depth
    min_runccg = LocalMinima(runccg-runccg(maxima_runccg(czI1)),...
        round(150/CCGbinsize),runccg(maxima_runccg(czI1)));
    
    [nearest_min1, mzI1] = min(abs(t(min_runccg)-t(maxima_runccg(czI1))));
    if ~isempty(mzI1)
        diplag1 = t(min_runccg(mzI1));
        if diplag1-t(maxima_runccg(czI1))>90
            min_runccg = LocalMinima(runccg-runccg(maxima_runccg(czI1)),...
                round(75/CCGbinsize),runccg(maxima_runccg(czI1)));

            [nearest_min1, mzI1] = min(abs(t(min_runccg)-t(maxima_runccg(czI1))));
            diplag1 = t(min_runccg(mzI1));
        end
    else
        diplag1 = NaN;
    end
    [nearest_min2, mzI2] = min(abs(t(min_runccg)-t(maxima_runccg(czI2))));
    if ~isempty(mzI2)
        diplag2 = t(min_runccg(mzI2));
        if diplag2-t(maxima_runccg(czI2))>90
            min_runccg = LocalMinima(runccg-runccg(maxima_runccg(czI2)),...
                round(75/CCGbinsize),runccg(maxima_runccg(czI2)));

            [nearest_min2, mzI2] = min(abs(t(min_runccg)-t(maxima_runccg(czI2))));
            diplag2 = t(min_runccg(mzI2));
        end
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


    
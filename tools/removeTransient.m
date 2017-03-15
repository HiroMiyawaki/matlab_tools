function [Result,n]=removeTransient(Periods,MinInterval,MinDuration,RemoveFirst)
% removeTransient(Periods,MinInterval,MinDuration)
% remove Transient state changes from Periods
%
% Periods: n x 2 matrix, each row contains begining ane d ending frame of
%    event
% MinInterval: minimum interval of events. Events sepalated with shorter gap
%    than this value will be fused.
%
% MinDuration: minimum duration of events Events shorter than this will be
%    deleted.
%
    
    if nargin < 4
        RemoveFirst=false;
    end
       


    begFrame=Periods(:,1);
    endFrame=Periods(:,2);
    
    
    if RemoveFirst
        shortEvt = find(endFrame-begFrame<MinDuration);
        endFrame(shortEvt)=[];
        begFrame(shortEvt)=[];        

        shortIEI=find(begFrame(2:end)-endFrame(1:end-1)<MinInterval);
        endFrame(shortIEI)=[];
        begFrame(shortIEI+1)=[];
    else  
        shortIEI=find(begFrame(2:end)-endFrame(1:end-1)<MinInterval);
        endFrame(shortIEI)=[];
        begFrame(shortIEI+1)=[];

        shortEvt = find(endFrame-begFrame<MinDuration);
        endFrame(shortEvt)=[];
        begFrame(shortEvt)=[];
    end
    
    Result=[begFrame,endFrame];
    
    
    if nargout>1
        n=size(Periods,1)-size(Result,1);
    end
    
end
    
    
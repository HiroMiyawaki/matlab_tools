function Periods=detectPeriods(State,MinInterval,MinDuration)
% detectPeriods(State,MinInterval,MinDuration)
%   detect periods in which State is true
%
% State: nx1 boolian vector
%
% MinInterval: minimum interval of events. Events sepalated with shorter gap
%    than this value will be fused.
%
% MinDuration: minimum duration of events Events shorter than this will be
%    deleted.
%
    begFrame=find([0,diff(State)]==1);
    endFrame=find([0,diff(State)]==-1);
    if ~isempty(begFrame)
        if isempty(endFrame)
            endFrame=length(State);
        elseif begFrame(1)>endFrame(1)
            begFrame=[1,begFrame];
        end
    elseif ~isempty(endFrame)
        begFrame=1;
    end

    
    if length(begFrame)>length(endFrame)
        endFrame=[endFrame,length(State)];
    end
    
    
    if(~isempty(begFrame) && ~isempty(endFrame))
        shortIEI=find(begFrame(2:end)-endFrame(1:end-1)<MinInterval);

        endFrame(shortIEI)=[];
        begFrame(shortIEI+1)=[];
    end
    
    if(~isempty(begFrame) && ~isempty(endFrame))
        shortEvt = find(endFrame-begFrame<MinDuration);
        endFrame(shortEvt)=[];
        begFrame(shortEvt)=[];
    end
    
    if(size(begFrame,1)<size(begFrame,2))begFrame=begFrame';end
    if(size(endFrame,1)<size(endFrame,2))endFrame=endFrame';end
    
    
    Periods=[begFrame,endFrame];
end
    
    
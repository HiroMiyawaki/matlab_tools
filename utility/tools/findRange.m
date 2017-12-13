function [FirstIndex,LastIndex]=findRange(Series,Range,IncludeEdge)

if nargin<3
    IncludeEdge=1;
end

if IncludeEdge==1
    FirstIndex=find(Series<min(Range),1,'last');
    if isempty(FirstIndex); FirstIndex=1; end

    LastIndex=find(Series>max(Range),1,'first');
    if isempty(LastIndex); LastIndex=length(Series); end
else
    
    FirstIndex=find(Series>min(Range),1,'first');
    if isempty(FirstIndex); FirstIndex=1; end

    LastIndex=find(Series<max(Range),1,'last');
    if isempty(LastIndex); LastIndex=length(Series); end
    
end
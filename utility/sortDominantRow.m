function varargout=sortDominantRow(input,takeAbs,threshold)

if ~exist('takeAbs','var') || isempty(takeAbs)
    takeAbs=true;
end
if ~exist('threshold','var') || isempty(threshold)
    threshold=-inf;
end
if takeAbs
    maxVal=max(abs(input),[],2);
    mask=abs(input)==maxVal&abs(input)>threshold;
else
    maxVal=max(input,[],2);
    mask=(input==maxVal)&input>threshold;
end
[~,order]=sortrows(mask,'descend');


mask=mask(order,:);
output=(input(order,:));

for cIdx=1:size(input,2)
    rIdx=find(mask(:,cIdx));
    [~,temp]=sort(output(rIdx,cIdx),'descend');

    output(rIdx,:)=output(rIdx(temp),:);
    order(rIdx)=order(rIdx(temp));
end

if nargout>0
    varargout{1}=output;
end
    
if nargout>1
    varargout{2}=order;
end

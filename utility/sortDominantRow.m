function sortDominantRow(input,takeAbs)

if ~exist('takeAbs','var') || isempty(takeAbs)
    takeAbs=true;
end

if takeAbs
    maxVal=max(abs(input),[],2);
    mask=abs(input)==maxVal;
else
    maxVal=max(input,[],2);
    mask=(input==maxVal);
end
[~,order]=sortrows(mask,'descend');


mask=mask(order,:);
input=(input(order,:));

for cIdx=1:size(input,2)
    rIdx=find(mask(:,cIdx));
    [~,order]=sort(input(rIdx,cIdx),'descend');

    input(rIdx,:)=input(rIdx(order),:);
end

imagesc(input)
    

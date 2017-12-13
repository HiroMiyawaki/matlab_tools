function Results=isInRange(RangeList,InputList)

Results=false(size(InputList));

if isempty(RangeList)
    return
end
if size(RangeList,1)<size(RangeList,2) & size(RangeList,1)~=1
    RangeList=RangeList';
end

[InputList,order]=sort(InputList);
[~,order]=sort(order);

RangeList=sortrows(RangeList);


offset=0;
for idx=1:size(RangeList,1)
    first=find(InputList>RangeList(idx,1),1,'first');
    last=find(InputList<RangeList(idx,2),1,'last');
        
    Results(offset+(first:last))=true;
    if ~isempty(last)
        InputList(1:last)=[];    
        offset=offset+last;
    end
end
Results=Results(order);
        
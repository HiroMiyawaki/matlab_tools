function Results=isInRange2(RangeList,InputList)

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
for idx=1:length(RangeList)
    first=find(InputList>RangeList(idx,1),1,'first');
    last=find(InputList<RangeList(idx,2),1,'last');
        
    Results(offset+(first:last))=true;
    if ~isempty(last)
        InputList(1:last)=[];    
        offset=offset+last;
    end
end
Results=Results(order);

% for n=1:length(InputList)    
%     for m=1:size(RangeList,1)
% %           Results(InputList>RangeList(m,1) & InputList<RangeList(m,2))=true;
%         
%         if RangeList(m,1)<InputList(n) && RangeList(m,2)>InputList(n)
%             Results(n)=true;
%             continue
%         end
%     end
% end
        
        
        
        


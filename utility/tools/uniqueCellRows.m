function varargout=uniqueCellRows(x)

[list,~,id]=unique(x);
id=reshape(id,size(x));

[rowList,firstIndex,rowID]=unique(id,'rows');

if nargout>0
    if size(rowList,1)==1
        varargout{1}=list(rowList)';
    else
        varargout{1}=list(rowList);
    end
end

if nargout>1
    varargout{2}=firstIndex;
end

if nargout>2
    varargout{3}=rowID;
end


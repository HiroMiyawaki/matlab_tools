function res=ste(X,flag,dim);
    if ~exist('flag','var')
        flag=0;
    end
    
    if ~exist('dim','var')
        dim=1;
        
        if size(X,dim)==1
            dim=2;
        end
        
    end    
    
    if isempty(X)
        res=NaN;
    else
        res=std(X,flag,dim)/sqrt(size(X,dim)-1);
    end
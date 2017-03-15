function res=nanste(X,flag,dim);
    if ~exist('flag','var')
        flag=0;
    end
    
    if ~exist('dim','var')
        dim=1;
        
        if size(X,dim)==1
            dim=2;
        end
        
    end     
    
    res=nanstd(X,flag,dim)./sqrt(sum(~isnan(X),dim)-1);
    
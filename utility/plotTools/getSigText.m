function sigText=getSigText(p,bonferroni,pLevel,sigTextList)
    if ~exist('bonferroni','var')
        bonferroni=1;
    end
    
    if ~exist('pLevel','var') || isempty(pLevel)
        pLevel=[0.001,0.01,0.05];
    end

    if ~exist('sigTextList','var') || isempty(sigTextList)
        sigTextList={'***','**','*'};
    end
    
    sigText='';
    
    [pLevel,order]=sort(pLevel,'ascend');
    sigTextList=sigTextList(order);
    
    for idx=1:length(pLevel)
        if p*bonferroni<pLevel(idx)
            sigText=sigTextList{idx};
            break
        end
    end
end
    
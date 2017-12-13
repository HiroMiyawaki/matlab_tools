function plotIdentityLine(ah,options);
    if ~exist('ah','var')
        ah=gca;
    end
    if ~exist('options','var')
        options={};
    end
    
    ax=axis(ah);
    if strcmp('add',get(ah,'NextPlot'))
        setReplace=false;
    else
        setReplace=true;
    end
    
    minPos=max(ax([1,3]));
    maxPos=min(ax([2,4]));
    hold on
    plot([minPos,maxPos],[minPos,maxPos],options{:})
    
    if setReplace
        hold off
    end
    
    

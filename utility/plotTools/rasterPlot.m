function handle=rasterPlot(SpkTime,SpkGrp,col,options)

    %grpList=unique(SpkGrp);
    grpList=min(SpkGrp):max(SpkGrp);
    if(nargin<3)
        col=hsv(size(grpList,2));
    end
    if(nargin<4)
        options={};
    end
    for idx=1:size(grpList,2)
        time=SpkTime(SpkGrp==grpList(idx));
        plot([1;1]*time,[idx-0.5;idx+0.5]*ones(size(time)),'-','color',col(mod(idx-1,size(col,1))+1,:),options{:})
        hold on
    end
    handle=gca();
    hold off
end
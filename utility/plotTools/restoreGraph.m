function H=restoreGraph(Graph)

if strcmpi(Graph.type,'bar')
    for n=1:length(Graph.xValue)
        hold on
        if isfield(Graph,'error')
            plot([1;1]*Graph.xValue(n),...
                [1;1]*Graph.yValue(n)+[1;-1]*Graph.error(n),'color',Graph.color)
        end            
    end
    hold on
    H=bar(Graph.xValue,Graph.yValue,0.8,'faceColor',Graph.color,'linestyle','none');
elseif strcmpi(Graph.type,'multiColorBar')
    for n=1:length(Graph.xValue)
        hold on
        if isfield(Graph,'error')
            plot([1;1]*Graph.xValue(n),...
                [1;1]*Graph.yValue(n)+[0;2*(Graph.yValue(n)>0)-1]*Graph.error(n),'color',Graph.color(n,:))
        end
        bar(Graph.xValue(n),Graph.yValue(n),'linestyle','none','facecolor',Graph.color(n,:))
    end
%     hold on
        
%     H=bar(Graph.xValue,diag(Graph.yValue),'stack');
%     for h=H
%         set(h,'lineStyle','none')
%     end
%     colormap(gca,Graph.color)
elseif strcmpi(Graph.type,'multiBar')
    if isfield(Graph,'error')
        H=barWithError(Graph.xValue,Graph.yValue,Graph.error,0.8,Graph.color);
        for h=H
            set(h,'lineStyle','none')
        end        
    else
        H=bar(Graph.xValue,Graph.yValue,1);
        for colIdx=1:length(H)
            set(H(colIdx),'facecolor',Graph.color(colIdx,:),'lineStyle','none');
        end
    end
elseif strcmpi(Graph.type,'line')
    if iscell(Graph.xValue)
        for n=1:length(Graph.xValue)
            hold on        
            if isfield(Graph,'error')
%                 if any(isnan(Graph.error{n}))
%                     nanList=diff(isnan(Graph.error{n}));
%                     nanBeg=find(nanList==1);
%                     nanEnd=find(nanList==-1);
% 
%                     nanBeg=[nanBeg,length(Graph.error{n})]
%                     nanEnd=[0,nanEnd];
%                     nonNan=[nanEnd+1;nanBeg]';
% 
%                     for m=1:size(nonNan,1)
%                         hold on
%                     fill([Graph.xValue{n}(nonNan(m,1):1:nonNan(m,2)),Graph.xValue{n}(nonNan(m,2):-1:nonNan(m,1))],...
%                          [Graph.yValue{n}(nonNan(m,1):1:nonNan(m,2)),Graph.yValue{n}(nonNan(m,2):-1:nonNan(m,1))]+...
%                          [Graph.error{n}(nonNan(m,1):1:nonNan(m,2)),-1*Graph.error{n}(nonNan(m,2):-1:nonNan(m,1))],...
%                          Graph.color(n,:),'FaceColor',Graph.color(n,:),'lineStyle','none','FaceAlpha',0.5)                
%                     end
%                 else        
%                     fill([Graph.xValue{n},Graph.xValue{n}(end:-1:1)],...
%                          [Graph.yValue{n},Graph.yValue{n}(end:-1:1)]+...
%                          [Graph.error{n},-Graph.error{n}(end:-1:1)],...
%                          Graph.color(n,:),'FaceColor',Graph.color(n,:),'lineStyle','none','FaceAlpha',0.5)
%                 end
                H=errorbar(Graph.xValue{n},...
                    Graph.yValue{n},Graph.error{n},'color',Graph.color(n,:));
            else
                H=plot(Graph.xValue{n},...
                    Graph.yValue{n},'color',Graph.color(n,:));
            end
        end
    else
        if isfield(Graph,'error')
            errorbar(Graph.xValue,Graph.yValue,Graph.error,'color',Graph.color)
        else
            plot(Graph.xValue,...
                Graph.yValue,'color',Graph.color)
        end
    end
elseif strcmpi(Graph.type,'xyErrorLine')
    errorbarXY(Graph.xValue,Graph.yValue,Graph.error{1},Graph.error{2},Graph.color);    
elseif strcmpi(Graph.type,'scatter')
    if iscell(Graph.xValue)
        for cellIdx=1:length(Graph.xValue)
           hold on
           H=plot(Graph.xValue{cellIdx},Graph.yValue{cellIdx},'.','color',Graph.color(cellIdx,:));
        end
    else
        H=plot(Graph.xValue,Graph.yValue,'.','color',Graph.color(1,:));
    end
elseif strcmpi(Graph.type,'raster')
    rasterPlot(Graph.xValue,Graph.yValue,Graph.color)
elseif strcmpi(Graph.type,'largeRaster')
    H=scatter(Graph.xValue,Graph.yValue,1,Graph.color(Graph.yValue,:),'filled');
elseif strcmpi(Graph.type,'hypnograoh')
    for type=1:length(Graph.yValue);
        temp=Graph.xValue.(Graph.yValue{type});
        for idx=1:size(temp,1)
            per =temp(idx,:);
            rectangle('position',[per(1),type-1,per(2)-per(1),1],'LineStyle','none','facecolor',Graph.color(type,:))
        end
    end
    set(gca,'ytick',[0.5:1:length(Graph.yValue)],'yticklabel',Graph.yValue) 
    xlabel('min');    
elseif strcmpi(Graph.type,'rectangle')
    for n=1:length(Graph.xValue)
        for m=1:size(Graph.xValue{n},1)
            rectangle('position',[...
                Graph.xValue{n}(m,1),...
                Graph.yValue{n}(1),...
                diff(Graph.xValue{n}(m,:)),...
                diff(Graph.yValue{n})],'linestyle','none','facecolor',Graph.color(n,:))
        end
    end
elseif strcmpi(Graph.type,'spectrum')
    imagescXY(Graph.xValue(1:2),Graph.xValue(3:4),Graph.yValue)
    set(gca,'CLim',Graph.info.CLim)
elseif strcmpi(Graph.type,'fill')
    fill(Graph.xValue,Graph.yValue,Graph.color,'lineStyle','none')
    set(gca,'CLim',Graph.info.CLim)
elseif strcmpi(Graph.type,'rasterized')
    image(Graph.info.XLim,Graph.info.YLim,Graph.image)
    set(gca, 'ydir', 'normal');
end

box('off')
grid('off')
xlim(Graph.info.XLim)
ylim(Graph.info.YLim)
set(gca,'xtick',Graph.info.XTick,'xtickLabel',Graph.info.XTickLabel)
set(gca,'ytick',Graph.info.YTick,'ytickLabel',Graph.info.YTickLabel)
set(gca,'xScale',Graph.info.XScale,'yScale',Graph.info.YScale)
xlabel(Graph.xlabel)
ylabel(Graph.ylabel)
title(Graph.title);
set(gca,'titleFontWeight','normal')

if ~exist('H','var')
    H=gca;
end







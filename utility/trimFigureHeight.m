function trimFigureHeight(fh,bottomMargin)

if ~exist('fh','var') || isempty(fh)
    fh=gcf;
end
if ~exist('bottomMargin','var') || isempty(bottomMargin)
    bottomMargin=1;
end

unit=get(fh,'paperunit');
if ~strcmp(unit,'centimeters')
    set(fh,'paperunit','centimeters')
end

ah=get(fh,'children');

bottomPos=1;

for n=1:length(ah)
    if ~strcmpi(get(ah(n),'type'),'axes')
        continue
    end
    pos=get(ah(n),'Position');

    bottomPos=min([bottomPos,pos(2)]);
end


paperSize=get(fh,'paperSize');
bottomPos=paperSize(2)*(1-bottomPos)+bottomMargin;
paperSize(2)=min(paperSize(2),bottomPos)
set(fh,'paperSize',paperSize);
set(fh,'paperPosition',[0,0,paperSize])
% pos=get(fh,'position')
% set(fh,'position',[pos(1:2),paperSize])

% subplot('position',[left,bottom,width,height])



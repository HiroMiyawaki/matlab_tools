function addFigureLabel(Label,XPos,Offset,PositionType,TextOption)

if ~exist('Label','var')
    Label='No labels';
end

if ~exist('XPos','var')
XPos=2.5;
end

if ~exist('Offset','var')
Offset=5;
end

if ~exist('PositionType','var')
PositionType='bottom';
end

if ~exist('TextOption','var')
    TextOption={};
end

if ~any(strcmpi('FontSize',TextOption))
    TextOption{end+1}='FontSize';
    TextOption{end+1}=8;
end
if ~any(strcmpi('FontWeight',TextOption))
    TextOption{end+1}='FontWeight';
    TextOption{end+1}='bold';
end


unit=get(gcf,'paperunit');
if ~strcmp(unit,'centimeters')
    set(gcf,'paperunit','centimeters')
end

ah=get(gcf,'children');

topPos=0;
bottomPos=1;

for n=1:length(ah)
    if ~strcmpi(get(ah(n),'type'),'axes')
        continue
    end
    pos=get(ah(n),'Position');

    topPos=max([topPos,pos(2)+pos(4)]);
    bottomPos=min([bottomPos,pos(2)]);
end


paperPos=get(gcf,'paperPosition');
paperPos=paperPos*10;

% subplot('position',[left,bottom,width,height])



if strcmpi(PositionType,'top')
    yPos=(1-topPos)*paperPos(4)-Offset;
    subplotInMM(XPos,yPos,10,5)
    if ~any(strcmpi('verticalAlign',TextOption))
        TextOption{end+1}='verticalAlign';
        TextOption{end+1}='bottom';
    end
else
    if ~strcmpi(PositionType,'bottom')
        display('Invarid option: set position type bottom')
    end
    yPos=(1-bottomPos)*paperPos(4)+Offset;
    subplotInMM(XPos,yPos,10,5,true)
    if ~any(strcmpi('verticalAlign',TextOption))
        TextOption{end+1}='verticalAlign';
        TextOption{end+1}='top';
    end
end

if ~any(strcmpi('horizontalAlign',TextOption))
    TextOption{end+1}='horizontalAlign';
    TextOption{end+1}='left';
end

xlim([0,1])
ylim([0,1])
axis off
text(0,0,Label,TextOption{:})
if ~strcmp(unit,'centimeters')
    set(gcf,'paperunit',unit)
end

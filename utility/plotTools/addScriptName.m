function addScriptName(ScriptName,Offset,TextOption)

if ~exist('ScriptName','var') || isempty(ScriptName)
    ScriptName=['script called at ' datestr(now)];
elseif ScriptName(end) ~= 'm'
    ScriptName=[ScriptName '.m'];
end

if ~exist('Offset','var')
Offset=7.5;
end

if ~exist('TextOption','var')
    TextOption={};
end

if ~any(strcmpi('FontSize',TextOption))
    TextOption{end+1}='FontSize';
    TextOption{end+1}=4;
end

if ~any(strcmpi('horizontalAlign',TextOption))
    TextOption{end+1}='horizontalAlign';
    TextOption{end+1}='right';
end
if ~any(strcmpi('verticalAlign',TextOption))
    TextOption{end+1}='verticalAlign';
    TextOption{end+1}='top';
end
if ~any(strcmpi('interpreter',TextOption))
    TextOption{end+1}='interpreter';
    TextOption{end+1}='none';
end
unit=get(gcf,'paperunit');
if ~strcmp(unit,'centimeters')
    set(gcf,'paperunit','centimeters')
end

ah=get(gcf,'children');

bottomPos=1;
rightPos=0;


for n=1:length(ah)
    if ~strcmpi(get(ah(n),'type'),'axes')
        continue
    end
    pos=get(ah(n),'Position');

    bottomPos=min([bottomPos,pos(2)]);
    rightPos=max([rightPos,pos(1)+pos(3)]);

end


paperPos=get(gcf,'paperPosition');
paperPos=paperPos*10;


yPos=(1-bottomPos)*paperPos(4)+Offset;
xPos=rightPos*paperPos(3);
subplotInMM(xPos-10,yPos,10,5,true)

xlim([0,1])
ylim([0,1])
axis off
text(1,0,['made with ' ScriptName],TextOption{:})
if ~strcmp(unit,'centimeters')
    set(gcf,'paperunit',unit)
end
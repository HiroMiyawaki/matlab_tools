function h=subplotInMM(Xpos,Ypos,Width,Height,SetTop)

if nargin<5
    SetTop=false;
end

unit=get(gcf,'paperunit');
if ~strcmp(unit,'centimeters');
    set(gcf,'paperunit','centimeters');
end

paperPos=get(gcf,'paperPosition');
paperPos=paperPos*10;

% scale=(paperPos(3:4)-paperPos(1:2));
scale=paperPos(3:4);

% Xpos=Xpos-paperPos(1);
% Ypos=paperPos(4)-paperPos(2)-Ypos;
Ypos=paperPos(4)-Ypos;

if SetTop;
    h=subplot('position',[Xpos/scale(1),Ypos/scale(2)-Height/scale(2),Width/scale(1),Height/scale(2)]);
else
    h=subplot('position',[Xpos/scale(1),Ypos/scale(2),Width/scale(1),Height/scale(2)]);
end

set(gcf,'paperunit',unit);

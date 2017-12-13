function h=panelLetter(Xpos,Ypos,String,FontSize,FontWeight,Property)

targetPos=[Xpos,Ypos]/10;
if ~exist('Property','var')
    Property={};
end
if ~exist('FontSize','var')
    FontSize=8;
end
if ~exist('FontWeight','var')
    FontWeight='bold';
end
unit=get(gcf,'paperunit');
if ~strcmp(unit,'centimeters')
    set(gcf,'paperunit','centimeters')
end

paperPos=get(gcf,'paperPosition');
boxPos=get(gca,'Position');
boxRange=axis();

if strcmpi(get(gca,'xscale'),'log')
    boxRange(1:2)=log(boxRange(1:2));
end
if strcmpi(get(gca,'yscale'),'log')
    boxRange(3:4)=log(boxRange(3:4));
end

boxPos(1:2)=(paperPos([3:4])).*boxPos(1:2);
boxPos(3:4)=(paperPos([3:4])).*boxPos(3:4);
boxPos(2)=paperPos(4)-boxPos(2);

scale=boxPos(3:4)./(boxRange([2,4])-boxRange([1,3]));
scale(2)=-scale(2);

targetInPaper=(targetPos-boxPos(1:2))./scale+boxRange([1,3]);

if strcmpi(get(gca,'xscale'),'log')
    targetInPaper(1)=exp(targetInPaper(1));
end
if strcmpi(get(gca,'yscale'),'log')
    targetInPaper(2)=exp(targetInPaper(2));
end

h=text(targetInPaper(1),targetInPaper(2),String,'fontSize',FontSize,'fontWeight',FontWeight,Property{:});

if ~strcmp(unit,'centimeters')
    set(gcf,'paperunit',unit)
end

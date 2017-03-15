function fh=initFig4letter(isLandscape)

if nargin <1
    isLandscape=false;
end

if isLandscape
    fh=figure('position',[-1000,1000,1100,850]);
    set(fh,'PaperOrientation','landscape');
    set(fh,'paperPosition',[0,0,11,8.5])
else
    fh=figure('position',[-1000,1000,850,1100]);
    set(fh,'PaperOrientation','portrait');
    set(fh,'paperPosition',[0,0,8.5,11])
end

set(fh,'defaultAxesFontSize',12);
set(fh,'defaultTextFontSize',12);
set(fh,'defaultAxesLineWidth', 1);
set(fh,'defaultLineLineWidth', 1); 

set(fh,'DefaultAxesXGrid','off');
set(fh,'DefaultAxesYGrid','off');
set(fh,'DefaultAxesBox','off');
% set(fh,'PaperPositionMode','auto');

end
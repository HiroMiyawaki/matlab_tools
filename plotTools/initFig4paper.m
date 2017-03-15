function fh=initFig4paper(nColumn)

if nargin <1
    nColumn=1;
end

expand=5.5;
if nColumn==2
    fh=figure('position',[-1000,1000,174*expand,279.4*expand]);
    set(fh, 'paperUnit','centimeters')
    set(fh,'paperPosition',[0,0,17.4,27.94])
elseif nColumn==1.5
    fh=figure('position',[-1000,1000,114*expand,279.4*expand]);
    set(fh, 'paperUnit','centimeters')
    set(fh,'paperPosition',[0,0,11.4,27.94])
else    
    fh=figure('position',[-1000,1000,85*expand,279.4*expand]);
    set(fh, 'paperUnit','centimeters')
    set(fh,'paperPosition',[0,0,8.5,27.94])
end

set(fh,'defaultAxesFontName','Helvetica')
set(fh,'defaultTextFontName','Helvetica')
 
set(fh,'defaultAxesFontSize',11);
set(fh,'defaultTextFontSize',10);
set(fh,'defaultAxesLineWidth', 1);
set(fh,'defaultLineLineWidth', 1); 
set(fh,'DefaultLineMarkerSize', 12); 

set(fh,'DefaultAxesXGrid','off');
set(fh,'DefaultAxesYGrid','off');
set(fh,'DefaultAxesBox','off');
% set(fh,'PaperPositionMode','auto');

end
function fh=initFig4Nature(nColumn)

if nargin <1
    nColumn=1;
end

% expand=5.5;
expand=3.6;
if nColumn==2
    width=18.3;
    height=24.7;
else
    width=8.9;
    height=24.7;
end    




fh=figure('position',[-1000,1000,width*10*expand,height*10*expand]);
set(fh, 'paperUnit','centimeters')
set(fh,'PaperOrientation','portrait')
set(fh,'PaperType','usletter')
set(fh,'paperPosition',[(21.6-18.3)/2,(27.9-24.7)/2,width,height])

set(fh,'defaultAxesFontName','Helvetica')
set(fh,'defaultTextFontName','Helvetica')
 
set(fh,'defaultAxesFontSize',5);
set(fh,'defaultTextFontSize',5);
set(fh,'defaultAxesLineWidth', 1);
set(fh,'defaultLineLineWidth', 1); 
set(fh,'DefaultLineMarkerSize', 12); 

set(fh,'DefaultAxesXGrid','off');
set(fh,'DefaultAxesYGrid','off');
set(fh,'DefaultAxesBox','off');
% set(fh,'PaperPositionMode','auto');

end
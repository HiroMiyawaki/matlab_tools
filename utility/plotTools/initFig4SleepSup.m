function fh=initFig4SleepSup(nColumn)

if nargin <1
    nColumn=1;
end

% expand=5.5;
expand=3;
if nColumn==2
    width=8*2.54;
    height=9.5*2.54;
else
    width=3.3*2.54;
    height=9.5*2.54;
end    




fh=figure('position',[-1000,1000,width*10*expand,height*10*expand]);
set(fh, 'paperUnit','centimeters')
set(fh,'PaperOrientation','portrait')
set(fh,'PaperType','usletter')
set(fh,'paperPosition',[(8.5*2.54-8*2.54)/2,(11*2.54-height)/2,width,height])

set(fh,'defaultAxesFontName','Helvetica')
set(fh,'defaultTextFontName','Helvetica')
 
set(fh,'defaultAxesFontSize',9);
set(fh,'defaultTextFontSize',9);
set(fh,'defaultAxesLineWidth', 1);
set(fh,'defaultLineLineWidth', 1); 
set(fh,'DefaultLineMarkerSize', 4); 

set(fh,'DefaultAxesXGrid','off');
set(fh,'DefaultAxesYGrid','off');
set(fh,'DefaultAxesBox','off');
% set(fh,'PaperPositionMode','auto');

end
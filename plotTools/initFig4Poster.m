function fh=initFig4PosterHalf(nColumn)

nColumn=2;

expand=3;
width=11*2.54;
height=8.5*2.54;


fh=figure('position',[-1000,1000,width*10*expand,height*10*expand]);
set(fh, 'paperUnit','centimeters')
% set(fh,'PaperOrientation','portrait')
set(fh,'PaperOrientation','landscape');
set(fh,'PaperType','usletter')
set(fh,'paperPosition',[0,0,width,height])

set(fh,'defaultAxesFontName','Helvetica')
set(fh,'defaultTextFontName','Helvetica')
 
set(fh,'defaultAxesFontSize',14);
set(fh,'defaultTextFontSize',14);
set(fh,'defaultAxesLineWidth', 1);
set(fh,'defaultLineLineWidth', 1); 
set(fh,'DefaultLineMarkerSize', 24); 

set(fh,'DefaultAxesXGrid','off');
set(fh,'DefaultAxesYGrid','off');
set(fh,'DefaultAxesBox','off');
% set(fh,'PaperPositionMode','auto');

end
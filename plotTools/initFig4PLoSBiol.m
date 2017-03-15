function fh=initFig4PLoSBiol


expand=5.5;
width=19.05;
height=22.23;




fh=figure('position',[-1000,1000,width*10*expand,height*10*expand]);
set(fh, 'paperUnit','centimeters')
set(fh,'PaperOrientation','portrait')
set(fh,'PaperType','usletter')
set(fh,'paperPosition',[(8.5*2.54-19.05)/2,(11*2.54-height)/2,width,height])

set(fh,'defaultAxesFontName','Arial')
set(fh,'defaultTextFontName','Arial')
 
set(fh,'defaultAxesFontSize',8);
set(fh,'defaultTextFontSize',8);
set(fh,'defaultAxesLineWidth', 1);
set(fh,'defaultLineLineWidth', 1); 
set(fh,'DefaultLineMarkerSize', 4); 

set(fh,'DefaultAxesXGrid','off');
set(fh,'DefaultAxesYGrid','off');
set(fh,'DefaultAxesBox','off');
% set(fh,'PaperPositionMode','auto');

end
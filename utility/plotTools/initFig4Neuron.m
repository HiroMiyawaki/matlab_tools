function fh=initFig4Neuron(nColumn)

if nargin <1
    nColumn=1;
end

expand=5.5;
if nColumn==2
    width=17.4;
    height=11*2.54-(8.5*2.54-17.4);
elseif nColumn==1.5
    width=11.4;
    height=11*2.54-(8.5*2.54-17.4);
else
    width=8.5;
    height=11*2.54-(8.5*2.54-17.4);
end    




fh=figure('position',[-1000,1000,width*10*expand,height*10*expand]);
set(fh, 'paperUnit','centimeters')
set(fh,'PaperOrientation','portrait')
set(fh,'PaperType','usletter')
set(fh,'paperPosition',[(8.5*2.54-17.4)/2,(11*2.54-height)/2,width,height])

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
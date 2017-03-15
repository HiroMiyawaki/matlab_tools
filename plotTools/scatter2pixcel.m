function img=scatter2pixcel(graph,width,height,markerSize)

if ~exist('markerSize','var')
    markerSize=4;
end
widthTemp=width/10;
heightTemp=height/10;
expand=3.6;

fhTemp=figure('position',[-1000,1000,widthTemp*10*expand,heightTemp*10*expand]);
set(fhTemp, 'paperUnit','centimeters')
set(fhTemp,'PaperOrientation','portrait')
set(fhTemp,'PaperType','usletter')
set(fhTemp,'paperPosition',[(21.6-18.3)/2,(27.9-24.7)/2,widthTemp,heightTemp])

set(fhTemp,'defaultAxesFontName','Helvetica')
set(fhTemp,'defaultTextFontName','Helvetica')

set(fhTemp,'defaultAxesFontSize',5);
set(fhTemp,'defaultTextFontSize',5);
set(fhTemp,'defaultAxesLineWidth', 1);
set(fhTemp,'defaultLineLineWidth', 1);
set(fhTemp,'DefaultLineMarkerSize', 12);

set(fhTemp,'DefaultAxesXGrid','off');
set(fhTemp,'DefaultAxesYGrid','off');
set(fhTemp,'DefaultAxesBox','off');


% set(fh,'PaperPositionMode','auto');

subplotInMM(0,0,width,height,true)


set(fhTemp,'DefaultLineMarkerSize', markerSize);
restoreGraph(graph);
set(gca, 'ydir', 'reverse');
axis off
figName=['~/Desktop/Fig'  num2str(floor(now)) '.tiff'];
print(fhTemp,figName,'-dtiff','-r600')

img=imread(figName);

unix(['rm ' figName])
close(fhTemp)
end
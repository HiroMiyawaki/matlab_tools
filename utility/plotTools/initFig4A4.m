function fh=initFig4A4(varargin)


param.landscape=false;
param.fontsize=10;
param.markerSize=9;
param.lineWidth=1;
param.margin=0;
param.windowBottom=20;
param.windowLeft=0;
param.axesColor=[0,0,0];

param=parseParameters(param,varargin);
%%
% expand=5.5;
expand=3;

width=21.0;
height=29.7;


if param.landscape
    temp=width;
    width=height;
    height=temp;
    clear temp    
    paperOrient='landscape';
else
   paperOrient='portrait';
end

% fh=figure('position',[-1000,1000,(width-param.margin*2)*10*expand,(height-param.margin*2)*10*expand]);
% fh=figure('position',[-1000,1000,width*10*expand,height*10*expand]);
fh=figure();
set(fh, 'paperUnit','centimeters','Units','centimeters')
% set(fh,'position',[0,1000,width,height]);
set(fh,'position',[param.windowLeft,param.windowBottom,(width-param.margin*2),(height-param.margin*2)])
set(fh, 'Units','centimeters')
set(fh,'PaperOrientation',paperOrient)
set(fh,'PaperType','a4')
set(fh,'paperPosition',[param.margin,param.margin,width-param.margin,height-param.margin])
% set(fh,'paperPosition',[0,0,width,height])

set(fh,'defaultAxesFontName','Helvetica')
set(fh,'defaultTextFontName','Helvetica')
 
set(fig,'defaultAxesXColor',param.axesColor); % factory is [0.15,0.15,0.15]
set(fig,'defaultAxesYColor',param.axesColor);
set(fig,'defaultAxesZColor',param.axesColor);

set(fh,'defaultAxesFontSize',param.fontsize);
set(fh,'defaultTextFontSize',param.fontsize);
set(fh,'defaultAxesLineWidth', param.lineWidth);
set(fh,'defaultLineLineWidth', param.lineWidth); 
set(fh,'DefaultLineMarkerSize', param.markerSize); 

set(fh,'DefaultAxesXGrid','off');
set(fh,'DefaultAxesYGrid','off');
set(fh,'DefaultAxesBox','off');
set(fh,'PaperPositionMode','auto');

end
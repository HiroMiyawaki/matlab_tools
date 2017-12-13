function Graph=loadGraph(FigureNumber,PanelLetter,PaperDir)

if ~exist('PaperDir','var')
    PaperDir='~/Dropbox/Paper/figure/';
end

figureDir=[PaperDir 'Fig' FigureNumber '/'];
temp=load([figureDir 'panel_' PanelLetter '.mat']);
Graph=temp.graph;

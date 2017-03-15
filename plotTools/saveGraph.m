function saveGraph(FigureNumber,PanelLetter,Type,Xvalue,Yvalue,Error,Color,Info,Xlabel,Ylabel,Title,Legend,MadeBy,PaperDir)

if ~exist('PaperDir','var')
    PaperDir='~/Dropbox/Paper/figure/';
end

if ~exist('Ylabel','var')
    Ylabel='';
end

if ~exist('Xlabel','var')
    Xlabel='';
end
if ~exist('Title','var')
    Title='';
end
if ~exist('Legend','var')
    Legend='';
end
if ~exist('MadeBy','var')
    MadeBy='';
end
graph.xValue=Xvalue;
graph.yValue=Yvalue;
if ~isempty(Error)
    graph.error=Error;
end
graph.type=Type;

pList=fieldnames(Info);
pList=pList(~strcmpi('Children',pList) & ~strcmpi('Parent',pList));
for pIdx=1:length(pList)
    graph.info.(pList{pIdx})=Info.(pList{pIdx});
end
graph.xlabel=Xlabel;
graph.ylabel=Ylabel;
graph.title=Title;
graph.legend=Legend;
graph.color=Color;
graph.madeby=MadeBy;

if ~exist(PaperDir, 'dir')
    mkdir(PaperDir)
end

figureDir=[PaperDir 'Fig' FigureNumber '/'];

if ~exist(figureDir, 'dir')
    mkdir(figureDir)
end

save([figureDir 'panel_' PanelLetter '.mat'],'graph','-v7.3')


function saveGraph2(FigureNumber,PanelLetter,Type,Xvalue,Yvalue,Error,Color,Legend,MadeBy,PaperDir)
    if ~exist('PaperDir','var')
        PaperDir='~/Dropbox/Paper/figure/';
    end

    saveGraph(FigureNumber,PanelLetter,...
        Type,...
        Xvalue,... %x
        Yvalue,... %y
        Error,... %error 
        Color,... %color
        get(gca),... %info
        get(get(gca,'xlabel'),'string'),... %xlabel
        get(get(gca,'ylabel'),'string'),... %ylabel
        get(get(gca,'title'),'string'),... %title,
        Legend,... %legend
        MadeBy,...
        PaperDir)                  

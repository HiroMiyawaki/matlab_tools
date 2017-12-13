function ah = addAxis(Target,YAxisLocation,YColor,options)

if ~exist('Target','var')
    Target=gca;
end

if ~exist('Target','var')
    Target=gca;
end

if ~exist('YAxisLocation','var')
    YAxisLocation='left';
end

if ~exist('YColor','var')
    YColor='k';
end

if ~exist('options','var')
    options={};
end

ah = axes('Position',get(Target,'Position'));
hold on
set(ah,'YAxisLocation',YAxisLocation,'YColor',YColor,'color','none',options{:})

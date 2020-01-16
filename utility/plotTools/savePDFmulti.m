function savePDFmulti(fhList,pdfFile,varargin)
% savePDFmulti(fhList,pdfFile,...)
%   save multiple figures into one PDF
%   This function uses catPDF, which requires gs
%
%   fhList list of figure numbers
%   pdfFile name of final output pdf
%
%   options and default values
%     vector : true %set true to use painters
%     resolution : 300 %resolution of output PDF
%     catPDFoptions : {} %options passed to catPDF
%
%  by Hiro Miyawaki at the Osaka City Univ, Feb 2019
%

    param.vector=true;
    param.resolution=300;
    param.catPDFoptions={};
    param.pngPage=[];
    param.convertPath='/usr/local/bin/convert';
    
    param=parseParameters(param,varargin);

    if param.vector
        renderer='-painters';
    else
        renderer='';
    end
    
    if isnumeric(param.resolution)
        resolution=['-r' num2str(param.resolution)];
    else
        resolution='';
    end
        
    tempDir=fullfile('~/Desktop',['temp' datestr(now,'yyyymmddhhMMss')]);
    mkdir(tempDir);
    pdfList={};
    for fIdx=1:length(fhList)
        pdfList{fIdx}=fullfile(tempDir, ['page' num2str(fIdx) '.pdf']);
        print(fhList(fIdx),pdfList{fIdx},'-dpdf',resolution,renderer)
    end
    
    catPDF(pdfFile,pdfList,'remove',true,param.catPDFoptions{:})
    rmdir(tempDir,'s');
    
    if ~isempty(param.pngPage)
        [filePath,fileName,~]=fileparts(pdfFile)
        
        if ~exist(fullfile(filePath,'png'),'dir')
            mkdir(fullfile(filePath,'png'))
        end
        if ~exist(fullfile(filePath,'jpeg'),'dir')
            mkdir(fullfile(filePath,'jpeg'))
        end
        
        for n=1:length(param.pngPage)  
            
            if n==1 && length(fhList)==1
                postFix='';
            else                
                postFix=sprintf('_page%02d',n);
            end
            
            orient(fhList(param.pngPage(n)),'portrait')
            print(fhList(param.pngPage(n)),fullfile(filePath,'png',sprintf('%s%s.png',fileName,postFix)),'-dpng',resolution)
            
            command=sprintf('%s %s.png -quality 60 %s.jpeg',...
                param.convertPath,...
                fullfile(filePath,'png',sprintf('%s%s',fileName,postFix)),...
                fullfile(filePath,'jpeg',sprintf('%s%s',fileName,postFix)));
            system(command);
        end
    end

    
end
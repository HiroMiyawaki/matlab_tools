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
end
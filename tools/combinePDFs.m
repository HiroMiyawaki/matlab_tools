function combinePDFs(outFileName,inFileList,varargin)


remove=false;
rmPath='/bin/rm';

gsPath='/usr/local/bin/gs';
gsOption='-q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite';

for n=1:length(varargin)/2
    name=lower(varargin{2*n-1});
    val=varargin{2*n};
    
    switch name
        case 'remove'
            remove=val;
        case 'gspath'
            gsPath=val;
        case 'rmpath'
            rmPath=val;
        case 'gsoption'
            gsOption=val;
        otherwise
            error('wrong option')
    end
end

for n=1:length(inFileList)
    [status,temp]=fileattrib(inFileList{n});
    if status==0
        error(sprintf('%s not found',inFileList{n}));
    end
    inFileList{n}=temp.Name;
end
          
[outPath,outName,outExt]=fileparts(outFileName);
[status,temp]=fileattrib(outPath);
if status==0
    error(sprintf('can not make output file since %s does not exist',outPath));
end    
outFileName=fullfile(temp.Name,[outName,outExt]);

eval(sprintf('! %s %s -sOutputFile=%s %s',gsPath,gsOption,outFileName,strjoin(inFileList)))

if remove 
    eval(sprintf('! %s %s -sOutputFile=%s %s && %s %s',gsPath,gsOption,outFileName,strjoin(inFileList),rmPath,strjoin(inFileList)))
else
    eval(sprintf('! %s %s -sOutputFile=%s %s',gsPath,gsOption,outFileName,strjoin(inFileList)))
end




function gitPull(varargin)


    param.gitDir='/usr/local/bin/git';
    param.repoDir='~/Documents/MATLAB/matlab_tools';    
    
    paramNames=fieldnames(param);
    
    if mod(length(varargin),2)==1
        error('option must be a pair of name and its value');
    end
        
    for n=1:length(varargin)/2        
        name=paramNames(strcmpi(paramNames,varargin{2*n-1}));
        if isempty(name)
            error('Wrong option')
        else
            param.(name)=varargin{2*n};
        end
    end
    
    %add gitDir to $PATH
    currentPath=getenv('PATH')
    setenv('PATH',[param.gitDir ':' currentPath]);
    
    system(['git -C ' param.repoDir ' pull']);
    
    %remove gitDir from $PATH
    setenv('PATH',currentPath)

    
    
    
    
    
function gitPush(varargin)

    param.gitDir='/usr/local/bin';
    param.repoDir='~/Documents/MATLAB/matlab_tools';
    param.comment=['comit at ' datestr(now) ];
        
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
    
    system(['git  -C ' param.repoDir ' add --all']);
    system(['git -C ' param.repoDir ' commit -m ''' param.comment '''']);
    system(['git -C ' param.repoDir ' push']);
    
    %remove gitDir from $PATH
    setenv('PATH',currentPath)
    
    
    
    
    
    
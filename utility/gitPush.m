function gitPush(varargin)

    param.gitPath='/usr/local/bin/git';
    param.repoPath='~/Documents/MATLAB/matlab_tools/';
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
    
    eval(['!' param.gitPath ' -C ' param.repoPath ' add --all'])
    eval(['!' param.gitPath ' -C ' param.repoPath ' commit -m ''' param.comment ''''])
    eval(['!' param.gitPath ' -C ' param.repoPath ' push'])
    
    
    
    
    
    
    
function git_push(varargin)


    param.gitPath='/usr/local/bin/git';
    param.localPath='~/Documents/MATLAB/matlab_tools/';
    param.comment=['comit at ' datestr(now) ];
    
    
    paramNames=fieldnames(param);
    
    for n=1:length(varargin)/2        
        name=paramNames(strcmpi(paramNames,a));
        if isempty(name)
        
        
    end
    
    eval(['!' param.gitPath ' -C ' param.repoPath ' add --all'])
    eval(['!' param.gitPath ' -C ' param.repoPath ' commit -m ''' param.comment ''''])
    eval(['!' param.gitPath ' -C ' param.repoPath ' push'])
    
    
    
    
    
    
    
function git_push(gitPath)


    gitPath='/usr/local/bin/git'
    localPath='~/Documents/MATLAB/matlab_tools/';
    commitComment=['comit at ' datestr(now) ];
    
    eval(['!' gitPath ' -C ' localPath ' add --all'])
    eval(['!' gitPath ' -C ' localPath ' commit -m ''' commitComment ''''])
    eval(['!' gitPath ' -C ' localPath ' push'])
    
    
    
    
    
    
    
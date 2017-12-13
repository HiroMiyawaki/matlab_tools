function git_commit(gitPath)


    gitPath='/usr/local/bin/git'
    localPath='~/Documents/MATLAB/matlab_tools/';
    commitComment=['comit at ' datestr(now) ];
    
    eval(['!' gitPath ' -C ' localPath ' add --all'])
    eval(['!' gitPath ' -C ' localPath ' commit -m ''' commitComment ''''])
    
    
    
    
    
    
    
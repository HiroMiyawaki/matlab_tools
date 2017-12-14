function gitPush(comment,varargin)
% quick shortcut to push local repository to remote
%
% gitPush(comment,[options])
%    comment : commit comment (comit at YYYY-MMM-DD hh-mm-ss)
%    options : pair of name and its value
%       gitDir : directory which contains git commands ('/usr/local/bin')
%       repoDir : repository directory ('try current path then use ~/Documents/MATLAB/analyses')
%
% Dec 2017
% Hiroyuki Miyawaki
%
    param.gitDir='/usr/local/bin';
    param.repoDir='';
    
    if ~exist('comment','var')
        comment=['comit at ' datestr(now) ];
    end
        
    paramNames=fieldnames(param);    
    if mod(length(varargin),2)==1
        error('option must be a pair of name and its value');
    end
        
    for n=1:length(varargin)/2        
        name=paramNames(strcmpi(paramNames,varargin{2*n-1}));
        if isempty(name)
            error('Wrong option')
        else
            param.(name{1})=varargin{2*n};
        end
    end

    % determine repoDir
    if isempty(param.repoDir)
        currentDir=pwd;
        
        while ~strcmp(currentDir,'/')
            if exist(fullfile(currentDir,'.git'),'dir')
                break
            end
            currentDir=fileparts(currentDir);
        end
    
        if strcmp(currentDir,'/')
            param.repoDir='~/Documents/MATLAB/analyses';    
        else
            param.repoDir=currentDir;
        end
    end
    
    disp(['repository directory :' param.repoDir])
    
    %add gitDir to $PATH
    currentPath=getenv('PATH');
    setenv('PATH',[param.gitDir ':' currentPath]);
    
    system(['git  -C ' param.repoDir ' add --all']);
    system(['git -C ' param.repoDir ' commit -m ''' comment '''']);
    system(['git -C ' param.repoDir ' push']);
    
    %remove gitDir from $PATH
    setenv('PATH',currentPath)
    
    
    
    
    
    
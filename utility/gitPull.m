function gitPull(varargin)
% quick shortcut to pull remote repository to local
%
% gitPull([options, vaules])
%    gitDir : directory which contains git commands ('/usr/local/bin')
%    repoDir : repository directory (try current path then use '~/Documents/MATLAB/analyses')
%
% Dec 2017
% Hiroyuki Miyawaki
%

    param.gitDir='/usr/local/bin';
    param.repoDir='';
    paramNames=fieldnames(param);
    
    if mod(length(varargin),2)==1
        error('option must be a pair of name and its value');
    end
        
    %set parameters
    for n=1:length(varargin)/2        
        name=paramNames(strcmpi(paramNames,varargin{2*n-1}));
        if isempty(name)
            error('Wrong option')
        else
            param.(name)=varargin{2*n};
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
    
    
    
    %add gitDir to $PATH
    currentPath=getenv('PATH');
    setenv('PATH',[param.gitDir ':' currentPath]);
    
    %git pull
    system(['git -C ' param.repoDir ' pull']);
    
    %remove gitDir from $PATH
    setenv('PATH',currentPath)

    
    
    
    
    
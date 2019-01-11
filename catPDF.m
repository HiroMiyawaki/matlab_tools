function catPDF(outputFile,inputFiles,varargin)
% function catPDF(outputFile,inputFiles,options)
%  concatenate multiple PDFs to one PDF file using gs
%
%  outputFile : output PDF file name
%  inputFiles : cell which contains list of input PDF files;
%
%  options and default values
%   gsPath='/usr/local/bin/gs' %path of gs command
%   rmPath='/bin/rm' %path of rm command
%   overwrite=true % overwrite when output file exists
%   remove=false % remove input files after concatenate
%
%  by Hiro Miyawaki at the Osaka City Univ, Jan 2019
%

%% set default
param.gsPath='/usr/local/bin/gs';
param.rmPath='/bin/rm';
param.overwrite=true;
param.remove=false;

param=parseParameters(param,varargin);

%% check input files
if isempty(inputFiles)
    error('give at least one input file')
end

for n=1:length(inputFiles)
    if exist(inputFiles{n},'file'); 
        continue
    elseif exist([inputFiles{n} '.pdf'],'file') 
        inputFiles{n} =[inputFiles{n} '.pdf'];
    else
        error('%s not found',inputFiles{n})
    end
end

%% get fullpath of inputs
for n=1:length(inputFiles)
    [~,temp]=fileattrib(inputFiles{n});
    inputFiles{n}=temp.Name;
end

%% remove redundant input
[~,idx]=unique(inputFiles);
if length(idx) ~=length(inputFiles)
    warning('%d redundant input Files were removed',length(inputFiles)- length(idx))
    inputFiles=inputFiles(sort(idx));
end
%% check output file
if length(outputFile)<4  || ~strcmpi(outputFile(end-3:end),'.pdf')
    outputFile=[outputFile '.pdf'];
end

%% get fullpath of output
[fPath,fName,fExt]=fileparts(outputFile);
if isempty(fPath)
    fPath=pwd;
else
    if ~exist(fPath,'dir')
        mkdir(fPath);
    end
    [~,temp]=fileattrib(fPath);
    fPath=temp.Name;
end    
outputFile=fullfile(fPath,[fName,fExt]);

%% check overwrite
if exist(outputFile,'file')
    if param.overwrite
        warning('%s is overwritten',outputFile)
    else
        error('%s already exist',outputFile)
    end
end

%% call gs
[st,cmdOut]=system(sprintf('%s -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=%s %s',param.gsPath,outputFile,strjoin(inputFiles)));

if st~=0
    %gs didn't finish correctly
    error(cmdOut)
end
%%
if param.remove
    [st,cmdOut]=system(sprintf('%s %s',param.rmPath,strjoin(inputFiles)));
    if st~=0
        %gs didn't finish correctly
        error(cmdOut)
    end
end











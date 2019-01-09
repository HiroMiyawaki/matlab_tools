function catPDF(output,inputs,varargin)
% function catPDF(output,inputs,options)
%  concatenate multiple PDFs to one PDF file using gs
%
%  output : output PDF file name
%  inputs : cell which contains list of input PDF files;
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
if isempty(inputs)
    error('give at least one input file')
end

for n=1:length(inputs)
    if exist(inputs{n},'file'); 
        continue
    elseif exist([inputs{n} '.pdf'],'file') 
        inputs{n} =[inputs{n} '.pdf'];
    else
        error('%s not found',inputs{n})
    end
end

%% get fullpath of inputs
for n=1:length(inputs)
    [~,temp]=fileattrib(inputs{n});
    inputs{n}=temp.Name;
end

%% check output file
if length(output)<4  || strcmpi(output(end-3:end),'.pdf')
    output=[output '.pdf'];
end

%% get fullpath of output
[fPath,fName,fExt]=fileparts(output);
if isempty(fPath)
    fPath=pwd;
else
    if ~exist(fPath,'dir')
        mkdir(fPath);
    end
    [~,temp]=fileattrib(fPath);
    fPath=temp.Name;
end    
output=fullfile(fPath,[fName,fExt]);

%% check overwrite
if exist(output,'file')
    if param.overwrite
        warning('%s is overwritten',output)
    else
        error('%s already exist',output)
    end
end

%% call gs
[st,cmdOut]=system(sprintf('%s -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=%s %s',param.gsPath,output,strjoin(inputs)));

if st~=0
    %gs didn't finish correctly
    error(cmdOut)
end
%%
if param.remove
    [st,cmdOut]=system(sprintf('%s %s',param.rmPath,strjoin(inputs)));
    if st~=0
        %gs didn't finish correctly
        error(cmdOut)
    end
end











function param=parseParameters(default,varargin)
% param=parseParameters(default, name, value, name, value,...)
% set parameters with given option
% default: structure with default values
%

if mod(length(varargin),2)~=0
    error('options must be pairs of name and value')
end
param=default;
optionList=fieldnames(default);
for n=1:length(varargin)/2
    idx=find(strcmpi(optionList,varargin{2*n-1}));
    if isempty(idx)
        error('Wrong option: %s',varargin{2*n-1})
    end
    param.(optionList{idx})=varargin{2*n};
end
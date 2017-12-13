% [n, bin] = histcI(x, edges, dim)
%
% This is like histc (MATLAB builtin function) but with the
% difference that there is one less output bin - the annoying
% one that contained anything equal to edges(end) is gone -
% insteac anything equal to the edges(end) is included in the
% previous bin

function [n, bin] = histcI(varargin)

[n, bin] = histc(varargin{:});

len = length(n);
n(len-1) = n(len-1)+n(len);
n(len) = [];

bin(find(bin==len)) = len-1;

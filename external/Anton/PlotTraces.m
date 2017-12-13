%function h = PlotTraces(x,t,sr,scale,color,ifnorm, AxesIncr)
% x is a matrix of signals to plot (dims order doesn't matter)
% t is time axis, sr - sampling, scale - coefficient to scale up the signals
% color - to use, norm - if you want ot normolize them all evenly
function h = PlotTraces(x,varargin)
x=squeeze(x);
nChannels = min(size(x));
nTime = max(size(x));
if (size(x,1)~=nTime)
    x=x';
end
[ t,sr,scale,color,ifnorm,AxesIncr] = DefaultArgs(varargin, { [], 1600,  1, 'k', 0, 0});
if isempty(t)
    t= [1:nTime]*1000/sr;
end
%ranChAmp = range(x);

x = x*scale;

newx = x - repmat(mean(x([1:2,end-1:end],:),1),nTime,1);
%shift = max(ChAmp);
shift =max(max(x));
newx = newx - shift/2-repmat([0:nChannels-1].*shift,nTime,1);
h= plot(t,newx,color);
axis tight
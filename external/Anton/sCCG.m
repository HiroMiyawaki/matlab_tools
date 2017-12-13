%function [sccg ccg tbin Width] = sCCG(T1,T2,BinSize,HalfBins,SampleRate,Normalization, Width)
function [sccg ccg tbin Width] = sCCG(T1,T2,BinSize,HalfBins,SampleRate,varargin)
[Normalization,Width] = DefaultArgs(varargin,{'count',[]});

if isempty(Width) 
    Width = BinSize;
end
nn = NearestNeighbour(T1,T2,'both',BinSize*(HalfBins+1));
if isempty(nn)
    sccg=zeros(HalfBins*2+1,1);
    ccg=zeros(HalfBins*2+1,2,2);
    tbin=zeros(HalfBins*2+1,1);
    Width=Width;
%     warning('two spike trains do not overlap by BinSize*(HalfBins+1)');
    return
end

[T,G] = CatTrains({T1,T2},{1,2});
[T si] = sort(T);
G = G(si);

[ccg tbin pairs] = CCG(T,G,BinSize,HalfBins,SampleRate,Normalization,[1 2]);
if isempty(pairs)
    sccg=zeros(HalfBins*2+1,1);
    ccg=zeros(HalfBins*2+1,2,2);
    tbin = [-HalfBins:HalfBins]*BinSize/SampleRate*1000;
    Width=Width;
    warning('two spike trains do not overlap by BinSize*(HalfBins+1)');
    return
end
T=T'; %fix for 1 pair

XPairs = pairs(G(pairs(:,1))==1&G(pairs(:,2))==2,:);
Lag = diff(T(XPairs),1,2);

stbin = tbin*SampleRate/1000;
if isempty(Width)
    [f,xi,Width] = ksdensity(Lag,stbin);
else
    [f,xi,Width] = ksdensity(Lag,stbin,'width',Width);
end
k = sum(f)./sum(ccg(:,1,2));
sccg = f./k;

 if nargout<1
     figure
     bar(tbin,ccg(:,1,2));hold on
     plot(tbin,sccg,'r','LineWidth',2);
     axis tight
 end
%keyboard

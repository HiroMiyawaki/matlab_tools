% [m Bins iq Resid] = MedianSmooth(x,y,Bins)
% splits x into bins, and calculates the median of y in each bin.
%
% Bins may be a vector in which case the nth bin is all those points
% greater than or equal to x(n) but less than x(n+1), and the last
% one is all those greater than x(end).  Or it may be a number in
% which case bins are assigned automatically so that each bin has
% that many points in it.
%
% third optional output argument is the iqr of the relevant bin
%
% fourth optional output is the residual
%
% see also MeanSmooth

function [m, Bins, iq, Resid] = MedianSmooth(x,y,Bins)

if (length(Bins) == 1)
	PointsPerBin = Bins;
	sorted = sort(x);
	Bins = sorted(1:PointsPerBin:end);
end
nBins = length(Bins);

m = zeros(nBins,1);
iq = zeros(nBins,1);
PointsInBin = cell(nBins, 1);

for n=1:nBins-1
	PointsInBin{n} = find(x>=Bins(n) & x<Bins(n+1));
	if ~isempty(PointsInBin{n})
		m(n) = median(y(PointsInBin{n}));
		iq(n) = iqr(y(PointsInBin{n}));
	end
end

% do last bin
PointsInBin{nBins} = find(x>=Bins(nBins));
if ~isempty(PointsInBin{nBins})
	m(nBins) = median(y(PointsInBin{nBins}));
	iq(nBins) = iqr(y(PointsInBin{nBins}));
end

% Calculate residuals
Resid = zeros(size(x));
for n=1:nBins
	Resid(PointsInBin{n}) = y(PointsInBin{n}) - m(n);
end
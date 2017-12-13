% [m Bins sd stderr] = MeanSmooth(x,y,Bins)
% splits x into bins, and calculates the mean of y in each bin.
%
% Bins may be a vector in which case the nth bin is all those points greater than
% or equal to x(n) but less than x(n+1), and the last one is all those greater than
% x(end).  Or it may be a number - in which case the range of x is divided into
% bins containing that many points.
%
% third and fourth optional output arguments are the sd and standard error for
% the relevant bin.
%
% see also MedianSmooth

function [m, Bins, sd, stderr] = MeanSmooth(x,y,Bins)

if (length(Bins) == 1)
	PointsPerBin = Bins;
	sorted = sort(x);
	Bins = sorted(1:PointsPerBin:end);
end
nBins = length(Bins);

m = zeros(nBins,1);
sd = zeros(nBins,1);
stderr = zeros(nBins,1);

for n=1:nBins-1
	PointsInBin = find(x>=Bins(n) & x<Bins(n+1));
	if ~isempty(PointsInBin)
		m(n) = mean(y(PointsInBin));
		sd(n) = std(y(PointsInBin));
		stderr(n) = sd(n) / sqrt(length(PointsInBin));
	end
end

% do last bin
PointsInBin = find(x>=Bins(nBins));
if ~isempty(PointsInBin)
	m(nBins) = mean(y(PointsInBin));
	sd(nBins) = std(y(PointsInBin));
	stderr(nBins) = sd(nBins) / sqrt(length(PointsInBin));
end
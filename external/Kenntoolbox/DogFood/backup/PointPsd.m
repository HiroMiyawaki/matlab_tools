function [out, mu, sd] = PointPsd(t,FreqRange, nBins, tRange)
%function [p,mu,sd] = PointPsd(t, FreqRange, nBins, tRange)
%
% Estimates power spectrum for a point process
%
% t is the input time series, a vector of event times
%
% FreqRange is the range of frequencies to evaluate at.
%
% nBins is for averaging - as in Welch's method
%
% tRange optionally gives max and min times - otherwise its
% min and max of data
%
% optional outputs give the mean and s.d. expected for a
% Poisson process

FreqRange = FreqRange(:);
nFreqs = length(FreqRange);
t = t(:);

if nargin<4
    MaxTime = max(t);
    MinTime = min(t);
else
    MaxTime = tRange(2);
    MinTime = tRange(1);
end

BinSize = (MaxTime - MinTime) / nBins;

Bin = ceil((t-MinTime) / BinSize);

Bin(1) = 1;

Transform = zeros(nBins, nFreqs);

Mul = sqrt(2/3);
for b = 1:nBins
	Times = t(find(Bin==b));
    if length(Times)==0, continue;end;
	TimeSinceBinStart = Times-(b+1)*BinSize;
	Exponent = exp(2*pi*i * Times * FreqRange');
	Taper = Mul*(1 - cos(2*pi*TimeSinceBinStart/BinSize));
	TaperMat = repmat(Taper, 1, nFreqs);
	Transform(b,:) = sum(Exponent .* TaperMat, 1);
end;

p = sum(abs(Transform).^2,1) / (nBins*BinSize);

if nargout<1
	newplot;
	plot(FreqRange,10*log10(abs(p))), grid on
	xlabel('Frequency'), ylabel('Power Spectrum Magnitude (dB)');
else
	out = p;
    mu = length(t)/(MaxTime-MinTime);
    sd = mu/sqrt(nBins);
end

% [rho sig] = RankCorrelation(y,x)
%
% Spearman's rank correlation coefficient
% Use this like regress - because all it does is make ranks from
% the inputs and call regress.
%
% p returns significance level.
% for small sample sizes (<=20) this is either 0 or .0.05
% because it is based on a table

function [rho, p] = RankCorrelation(y,x)

n = length(y);
if (n~=length(x))
	error('y and x should have the same length');
end

if n<=2
	rho = 1;
	sig = 0;
	p = 1;
	return;
end

% calculate ranks
xRank = Stiedrank(x);
yRank = Stiedrank(y);

% old version
% [xSort xInd] = sort(x);
% xRank(xInd) = (1:n)';
% % look for ties
% d = [1,diff(xSort(:))',1];
% dd = diff(d==0);
% TieStart = find(dd==1);
% TieEnd = find(dd==-1);
%[ySort yInd] = sort(y);
%yRank(yInd) = (1:n)';

R = sum((xRank-yRank).^2);

rho = 1 - 6*R/(n^3-n);

% evaluate significance

if (n>20)
	z = (6*R - n*(n^2-1))/(n*(n+1)*sqrt(n-1));
	sig = abs(z) > 1.96; % .05%, 2 sided
	p = 1-Snormcdf(abs(z)); % 1 sided p-value
else
	% .05 significance, 2 tailed
	SigVal = [1 1 1 1 .9 .8286 .7450 .6905 .6833 .6364 ...
		.6091 .5804 .5549 .5341 .5179 .5000 .4853 .4716 .4579 .4451];

	% .1 significance, 2 tailed
%	SigVal = [1 1 1 .8 .8 .7714 .6786 .5952 .5833 .5515 ...
%		.5273 .4965 .4780 .4593 .4429 .4265 .4118 .3994 .3895 .3789];
	if abs(rho) > SigVal(n)
		p = .05;
	else
		p = 1;
	end
	
%	sig = abs(rho) > SigVal(n);
%	p = 1 - .95*sig;

end;

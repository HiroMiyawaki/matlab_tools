function power=ttestPower (n,alpha,d,type)
% calculate t-test (one sample, paired, or equal two samples),
% with n points for each group, effect size (difference of mean / std)
% tested with The Level of Significance alpha 
%
% took from R package "pwr" and converted to Matlab by HM, on Sep 2015


if exist('type','var') && strcmpi(type, 'twoSample')
    tsample=2;
else
    tsample=1;
end


d=abs(d);
qu=tinv(1-alpha/2,n-1);
power=1-nctcdf(qu, n-1, sqrt(n/tsample) * d) + nctcdf(-qu, n-1, sqrt(n/tsample) * d)


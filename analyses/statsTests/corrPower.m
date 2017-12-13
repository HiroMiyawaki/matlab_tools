function power=corrPower(r,alpha,n)
% calculate Pearson correlation coeeficeint r from n points,
% tested with The Level of Significance alpha 
%
% took from R package "pwr" and converted to Matlab by HM, on Sep 2015
r=abs(r);
ttt=tinv(1-alpha/2,n-2);

rc=sqrt(ttt^2/(ttt^2 + n -2));
zr=atanh(r)+r/(2*(n-1));
zrc=atanh(rc);

power=normcdf((zr-zrc)*sqrt(n-3)) + normcdf((-zr -zrc) * sqrt (n-3));

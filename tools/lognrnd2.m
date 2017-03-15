function val=lognrnd2(mu,sigma,m,n)

if ~exist('m','var')
    m=1;
end
if ~exist('n','var')
    n=1;
end

val=lognrnd(log(mu^2/sqrt(sigma^2+mu^2)),sqrt(log(sigma^2/mu^2+1)),m,n);

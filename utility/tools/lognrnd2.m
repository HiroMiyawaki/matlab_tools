function val=lognrnd2(mu,sigma,varargin)
    val=lognrnd(log(mu^2/sqrt(sigma^2+mu^2)),sqrt(log(sigma^2/mu^2+1)),varargin{:});


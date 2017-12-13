% th = VonMisesRnd(MU, K)
%
% returns a matrix of random numbers from a VonMises distribution
% with parameters MU and K.
% The size of R is the common size of MU and K if both are matrices.
% If either parameter is a scalar, the size of R is the size of the other
% parameter. Alternatively, th = VonMisesRnd(MU,K,M,N) returns an M by N
% matrix.

function th = VonMisesRnd(mu, k, m, n)

% check input args (cribbed from nbinrnd)

if nargin == 2
    [errorcode rows columns] = rndcheck(2,2,mu,k);
    if max(size(mu)) == 1,mu = mu(ones(rows,1),ones(columns,1));end
    if max(size(k)) == 1,k = k(ones(rows,1),ones(columns,1));end
end


if nargin == 3
    [errorcode rows columns] = rndcheck(3,2,mu,k,m);
    mu = mu(ones(m(1),1),ones(m(2),1));
    k = k(ones(m(1),1),ones(m(2),1));

end

if nargin == 4
    [errorcode rows columns] = rndcheck(4,2,mu,k,m,n);
    mu = mu(ones(m,1),ones(n,1));
    k = k(ones(m,1),ones(n,1));
end

if errorcode > 0
    error('Size information is inconsistent.');
end

% now the real part - see Fisher p.49
a = 1+ sqrt(1+4*k.*k);
b = (a-sqrt(2*a))./(2*k);
r = (1+b.^2)./(b*2);

ToDo = 1:prod(size(mu));
% builds up valid f
fMat = zeros(size(mu));
while(~isempty(ToDo))
    rMy = reshape(r(ToDo), size(ToDo));
    kMy = reshape(k(ToDo), size(ToDo));
    
    z = cos(pi*rand(size(ToDo)));
    f = (1+rMy.*z)./(rMy+z);
    fMat(ToDo) = f;

    c = kMy.*(rMy-f);
    u2 = rand(size(ToDo));
    ToDo = ToDo(find(c.*(2-c)-u2<=0 & log(c./u2)+1-c<0 ));
end

th = mod(sign(rand(size(mu))-.5).*acos(fMat) + mu, 2*pi);

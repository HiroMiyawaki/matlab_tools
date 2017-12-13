% [p, t2] = t2test(x1, x2)
%
% Hotelling's T2 test that two multivariate normal populations have the same mean

function [p, t2] = t2test(x1, x2)

n1 = size(x1,1);
n2 = size(x2,1);

d = size(x1,2);

% subtract means
m1 = mean(x1);
m2 = mean(x2);
x10 = x1-ones(n1,1)*m1;
x20 = x2-ones(n2,1)*m2;

S = (x10'*x10 + x20'*x20) / (n1+n2-2);

del = m1-m2;

t2 = del*inv(S*(1/n1 + 1/n2))*del';

f = t2*(n1+n2-d-1)/(d*(n1+n2-2));

p = 1-fcdf(f, d, n1+n2-d-1);

%keyboard
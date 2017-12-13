% [L, d, dd, mu, PlaceFac] = CalcL(Par, Data, Predictor, c, t)
% computes log_e-likelihood, derivative, and hessian
% for predicting cell c summed over timepoints t
%
% LinkFn 0 - exp. 1 - exp for x<=0 1+x for x>0. 2 - 1./(1-x) for x<=0 1+x for x>0.

function [L, d, dd, mu, PlaceFac] = CalcL(Par, Data, Predictor, c, t)

PlaceFac = Predictor.Pf(sub2ind(Par.SpaceGrid*[1 1], Data.iPos(t,1), Data.iPos(t,2)));

% compute mean rate
MeanRate = sum(Data.SpkCnt(t,c))/length(t);
n = Data.SpkCnt(t,c);

if length(Data.SmSpkCnt)>0
    
    % compute training array.
    if Par.ExcludeSameTetrode
        PredCells = find(Par.TetNo>=0 &  Par.TetNo~=Par.TetNo(c));
    else
        PredCells = find(Par.TetNo>=0 & ([1:Par.nCells]'~=c));
    end
    v = Data.SmSpkCnt(t,PredCells);
    
    % we are using temporal smoothing.
    Eta = v * Predictor.Wt;
    Minus = find(Eta<=0); 
    Plus = find(Eta>0);
    if Par.LinkFn==1        
        % use fancy link function
        % which ones are log and which linear?
        PopFac(Minus) = exp(Eta(Minus));
        PopFac(Plus) = (1+Eta(Plus));
    elseif Par.LinkFn==2
        PopFac(Minus) = 1./(1-Eta(Minus));
        PopFac(Plus) = (1+Eta(Plus));
    else
        % just use exponential
        PopFac = exp(Eta);
    end
    PopFac = PopFac(:);
else
    % no temporal smoothing
    PopFac = 1;
end

% compute expected # spikes
mu = PlaceFac .* PopFac; % predicted mean firing rate

% compute L
% L = sum( -(mu-MeanRate) + (log(mu)-log(MeanRate)).*n)/log(2);
L = sum( -mu + log(mu).*n) - Par.Ridge * sum(Predictor.Wt.^2);;

% compute derivative and Hessian (if needed)
if nargout<2; return; end;

% if you've asked for d and dd when TimeSm<0, get a warning and 0
if isempty(Data.SmSpkCnt)
    d = []; dd = [];
%     warning('You can''t compute derivative and Hessian if there is no weights!');
    return;
end
    
if Par.LinkFn==1
    % Mult is what you multiply v by 
    Mult(Minus) = n(Minus) - mu(Minus);
    Mult(Plus) = (n(Plus)./mu(Plus) - 1).*PlaceFac(Plus);
elseif Par.LinkFn==2
    Mult(Minus) = (n(Minus)- mu(Minus)).*PopFac(Minus);
    Mult(Plus) = (n(Plus)./mu(Plus) - 1).*PlaceFac(Plus);
else
	Mult = (n - mu);
end
dNoRidge = Mult(:)' * v;
d = dNoRidge - 2 * Par.Ridge * Predictor.Wt';

if nargout<3; return; end;
if Par.LinkFn==1
    Mult(Minus) = mu(Minus);
    Mult(Plus) = n(Plus) .* PlaceFac(Plus).^2 .* mu(Plus).^-2;
%    Mult(Plus) = PlaceFac(Plus).^2./mu(Plus); % fisher info = expectation of dd
elseif Par.LinkFn==2
    Mult(Minus) = (2*mu(Minus)-n(Minus)).*PopFac(Minus).^2;
    Mult(Plus) = n(Plus) .* PlaceFac(Plus).^2 .* mu(Plus).^-2;
else
    Mult = mu;
end    

ddNoRidge = v'*sparse(1:length(mu),1:length(mu),Mult)*v;
dd = ddNoRidge + 2*Par.Ridge*eye(length(PredCells));

if 0
plot(Eta);
whos Minus Plus
keyboard
end
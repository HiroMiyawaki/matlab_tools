% Quantile(X, y)
%
% Computes the quantiles that show how the values in y are distributed 
% relative to the distribution of X.  So if X was a sample from N(0,1),
% and y was 0, the answer would be 0.5.

function q = Quantile(X, y)

% remove Nans from X
X(find(isnan(X))) = [];

nX = length(X);
ny = length(y);

ToSort = [X(:) ; y(:)];
Label = [ones(nX,1) ; zeros(ny,1)];
[Sorted Index] = sort(ToSort);
CumDist = cumsum(Label(Index));
qAll(Index) = CumDist/nX;
q1 = qAll(nX+1:end);

% do it again with y coming before X - this way if there are ties, 
% y can take the average of the two.
ToSort = [y(:) ; X(:)];
Label = [zeros(ny,1); ones(nX,1)];
[Sorted Index] = sort(ToSort);
CumDist = cumsum(Label(Index));
qAll(Index) = CumDist/nX;
q2 = qAll(1:ny);

% make the average
q = (q1+q2)/2;

% don't allow NaNs through
q(find(isnan(y))) = NaN;
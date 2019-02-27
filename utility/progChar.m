function nProgChar=progChar(tStart,n,nTotal,nPrevChar,nDivBar,newLineEvery)
% nProgChar=progChar(tStart,n,nTotal,nPrevChar,nDivBar,newLineEvery)
%  show progress of iteration on command window
%    set nDivBar = 0 when progress bar is not needed
%    set newLineEvery = -1 when line break is not needed
%
%  see how to use in the follwoing example
%  
%     %typical usage
%     clc
%     t=now;
%     nChar=0
%     for n=1:nIteration
%         %
%         % do something here
%         %
%         nChar=progChar(t,n,nIteration,nChar)
%     end
%
% by Hiro Miyawaki at the Osaka City Univ, Feb 2019
%

if ~exist('nDivBar','var') || isempty(nDivBar)
    nDivBar=60;
end
if ~exist('newLineEvery','var') || isempty(newLineEvery)
    newLineEvery=100;
end


procText='';
procBar=[repmat('-',1,nDivBar)];
procBar(ceil(n/nTotal*nDivBar))='*';
procBar(1:floor(n/nTotal*nDivBar))='=';

tNow=now;
tEst=tNow+(tNow-tStart)/n*(nTotal-n);

if n>1
    fprintf(repmat('\b',1,nDivBar));
end
fprintf(repmat('\b',1,nPrevChar));
procText=sprintf('%s %d/%d, est. finish: %s\n',datestr(tNow),n,nTotal,datestr(tEst));

fprintf(procText);
fprintf(procBar);
if mod(n,newLineEvery)==1
    procText='';
end
if n==nTotal
    fprintf(' Done at %s \n',datestr(now))
end
nProgChar=numel(procText);

    




%
%  function [ccgR,tR,GSPExc,GSPInh]=CCG_jitter(spiket,spikeind,clu1,clu2,BinSize,HalfBins,jscale,njitter,alpha)
%
%  spiket, spikeind  : res file, clu file
%  clu1, clu2        : the cell numbers
%  Bizsize, HalfBins : --> see 'CCG.m'
%  jscale            : jittering scale, unit is 'ms'
%  njitter           : # of jittering
%  alpha             : significant level
%  ---------------------------------------------------
%  ccgR   : ccg of real data   <-- [ccg,t]=CCG(...);
%  tR     : t of real data
%  GSPExc : Global Significant Period of Mono Excitation.
%  GSPInh : Global Significant Period of Mono Inhibition.
%  ---------------------------------------------------
%  Example  : [ccgR,tR] = CCG_jitter(spiket,spikeind,clu1,clu2,1,50,5,500,0.01);
%             --- binsize is 1ms (20khz), jitter time scale is 5ms, 500 times jittering, p<0.01
%
%  Coded by  Shigeyoshi Fujisawa
%   based on Asohan Amarasimghan's resampling methods

function [GSPExc,GSPInh,pvalE,pvalI,ccgR,tR]=CCG_jitter(res1,res2,SampleRate,BinSize,HalfBins,jscale,njitter,alpha,plot_output)

if nargin<9
    plot_output = 0;
end

% jscale : unit is 'ms'

one_ms = SampleRate/1000;
% 
% res1 = spiket(spikeind==clu1);
% res2 = spiket(spikeind==clu2);

% clear spiket spikeind

% set default values
if plot_output
ccgj = zeros(2*HalfBins+1,njitter);
end

ccgjmax = zeros(1,2*HalfBins+1);
ccgjmin = zeros(1,2*HalfBins+1);
tR = -HalfBins:HalfBins;
ccgR = zeros(2*HalfBins+1,2,2);


if ~isempty(res1)&~isempty(res2)
    nn = NearestNeighbour(res1,res2,'both',BinSize*(HalfBins+1));
    if isempty(nn)
        % try to save some time in case no overlap
        warning('two spike trains do not overlap by BinSize*(HalfBins+1)');
    else

        [ccgR, tR] = CCG([res1;res2],[ones(size(res1));2*ones(size(res2))], BinSize, HalfBins, SampleRate,'count',[1,2]);

        %%%%%%  CCG for jittering data
        for ii=1:njitter
            res2_jitter = res2 + 2*(one_ms*jscale)*rand(size(res2))-1*one_ms*jscale;
            [ccg] = CCG([res1;res2_jitter],[ones(size(res1));2*ones(size(res2))], BinSize, HalfBins, SampleRate,'count',[1,2]);
            if plot_output
                ccgj(:,ii)=ccg(:,1,2);
            end
            ccgjmax(ii)=max(ccg(:,1,2));
            ccgjmin(ii)=min(ccg(:,1,2));
        end

    end
end

%%%%%%  Compute the pointwise line
signifpoint = njitter*alpha;

%%%%%%%%%%%%%%% Presentation
if plot_output
    figure
    %plot(tR,ccgR(:,1,2),'color','k')
    bar(tR,ccgR(:,1,2),'w')
    line(tR,ccgjm,'linestyle','--','color','b')
    line(tR,ccgjptMax,'linestyle','--','color','r')
    line(tR,ccgjgbMax,'linestyle','--','color','m')
    line(tR,ccgjptMin,'linestyle','--','color','r')
    line(tR,ccgjgbMin,'linestyle','--','color','m')
    set(gca,'XLim',[min(tR),max(tR)])

    for ii=1:2*HalfBins+1;
        sortjitterDescend  = sort(ccgj(ii,:),'descend');
        sortjitterAscend   = sort(ccgj(ii,:),'ascend');
        ccgjptMax(ii) = sortjitterDescend(signifpoint);
        ccgjptMin(ii) = sortjitterAscend(signifpoint);
    end
    ccgjm  = mean(ccgj,2);

clear ccgj

end

%%%%%%  Compute the global line
sortgbDescend   = sort(ccgjmax,'descend');
sortgbAscend    = sort(ccgjmin,'ascend');
ccgjgbMax  = sortgbDescend(signifpoint)*ones(1,2*HalfBins+1);
ccgjgbMin  = sortgbAscend(signifpoint)*ones(1,2*HalfBins+1);


%%%%%%%%%%%%%% Significant Period

GSPExc = zeros(size(tR));  % Global Significant Period of Mono Excitation
GSPInh = zeros(size(tR));  % Global Significant Period of Mono Inhibition

pvalE = ones(size(tR));
pvalI = ones(size(tR));
    
min_ccgcount = 1*(2*HalfBins+1);
mincount = 6;
if sum(ccgR(:,1,2))>min_ccgcount

    findExc = find((ccgR(:,1,2)>ccgjgbMax')&(ccgR(:,1,2)>=mincount)); %&abs(tR')<=5
    findInh = find((ccgR(:,1,2)<ccgjgbMin')); % &abs(tR')<=5

    GSPExc(findExc) = 1;
    GSPInh(findInh) = 1;

if nargout>2
    for ii=1:size(tR,2);
%         pvalE(ii) = sum(ccgjmax > ccgR(ii,1,2))/njitter; % = ccgR(ii,1,2)/median(ccgR(:,1,2));
%         pvalI(ii) = sum(ccgjmin < ccgR(ii,1,2))/njitter; % = median(ccgR(:,1,2))/ccgR(ii,1,2);
        pvalE(ii) = ccgR(ii,1,2)/(eps+median(ccgR(:,1,2)));
        pvalI(ii) = ccgR(ii,1,2)/(eps+median(ccgR(:,1,2)));
    end
end

end


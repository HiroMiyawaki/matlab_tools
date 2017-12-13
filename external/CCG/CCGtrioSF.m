 function [ccgTr,tTr,T_trios,sccgTr] =  CCGtrioSF(spike,shank1,cluster1,shank2,cluster2,shank3,cluster3,BinSize,HalfBins)
%
%  spiket  : spike times   (=res)
%  spikeind: spike indices (=clu)
%  cluA, cluB, cluC : cell index (single value) which you want to compute CCG; cluA is the reference.
%

% function [ccgTr,tTr,T_trios,sccgTr] =  CCGtrio(spiket,spikeind,cluA,cluB,cluC,BinSize,HalfBins,SmoothWidth)

% cluA is the reference to the CCG A vs B
% cluA is the reference to the CCG A vs C

one_ms = 32.552;
if nargin<8;
    BinSize = 32.552;
    HalfBins = 20;
end

   resA = spike.t(find(spike.shank==shank1 & spike.cluster==cluster1 & spike.theta==1 & spike.ripple==0 & spike.speed>5));
   resB = spike.t(find(spike.shank==shank2 & spike.cluster==cluster2& spike.theta==1 & spike.ripple==0 & spike.speed>5));
   resC = spike.t(find(spike.shank==shank3 & spike.cluster==cluster3& spike.theta==1 & spike.ripple==0 & spike.speed>5));
   
%    resA = [1:32552:50*32552]';
%    resB = resA(20:40) + 2*one_ms;
%    resB = resB + one_ms*randn(size(resB));
%    resC = resA(20:30) + 7*one_ms;
%    resC = resC + one_ms*randn(size(resC));
   
   
   T_AB=[resA;resB];
   G_AB=[ones(size(resA));2*ones(size(resB))];
   [ccgAB,tAB,pairs1] = CCG(T_AB,G_AB, BinSize, HalfBins, 32552,'count');  
   % pairs1 includes autocorr
   % gives indices of T_AB which fall within CCG timebin.
   PairsAB = pairs1(G_AB(pairs1(:,1))==1 & G_AB(pairs1(:,2))==2 , :);   % Now pairsAB includes only crosscorr
   
   
   T_AC=[resA;resC];
   G_AC=[ones(size(resA));2*ones(size(resC))];
   [ccgAC,tAC,pairs2] = CCG(T_AC,G_AC, BinSize, HalfBins, 32552,'count');
   PairsAC = pairs2(G_AC(pairs2(:,1))==1 & G_AC(pairs2(:,2))==2 , :);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T_C = T_AC(unique(PairsAC(:,2)));

deltaAB = round(diff(T_AB(PairsAB)')/(BinSize))'*BinSize/one_ms;
   
ccgTr1 = [];
allspikes1 = [];
cspikes1 = [];
for dt = tAB;
    findthisAB = find(deltaAB==dt);
    allspikes1 = [allspikes1;findthisAB];
    res = [T_AB(PairsAB(findthisAB,1));T_C];
    clu = [ones(length(findthisAB),1);2*ones(size(T_C))];
    ccgACt = CCG(res,clu, BinSize, HalfBins, 32552,'count');
    cspikes1 = [cspikes1;sum(ccgACt(:,1,2))];
    ccgTr1 = [ccgTr1;ccgACt(:,1,2)'];
%     if ~isempty(findthisAB)
%         keyboard
%     end
end
   
allspikes = [];
cspikes = [];
   uniA = unique(PairsAB(:,1));
   Trios=[];
   for i=1:length(uniA)

       findthisAB=find(PairsAB(:,1)==uniA(i));
       findthisAC=find(PairsAC(:,1)==uniA(i));

       nAB=length(findthisAB);
       nAC=length(findthisAC);
    allspikes = [allspikes;nAB];
    cspikes = [cspikes;nAC];
       if nAC>0
          A_B123123 = repmat(PairsAB(findthisAB,:),[nAC,1]);                    %
          A_C111222 = reshape(repmat(PairsAC(findthisAC,2),[1,nAB])',[nAB*nAC,1]);       %
          Triosthis= [A_B123123 A_C111222];
          Trios    = [Trios;Triosthis];

       end
   end
   
%    T_trios=[resA(Trios(:,1)) T_AB(Trios(:,2)) T_AC(Trios(:,3))];
   T_trios=[T_AB(Trios(:,1)) T_AB(Trios(:,2)) T_AC(Trios(:,3))];
   
   % first column is times of relevant spikes of cell A
   % second column is time of cell B spikes after cell A
   % third column is time of cell C spikes after cell A
   Tdiff  = [T_trios(:,2)-T_trios(:,1), T_trios(:,3)-T_trios(:,1)]/(32552/1000);

   %tTr=[-BinSize*HalfBins:BinSize:BinSize*HalfBins];
   tTr=tAB;
   ctrs{1}=tTr;
   ctrs{2}=tTr;
   ccgTr=hist3(Tdiff,ctrs);

   % do the smoothing
% 
%    SmoothWidth=0.025*BinSize/max(tTr);
%    %SmoothWidth=0.05;
%    r = tTr/max(tTr);
%    Smoother = exp(-r.^2/(SmoothWidth)^2/2);
%    sccgTr = conv2(Smoother, Smoother, ccgTr, 'same');
   figure(124)
   clf
   
   imagesc(tAB,tAB,ccgTr1')
%    imagesc(tTr,tTr,sccgTr')
%    axis image
   axis xy
   
   hold on
   plot([-25 25],[-25 25],'m')
   plot([0 0],[-25 25],'m')
   plot([-25 25],[0 0],'m')
   hold off
   xlabel('Cell 1 vs. Cell 2')
   ylabel('Cell 1 vs. Cell 3')

   figure(123)
   clf
   
   imagesc(tTr,tTr,ccgTr')
%    imagesc(tTr,tTr,sccgTr')
%    axis image
   axis xy
   
   hold on
   plot([-25 25],[-25 25],'m')
   plot([0 0],[-25 25],'m')
   plot([-25 25],[0 0],'m')
   hold off
   xlabel('Cell 1 vs. Cell 2')
   ylabel('Cell 1 vs. Cell 3')
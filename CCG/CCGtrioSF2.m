 function [ccgTr,tTr,T_trios,sccgTr] =  CCGtrioSF(spike,shank1,cluster1,shank2,cluster2,shank3,cluster3,BinSize,HalfBins)
%
%  spiket  : spike times   (=res)
%  spikeind: spike indices (=clu)
%  cluA, cluB, cluC : cell index (single value) which you want to compute CCG; cluA is the reference.
%

% function [ccgTr,tTr,T_trios,sccgTr] =  CCGtrio(spiket,spikeind,cluA,cluB,cluC,BinSize,HalfBins,SmoothWidth)

% cluA is the reference to the CCG A vs B
% cluA is the reference to the CCG A vs C

if nargin<8;
    BinSize = 32.552;
    HalfBins = 20;
end
   resA = spike.shank==shank1 & spike.cluster==cluster1;
   resB = spike.shank==shank2 & spike.cluster==cluster2;
   resC = spike.shank==shank3 & spike.cluster==cluster3;
   acluA = spike.aclu(find(resA,1,'first'));
   acluB = spike.aclu(find(resB,1,'first'));
   acluC = spike.aclu(find(resC,1,'first'));
   
   T_AB=spike.t(find(resA|resB));
   G_AB=spike.aclu(find(resA|resB));
   [ccgAB,tAB,pairs1] = CCG(T_AB,G_AB, BinSize, HalfBins, 32552,'count');  
   % pairs1 includes autocorr
   % gives indices of T_AB which fall within CCG timebin.
   PairsAB = pairs1(spike.aclu(pairs1(:,1))==acluA & G_AB(pairs1(:,2))==acluB , :);   % Now pairsAB includes only crosscorr
   
   T_AC=spike.t(find(resA|resC));
   G_AC=spike.aclu(find(resA|resC));
   [ccgAC,t,pairs2] = CCG(T_AC,G_AC, BinSize, HalfBins, 32552,'count');
   PairsAC = pairs2(G_AC(pairs2(:,1))==acluA & G_AC(pairs2(:,2))==acluC,:);

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   tic
   uniA = unique(PairsAB(:,1));
   Trios=[];
   % goes through every spike in cell A that contributes to AB pairs
   for i=1:length(uniA)

       findthisAB=find(PairsAB(:,1)==uniA(i));
       findthisAC=find(PairsAC(:,1)==uniA(i));

       nAB=length(findthisAB);
       nAC=length(findthisAC);
       
       % are there spikes in C near enough?
       if nAC>1

          %% concatenate A-[B1 B2 B3 ..] & A-[C1 C2 ..]
          A_B123123 = repmat(PairsAB(findthisAB,:),[nAC,1]);                    %
          A_C111222 = reshape(repmat(PairsAC(findthisAC,2),[1,nAB])',[nAB*nAC,1]);       %
          Triosthis= [A_B123123 A_C111222];
          Trios    = [Trios;Triosthis];

       end
   end

   T_trios=[resA(Trios(:,1)) T_AB(Trios(:,2)) T_AC(Trios(:,3))];
   
   % first column is times of relevant spikes of cell A
   % second column is time of cell B spikes after cell A
   % third column is time of cell C spikes after cell A
   Tdiff  = [T_trios(:,2)-T_trios(:,1), T_trios(:,3)-T_trios(:,1)]/(32552/1000);

   %tTr=[-BinSize*HalfBins:BinSize:BinSize*HalfBins];
   tTr=tAB;
   ctrs{1}=tTr;
   ctrs{2}=tTr;
   ccgTr=hist3(Tdiff,ctrs);
%    imagesc(tTr,tTr,ccgTr)

toc
t = toc
   % do the smoothing

   SmoothWidth=0.025*BinSize/max(tTr);
   %SmoothWidth=0.05;
   r = tTr/max(tTr);
   Smoother = exp(-r.^2/(SmoothWidth)^2/2);
   sccgTr = conv2(Smoother, Smoother, ccgTr, 'same');

   figure(123)
   clf
   
   imagesc(tTr,tTr,sccgTr')
   axis image
   axis xy
   
   hold on
   plot([-25 25],[-25 25],'m')
   plot([0 0],[-25 25],'m')
   plot([-25 25],[0 0],'m')
   hold off
   xlabel('Cell 1 vs. Cell 2')
   ylabel('Cell 1 vs. Cell 3')
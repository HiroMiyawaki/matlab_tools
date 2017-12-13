function [ccg,t] = CCGplot(fileinfo,shank1,cluster1,shank2,cluster2,HalfBins,BinSize);
% function [ccg,t] = CCGplot(fileinfo,shank1,cluster1,shank2,cluster2,HalfBins,BinSize);

% calculate and plot the CCG for 2 cluster in four conditions...

if (nargin<6)
    HalfBins = 200;
end
if (nargin<7)
    BinSize = 32.552;
end

currentdir = pwd; 
directory = fileinfo.name;
FileBase = [currentdir '/' directory '/' directory];

load([FileBase '.spikeII.mat']);

first_cluster = zeros(size(spike.t));
second_cluster = zeros(size(spike.t));
for nn=1:4;
%     first_cluster = find(spike.shank==shank1 & spike.cluster == cluster1);
%     second_cluster = find(spike.shank==shank2 & spike.cluster == cluster2);
    pmap = squeeze(fileinfo.pmat{shank1}(cluster1,nn,:));
    peak = find(pmap==max(pmap),1,'first');
    if max(pmap)>0
    lesspeak = find(pmap<=0.1*max(pmap));
    ilp = find(lesspeak<peak,1,'last');
    edgein = lesspeak(ilp);
    ilp = find(lesspeak>peak,1,'first');
    edgeout = lesspeak(ilp);
    first_cluster = first_cluster + (spike.shank==shank1 & spike.cluster==cluster1 ...
        & spike.traj==nn & spike.speed>2);%& ...
%         spike.x>=edgein/100 & spike.x<=edgeout/100);
    end
    pmap = squeeze(fileinfo.pmat{shank2}(cluster2,nn,:));
    if max(pmap)>0
    peak = find(pmap==max(pmap),1,'first');
    lesspeak = find(pmap<=0.1*max(pmap));
    ilp = find(lesspeak<peak,1,'last');
    edgein = lesspeak(ilp);
    ilp = find(lesspeak>peak,1,'first');
    edgeout = lesspeak(ilp);
    second_cluster = second_cluster + (spike.shank==shank2 & spike.cluster==cluster2 ...
        & spike.traj==nn & spike.speed>2);%& ...
%         spike.x>=edgein/100 & spike.x<=edgeout/100);
    end
end
first_cluster = find(first_cluster);
second_cluster = find(second_cluster);

tempvec = sortrows([[spike.t(first_cluster) ones(size(first_cluster)) spike.traj(first_cluster)];...
    [spike.t(second_cluster) 2*ones(size(second_cluster)) spike.traj(second_cluster)]]);

maxis = zeros(1,4); maxis2 = zeros(1,4);

for cc = 1:3;
    figure(cc);clf
end
figure(3)
[ccgwhole, t] = CCG(tempvec(:,1),tempvec(:,2),BinSize,HalfBins,32552,'count',unique(tempvec(:,2)));
bar(t,squeeze(ccgwhole(:,1,2)),'k');
axis tight
title('CCG with all spikes') 

for nn = 1:4;
    find_nn = find(tempvec(:,3)==nn);
    if size(unique(tempvec(find_nn,2)),1)<2;
        continue
    end            
            
    [ccg{nn},t] = CCG(tempvec(find_nn,1),tempvec(find_nn,2),BinSize,HalfBins,32552,'scale',unique(tempvec(find_nn,2)));

    figure(1)
    subplot(2,2,nn)
    bar(t,squeeze(ccg{nn}(:,1,2)),'k');
    ax = axis; maxis(nn) = ax(4); % for scaling axes
    
    figure(2)
    subplot(2,2,nn)
    pmap = squeeze(fileinfo.pmat{shank1}(cluster1,nn,:));
    plot(pmap,'b','LineWidth',2);hold on
    pmap = squeeze(fileinfo.pmat{shank2}(cluster2,nn,:));
    plot(pmap,'c','LineWidth',2);hold off
    ax = axis; maxis2(nn) = ax(4);
    legend('ref','2nd');
end

%         wh = title(['file= ' fileinfo.name]);
title(['\bf Rank= ' num2str(fileinfo.cluq2{shank1}(cluster1))...
    ' & Rank= ' num2str(fileinfo.cluq2{shank2}(cluster2))])
%         set(wh,'Interpreter','none')


for nn = 1:4;
    figure(1)
    subplot(2,2,nn)
    if (nn==2);
        title(['\bf Fet ' num2str(shank1) ',clus ' num2str(cluster1)...
            ' & Fet ' num2str(shank2) ',clus ' num2str(cluster2) ])
    end

%     ylim([0 max(maxis)])  % scale axes properly
    xlim([-HalfBins*BinSize/32.552 HalfBins*BinSize/32.552])
end

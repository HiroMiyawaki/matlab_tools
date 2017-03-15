function [ccg,t] = CCGEP(fileinfo,pair,BinSize,HalfBins,thetafilt,runfilt,ripplefilt);
% function [ccg,t] = CCGEP(fileinfo,pair,BinSize,HalfBins,thetafilt,runfilt,ripplefilt);

% calculate and plot the CCG for 2 cluster in four conditions...

if (nargin<3)
    BinSize = 32.552;
    HalfBins = 75;
end

if (nargin<7);ripplefilt = [];end
if (nargin<6);runfilt = [];end
if (nargin<5);thetafilt = [];end

currentdir = pwd; 
directory = fileinfo.name;
FileBase = [currentdir '/' directory '/' directory];
% numclu = fileinfo.numclu;

load([FileBase '.spikeII.mat']);

shank1 = pair(1);
cluster1 = pair(2);
shank2 = pair(3);
cluster2 = pair(4);

first_cluster = find(spike.shank==shank1 & spike.cluster == cluster1);
second_cluster = find(spike.shank==shank2 & spike.cluster == cluster2);

res = sortrows([[spike.t(first_cluster) ones(size(first_cluster)) spike.traj(first_cluster)];...
    [spike.t(second_cluster) 2*ones(size(second_cluster)) spike.traj(second_cluster)]]);
    
if ~isempty(runfilt)
    smoothwin = [ones(15,1)];
    smoothwin = smoothwin/sum(smoothwin);
    xyt = fileinfo.xyt;
    tbegin = fileinfo.tbegin;
    tend = fileinfo.ftend;
    numofbins = round((tend-tbegin)/1e6*120);
    xyt(:,1) = filtfilt(smoothwin,1,xyt(:,1));
    xyt=binpos(xyt,numofbins);
    tt = (xyt(:,3)-tbegin)/1e6*32552;
    diffx = abs(diff(xyt(:,1)));
    speed = interp1(tt(1:end-1),diffx,res);
    running = (speed > 0.00029);
    if runfilt
        res = res(find(running),:);
    else
        res = res(find(~running),:);
    end 
end

if ~isempty(thetafilt);
    sts = dlmread([FileBase '.theta.1'])'*26;
    res_ind = STSfilt(sts,res,thetafilt);
    res = res(res_ind,:);
end

if ~isempty(ripplefilt)
    ripple_result = ripple_result(:,[1 3])'/1252*32552;
    res_ind = STSfilt(ripple_result,res,ripplefilt);
    res = res(res_ind,:);
end

maxis = zeros(1,4); maxis2 = zeros(1,4);

for cc = 1:3;
    figure(cc);clf
end
figure(3)

[ccgwhole, t] = CCG(res(:,1),res(:,2),BinSize,HalfBins,32552,'count',unique(res(:,2)));
if size(ccgwhole,3)>1
bar(t,squeeze(ccgwhole(:,1,2)),'k');
xlim([-HalfBins*BinSize/32.552 HalfBins*BinSize/32.552])
title('CCG with all spikes') 
end

for nn = 1:4;
    find_nn = find(res(:,3)==nn);
    if size(unique(res(find_nn,2)),1)<2;
        continue
    end
    [ccg{nn},t] = CCG(res(find_nn,1),res(find_nn,2),BinSize,HalfBins,32552,'count',unique(res(find_nn,2)));

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
    xlim([-HalfBins/2 HalfBins/2])
end

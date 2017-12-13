function [ncl] = INCCG(fileinfo,cells_to_plot,thetafilt,runfilt,ripplefilt);

% calculate and plot the CCG for all the interneurons in fileinfo

BinSize = 32.552;

currentdir = pwd; 
directory = fileinfo.name;
FileBase = [currentdir '/' directory '/' directory];

load([FileBase '.spikeII.mat']);

Clusters = zeros(size(spike.t));
tempvec =[];
for ii = cells_to_plot
    shank_ii = fileinfo.INmaxp(1,ii);
    cluster_ii = fileinfo.INmaxp(2,ii);
    find_cluster = find(spike.shank==shank_ii & spike.cluster==cluster_ii);% ...
    tempvec = [tempvec;[spike.t(find_cluster) ii*ones(size(find_cluster)) spike.traj(find_cluster) ...
    spike.theta(find_cluster) spike.ripple(find_cluster) spike.speed(find_cluster)]];
end
tempvec = sortrows(tempvec);
   
theta = find(tempvec(:,4)==1 & tempvec(:,6)>10);
CCG(tempvec(theta,1),tempvec(theta,2),BinSize,175,32552,'scale',cells_to_plot)
% set(gcf,'Position',[20 -100 1500 1200])



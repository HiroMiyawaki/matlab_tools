function [fastlaps,slowlaps,alllaps,numspk,pmap] = Ratespeedtrials(fileinfo,shank,cluster);

currentdir = pwd; 
directory = fileinfo.name;
FileBase = [currentdir '/' directory '/' directory];

load([FileBase '.spikeII.mat']);

SampleRate = 32552.1;
xyt = fileinfo.xyt;
tbegin = fileinfo.tbegin; tend = fileinfo.tend;
numofbins = round((tend-tbegin)/1e6*100);
withinrange = find(xyt(:,3)>=tbegin & xyt(:,3)<=tend);
tt = (xyt(:,3)-tbegin)/1e6*SampleRate;  % transform to res coords
xyt(:,3) = tt;
xytp=binpos(xyt(withinrange,:),numofbins);
tt = xytp(:,3);
barriers = [[.2498 .7502];[.2498 .7502];[.128175 .871825];[.128175 .871825]];

inandout = Laptimes(fileinfo);

for nn = 1:4
    find_nn = find(spike.traj==nn);
    lapspeed = [];
    for ll = unique(spike.lap(find_nn))';
        lapspeed =  [lapspeed ...
            [mean(spike.speed(find(spike.traj==nn&spike.lap==ll)));ll]];
    end
    lapspeed = sortrows(lapspeed')';
    iilap = floor(size(lapspeed,2)/2);
    
    this_nn = inandout(:,find(inandout(4,:)==nn));
    within = [];
    for ii = 1:iilap
        jj = find(this_nn(3,:)==lapspeed(2,ii));
        add_within = find(tt>=this_nn(1,jj) & tt<this_nn(2,jj));
        within = [within;add_within];
    end
    within = sort(within);
    
    find_slow = find(spike.traj==nn & spike.shank==shank & spike.cluster==cluster...
        & ismember(spike.lap,lapspeed(2,1:iilap)));
    spktimes = spike.t(find_slow);
    nspk = hist(spktimes,xytp(:,3)); nspk(end)=0; nspk(1)=0; % find number of spikes per unit time.
    pmaps=PF1D(xytp(within,:),nspk(within)',.02,100);
    slowlaps(nn) = max(pmaps);
    
    within = [];
    for ii = iilap+1:size(lapspeed,2)
        jj = find(this_nn(3,:)==lapspeed(2,ii));
        add_within = find(tt>=this_nn(1,jj) & tt<this_nn(2,jj));
        within = [within;add_within];
    end
    within = sort(within);
    
    find_fast = find(spike.traj==nn & spike.shank==shank & spike.cluster==cluster...
        & ismember(spike.lap,lapspeed(2,iilap+1:end)));
    spktimes = spike.t(find_fast);
    nspk = hist(spktimes,xytp(:,3)); nspk(end)=0; nspk(1)=0; % find number of spikes per unit time.
    pmapf=PF1D(xytp(within,:),nspk(within)',.02,100);
    fastlaps(nn) = max(pmapf);  
    
    within = [];
    for jj = 1:size(this_nn,2);
        add_within = find(tt>=this_nn(1,jj) & tt<this_nn(2,jj));
        within = [within;add_within];
    end
    within = sort(within);
    
    find_all = find(spike.traj==nn & spike.shank==shank & spike.cluster==cluster);
    spktimes = spike.t(find_all);
    nspk = hist(spktimes,xytp(:,3)); nspk(end)=0; nspk(1)=0; % find number of spikes per unit time.
    pmap=PF1D(xytp(within,:),nspk(within)',.02,100);
    alllaps(nn) = max(pmap);
    
    numspk(nn) = size(find_all,1);
%     plot(pmaps,'g');hold on
%     plot(pmapf,'r');
%     plot(pmap,'b');hold off
%     keyboard
end

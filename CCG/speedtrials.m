function [fastlaps,slowlaps] = speedtrials(fileinfo);

currentdir = pwd; 
directory = fileinfo.name;
FileBase = [currentdir '/' directory '/' directory];

load([FileBase '.spikeII.mat']);

xyt = fileinfo.xyt;
tbegin = fileinfo.tbegin; tend = fileinfo.tend;
numofbins = round((tend-tbegin)/1e6*100);
withinrange = find(xyt(:,3)>=tbegin & xyt(:,3)<=tend);
tt = (xyt(:,3)-tbegin)/1e6*SampleRate;  % transform to res coords
xyt(:,3) = tt;
xytp=binpos(xyt(withinrange,:),numofbins);
tt = xytp(:,3);

for nn = 1:4
    find_nn = find(spike.traj==nn);
    lapspeed = [];
    for ll = unique(spike.lap(find_nn))';
        lapspeed =  [lapspeed ...
            [mean(spike.speed(spike.traj==nn&spike.lap==ll));ll]];
    end
    lapspeed = sortrows(lapspeed')';
    iilap = floor(size(lapspeed,2)/2);
    slowlaps(nn) = mean(lapspeed(1,1:iilap));
    fastlaps(nn) = mean(lapspeed(1,iilap+1:end));
end

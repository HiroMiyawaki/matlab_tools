function [ExcPairs,InhPairs,numclu] = FindPairsLS(fileinfo,thetafilt,runfilt,ripplefilt);

% find excitatory and inhibitory cell pairs on long and short track.

SampleRate = 32552.1;
one_ms = SampleRate/1000;
BinSize = one_ms;
HalfBins = 50;
alpha = .05;

jscale = 5; % units of ms
njitter = 200; % # of times to jitter

currentdir = pwd; 
directory = fileinfo.name;
FileBase = [currentdir '/' directory '/' directory];

load([FileBase '.newspike.mat']);

resIN = Loadres([FileBase 'IN.5.res']);
cluIN = LoadClu([FileBase 'IN.5.clu']);
ncl = dlmread([FileBase 'IN.5.numclu']);

maxp = fileinfo.maxp;
pp = fileinfo.pp;
frate = fileinfo.peak_hertz;
ppr = fileinfo.ppr;
pI = fileinfo.pI;
prefph = fileinfo.prefph;

direction = [1 -1 1 -1];
mrv = zeros(1,4);

for nn = 3:4;
    nonzero = find(maxp(nn,:)~=0| maxp(nn-2,:)~=0);
    numclu{nn} = maxp([1:7],nonzero);
    mrv(nn) = size(numclu{nn},2);
    numclu{nn} = [numclu{nn} [zeros(4,size(ncl,2));ncl;5*ones(1,size(ncl,2))]];
    numclu{nn-2} = numclu{nn};
    mrv(nn-2) = mrv(nn);
end

spacebins = 200;

for nn = 1:4
    keepclu = [];
    if ~isempty(numclu{nn})
        for cc = 1:size(numclu{nn},2);
            if numclu{nn}(nn,cc)~=0
                shank = numclu{nn}(5,cc);
                cluster = numclu{nn}(6,cc);
                pmap = squeeze(fileinfo.pmat{shank}(cluster,nn,:));
                peak = find(pmap==max(pmap),1,'first');
                lesspeak = find(pmap<=0.1*max(pmap));
                ilp = find(lesspeak<peak,1,'last');
                edgein = lesspeak(ilp);
                ilp = find(lesspeak>peak,1,'first');
                edgeout = lesspeak(ilp);

                cc_keep = find(spike.shank==shank & spike.cluster==cluster ...
                    & spike.traj==nn & spike.speed>2& ...
                    spike.x>=(edgein-1)/spacebins & spike.x<=(edgeout-1)/spacebins );% ...
                
                keepclu = [keepclu; [cc_keep cc*ones(size(cc_keep))]];
            end
        end


        if ~isempty(keepclu)
            keepclu = sortrows(keepclu); 
            res = sortrows([[spike.t(keepclu(:,1)) keepclu(:,2)];[resIN cluIN+mrv(nn)]]);
            [ExcPairs{nn},InhPairs{nn}] = CCG_jitter_group(res(:,1),res(:,2),[1:max(res(:,2))],BinSize,HalfBins,jscale,njitter,alpha);
        else
            ExcPairs{nn}=[];InhPairs{nn} = [];
            numclu{nn} = [numclu{nn}];
        end
    end
end

return

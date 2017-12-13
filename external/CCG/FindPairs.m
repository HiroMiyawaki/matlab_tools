function [ExcPairs,InhPairs,GapPairs,numclu] = FindPairsLS(fileinfo);

% find excitatory and inhibitory cell pairs on long and short track.

currentdir = pwd;
FileBase = [currentdir '/' fileinfo.name '/' fileinfo.name];

Par =LoadPar([FileBase '.par']); % either par or xml file needed
EegRate = Par.lfpSampleRate; % sampling rate of eeg file
SampleRate = Par.SampleRate;

alpha = .1;

jscale = 5; % units of ms
njitter = 200; % # of times to jitter

currentdir = pwd; 
directory = fileinfo.name;
FileBase = [currentdir '/' directory '/' directory];

load([FileBase '.spikeII.mat']);

INclu = unique(spike.aclu(spike.qclu==5))';
ncl = [];
for ii = INclu
    shank = spike.shank(find(spike.aclu==ii,1,'first'));
    cluster = spike.cluster(find(spike.aclu==ii,1,'first'));
    ncl = [ncl [shank;cluster;5]];
end

maxp = fileinfo.maxp;

direction = [1 -1 1 -1];
mrv = zeros(1,4);

% for nn = 3:4;
%     nonzero = find(maxp(nn,:)~=0| maxp(nn-2,:)~=0);
%     numclu{nn} = maxp([1:7],nonzero);
%     numclu{nn} = [numclu{nn} [zeros(4,size(ncl,2));ncl]];
%     numclu{nn} = [numclu{nn};1:size(numclu{nn},2)];
%     numclu{nn-2} = numclu{nn};
% end

numclu = [maxp [zeros(4,size(ncl,2));ncl]];
for ii = 1:size(numclu,2);
    numclu(8,ii) = fileinfo.maxelec{numclu(5,ii)}(numclu(6,ii));
end

spacebins = 200;

for nn = 1:4
    keepclu = [];
    ExcPairs{nn}=[];InhPairs{nn}=[];
    if ~isempty(numclu)
        for cc = 1:size(numclu,2)
            if numclu(nn,cc)~=0|numclu(7,cc)==5
                shank = numclu(5,cc);
                cluster = numclu(6,cc);
                pmap = squeeze(fileinfo.pmat{shank}(cluster,nn,:));
                if max(pmap)>=2;
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
        end
        if ~isempty(keepclu)
            keepclu = sortrows(keepclu); 
            res = sortrows([spike.t(keepclu(:,1)) keepclu(:,2)]);
            [ExcPairs{nn},InhPairs{nn},GapPairs{nn}] = CCG_jitter_group(res(:,1),res(:,2),unique(res(:,2)),SampleRate,jscale,njitter,alpha);
            if ~isempty(ExcPairs{nn})
                ExcPairs{nn} = [ExcPairs{nn};numclu([5 6],ExcPairs{nn}(1,:))];
                ExcPairs{nn} = [ExcPairs{nn};numclu([5 6],ExcPairs{nn}(2,:))];
            end
            if ~isempty(InhPairs{nn})
                InhPairs{nn} = [InhPairs{nn};numclu([5 6],InhPairs{nn}(1,:))];
                InhPairs{nn} = [InhPairs{nn};numclu([5 6],InhPairs{nn}(2,:))];
            end
            if ~isempty(GapPairs{nn})
                GapPairs{nn} = [GapPairs{nn};numclu([5 6],GapPairs{nn}(1,:))];
                GapPairs{nn} = [GapPairs{nn};numclu([5 6],GapPairs{nn}(2,:))];
            end
            
        end
    end
end

return

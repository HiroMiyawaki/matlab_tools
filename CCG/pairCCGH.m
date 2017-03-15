function [sccg,t,elsevec,hccg,bbccg,tbb,fastccg,slowccg,tpccg]...
    = pairCCG(fileinfo,qset,CCGbinsize,xtrans,BinSize, HalfBins);
% function [sccg,t,elsevec,hccg,bbccg,tbb,fastccg,slowccg,tpccg]...
%     = pairCCG(fileinfo,qset,CCGbinsize,xtrans,BinSize, HalfBins);
% This function goes through all the shanks and calculates all the ccg's
% for 'filename', before and after the track length is changed (in sccg)
% for the first and second half of the shortened track (in hccg)
% on the slow timescale (in bbccg)
% for fast and slow trials (fastccg and slowccg)
% and for pretransition and posttransition points (tpccg)

t = [];tbb = [];
if (nargin<5)
    BinSize = 32.552*CCGbinsize;
    HalfBins = ceil(2500/CCGbinsize);
end

currentdir = pwd; 
directory = fileinfo.name;
FileBase = [currentdir '/' directory '/' directory];

load([FileBase '.spikeII.mat']);

% maxp = PlaceMax(fileinfo,2,[1 2 4 9],'cmass');
maxp = fileinfo.maxp;
maxpC = fileinfo.maxp_cmass;
% maxp = fileinfo.maxp_fix;
pp = fileinfo.ppII;
frate = fileinfo.peak_hertz;
ppr = fileinfo.pprII;
pI = fileinfo.pIII;
prefph = fileinfo.prefph;
deltaph = fileinfo.deltaph;
fw = fileinfo.field_width;
fs = fileinfo.field_speed;

direction = [1 -1 1 -1];

for nn = 3:4;
    nonzero = find(maxp(nn,:)~=0| maxp(nn-2,:)~=0);
%     elsevec{nn} = sortrows(maxp(:,onezero)',nn)';
    elsevec{nn} = [maxp([1:7],nonzero);direction(nn)*pp([nn-2 nn],nonzero);...
        fw([nn-2 nn],nonzero);fs([nn-2 nn],nonzero);...
        deltaph([nn-2 nn],nonzero);maxpC([nn-2 nn],nonzero)];
    elsevec{nn-2} = elsevec{nn};
end

spacebins = 200;

for nn = 1:4
    keepclu = [];
    if ~isempty(elsevec{nn})
        for cc = 1:size(elsevec{nn},2);
            if elsevec{nn}(nn,cc)~=0
                shank = elsevec{nn}(5,cc);
                cluster = elsevec{nn}(6,cc);
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
        if size(keepclu,1)>1
            keepclu = sortrows(keepclu);
            %     figure(nn)
%             disp([directory ' trajectory #' num2str(nn) '...'])
%             sprintf('%s','...')
            [sccg{nn},t] = CCG(spike.t(keepclu(:,1)),keepclu(:,2),...
                BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            [bbccg{nn},tbb] = CCG(spike.t(keepclu(:,1)),keepclu(:,2),...
                BinSize*5,round(HalfBins/5),32552,'count',[1:size(elsevec{nn},2)]);
        else
            [sccg{nn},t] = CCG([],[],...
                BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            [bbccg{nn},tbb] = CCG([],[],...
                BinSize*5,round(HalfBins/5),32552,'count',[1:size(elsevec{nn},2)]);
        end
    else
        sccg{nn}=[];bbccg{nn} = [];
    end
end

if nargout>6
    for nn = 1:4
        keepclu = [];
        keepclu2 = [];
        if ~isempty(elsevec{nn})
            find_nn = find(spike.traj==nn);
            lapspeed = [];
            for ll = unique(spike.lap(find_nn))';
                lapspeed =  [lapspeed ...
                    [mean(spike.speed(spike.traj==nn&spike.lap==ll));ll]];
            end
            lapspeed = sortrows(lapspeed')';
            iilap = floor(size(lapspeed,2)/2);
            for cc = 1:size(elsevec{nn},2);
                if elsevec{nn}(nn,cc)~=0
                    shank = elsevec{nn}(5,cc);
                    cluster = elsevec{nn}(6,cc);
                    pmap = squeeze(fileinfo.pmat{shank}(cluster,nn,:));
                    peak = find(pmap==max(pmap),1,'first');
                    lesspeak = find(pmap<=0.1*max(pmap));
                    ilp = find(lesspeak<peak,1,'last');
                    edgein = lesspeak(ilp);
                    ilp = find(lesspeak>peak,1,'first');
                    edgeout = lesspeak(ilp);

                    cc_keep = spike.shank==shank & spike.cluster==cluster ...
                        & spike.traj==nn & spike.speed>2& ...
                        spike.x>=(edgein-1)/spacebins & spike.x<=(edgeout-1)/spacebins;
                    cc_keep2 = find(cc_keep & ismember(spike.lap,lapspeed(2,1:iilap)));
                    cc_keep = find(cc_keep & ismember(spike.lap,lapspeed(2,iilap+1:end)));

                    keepclu = [keepclu; [cc_keep cc*ones(size(cc_keep))]];
                    keepclu2 = [keepclu2; [cc_keep2 cc*ones(size(cc_keep2))]];
                end
            end
            if size(keepclu,1)>1
                keepclu = sortrows(keepclu);
                [fastccg{nn},t] = CCG(spike.t(keepclu(:,1)),keepclu(:,2),...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            else
                [fastccg{nn},t] = CCG([],[],...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            end
            if size(keepclu2,1)>1
                keepclu2 = sortrows(keepclu2);
                [slowccg{nn},t] = CCG(spike.t(keepclu2(:,1)),keepclu2(:,2),...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            else
                [slowccg{nn},t] = CCG([],[],...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            end
        else
            fastccg{nn}=[];
            slowccg{nn}=[];
        end
    end
end

if nargout>3
    for nn = 1:2
        keepclu = [];
        keepclu2 = [];
        if ~isempty(elsevec{nn})
            for cc = 1:size(elsevec{nn},2);
                if elsevec{nn}(nn,cc)~=0
                    shank = elsevec{nn}(5,cc);
                    cluster = elsevec{nn}(6,cc);
                    pmap = squeeze(fileinfo.pmat{shank}(cluster,nn,:));
                    peak = find(pmap==max(pmap),1,'first');
                    lesspeak = find(pmap<=0.1*max(pmap));
                    ilp = find(lesspeak<peak,1,'last');
                    edgein = lesspeak(ilp);
                    ilp = find(lesspeak>peak,1,'first');
                    edgeout = lesspeak(ilp);

                    cc_keep = spike.shank==shank & spike.cluster==cluster ...
                        & spike.traj==nn & spike.speed>2& ...
                        spike.x>=(edgein-1)/spacebins & spike.x<=(edgeout-1)/spacebins;
                    number_laps = max(spike.lap(find(spike.traj==nn)));
                    cc_keep2 = find(cc_keep & spike.lap>ceil(number_laps/2));
                    cc_keep = find(cc_keep & spike.lap<=ceil(number_laps/2));

                    keepclu = [keepclu; [cc_keep cc*ones(size(cc_keep))]];
                    keepclu2 = [keepclu2; [cc_keep2 cc*ones(size(cc_keep2))]];
                end
            end
            if size(keepclu,1)>1
                keepclu = sortrows(keepclu);
                %     figure(nn)
%                 disp([directory ' trajectory #' num2str(nn) '...'])
                [hccg{nn},t] = CCG(spike.t(keepclu(:,1)),keepclu(:,2),...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            else
                [hccg{nn},t] = CCG([],[],...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            end
            if size(keepclu2,1)>1
                keepclu2 = sortrows(keepclu2);
                [hccg{nn+2},t] = CCG(spike.t(keepclu2(:,1)),keepclu2(:,2),...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            else
                [hccg{nn+2},t] = CCG([],[],...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            end
        else
            hccg{nn}=[];
        end
    end
end

if nargout>8
    for nn = 1:2
        keepclu = [];
        keepclu2 = [];
        if ~isempty(elsevec{nn})
            for cc = 1:size(elsevec{nn},2);
                if elsevec{nn}(nn,cc)~=0
                    shank = elsevec{nn}(5,cc);
                    cluster = elsevec{nn}(6,cc);
                    pmap = squeeze(fileinfo.pmat{shank}(cluster,nn,:));
                    peak = find(pmap==max(pmap),1,'first');
                    lesspeak = find(pmap<=0.1*max(pmap));
                    ilp = find(lesspeak<peak,1,'last');
                    edgein = lesspeak(ilp);
                    ilp = find(lesspeak>peak,1,'first');
                    edgeout = lesspeak(ilp);

                    cc_keep = spike.shank==shank & spike.cluster==cluster ...
                        & spike.traj==nn & spike.speed>2& ...
                        spike.x>=(edgein-1)/spacebins & spike.x<=(edgeout-1)/spacebins;                    
                        % need to input transition point somehow
                    number_laps = max(spike.lap(find(spike.traj==nn)));
                    cc_keep2 = find(cc_keep & spike.x>=(xtrans-1)/spacebins);
                    cc_keep = find(cc_keep & spike.x<(xtrans-1)/spacebins);

                    keepclu = [keepclu; [cc_keep cc*ones(size(cc_keep))]];
                    keepclu2 = [keepclu2; [cc_keep2 cc*ones(size(cc_keep2))]];
                end
            end
            if size(keepclu,1)>1
                keepclu = sortrows(keepclu);
                %     figure(nn)
%                 disp([directory ' trajectory #' num2str(nn) '...'])
                [tpccg{nn},t] = CCG(spike.t(keepclu(:,1)),keepclu(:,2),...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            else
                [tpccg{nn},t] = CCG([],[],...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            end
            if size(keepclu2,1)>1
                keepclu2 = sortrows(keepclu2);
                [tpccg{nn+2},t] = CCG(spike.t(keepclu2(:,1)),keepclu2(:,2),...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            else
                [tpccg{nn+2},t] = CCG([],[],...
                    BinSize,HalfBins,32552,'count',[1:size(elsevec{nn},2)]);
            end
        else
            tpccg{nn}=[];
        end
    end
end

function [sccg,t,elsevec,bbccg,tbb]...
    = pairCCGC(fileinfo,qset,CCGbinsize,xtrans,BinSize, HalfBins);
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
% maxp = fileinfo.maxp_fix;
pp = fileinfo.pp;
frate = fileinfo.peak_hertz;
ppr = fileinfo.ppr;
pI = fileinfo.pI;
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
        deltaph([nn-2 nn],nonzero)];
    elsevec{nn-2} = elsevec{nn};
end

spacebins = 200;

for nn = 3:4
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


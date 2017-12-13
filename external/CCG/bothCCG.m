function [ccg,t,sortvec] = bothCCG(fileinfo,qset,BinSize, HalfBins);

% good numbers to use for BinSize and HalfBins would be

% This function goes through all the shanks and calculates all the ccg's
% for 'filename', before and after the track length is changed.

t = [];
if (nargin<3)
%     BinSize = 32.552*2;
%     HalfBins = 80;
    HalfBins = 82*2;
    BinSize = 32.552*3;
end
if nargin<2
    qset = [1 2 9];
end

currentdir = pwd; 
directory = fileinfo.name;
FileBase = [currentdir '/' directory '/' directory];

load([FileBase '.INspike.mat']);

[maxp] = PlaceMax(fileinfo,2,qset);

for nn = 3:4;
    nonzero = find(maxp(nn,:)~=0 & maxp(nn-2,:)~=0);
%     sortvec{nn} = sortrows(maxp(:,nonzero)',nn)';
    sortvec{nn} = maxp(:,nonzero);

    
end
for nn = 1:2;
    sortvec{nn} = sortvec{nn+2};
    %     nonzero = find(maxp(nn,:)~=0 & maxp(nn+2,:)~=0);
%     sortvec{nn} = sortrows(maxp(:,nonzero)',nn+2)';
end


for nn = 1:4
    keepclu = [];
    if ~isempty(sortvec{nn})
        for cc = 1:size(sortvec{nn},2);
            shank = sortvec{nn}(5,cc);
            cluster = sortvec{nn}(6,cc);
            pmap = squeeze(fileinfo.pmat{shank}(cluster,nn,:));
            peak = find(pmap==max(pmap),1,'first');
            lesspeak = find(pmap<=0.1*max(pmap));
            ilp = find(lesspeak<peak,1,'last');
            edgein = lesspeak(ilp);
            ilp = find(lesspeak>peak,1,'first');
            edgeout = lesspeak(ilp);
            
            cc_keep = find(spike.shank==shank & spike.cluster==cluster ...
                & spike.traj==nn & spike.speed>10& ...
                spike.x>=edgein/100 & spike.x<=edgeout/100 );% ...
%                 & spike.lap>14 & spike.lap<25);
%             if size(cc_keep,2)>1
%             cc_keep = cc_keep([1;find(diff(spike.t(cc_keep))>=.005*32552.1)+1]);
%             end
            keepclu = [keepclu; [cc_keep cc*ones(size(cc_keep))]];
        end
        keepclu = sortrows(keepclu);
        %     figure(nn)
        disp([directory ' trajectory #' num2str(nn) '...'])
        [ccg{nn},t] = CCG(spike.t(keepclu(:,1)),keepclu(:,2),...
            BinSize,HalfBins,32552,'count',[1:size(sortvec{nn},2)]);
%     Saveres([FileBase  'LS.' num2str(nn)  '.res'],spike.t(keepclu(:,1)));
%     SaveClu([FileBase  'LS.' num2str(nn)  '.clu'],keepclu(:,2));
    else
        ccg{nn}=[];
    end
end



% save([FileBase '.ccg.mat'],'ccg','t','prs');

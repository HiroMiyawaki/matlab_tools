function [ccg,numclu,t] = evaluateCCGs(fileinfo,qset,BinSize,HalfBins);

% This function goes through all the clusters and calculates all the ccg's
% for fileinfo.  Input needs to be array that contains info about the
% recording.  qset is set of cells to calculate for, based on cluster
% quality

if (nargin<3)
    BinSize = 6000;
    HalfBins = 180;
end

if (nargin<2)
    qset = 2; % default is only best cells
end


basedir = pwd;
filename = fileinfo.name;
chts = fileinfo.chts;
tbegin = fileinfo.tbegin;

FileBase = [basedir '/' filename '/' filename];
load([FileBase '.xyt.mat'])  

% tbegin = textread([FileBase '.nl2dat.log'],'Beginning timestamp : %f',1,'headerlines',3);
tchg = (chts-tbegin)/1e6*32552.1;
tt = (xyt(:,3)-tbegin)/1e6*32552.1;

res = []; clu = [];next = 1; numclu = [];
for ii = 1:8;
    rest = Loadres([FileBase '.res.' num2str(ii)]);
    clut = LoadClu([FileBase '.clu.' num2str(ii)]);
    numok = find(ismember(fileinfo.cluq{ii},qset));
    for jj = numok;
        good = find(clut == jj);
        res = [res; rest(good)];  % avoiding noisy clusters
        clu = [clu; next*ones(size(good))];
        next = next + 1;
    end
    numclu = [numclu;numok' ii*ones(length(numok),1)];
end

before = find(res < tchg);

tempvec = [res(before) clu(before)];
tempvec = sortrows(tempvec);
xbin = interp1(tt,xyt(:,1),tempvec(:,1));

cageout = find(xbin > max(xr1));
cagein = find(xbin < min(xr1));

ares{3} = tempvec(cageout,1);
aclu{3} = tempvec(cageout,2);
ares{4} = tempvec(cagein,1);
aclu{4} = tempvec(cagein,2);

after = find(res > tchg);
tempvec = [res(after) clu(after)];
tempvec = sortrows(tempvec);
xbin = interp1(tt,xyt(:,1),tempvec(:,1));

cageout = find(xbin > max(xr2));
cagein = find(xbin < min(xr2));

ares{1} = tempvec(cageout,1);
aclu{1} = tempvec(cageout,2);
ares{2} = tempvec(cagein,1);
aclu{2} = tempvec(cagein,2);


for nn = 1:4;
    for ii=1:size(numclu,1);
        if isempty(find(aclu{nn} == ii,1,'first'))
            ares{nn} = [ares{nn}; ares{nn}(1) + eps];
            aclu{nn} = [aclu{nn}; ii];
        end
    end
    [ccg{nn},t,prs] = CCG(ares{nn},aclu{nn},BinSize,HalfBins);
end

% ccg.numclu = numclu;
% ccg.date = fileinfo.name;

% 
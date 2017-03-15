function [spike] = MakeSpikeFile(fileinfo,qset)
% function [spike] = MakeSpikeFile(fileinfo,qset)
% creates output "cell" spike containing:
% spike.t = spike times
% spike.shank = corresponding shank
% spike.cluster = corresponding cluster
% spike.aclu = corresponding "all cluster" (obtained from combining all shanks)
% spike.qclu = corresponding cluster quality
% spike.cluinfo = corresponding cluinfo (cluq for each trajectory type from 1 to 4)
% spike.x = position
% spike.speed = speed
% spike.traj = trajectory from 1 to 4

if nargin<2;
    qset = [1 2 4 6 7 9];
end

SampleRate = 32552.1;

tbegin = fileinfo.tbegin;
tend = fileinfo.ftend;
videorate = 120;
numofbins = round((tend-tbegin)/1e6*videorate); % binned into 120 Hz video sampling
% tchg = (chts-tbegin)/1e6*SampleRate;

xyt = fileinfo.xyt;
xr = fileinfo.xr;
yr = fileinfo.yr;

currentdir = pwd;
FileBase = [currentdir '/' fileinfo.name '/' fileinfo.name];

ares = []; aclu = [];qclu=[];infoclu = [];shank=[];cluster=[];

disp('obtaining res times...');
next = 1;numclu = [];test =[];track=[];
for ii = 1:length(fileinfo.cluq2);
    rest = Loadres([FileBase '.res.' num2str(ii)]);
    clut = LoadClu([FileBase '.clu.' num2str(ii)]);
    numok = [];
    for jj = find(ismember(fileinfo.cluq2{ii},qset));
        next = next + 1;
        good = find(clut == jj);
        ares = [ares; rest(good)];  % avoiding noisy clusters and making one
        aclu = [aclu; next*ones(size(good))];  % clu and res vec
        qclu = [qclu; fileinfo.cluq2{ii}(jj)*ones(size(good))];
        infoclu = [infoclu; ones(size(good))*fileinfo.cluinfo{ii}(:,jj)'];
        shank = [shank; ii*ones(size(good))];
        cluster = [cluster; jj*ones(size(good))];
    end                                            % contains cluster number
end
% combine again and order
res = sortrows([ares aclu qclu infoclu shank cluster]);

disp('writing res times...')
spike.t = res(:,1);
spike.shank = res(:,8);
spike.cluster = res(:,9);
spike.aclu = res(:,2);
spike.qclu = res(:,3);
spike.cluinfo = res(:,4:7);

clear res

smoothwin = [ones(15,1)]; 
smoothwin = smoothwin/sum(smoothwin);

xyt(:,1) = filtfilt(smoothwin,1,xyt(:,1));

xyt=binpos(xyt,numofbins);
tt = (xyt(:,3)-tbegin)/1e6*SampleRate;
diffx = abs(diff(xyt(:,1)));

spike.x = interp1(tt,xyt(:,1),spike.t);
spike.speed = interp1(tt(1:end-1),diffx,spike.t) *videorate* 800/ 2.8;

withinrange = find(xyt(:,3)>=tbegin & xyt(:,3)<=fileinfo.tend);
xyt = xyt(withinrange,:);
tt = (xyt(:,3)-tbegin)/1e6*SampleRate;
iend = find(xyt(:,3) <= tend,1,'last');

xyt(:,3) = tt;

[outleft,inleft,outright,inright] = trackCrossTmaze(xyt(1:iend,1:2),xr,yr);

disp('processing trajectories...');
spike.traj = zeros(size(spike.t));
spike.lap = -1*ones(size(spike.t));


if ~isempty(inleft)
    for ii = 1:size(outleft,2)
        find_ii = find(spike.t>tt(outleft(1,ii)) & spike.t<tt(outleft(2,ii)));
        spike.traj(find_ii) = 1;
        spike.lap(find_ii) = ii;
    end
    for ii = 1:size(inleft,2)
        find_ii = find(spike.t>tt(inleft(1,ii)) & spike.t<tt(inleft(2,ii)));
        spike.traj(find_ii) = 2;
        spike.lap(find_ii) = ii;
    end
end

if ~isempty(inright)
    for ii = 1:size(outright,2)
        find_ii = find(spike.t>tt(outright(1,ii)) & spike.t<tt(outright(2,ii)));
        spike.traj(find_ii) = 3;
        spike.lap(find_ii) = ii;
    end
    for ii = 1:size(inright,2)
        find_ii = find(spike.t>tt(inright(1,ii)) & spike.t<tt(inright(2,ii)));
        spike.traj(find_ii) = 4;
        spike.lap(find_ii) = ii;
    end
end

ThPhase = InternThetaPh(fileinfo);
spike.ph = mod(ThPhase.deg(round(spike.t/32552*1252)),2*pi); 

df = [0; find(diff(mod(ThPhase.deg,pi))<0); size(ThPhase.deg,1)-1];

bigT = zeros(size(ThPhase.deg));
for ff = 1:length(df)-1;
    bigT(df(ff)+1:df(ff+1))=150*ff;
end
    
spike.bT = spike.t + bigT(round(spike.t/32552*1252))*32552/1000;

save([FileBase '.spike.mat'],'spike')

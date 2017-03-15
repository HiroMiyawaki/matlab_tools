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
%     qset = [1 2 3 4 5 6 7 8 9];
    qset = [1 2 4 5 6 7 9];
end

currentdir = pwd;
FileBase = [currentdir '/' fileinfo.name '/' fileinfo.name];

Par =LoadPar([FileBase '.par']); % either par or xml file needed
EegRate = Par.lfpSampleRate; % sampling rate of eeg file
SampleRate = Par.SampleRate;
numch = Par.nChannels;

chts = fileinfo.chts;
tbegin = fileinfo.tbegin;
tend = fileinfo.tend;
videorate = 120;
numofbins = round((tend-tbegin)/1e6*videorate); % binned into 120 Hz video sampling

xyt = fileinfo.xyt;
xr1 = fileinfo.new_xlim(3,:);
xr2 = fileinfo.new_xlim(1,:);

load([FileBase '-rip.mat']);

fprintf('Calculating gamma phase and power... \n');
if ~isempty(fileinfo.CA1thetach)
    elc = fileinfo.CA1thetach+1;
elseif ~isempty(fileinfo.CA3thetach)
    elc = fileinfo.CA3thetach+1;
else
    error('no channel for gamma phase detection is specified.');
end
% 
FreqRange = [20 300];
NFreq = EegRate/2;
Eeg = readsinglech([FileBase '.eeg'],numch,fileinfo.CA3thetach+1)';
Eegf = ButFilter(Eeg,4,FreqRange/NFreq,'bandpass');
% 
Eegf = Eegf - mean(Eegf);
Hilb = Shilbert(Eegf);
GammaPh = angle(Hilb);
GammaFreq = diff(GammaPh)*EegRate;
blip = find(GammaFreq < -pi*EegRate);
GammaFreq(blip) = GammaFreq(blip)+2*pi*EegRate;
blip = find(GammaFreq > pi*EegRate);
GammaFreq(blip) = GammaFreq(blip)-2*pi*EegRate;
GammaFreq = GammaFreq/2/pi;
GammaAmp = abs(Hilb);
% 
% rise = LocalMinima(-diff(Eegf),round(EegRate/30));
% rise = rise(find(GammaAmp(rise) > median(GammaAmp)-0.5*std(GammaAmp)));
% % peaks = LocalMinima(-Eegf,round(EegRate/30));
% % peaks = peaks(find(GammaAmp(peaks)> median(GammaAmp)-0.5*std(GammaAmp)));
% % dips = LocalMinima(Eegf,round(EegRate/30));
% % dips = dips(find(GammaAmp(dips)> median(GammaAmp)-0.5*std(GammaAmp)));
% 
% % fi = [];
% % for dd = 1:length(dips)
% %     fi = [fi;find((rise-dips(dd))>0 & (rise-dips(dd))<round(EegRate/60),1,'first')];
% % end
% % rise = rise(fi);
% 
% ares = round(rise*SampleRate/EegRate);
% cluster = ones(size(rise));
% % 
% % ares = [ares;round(rise*SampleRate/EegRate)];
% % cluster = [cluster;2*ones(size(rise))];
% 
% % ares = [ares;round(peaks*SampleRate/EegRate)];
% % cluster = [cluster;3*ones(size(peaks))];
% aclu = zeros(size(ares));
% qclu = 5*ones(size(ares));
% infoclu = 13*ones(size(ares,1),4);
% shank = 13*ones(size(ares));

% EegChunks = [];
% for ii=1:length(zerophase)
%     if zerophase(ii)>125 & zerophase(ii)<length(Eeg)-125
%         EegChunks = [EegChunks Eeg(zerophase(ii)-125:zerophase(ii)+125)];
%     end
% end

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

withinrange = find(xyt(:,3)>=tbegin & xyt(:,3)<=fileinfo.tend);
xyt = xyt(withinrange,:);
xyt=binpos(xyt,numofbins);
% xyt(:,1) = filtfilt(smoothwin,1,xyt(:,1));

tt = (xyt(:,3)-tbegin)/1e6*SampleRate;
diffx = abs(diff(filtfilt(smoothwin,1,xyt(:,1))));

spike.x = interp1(tt,xyt(:,1),spike.t);
spike.y = interp1(tt,xyt(:,2),spike.t);

spike.speed = interp1(tt(1:end-1),diffx,spike.t) *videorate*fileinfo.pix2cm;

tchg = find(xyt(:,3) <= fileinfo.chts,1,'last');    % short
iend = find(xyt(:,3) <= tend,1,'last');

xyt(:,3) = tt;

[outgoing,incoming] = trackCrossIII(xyt(tchg:iend,1),min(xr2),max(xr2),0);
outgoing = outgoing + tchg-1; incoming = incoming + tchg-1;

disp('processing trajectories...');
spike.traj = zeros(size(spike.t));
spike.lap = -1*ones(size(spike.t));

if ~isempty(incoming)
    if incoming(1)<outgoing(1);
        shiftin = [incoming(1,:) iend];
        innew = [incoming(1,:);outgoing(1,:)];
        outnew =[outgoing(1,:);shiftin(2:end)];
    else
        shiftin = [outgoing(1,:) iend];
        innew = [incoming(1,:);shiftin(2:end)];
        outnew =[outgoing(1,:);incoming(1,:)];
    end
    for ii = 1:size(outnew,2)
        find_ii = find(spike.t>=tt(outnew(1,ii)) & spike.t<tt(outnew(2,ii)));
        spike.traj(find_ii) = 11;
    end
    for ii = 1:size(outgoing,2)
        find_ii = find(spike.t>=tt(outgoing(1,ii)) & spike.t<tt(outgoing(2,ii)));
%         plot(xyt(outgoing(1,ii),1),xyt(outgoing(1,ii),3),'^');hold on
        
        spike.traj(find_ii) = 1;
    end
    for ii = 1:size(innew,2)
        find_ii = find(spike.t>=tt(innew(1,ii)) & spike.t<tt(innew(2,ii)));
        spike.traj(find_ii) = 12;
    end
    for ii = 1:size(incoming,2)
        find_ii = find(spike.t>=tt(incoming(1,ii)) & spike.t<tt(incoming(2,ii)));
        spike.traj(find_ii) = 2;
    end
end

[outgoing,incoming] = trackCrossIII(xyt(1:tchg-1,1),min(xr1),max(xr1),0);
if ~isempty(incoming)
    if incoming(1)<outgoing(1);
        shiftin = [incoming(1,:) tchg-1];
        innew = [incoming(1,:);outgoing(1,:)];
        outnew =[outgoing(1,:);shiftin(2:end)];
    else
        shiftin = [outgoing(1,:) tchg-1];
        innew = [incoming(1,:);shiftin(2:end)];
        outnew =[outgoing(1,:);incoming(1,:)];
    end
    for ii = 1:size(outnew,2)
        find_ii = find(spike.t>=tt(outnew(1,ii)) & spike.t<tt(outnew(2,ii)));
        spike.traj(find_ii) = 13;
    end
    for ii = 1:size(outgoing,2)
        find_ii = find(spike.t>=tt(outgoing(1,ii)) & spike.t<tt(outgoing(2,ii)));
        spike.traj(find_ii) = 3;
    end
    for ii = 1:size(innew,2)
        find_ii = find(spike.t>=tt(innew(1,ii)) & spike.t<tt(innew(2,ii)));
        spike.traj(find_ii) = 14;
    end
    for ii = 1:size(incoming,2)
        find_ii = find(spike.t>=tt(incoming(1,ii)) & spike.t<tt(incoming(2,ii)));
        spike.traj(find_ii) = 4;
    end
end

[inandout] = Laptimes(fileinfo);
for jj = 1:size(inandout,2);
    find_jj = find(spike.t>=inandout(1,jj) & spike.t<inandout(2,jj));
    spike.lap(find_jj) = inandout(3,jj);
end

ThPhase = InternThetaPh(fileinfo,0);
spike.ph = mod(ThPhase.deg(round(spike.t/SampleRate*EegRate)),2*pi); 

spike.gamma = mod(GammaPh(round(spike.t/SampleRate*EegRate)),2*pi); 
spike.amp = GammaAmp(round(spike.t/SampleRate*EegRate)); 
spike.freq = GammaFreq(round(spike.t/SampleRate*EegRate)); 

% df = [0; find(diff(mod(ThPhase.deg,pi))<0); size(ThPhase.deg,1)-1];

% bigT = zeros(size(ThPhase.deg));
% for ff = 1:length(df)-1;
%     bigT(df(ff)+1:df(ff+1))=150*ff;
% end
%     
% spike.bT = spike.t + bigT(round(spike.t/SampleRate*EegRate))*SampleRate/1000;

for nn=1:4;
    find_bad = find(ismember(spike.traj,[nn nn+10])&...
        (spike.y<fileinfo.new_ylim(nn,1)|spike.y>fileinfo.new_ylim(nn,2)));
    spike.traj(find_bad)=7;
end

spike.theta = zeros(size(spike.t));
sts = dlmread([FileBase '.theta.1'])'*round(SampleRate/EegRate);
res_ind = STSfilt(sts,spike.t,1);
spike.theta(res_ind)=1;

spike.ripple = zeros(size(spike.t));
if ~isempty(ripple_result)
    ripple_result = ripple_result(:,[1 3])'*round(SampleRate/EegRate);
    res_ind = STSfilt(ripple_result,spike.t,1);
    spike.ripple(res_ind)=1;
end


save([FileBase '.spikeII.mat'],'spike')

% gamma = find(spike.shank==13 & spike.theta==1 & spike.speed>5);
% Saveres([FileBase 'GAMMA.13.res'],spike.t(gamma));
% SaveClu([FileBase 'GAMMA.13.clu'],spike.cluster(gamma));
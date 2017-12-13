function [Pfv,meanspeed,meantheta,meanpower,meanpower_CA3,meancoherence] = ...
    ThetaFreqPfv(fileinfo,timebinsize,overwrite);
% function [Pfv,meanspeed,meantheta,meanpower,meanpower_CA3,meancoherence] = ...
%     ThetaFreqPfv(fileinfo,timebinsize,overwrite);
% calculate the theta frequency on the long and short track
% during track running only

if nargin<3
    overwrite = 0;
end

currentdir = pwd;
FileBase = [currentdir '/' fileinfo.name '/' fileinfo.name];

Par =LoadPar([FileBase '.par']); % either par or xml file needed
numchannel = Par.nChannels; % total channel number, 6, 10 or 18
EegRate = Par.lfpSampleRate; % sampling rate of eeg file
SampleRate = Par.SampleRate;
FreqRange = [4 12]; % Range of theta frequence

% (0) Loading eeg file
if ~isempty(fileinfo.CA3thetach)
    CA3_channel = fileinfo.CA3thetach+1;
else
    CA3_channel = [];
end
if ~isempty(fileinfo.CA1thetach)
    CA1_channel = fileinfo.CA1thetach+1;
else
    CA1_channel = [];
end
    
if ~FileExists([FileBase '.pxx']) | overwrite
    win = 2^floor(1+log2((eeg_rate/mean(FreqRange)*5)));
    if ~isempty(CA1_channel)
    fprintf(' Calculating theta frequency and power... \n');
    eeg = readsinglech([FileBase '.eeg'],numchannel,CA1_channel);
    %choose window: should be ~7 cycles to give good freq. resolution
    %compute spectrogram in the freq. range 1: fr(2)+5Hz
    weeg = WhitenSignal(eeg);
    [Pxx,fxx,txx] = mtchglong(weeg,win,eeg_rate,win,win/2,3,'linear',[],[1 FreqRange(2)+5]);
    else
        eeg = readsinglech([FileBase '.eeg'],numchannel,fileinfo.thetach+1);
        weeg = WhitenSignal(eeg);
        [Pxx,fxx,txx] = mtchglong(weeg,win,eeg_rate,win,win/2,3,'linear',[],[1 FreqRange(2)+5]);
%         matrixsize = floor(size(eeg,2)*2/win);
        Pxx = zeros(size(Pxx));
    end
    if ~isempty(CA3_channel)
        eeg3 = readsinglech([FileBase '.eeg'],numchannel,CA3_channel);
        weeg3 = WhitenSignal(eeg3);
        [Pxx3,fxx,txx] = mtchglong(weeg3,win,eeg_rate,win,win/2,3,'linear',[],[1 FreqRange(2)+5]);
        if ~isempty(CA1_channel)
            [Y]=mtchgband([weeg weeg3],win,eeg_rate,win,win/2,3,'linear',[],FreqRange);
            Coh = squeeze(Y(:,1,2));
        else
            Coh = zeros(size(Pxx,1),1);
        end
    else
        Pxx3 = zeros(size(Pxx));
        Coh = zeros(size(Pxx,1),1);
    end
    txx =  txx + win/4/eeg_rate; %times of the centers of the windows (units seconds)
    save([FileBase '.pxx'],'Pxx','Pxx3','Coh','fxx','txx');
else
  fprintf(' Loading theta frequency and power... \n');
  load([FileBase '.pxx'],'-MAT');
end

% keep only clear theta periods:
% sts = dlmread([FileBase '.theta.1'])'/eeg_rate;
% txx_ind = STSfilt(sts,txx,1);
% txx = txx(txx_ind,:);
% Pxx = Pxx(txx_ind,:);
% Pxx3 = Pxx3(txx_ind,:);
% Coh = Coh(txx_ind,:);

%find the center of mass of the freq. range

fi = find(fxx>FreqRange(1) & fxx<FreqRange(2));
if ~isempty(CA1_channel)
    thfreq = dotdot(sum(dotdot(Pxx(:,fi),'*',fxx(fi)'),2),'/',sum(Pxx(:,fi),2));
else
    thfreq = zeros(size(txx));
end
thpow = mean(Pxx(:,fi)')';
thpow3 = mean(Pxx3(:,fi)')';
  
Xseg_long = fileinfo.new_xlim(3,:);
Xseg_short = fileinfo.new_xlim(1,:);

tbegin = fileinfo.tbegin; tend = fileinfo.ftend;
numofbins = round((tend-tbegin)/1e6*(1/timebinsize));

xyt = fileinfo.xyt;
withinrange = find(xyt(:,3)>=tbegin & xyt(:,3)<=tend);
xytp=binpos(xyt(withinrange,:),numofbins);

smoothwin = [ones(15,1)]; 
smoothwin = smoothwin/sum(smoothwin);
xxsmooth= filtfilt(smoothwin,1,xytp(:,1));

xytp(:,3) = xytp(:,3)-tbegin;
speed = abs(diff(xxsmooth))*800/2.78/timebinsize;
xytp = xytp(1:end-1,:);
PfvxtnPC = zeros(size(xytp,1),8);

% PfvxtnPC(:,1) = interp1(txx*1e6,thpow,xytp(:,3),'linear','extrap');
% PfvxtnPC(:,2) = interp1(txx*1e6,thfreq,xytp(:,3),'linear','extrap');
% PfvxtnPC(:,3) = speed;
% PfvxtnPC(:,4) = floor(200*(xytp(:,1)-fileinfo.new_xmid));  % binning
% PfvxtnPC(:,5) = xytp(:,3);
% PfvxtnPC(:,7) = interp1(txx*1e6,thpow3,xytp(:,3),'linear','extrap');
% PfvxtnPC(:,8) = interp1(txx*1e6,Coh,xytp(:,3),'linear','extrap');

PfvxtnPC(:,1) = interp1(txx*1e6,thpow,xytp(:,3),'nearest','extrap');
PfvxtnPC(:,2) = interp1(txx*1e6,thfreq,xytp(:,3),'nearest','extrap');
PfvxtnPC(:,3) = speed;
PfvxtnPC(:,4) = floor(200*(xytp(:,1)-fileinfo.new_xmid));  % binning
PfvxtnPC(:,5) = xytp(:,3);
PfvxtnPC(:,7) = interp1(txx*1e6,thpow3,xytp(:,3),'nearest','extrap');
PfvxtnPC(:,8) = interp1(txx*1e6,Coh,xytp(:,3),'nearest','extrap');

tchg = find(xytp(:,3) > (fileinfo.chts-tbegin),1,'first');
iend = find(xytp(:,3) <= (tend-tbegin),1,'last');

[outgoing,incoming] = trackCross(xytp(tchg:iend,1),Xseg_short(1),Xseg_short(2),0);
outgoing = outgoing + tchg - 1; incoming = incoming + tchg - 1;
for ii = 1:size(outgoing,2)
    PfvxtnPC(outgoing(1,ii):outgoing(2,ii),6)=1;
end
for ii = 1:size(incoming,2)
    PfvxtnPC(incoming(1,ii):incoming(2,ii),6)=2;
end
    
[outgoing,incoming] = trackCross(xytp(1:tchg - 1,1),Xseg_long(1),Xseg_long(2),0);
for ii = 1:size(outgoing,2)
    PfvxtnPC(outgoing(1,ii):outgoing(2,ii),6)=3;
end
for ii = 1:size(incoming,2)
    PfvxtnPC(incoming(1,ii):incoming(2,ii),6)=4;
end

xpp = -100:99;
meanspeed = zeros(4,1);
minspeed = 10;
for nn = 1:4;  
    Pfv{nn} = zeros(length(xpp),6);
    test{nn} = zeros(length(xpp),1);
    find_nn = find(PfvxtnPC(:,6)==nn & PfvxtnPC(:,3)>=minspeed);
    for ii = 1:length(xpp)
        find_xx = find(PfvxtnPC(:,4)==xpp(ii) & PfvxtnPC(:,6)==nn &...
            PfvxtnPC(:,3)>=minspeed);
        if ~isempty(find_xx)
%             Pfv{nn}(ii,1:3) = mean(PfvxtnPC(find_xx,1:3));
            Pfv{nn}(ii,1) = sum(PfvxtnPC(find_xx,1));
            Pfv{nn}(ii,2) = sum(PfvxtnPC(find_xx,2));
            Pfv{nn}(ii,3) = sum(PfvxtnPC(find_xx,3));
            Pfv{nn}(ii,4) = sum(PfvxtnPC(find_xx,7));
            Pfv{nn}(ii,5) = length(find_xx)*timebinsize;
%             disp(num2str(length(find_xx)))
            Pfv{nn}(ii,6) = sum(PfvxtnPC(find_xx,8));
%             test{nn}(ii) = median(PfvxtnPC(find_xx,1));
        end
    end
    meanspeed(nn) = mean(PfvxtnPC(find_nn,3));
    meantheta(nn) = mean(PfvxtnPC(find_nn,2));
    meanpower(nn) = mean(PfvxtnPC(find_nn,1));
    meanpower_CA3(nn) = mean(PfvxtnPC(find_nn,7));
    meancoherence(nn) = mean(PfvxtnPC(find_nn,8));
%     meanspeed(nn) = median(PfvxtnPC(find_nn,3));
%     meantheta(nn) = median(PfvxtnPC(find_nn,2));
%     meanpower(nn) = median(PfvxtnPC(find_nn,1));
end


return

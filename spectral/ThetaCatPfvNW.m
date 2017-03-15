function [meanspeed,meantheta,meanpower,meanpower_CA3,meancoherence,meanPxx,fxx,meanPxx_CA3] = ...
    ThetaCatPfv(fileinfo,timebinsize,overwrite);
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
eeg_rate = 1252; % sampling rate of eeg file
SampleRate = 32552.1;
FreqRange = [4 12]; % Range of theta frequence

win = 2^floor(1+log2((eeg_rate/mean(FreqRange)*6)));

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
meanspeed = zeros(4,1);
meantheta = zeros(4,1);
meanpower = zeros(4,1);
meanpower_CA3 = zeros(4,1);
meancoherence = zeros(4,1);
meanPxx_CA3 = [];;
meanPxx = [];

fprintf(' Reading eeg signal... \n');
if ~isempty(CA1_channel)
    eeg = readsinglech([FileBase '.eeg'],numchannel,CA1_channel)';
%     weeg = WhitenSignal(eeg);
elseif ~isempty(CA3_channel)
    eeg = readsinglech([FileBase '.eeg'],numchannel,CA3_channel)';
%     weeg = WhitenSignal(eeg);
else
    eeg = readsinglech([FileBase '.eeg'],numchannel,fileinfo.thetach+1)';
%     weeg = WhitenSignal(eeg);
end
if ~isempty(CA3_channel)
    eeg3 = readsinglech([FileBase '.eeg'],numchannel,CA3_channel)';
%     weeg3 = WhitenSignal(eeg3);
else
%     weeg3 = zeros(size(weeg));
    eeg3 = zeros(size(eeg));
end
% 
tt = linspace(0,length(eeg)/eeg_rate,length(eeg))';

% sts = dlmread([FileBase '.theta.1'])'/eeg_rate;
% tt_ind = STSfilt(sts,tt,1);
% tt = tt(tt_ind,:);
% eeg = eeg(tt_ind,:);
% eeg3 = eeg3(tt_ind,:);

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
xytp = xytp(1:end-1,:);  %% keep in units of seconds

xx = interp1(xytp(:,3)/1e6,xytp(:,1),tt,'linear','extrap');

PfvxtnPC = zeros(size(eeg,1),8);

PfvxtnPC(:,1) = eeg;
PfvxtnPC(:,3) = interp1(xytp(:,3)/1e6,speed,tt,'nearest','extrap');
PfvxtnPC(:,4) = floor(200*(xx-fileinfo.new_xmid));; % binning
PfvxtnPC(:,5) = tt;
PfvxtnPC(:,7) = eeg3;

tchg = find(tt > (fileinfo.chts-tbegin)/1e6,1,'first');
iend = find(tt <= (tend-tbegin)/1e6,1,'last');

[outgoing,incoming] = trackCross(xx(tchg:iend),Xseg_short(1),Xseg_short(2),0);
outgoing = outgoing + tchg - 1; incoming = incoming + tchg - 1;
for ii = 1:size(outgoing,2)
    PfvxtnPC(outgoing(1,ii):outgoing(2,ii),6)=1;
end
for ii = 1:size(incoming,2)
    PfvxtnPC(incoming(1,ii):incoming(2,ii),6)=2;
end
    
[outgoing,incoming] = trackCross(xx(1:tchg - 1),Xseg_long(1),Xseg_long(2),0);
for ii = 1:size(outgoing,2)
    PfvxtnPC(outgoing(1,ii):outgoing(2,ii),6)=3;
end
for ii = 1:size(incoming,2)
    PfvxtnPC(incoming(1,ii):incoming(2,ii),6)=4;
end
  
xpp = -100:99;
minspeed = 10;
for nn = 1:4;  
    find_nn = find(PfvxtnPC(:,6)==nn & PfvxtnPC(:,3)>=minspeed);
    
    [Pxx,fxx,txx] = mtchglong(eeg(find_nn),win,eeg_rate,win,win/2,3,'linear',[],[1 100]);
    
    fi = find(fxx>FreqRange(1) & fxx<FreqRange(2));
    thpow = mean(Pxx(:,fi)')';
    thfreq = dotdot(sum(dotdot(Pxx(:,fi),'*',fxx(fi)'),2),'/',sum(Pxx(:,fi),2));
    meantheta(nn) = mean(thfreq);
    
    meanspeed(nn) = mean(PfvxtnPC(find_nn,3));
    if ~isempty(CA1_channel)
        meanpower(nn) = mean(thpow);
        meanPxx(nn,:) = mean(Pxx);
        
        if ~isempty(CA3_channel)
            Pxx3 = mtchglong(eeg3(find_nn),win,eeg_rate,win,win/2,3,'linear',[],[1 100]);
            meanpower_CA3(nn) = mean(mean(Pxx3(:,fi)')');
            meanPxx_CA3(nn,:) = mean(Pxx3);
            
            Y=mtchgband([eeg(find_nn) eeg3(find_nn)],win,eeg_rate,win,win/2,3,'linear',[],FreqRange);
            Coh = squeeze(Y(:,1,2));
            meancoherence(nn) = mean(Coh);
        end
    elseif ~isempty(CA3_channel)
        meanpower_CA3(nn) = mean(thpow);
        meanPxx_CA3(nn,:) = mean(Pxx);
    end
end

return

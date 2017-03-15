function [ripple_result] = RippleDetect(Basics,varargin)
% function [ripple_result] = RippleDetect(fileinfo,without,max_thresholdf,homefilter,runfilter,thetafilter)
%
% function is intended to detect ripple events, from 130-230 Hz, in the eeg file, given
% fileinfo, an array which contains the name and selected channels of the
% directory in question.

[without,max_thresholdf,homefilter,runfilter,thetafilter] = DefaultArgs(varargin,{[],5,0,0,1});

% homefilter: whether or not the rat should be in the home cage aread
%  runfilter: whether or not there should be a limit on the rat's running speed
% thetafilter whether or not we require robust theta oscillations
% max_thresholdf = 5; peak SD threshold

videorate = 120;

currentdir = pwd;
% FileBase = [currentdir '/' fileinfo.name '/' fileinfo.name];
FileBase =Basics.FileName;

% disp(sprintf('%s  detecting ripples...',fileinfo.name));
disp('   detecting ripples...');

highband = 230; % bandpass filter range
lowband = 130; % (250Hz to 100Hz)

thresholdf = 1  ; % power SD threshold for ripple detection

% min_sw_period = 50 ; % minimum ripple period, 50ms ~ 5-10 cycles
min_sw_period = 30 ; % minimum ripple period, 50ms ~ 5-10 cycles\
max_sw_period = 450;
% min_isw_period = 100; % minimum inter-ripple period
min_isw_period = 50; % minimum inter-ripple period

%%%%% Configuration %%%%%

Par =LoadPar([FileBase '.par']); % either par or xml file needed
numchannel = Par.nChannels; % total channel number, 6, 10 or 18
EegRate = Par.lfpSampleRate; % sampling rate of eeg file
SampleRate = Par.SampleRate; % sampling rate of dat file

forder = 100;  % filter order has to be even. The longer the more selective, but the operation
% will be linearly slower to the filter order. 100-125 for 1.25Hz (500 for 5 KH
avgfilorder = round(min_sw_period/1000*EegRate/2)*2+1 ; % should not change this. length of averaging filter
% avgfilorder = 101; % should not change this. length of averaging filter
forder = ceil(forder/2)*2; % to make sure filter order is even

%%%%% Ripple detection %%%%%
      
% if isempty(fileinfo.ripch)
if isempty(Basics.Ch.bestRipple)
    fprintf(1,'No CA1 ripple channels available\n')
    ripple_result = [];
    save([FileBase '-rip.mat'],'ripple_result'); %
    MakeEvtFile([],[FileBase '.rip.evt'],[],EegRate); % make evt file for neuroscope browsing
    return
end

% (0) Loading eeg file for ripple detection
% rip_channels = fileinfo.ripch(1:end-1) + 1; % tetrode/silicon probe 1-4,8,16ch
% subtract_channel = fileinfo.ripch(end) + 1; % need a relative channel to subtract

% rip_channels = fileinfo.bestch(1:end-1) + 1; % tetrode/silicon probe 1-4,8,16ch
% subtract_channel = fileinfo.bestch(end) + 1; % need a relative channel to subtract
rip_channels = Basics.Ch.bestRipple(1:end-1) + 1; % tetrode/silicon probe 1-4,8,16ch
subtract_channel = Basics.Ch.bestRipple(end) + 1; % need a relative channel to subtract

% [min_median,ix] = max(chm(1,:));
% subtract_channel = chm(2,ix);
% GammaCh = fileinfo.GammaCh(find(fileinfo.CA==1));
% 
% if ismember(subtract_channel,GammaCh)
%     GammaCh = GammaCh(find(GammaCh~=subtract_channel));
% end
    
% [sum_detection] = [];
% for shank = 1:size(bc,2);
% select_channel = [rip_channels GammaCh];  %  not yet finalized--how to select channels! %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
select_channel = [rip_channels]; 
% select_channel = bc(shank,:)';

firfiltb = fir1(forder,[lowband/EegRate*2,highband/EegRate*2]); % calculate convolution func
avgfiltb = ones(avgfilorder,1)/avgfilorder; % passbands are normalized to Nyquist frequency.

if FileExists([FileBase '.eeg'])
    filtered_data = readmulti([FileBase '.eeg'],numchannel,select_channel,subtract_channel); % load .eeg trace
elseif FileExists([FileBase '.lfp'])
    filtered_data = readmulti([FileBase '.lfp'],numchannel,select_channel,subtract_channel); % load .eeg trace
end    
%     thresholdbuffer = readlocalch([FileBase
%     '.eeg'],numchannel,select_channel,subtract_channel);

filtered_data = Filter0(firfiltb,filtered_data); % the actual filtering

if thetafilter && FileExists([FileBase '.theta.1'])
    exclude = dlmread([FileBase '.theta.1']);
else
    exclude = [];
end

if FileExists([FileBase '.ripExclude.mat']) & isempty(without)
    fprintf(1,'Warning!  Special ripple detection in place \n')
    load([FileBase '.ripExclude.mat'])
end
exclude = sortrows([exclude;without]);
  
filtered_data2 = filtered_data.^2; % to power trace
sdat = unity(Filter0(avgfiltb,sum(filtered_data2,2)),exclude); % averaging & standardizing

% (1) primary detection of ripple periods, based on thresholding
thresholded = sdat > thresholdf;
primary_detection_b = find(diff(thresholded)>0);
primary_detection_e = find(diff(thresholded)<0);

if primary_detection_b(1)>primary_detection_e(1);
    primary_detection_e = primary_detection_e(2:end);
end

sum_detection =[primary_detection_b(1:size(primary_detection_e,1),1) primary_detection_e];
% sum_detection_e = [sum_detection_e primary_detection_e];

sum_detection = sortrows(sum_detection);
primary_detection_b = sum_detection(:,1);
primary_detection_e = sum_detection(:,2);

if (length(primary_detection_e) == length(primary_detection_b)-1) % exclude ranged-out (1st or
    primary_detection_b = primary_detection_b(1:end-1);
end

if (length(primary_detection_e)-1 == length(primary_detection_b))
    primary_detection_e = primary_detection_e(2:end);
end

primary = [primary_detection_b,primary_detection_e]; % [start, end]


if isempty(primary)
    disp(sprintf('ERROR1; no more ripple %s\n',FileBase));
    ripple_result = [];
    if FileExists([FileBase '-rip.mat'])
        fprintf('save old ripple data...');
        com = ['mv ' FileBase '-rip.mat '  FileBase '-rip.bak.mat'];
        system(com);
        com = ['mv ' FileBase '.rip.evt '  FileBase '.rip.bak.evt'];
        system(com);
    end
    save([FileBase '-rip.mat'],'ripple_result'); %
    MakeEvtFile([],[FileBase '.rip.evt'],[],EegRate); % make evt file for neuroscope browsing
    return
end

% (2) merging ripples, if inter-ripples period is less than min_isw_period;
min_isw_period = min_isw_period/1000*EegRate; % in eeg
min_sw_period = min_sw_period/1000*EegRate; % in eeg
max_sw_period = max_sw_period/1000*EegRate;
secondary=[];
tmp_rip = primary(1,:);

for ii=2:size(primary,1)
    if (primary(ii,1)-tmp_rip(2)) < min_isw_period
        tmp_rip = [tmp_rip(1),primary(ii,2)]; % merge two ripples
    elseif abs(primary(ii,1)-tmp_rip(1)) < min_isw_period
        tmp_rip = [min([tmp_rip(1) primary(ii,1)]),max([tmp_rip(2) primary(ii,2)])]; % merge two ripples
    else
        secondary = [secondary;tmp_rip];
        tmp_rip = primary(ii,:);
    end
end

secondary = [secondary;tmp_rip]; % [start, end]

keeper = find((secondary(:,2)-secondary(:,1)) > min_sw_period & (secondary(:,2)-secondary(:,1)) < max_sw_period);
secondary = secondary(keeper,:);

if isempty(secondary)
    disp(sprintf('ERROR2; no more ripple %s\n',FileBase));
    ripple_result = [];
    if FileExists([FileBase '-rip.mat'])
        fprintf('save old ripple data...');
        com = ['mv ' FileBase '-rip.mat '  FileBase '-rip.bak.mat'];
        system(com);
        com = ['mv ' FileBase '.rip.evt '  FileBase '.rip.bak.evt'];
        system(com);
    end
    save([FileBase '-rip.mat'],'ripple_result'); %
    MakeEvtFile([],[FileBase '.rip.evt'],[],EegRate); % make evt file for neuroscope browsing
    return
end

% (3) ripples must have its peak power of > max_thresholdf
third = [];
SDmax = [];

for ii=1:size(secondary,1)
    [max_val,max_idx] = max(sdat([secondary(ii,1):secondary(ii,2)]));
%     mean_val = mean(sdat([secondary(ii,1):secondary(ii,2)]));
    if max_val > max_thresholdf % & mean_val>thresholdf
        third = [third;secondary(ii,:)]; % [start, end]
        SDmax = [SDmax;max_val];
    end
end

if isempty(third)
    disp(sprintf('ERROR3; no more ripple %s\n',FileBase));
    ripple_result = [];
    save([FileBase '-rip.mat'],'ripple_result'); %
    MakeEvtFile([],[FileBase '.rip.evt'],[],EegRate); % make evt file for neuroscope browsing
    return
end
% (4) detection of negative peak position of each ripple
peak_idx = zeros(size(third,1),1);

for ii=1:size(third,1)
    [min_val,min_idx] = min(filtered_data(third(ii,1):third(ii,2)));
    peak_idx(ii,1) = min_idx+third(ii,1)-1;
end

Fourth = [third(:,1),peak_idx,third(:,2),SDmax]; % [start, peak, end, SD]

% (7) save detected ripples
ripple_result = Fourth; % [start, peak, end, SD] (in eeg)
% 
% if homefilter & ~isempty(ripple_result);
%     chts = fileinfo.chts;
%     tbegin = fileinfo.tbegin;
%     tend = fileinfo.ftend;
%     xyt = fileinfo.xyt;
%     xr2 = 0.5 + [-.13 .13];
%     xr1 = 0.5 + [-.2 .2];
%     tchg = (chts-tbegin)/1e6*SampleRate;
% 
%     before = find(ripple_result(:,1) < tchg);
%     xbin = interp1(tt,xyt(:,1),ripple_result(before,1));
%     cageout = find(xbin > max(xr1));
%     cagein = find(xbin < min(xr1));
% 
%     resultb = [ripple_result(cageout,:);ripple_result(cagein,:)];
% 
%     after = find(ripple_result(:,1) > tchg);
%     xbin = interp1(tt,xyt(:,1),ripple_result(after,1));
% 
%     tempvec = ripple_result(after,:);
%     cageout = find(xbin > max(xr2));
%     cagein = find(xbin < min(xr2));
% 
%     resulta = [tempvec(cageout,:);tempvec(cagein,:)];
% 
%     ripple_result = sortrows([resultb;resulta]);
% end
% 
% if runfilter& ~isempty(ripple_result)
%     smoothwin = [ones(15,1)];
%     smoothwin = smoothwin/sum(smoothwin);
%     xyt = fileinfo.xyt;
%     tbegin = fileinfo.tbegin;
%     tend = fileinfo.tend;
%     numofbins = round((tend-tbegin)/1e6*videorate); % binned into 120 Hz video sampling
% 
%     withinrange = find(xyt(:,3)>=tbegin & xyt(:,3)<=tend);
%     xyt = xyt(withinrange,:);
%     xyt=binpos(xyt,numofbins);
%     tt = (xyt(:,3)-tbegin)/1e6*EegRate;
%     diffx = abs(diff(filtfilt(smoothwin,1,xyt(:,1))));
%     speed = interp1(tt(1:end-1),diffx,ripple_result(:,2))*videorate*fileinfo.pix2cm;
%     running = speed > 5;
%     ripple_result = ripple_result(~running,:);
% end

if thetafilter& ~isempty(ripple_result) & FileExists([FileBase '.theta.1']);
    sts = dlmread([FileBase '.theta.1'])';
    rip_ind = STSfilt(sts,ripple_result(:,2),~thetafilter);
    ripple_result = ripple_result(rip_ind,:);
end
% 

% if fileinfo.NumberOfRipples~=size(ripple_result,1)
%     disp(['Previous = ' num2str(fileinfo.NumberOfRipples) ', New = ' num2str(size(ripple_result,1))])
% % ex1 = ['neuroscope ' FileBase '.eeg &']; 
% % system(ex1)
% 
% end

if FileExists([FileBase '-rip.mat'])
    fprintf('save old ripple data...');
    com = ['mv ' FileBase '-rip.mat '  FileBase '-rip.bak.mat'];
    system(com);
    com = ['mv ' FileBase '.rpl.evt '  FileBase '.rpl.bak.evt'];
    system(com);
end

MakeEvtFile(ripple_result(:,1:3),[FileBase '.rpl.evt'],{'beg','peak','end'},EegRate); % make evt file for neuroscope browsing
save([FileBase '-rip.mat'],'ripple_result'); %

%to change into ms
ripple_result(:,1:3)=ripple_result(:,1:3)/EegRate*1000;

ripple_number = size(ripple_result,1);
% fprintf('%s  %d ripples detected successfully!\n',fileinfo.name,ripple_number);
fprintf('%d ripples detected successfully!\n',ripple_number);




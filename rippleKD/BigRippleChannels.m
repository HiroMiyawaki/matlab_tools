function [best_channels,ch_medians] = BigRippleChannels(fileinfo,overwrite);

% find the channels per shank that have the largest amplitude of power in
% the ripple band.

currentdir = pwd;
FileBase = [currentdir '/' fileinfo.name '/' fileinfo.name];

disp(sprintf('%s  Choosing Ripple Channels..',fileinfo.name));

highband = 230; % bandpass filter range
lowband = 130; % (250Hz to 80Hz)

thresholdf = 1  ; % power SD threshold for ripple detection

% min_sw_period = 50 ; % minimum ripple period, 50ms ~ 5-10 cycles
min_sw_period = 40 ; % minimum ripple period, 50ms ~ 5-10 cycles\

max_sw_period = 350;
% min_isw_period = 100; % minimum inter-ripple period
min_isw_period = 30; % minimum inter-ripple period

%%%%% Configuration %%%%%

Par =LoadPar([FileBase '.par']); % either par or xml file needed
numchannel = Par.nChannels; % total channel number, 6, 10 or 18
EegRate = Par.lfpSampleRate; % sampling rate of eeg file

forder = 100;  % filter order has to be even. The longer the more selective, but the operation
% will be linearly slower to the filter order. 100-125 for 1.25Hz (500 for 5 KH
avgfilorder = round(min_sw_period/1000*EegRate/2)*2+1 ; % should not change this. length of averaging filter
% avgfilorder = 101; % should not change this. length of averaging filter
forder = ceil(forder/2)*2; % to make sure filter order is even


firfiltb = fir1(forder,[lowband/EegRate*2,highband/EegRate*2]); % calculate convolution func
avgfiltb = ones(avgfilorder,1)/avgfilorder; % passbands are normalized to Nyquist frequency.

best_channels = [];
ch_medians = [];

if ~isempty(fileinfo.CA1thetach)
%     subtract_channel = fileinfo.ripch(end) + 1;

    exclude = dlmread([FileBase '.theta.1'])';

if FileExists([FileBase '.ripExclude.mat'])
    load([FileBase '.ripExclude.mat']); %
    exclude = sortrows([without;exclude'])';  
end
    
shank = find(fileinfo.CA==1);    
for ss = 1:length(shank);
    channels = Par.SpkGrps(shank(ss)).Channels+1;
    channels = channels(~ismember(channels,fileinfo.badch+1));
    
    filtered_data = readmulti([FileBase '.eeg'],numchannel,channels); % load .eeg trace
%     thresholdbuffer = readlocalch([FileBase
%     '.eeg'],numchannel,select_channel,subtract_channel);

    filtered_data = Filter0(firfiltb,filtered_data).^2; % filtering
 
    ii_ok = ones(size(filtered_data,1),1);
    B = filtered_data;
    for ii = 1:size(exclude,2)
        if size(filtered_data,2)>size(filtered_data,1)
            keyboard
        end
        ii_ok(exclude(1,ii):exclude(2,ii)) = 0;
    end
    filtered_data = zeros(length(find(ii_ok)),size(B,2));
    for jj = 1:size(filtered_data,2)
        filtered_data(:,jj) = B(find(ii_ok),jj);
    end
    clear B
    
    [median_order,ix] = sort(median(filtered_data),2,'descend');
%     [median_order,ix] = max(median(filtered_data));
    
%     ch_medians = [ch_medians [median_order;channels(ix)]'];
    ch_medians(ss,1:length(ix)) = median_order;
%     best_channels = [best_channels;[channels(ix)]];
    best_channels(ss,1:length(ix)) = channels(ix)-1;
%         best_channels = [best_channels channels(ix)];
    
end

[ch_medians,ii] = sort(ch_medians(:,1),'descend');
best_channels = best_channels(ii,1);
end

% if ~isequal(fileinfo.bestch,best_channels) & ~overwrite
%     disp('WARNING: ovewrite best channels??')
%     keyboard
% end

% ch_medians = sortrows(ch_medians,-1);


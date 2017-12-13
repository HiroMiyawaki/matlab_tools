function [best_channels,ch_medians] = BestGammaChannels(FileName,lfpSampleRate,Ch,nChannels,SpkGrps);

% find the 1 channel per shank that has the largest amplitude of power in
% the gamma band.  Excludes all non-theta epochs to prevent contamination
% from ripples, artifacts, etc.

%currentdir = pwd;
%FileBase = [currentdir '/' fileinfo.name '/' fileinfo.name];

disp(sprintf('%s  Choosing Gamma Channels..',FileName));

highband = 250; % bandpass filter range
lowband = 30; % (250Hz to 80Hz)

%%%%% Configuration %%%%%

min_sw_period = 50 ; % minimum Gamma Burst period, 50ms ~ 5 cycles\

%Par =LoadPar([FileBase '.par']); % either par or xml file needed
%numchannel = Par.nChannels; % total channel number, 6, 10 or 18
%EegRate = Par.lfpSampleRate; % sampling rate of eeg file


forder = 100;  % filter order has to be even. The longer the more selective, but the operation
% will be linearly slower to the filter order. 100-125 for 1.25Hz (500 for 5 KH
avgfilorder = round(min_sw_period/1000*lfpSampleRate/2)*2+1 ; % should not change this. length of averaging filter
% avgfilorder = 101; % should not change this. length of averaging filter
forder = ceil(forder/2)*2; % to make sure filter order is even

firfiltb = fir1(forder,[lowband/lfpSampleRate*2,highband/lfpSampleRate*2]); % calculate convolution func
%avgfiltb = ones(avgfilorder,1)/avgfilorder; % passbands are normalized to Nyquist frequency.

best_channels = [];
ch_medians = [];


for shank = 1:length(Ch.CA1Shanks);
    channels = SpkGrps(shank).Channels+1;
    
    filtered_data = readmulti([FileName '.eeg'],nChannels,channels); % load .eeg trace
%     thresholdbuffer = readlocalch([FileBase
%     '.eeg'],numchannel,select_channel,subtract_channel);

    filtered_data = Filter0(firfiltb,filtered_data).^2; % filtering
    
%     [median_order,ix] = sort(median(filtered_data));
    
    sts = dlmread([FileName '.theta.1'])';  %% we want to include only theta epochs in calculating gamma
    exclude = [[1 sts(2,:)];[sts(1,:) size(filtered_data,1)]];
    
    for ii = 1:size(exclude,2)
        filtered_data(exclude(1,ii):exclude(2,ii)) = 0;
    end
    
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
    
    [median_order,ix] = max(median(filtered_data));
    
%     ch_medians = [ch_medians [median_order;channels(ix)]];
    
    best_channels = [best_channels channels(ix)];
    
    
end



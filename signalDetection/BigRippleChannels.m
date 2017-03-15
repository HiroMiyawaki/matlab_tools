function [best_channels,ch_medians] = BigRippleChannels(Basics)

% find the channels per shank that have the largest amplitude of power in
% the ripple band.

% currentdir = pwd;
% FileBase = [currentdir '/' fileinfo.name '/' fileinfo.name];
% 
% disp(sprintf('%s  Choosing Ripple Channels..',fileinfo.name));

FileBase = Basics.FileName;

highband = 230; % bandpass filter range
lowband = 130; % (250Hz to 80Hz)

thresholdf = 1  ; % power SD threshold for ripple detection

% min_sw_period = 50 ; % minimum ripple period, 50ms ~ 5-10 cycles
min_sw_period = 40 ; % minimum ripple period, 50ms ~ 5-10 cycles\

max_sw_period = 350;
% min_isw_period = 100; % minimum inter-ripple period
min_isw_period = 30; % minimum inter-ripple period

%%%%% Configuration %%%%%

% Par =LoadPar([FileBase '.par']); % either par or xml file needed
% numchannel = Par.nChannels; % total channel number, 6, 10 or 18
% EegRate = Par.lfpSampleRate; % sampling rate of eeg file

EegRate = Basics.lfpSampleRate;

forder = 100;  % filter order has to be even. The longer the more selective, but the operation
% will be linearly slower to the filter order. 100-125 for 1.25Hz (500 for 5 KH
avgfilorder = round(min_sw_period/1000*EegRate/2)*2+1 ; % should not change this. length of averaging filter
% avgfilorder = 101; % should not change this. length of averaging filter
forder = ceil(forder/2)*2; % to make sure filter order is even


firfiltb = fir1(forder,[lowband/EegRate*2,highband/EegRate*2]); % calculate convolution func
avgfiltb = ones(avgfilorder,1)/avgfilorder; % passbands are normalized to Nyquist frequency.

best_channels = [];
ch_medians = [];
subtract_channel = Basics.Ch.ripple(end);

if FileExists([FileBase '.theta.1'])
    exclude = dlmread([FileBase '.theta.1'])';
else
    exclude=[];
end

if FileExists([FileBase '.ripExclude.mat'])
    load([FileBase '.ripExclude.mat']); %
    exclude = sortrows([without;exclude'])';  
end

% if ~isempty(Basics.Ch.CA1theta)

if FileExists([FileBase '.eeg'])
    eegFile=[FileBase '.eeg'];
elseif FileExists([FileBase '.lfp'])
    eegFile=[FileBase '.lfp'];
end

display(['      ' 'start reading sbutract channel at' datestr(now)]);
    

fh=fopen(eegFile);
fseek(fh,2*(subtract_channel-1),'bof');
refdata=fread(fh,[1,inf],'int16',2*(Basics.nChannels-1));
fclose(fh);


for shank = Basics.Ch.CA1Shanks;
    display(['   ' datestr(now) ' shank ' num2str(shank) ' is being processed']);
    channels = Basics.SpkGrps(shank).Channels+1;

    clear medianVal
    for nn=1:length(channels)
        targetCh=channels(nn);
        
        if targetCh==subtract_channel
            medianVal(nn)=0;
            continue
        end
        
    display(['      ' 'start reading Ch ' num2str(targetCh) ' at' datestr(now)]);
    
%     if FileExists([FileBase '.eeg'])
%         filtered_data = readmulti([FileBase '.eeg'],Basics.nChannels,channels,subtract_channel); % load .eeg trace
%     elseif FileExists([FileBase '.lfp'])
%         filtered_data = readmulti([FileBase '.lfp'],Basics.nChannels,channels,subtract_channel); % load .eeg trace
%     end
    %     thresholdbuffer = readlocalch([FileBase
%     '.eeg'],numchannel,select_channel,subtract_channel);

    fh=fopen(eegFile);
    fseek(fh,2*(targetCh-1),'bof');
    filtered_data=fread(fh,[1,inf],'int16',2*(Basics.nChannels-1));
    fclose(fh);
    
    filtered_data=filtered_data-refdata;

    display(['      ' 'start filtering EEG at' datestr(now)]);
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

        medianVal(nn)=median(filtered_data);
    end
    
    display(['      ' 'start getting median order at ' datestr(now)]);
%     [median_order,ix] = sort(median(filtered_data),2,'descend');
    [median_order,ix] = sort(medianVal,'descend');
%     [median_order,ix] = max(median(filtered_data));
    
%     ch_medians = [ch_medians [median_order;channels(ix)]'];
    ch_medians(shank,1:length(ix)) = median_order;
%     best_channels = [best_channels;[channels(ix)]];
    best_channels(shank,1:length(ix)) = channels(ix);
%         best_channels = [best_channels channels(ix)];
    
end
display(['   ' datestr(now) ' picking up the best channel'])
ch_medians=ch_medians(Basics.Ch.CA1Shanks,:);
best_channels=best_channels(Basics.Ch.CA1Shanks,:);
% end
[ch_medians,ii] = sort(ch_medians(:,1),'descend');
best_channels = best_channels(ii,1)-1;
%beep
% ch_medians = sortrows(ch_medians,-1);


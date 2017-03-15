function thetaChannels = bestThetaChannel2(fileName,sampleRate,nCh,CA1Shanks,Channels)

%     fileName=[basics.FileName,'.eeg'];
%     sampleRate = basics.lfpSampleRate;
%     nCh=basics.nChannels;
%     CA1Shanks = basics.Ch.CA1Shanks;
%     Channels=basics.SpkGrps

    fNum= 2^floor(log(600*sampleRate)/log(2)+1);

    fh = fopen(fileName);
    data = [fread(fh,[nCh,fNum],'int16')]';
    fclose(fh);

%     temp=fft(data);

    forder = 256;  % filter order has to be even. The longer the more selective, but the operation
    % will be linearly slower to the filter order. 100-125 for 1.25Hz (500 for 5 KH
    forder = ceil(forder/2)*2; % to make sure filter order is even
    hTheta = 10; % bandpass filter range
    lTheta = 6; %

    hDelta = 4; % bandpass filter range
    lDelta = 1; % 

    hAlpha = 14; % bandpass filter range
    lAlpha = 11; % 
    
    
    fTheta = fir1(forder,[lTheta/sampleRate*2,hTheta/sampleRate*2]); % calculate convolution func
    dTheta=Filter0(fTheta,data);

    fDelta = fir1(forder,[lDelta/sampleRate*2,hDelta/sampleRate*2]); % calculate convolution func
    dDelta=Filter0(fTheta,data);

    fAlpha = fir1(forder,[lAlpha/sampleRate*2,hAlpha/sampleRate*2]); % calculate convolution func
    dAlpha=Filter0(fAlpha,data);
    

%     avgTheta = mean(dTheta.^2);
    avgTheta = mean(dTheta*2./(dDelta + dAlpha));
    thetaChannels=[];
    for shank = CA1Shanks
        ch = Channels(shank).Channels+1;
%         [dummy,pos]=max(cv(ch));
        [dummy,pos]=max(avgTheta(ch));
        thetaChannels=[thetaChannels,ch(pos)];
    end
    
    
%     fDelta = fir1(forder,[lDelta/sampleRate*2,hDelta/sampleRate*2]); % calculate convolution func
%     dDelta=Filter0(fDelta,data(:,thetaChannels));
%     avgDelta = mean(dDelta.^2);
%     ratio = avgTheta(thetaChannels)./avgDelta;
%     [dummy,idx]=sort(ratio,'descend');
    
     [dummy,idx]=sort(avgTheta(thetaChannels),'descend');    
    thetaChannels=thetaChannels(idx);
    
end

    



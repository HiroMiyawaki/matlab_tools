function add2eeg(FileName,nCh,Position,SpkTime,Pix2cm,lfpSampleRate,winSigma)

    binSize = 1000/lfpSampleRate;
    
    bufferSize=4096;
    

    winWidth = 4 ;%sigma units
    %gaussWin = exp(-((-winSigma*winWidth):binSize:(winSigma*winWidth)).^2/(2*winSigma^2))/(winSigma*(2*pi)^0.5);
    gaussWin = exp(-((-winSigma*winWidth):binSize:(winSigma*winWidth)).^2/(2*winSigma^2));
    gaussWin = gaussWin./sum(gaussWin);

    %numOfBins = round((position.t(end)-position.t(1))/1e3/binSize);
    inputFnameInfo=dir([FileName,'.eeg']);   
%     numOfBins = size(data,1);
    numOfBins = inputFnameInfo.bytes/nCh/2;
    
    if mod(numOfBins,1)~=0
        display('eeg file and/or channle number are not correct')
        return;
    end
    tbin = linspace(Position.t(1),Position.t(end),numOfBins);
    
    spkHist = hist(SpkTime,tbin);
    spkHist(1)=0;
    spkHist(end)=0;


    temp = conv(spkHist,gaussWin,'same');
        
    z=(temp-mean(temp))/std(temp);
    


 %   Pix2cm =(72*2.54/500 + 48*2.54/300)/2;
    
    %smoothing position (mean filter)
    runWin = [ones(15,1)/15];
    xyt = [filtfilt(runWin,1,Position.x*Position.xMax);filtfilt(runWin,1,Position.y*Position.yMax);Position.t]';

    sigma=30;
    gFilWidth=(sigma/binSize);
    gfil = exp(-((-gFilWidth*3:gFilWidth*3)*binSize).^2/sigma^2/2);
    gfil = gfil/sum(gfil);

    xyt=binpos(xyt,numOfBins);
    
    diffx = diff(xyt(:,1));
    diffy = diff(xyt(:,2));
    diffxy = (diffx.^2+diffy.^2).^0.5;
    speed = [0;diffxy]'.*Pix2cm/(binSize/1000);
    speed = conv(speed,gfil,'same');

%     dz = diff([0,z]);
%     ddz = diff([0,dz]);
%     
%     dz = (2*(dz-min(dz))/(max(dz)-min(dz))-1)*2^15;;
%     ddz = (2*(ddz-min(ddz))/(max(ddz)-min(ddz))-1)*2^15;;
      
%       z(z>3)=3;
%       z(z<-2)=-2;   
      z=(2*(z-min(z))/(max(z)-min(z))-1)*2^15;

%       speed(speed>20)=20;
%       speed(speed<0)=0;
      speed= (2*(speed-min(speed))/(max(speed)-min(speed))-1)*2^15;

      
    inputFileHandle = fopen([FileName,'.eeg']);
    outputFileHandle=fopen([FileName,'-2.eeg'],'w');
    doneFrame=0;
    while ~feof(inputFileHandle)
        data = [fread(inputFileHandle,[nCh,bufferSize],'int16')]';
        for frame=1:size(data,1)
            fwrite(outputFileHandle,[data(frame,:),z(frame+doneFrame),speed(frame+doneFrame)]','int16');
        end
        doneFrame=doneFrame+frame;
        display(['done ' num2str(doneFrame),' frames / total ',num2str(numOfBins) ' frames (' ...
            num2str(round(doneFrame/numOfBins*100*100)/100) '%) at' datestr(now,'mm/dd HH:MM:SS')])
    end
    
    fclose(inputFileHandle);
    fclose(outputFileHandle);
    
end
function [dname,time,jumped,invFlag,frequency]=checkTimeStamp()
[ncsFile, ncsDir, loadFlag] = uigetfile( {'*.ncs','ncs file (*.ncs)'; '*','any file (*)'}, 'select ncs file');
dname = ncsDir;
[timestamps,nrBlocks,nrSamples,sampleFreq,isContinous,headerInfo] = getRawCSCTimestamps( fullfile(ncsDir,ncsFile));

for n=1:size(headerInfo)
    if ~isempty(strfind(headerInfo{n},'-InputInverted'))
        if ~isempty(strfind(headerInfo{n},'False'))
            invFlag=0;
        else
            invFlag=1;
        end
    end
    
    if ~isempty(strfind(headerInfo{n},'-SamplingFrequency '))
        [dummy, temp] = strtok(headerInfo{n});
        frequency = str2num(temp)
    end
end

dt = diff(timestamps);

jumped=timestamps(dt>2*dt(1));
time= [timestamps(1),timestamps(end)];

end
% function [Segs, Complete] = LoadSegs(FileName, StartPoints, SegLen, nChannels, Channels, SampleRate, ResampleCoef, Buffer) 
% loads segments from FileName (full name) for selection of Channels 
% StartPoints give the starting times of the segments.
% SegLen gives the length of the segments.  All segments must be
% the same length, and a rectangular array is returned
% (dim 1:time within segment,  dim 2:channel, dim 3: segment number);
%

function [Segs, Complete] = LoadSegs(FileName, StartPoints, SegLen, nChannels, varargin) 
FileBase = FileName(1:end-4);

if isempty(nChannels)
	 Par = LoadPar([FileBase '.par']);
 	nChannels = Par.nChannels; 
 end
[ Channels, SampleRate, ResampleCoef,Buffer ] = DefaultArgs(varargin,{[1:nChannels], 1600, 1,1});

StartPoints = StartPoints(:);
FileLen = FileLength(FileName);
nSamples = FileLen / 2 / nChannels;
Complete = find(StartPoints>0 & StartPoints+SegLen<nSamples);
StartPoints = StartPoints(Complete);	
nSegs = length(StartPoints);
nUsedChannels = length(Channels);

% if file size is small and many triggers and many channels are used
if (FileLen < 0.5*FreeMemory)  & (nUsedChannels*nSegs*SegLen*2 > 0.1*FileLen)
    Dat = bload(FileName, [nChannels, inf], 0);
    if ResampleCoef>1
        Dat = resample(Dat',1,ResampleCoef)';
        StartPoints = round(StartPoints/ResampleCoef);
        SegLen = round(SegLen/ResampleCoef);
    end
    [Segs, Complete] = GetSegs(Dat(Channels, :)',  StartPoints, SegLen);
    Segs = permute(Segs, [1, 3, 2]);
else
    cnt=1;
    %Complete = [];
    
    if Buffer==0
    
        for i=1:nSegs

            %   if StartPoints(i)+SegLen <= nSamples
            PositionBegBytes = StartPoints(i)*nChannels*2;
            if ResampleCoef==1
                Segs(:,:,i) = bload(FileName, [nChannels, SegLen], PositionBegBytes);
            else
                loadseg = bload(FileName, [nChannels, SegLen], PositionBegBytes);
                Segs(:,:,i) = resample(loadseg',1,ResampleCoef)';
            end

            %      cnt=cnt+1;
            %       Complete(end+1) = i;
            % end

        end
        Segs = permute(Segs, [2, 1, 3]);
        Segs = Segs(:,Channels,:);
    
    else
       BufLen = 100000;
       nT= StartPoints(end)+SegLen+2-StartPoints(1);
       nBuf = floor(nT/BufLen)+1;
       curs =0;
       Segs =[];
       for ii=1:nBuf
           if ii==nBuf+1
               keyboard
           end
           curseg =  [BufLen*(ii-1) BufLen*(ii)] + StartPoints(1);
           
           mySegi = find(StartPoints>= curseg(1) & StartPoints< curseg(2));
           myStartPoints = StartPoints(mySegi) - BufLen*(ii-1) - StartPoints(1);
           nmySeg = length(myStartPoints);
           if nmySeg>0
           PositionBegBytes = (BufLen*(ii-1 )+StartPoints(1))*nChannels*2;
           BufSeg = bload(FileName, [nChannels, BufLen], PositionBegBytes);
           
           Segs(:,curs+[1:nmySeg],:) = GetSegs(BufSeg(Channels,:)', myStartPoints, SegLen);
           curs=curs+nmySeg;          
           end
       end
       Segs = permute(Segs,[1 3 2]);
    end
        
end


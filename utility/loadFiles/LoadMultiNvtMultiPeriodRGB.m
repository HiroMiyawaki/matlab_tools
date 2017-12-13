function [res,raw] = LoadMultiNvtMultiPeriodRGB(Dir,FileList,useLED,Border,trackType,Periods,TrackMax,TrackMin,ConnectionType)
%function [t, x, y, angle, targets, points, header] = loadNvt(dirBase,FileBase,Ext)
%read timestamp, x-position, y-position, angle, targets, points, and header
%of nvt file.
% if all of x, y, and angle are zero, it reagarde as led detection failure
% and these values replased to NaN

    %variables for time, position(x,y), and angle
    t=[];
    x=[];
    y=[];
    
                
    %in future, these parameters are set from Data.Position.header

    
    
    if nargin>2 & size(Periods,2) ~= length(FileList)
        display('number of files and periods should be same');
        raw=[];
        res=[];
        return
    end
    
    
    %load nvt files
    for m=1:length(FileList)
        for p=1:size(Periods(m).time,1)
            display(['start loading position data of session ', num2str(m), 'period ', num2str(p)]);
            [tempPos,tempRaw]=detectPositionRGB([Dir,FileList{m},'.nvt'],useLED,Border{m}, Periods(m).time(p,:));
            raw(m).x{p}=tempRaw.x;
            raw(m).y{p}=tempRaw.y;
            raw(m).t{p}=tempRaw.t;                    
            t=[t,tempPos.t];
            x=[x,tempPos.x];
            y=[y,tempPos.y];
        end
    end

    res.Resolution.x=720;
    res.Resolution.y=480;
    res.SamplingFrequency = 29.970000;
    
    res.x = x;
    res.y = y;
    res.t = t;
    
    res.xMin = 0;
    res.xMax = res.Resolution.x;
    res.yMin = 0;
    res.yMax = res.Resolution.y;
    
    
    res.normX = (x-res.xMin)./(res.xMax-res.xMin);
    res.normY = (y-res.yMin)./(res.yMax-res.yMin);
    plot(x,y,'.');
    
    if(trackType == 'I')
        if (nargin<7)
            disp('select start and end points of the track');
            trackEnd = ginput(2);
            res.trackMin = (min(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
            res.trackMax = (max(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
        else
            res.trackMin = TrackMin;
            res.trackMax = TrackMax;
        end
        
        
    elseif(trackType == 'L')
        if (nargin<7)
            
            disp('select start and end points of the track along x-axis');
            trackEnd = ginput(2);
            res.trackMin(1) = (min(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
            res.trackMax(1) = (max(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
            
            flag =0;
            if(mean(trackEnd(:,2))<res.Resolution.x/2) flag=flag+1;end
            
            disp('select start and end points of the track along y-axis');
            trackEnd = ginput(2);
            res.trackMin(2) = (min(trackEnd(:,2))-res.yMin)/(res.yMax-res.yMin);
            res.trackMax(2) = (max(trackEnd(:,2))-res.yMin)/(res.yMax-res.yMin);
            
            if(mean(trackEnd(:,1))<res.Resolution.y/2)
                res.connection = 'reverse';
            else
                res.connection = 'normal';
            end
        else
            for k=1:2
                res.trackMin(k) = TrackMin(k);
                res.trackMax(k) = TrackMax(k);
            end
            res.connection = ConnectionType;
        end
    elseif(trackType == 'U')
        if (nargin<7)
            
            disp('select start and end points of the track along x-axis');
            trackEnd = ginput(2);
            res.trackMin(1) = (min(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
            res.trackMax(1) = (max(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
            
            flag =0;
            if(mean(trackEnd(:,2))<res.Resolution.x/2) flag=flag+1;end
            
            disp('select start and end points of the track along y-axis');
            trackEnd = ginput(2);
            res.trackMin(2) = (min(trackEnd(:,2))-res.yMin)/(res.yMax-res.yMin);
            res.trackMax(2) = (max(trackEnd(:,2))-res.yMin)/(res.yMax-res.yMin);
            
            disp('select start and end points of the third track');
            trackEnd = ginput(2);
            if (min(trackEnd(:,2))-res.yMin)>(res.yMax-res.yMin)/2 || ...
                (max(trackEnd(:,2))-res.yMin)<(res.yMax-res.xMin)/2
                res.trackMin(3) = (min(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
                res.trackMax(3) = (max(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
            else
                res.trackMin(3) = (min(trackEnd(:,2))-res.yMin)/(res.yMax-res.yMin);
                res.trackMax(3) = (max(trackEnd(:,2))-res.yMin)/(res.yMax-res.yMin);
            end
            
            if(mean(trackEnd(:,1))<res.Resolution.y/2)
                res.connection = 'reverse';
            else
                res.connection = 'normal';
            end
        else
            for k=1:3
                res.trackMin(k) = TrackMin(k);
                res.trackMax(k) = TrackMax(k);
            end
            res.connection = ConnectionType;
        end
    elseif(trackType == 'N')
         %do nothing        
    end

    
end



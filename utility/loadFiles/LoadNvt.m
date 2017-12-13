function res = LoadNvt(FileBases,trackType,Periods)
%function [t, x, y, angle, targets, points, header] = loadNvt(dirBase,FileBase,Ext)
%read timestamp, x-position, y-position, angle, targets, points, and header
%of nvt file.
% if all of x, y, and angle are zero, it reagarde as led detection failure
% and these values replased to NaN

    %variables for time, position(x,y), and angle
    t=[];
    x=[];
    y=[];
    angle=[];
    
    %variable for record start and end time of each period
    periods=[];
    
    %load nvt files
    for n=1:length(FileBases)
        fName = strcat(FileBases(n),'.nvt');
        [tTemp,xTemp, yTemp, angleTemp,targetsTemp,pointsTemp,headerTemp] =...
            Nlx2MatVT_v3(fName{1},[1,1,1,1,1,1],1,1,[]);
        
        t=[t,tTemp];       
        x=[x,xTemp];
        y=[y,yTemp];
        angle=[angle,angleTemp];
        periods=[periods;tTemp(1),tTemp(end)];
    end
        
            
    %in future, these parameters are set from Data.Position.header
    res.Resolution.x=720;
    res.Resolution.y=480;
    res.SamplingFrequency = 29.970000;
    res.periods = periods;

    
    res.t = t; 
        
    res.rawX = x;
    res.rawY = y;   
    res.rawAngle = angle;
    
    mx = medfilt1(x,151);
    my = medfilt1(y,151);
    
    x(x==0 & y==0)=NaN;
    y(x==0 & y==0)=NaN;
    mx(x==0 & y==0)=NaN;
    my(x==0 & y==0)=NaN;
    
    
    index=find(abs(mx-x)>100|abs(my-y)>100);
    x(index)=NaN;
    y(index)=NaN;
              
    
    %estimate defect position
    nanStart=0;
    for n = 1:length(x);
        if(isnan(x(n)))
            if(nanStart == 0)
                nanStart = n;
            end
        else
            if(nanStart ~= 0)
                if(nanStart == 1)
                    x(1,[nanStart:n]) = x(1,n);
                    y(1,[nanStart:n]) = y(1,n);
                    nanStart=0;
                else
                    if(n >= length(x) || ~isnan(x(n+1)))
                        x(1,[(nanStart-1):n]) = linspace(x(1,nanStart-1),x(1,n),(n-nanStart)+2);
                        y(1,[(nanStart-1):n]) = linspace(y(1,nanStart-1),y(1,n),(n-nanStart)+2);
                        nanStart=0;
                    end
                end
            end
        end
    end
    if(isnan(x(end)))
         x(1,nanStart:n)=x(1,nanStart-1);
         y(1,nanStart:n)=y(1,nanStart-1);
         
    end
    
%     res.rawX = x;
%     res.rawY = y;   
%     res.rawAngle = angle;
    
    %res.targets = targets;
    %res.points = points;an
    %res.header =header;
    
    x = medfilt1(x,15);
    y = medfilt1(y,15);

    res.x = x;
    res.y = y;
    res.t = t;
        
    plot(x,y,'.');

%     disp('select track area including platforms');
%     
%     lims = ginput(2);
%     
%     res.xMin = min (lims(:,1));
%     res.xMax = max (lims(:,1));
%     res.yMin = min (lims(:,2));
%     res.yMax = max (lims(:,2));

     res.xMin = 0;
     res.xMax = res.Resolution.x;
     res.yMin = 0;
     res.yMax = res.Resolution.y;

    
    res.normX = (x-res.xMin)./(res.xMax-res.xMin);
    res.normY = (y-res.yMin)./(res.yMax-res.yMin);
    
    if(trackType == 'I')
        disp('select start and end points of the track');
        trackEnd = ginput(2);
        res.trackMin = (min(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
        res.trackMax = (max(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
    
    elseif(trackType == 'L')
        disp('select start and end points of the track along x-axis');
        trackEnd = ginput(2);
        res.track1Min = (min(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
        res.track1Max = (max(trackEnd(:,1))-res.xMin)/(res.xMax-res.xMin);
        
        flag =0;
        if(mean(trackEnd(:,2))<res.Resolution.x/2) flag=flag+1;end

        disp('select start and end points of the track along y-axis');
        trackEnd = ginput(2);
        res.track2Min = (min(trackEnd(:,2))-res.yMin)/(res.yMax-res.yMin);
        res.track2Max = (max(trackEnd(:,2))-res.yMin)/(res.yMax-res.yMin);

        if(mean(trackEnd(:,1))<res.Resolution.y/2) flag=flag+1;end
        
        if(mod(flag,2)==0)
            res.connection = 'reverse';
        else
            res.connection = 'normal';
        end
        
        
    end
    

    
    
end


% NLX2MATVT Imports data from Neuralynx NVT files to Matlab variables.
%
%   [TimeStamps, ExtractedX, ExtractedY, ExtractedAngle, Targets, Points] =
%                      Nlx2MatVT(  Filename, FieldSelection, ExtractHeader,
%                                 ExtractMode, ModeArray );
%
%   Version 5.0.1 
%
%   INPUT ARGUMENTS:
%   FileName: String containing either the complete ('C:\CheetahData\
%             VT1.nvt') or relative ('VT1.nvt') path of the file you wish
%             to import. 
%   FieldSelectionFlags: Vector with each item being either a zero (excludes
%                        data) or a one (includes data) that determines which
%                        data will be returned for each record. The order of
%                        the items in the vector correspond to the following:
%                           FieldSelectionFlags(1): Timestamps
%                           FieldSelectionFlags(2): Extracted X
%                           FieldSelectionFlags(3): Extracted Y
%                           FieldSelectionFlags(4): Extracted Angle
%                           FieldSelectionFlags(5): Targets
%                           FieldSelectionFlags(6): Points
%                        EXAMPLE: [1 0 0 0 0 1] imports timestamp and points
%                        data from each record and excludes all other data.
%   HeaderExtractionFlag: Either a zero if you do not want to import the header
%                         or a one if header import is desired..
%   ExtractionMode: A number indicating how records will be processed during
%                   import. The numbers and their effect are described below:
%                      1 (Extract All): Extracts data from every record in
%                        the file.
%                      2 (Extract Record Index Range): Extracts every record
%                        whose index is within a range.
%                      3 (Extract Record Index List): Extracts a specific list
%                        of records based on record index.
%                      4 (Extract Timestamp Range): Extracts every record whose
%                        timestamp is within a range of timestamps.
%                      5 (Extract Timestamp List): Extracts a specific list of
%                        records based on their timestamp.
%   ExtractionModeVector: The contents of this vector varies based on the
%                         ExtractionMode. Each extraction mode is listed with
%                         a description of the ExtractionModeVector contents.
%                      1 (Extract All): The vector value is ignored.
%                      2 (Extract Record Index Range): A vector of two indices,
%                        in increasing order, indicating a range of records to
%                        extract. A record index is the number of the record in
%                        the file in temporal order (i.e. first record is index
%                        1, second is 2, etc.). This range is inclusive of the
%                        beginning and end indices. If the last record in the
%                        range is larger than the number of records in the
%                        file, all records until the end of the file will be
%                        extracted.
%                        EXAMPLE: [10 50] imports the 10th record through the
%                        50th record (total of 41 records) of the file.
%                      3 (Extract Record Index List): A vector of indices
%                        indicating individual records to extract. A record
%                        index is the number of the record in the file in
%                        temporal order (i.e. first record is index
%                        1, second is 2, etc.). Data will be extracted in the
%                        order specified by this vector. If an index in the
%                        vector is less than 1 or greater than the number of
%                        records in the file, the index will be skipped.
%                        EXAMPLE: [7 10 1] imports record 7 then 10 then 1,
%                        it is not sorted temporally
%                      4 (Extract Timestamp Range): A vector of two timestamps,
%                        in increasing order, indicating a range of time to use
%                        when extracting records. If either of the timestamps
%                        in the vector are not contained within the timeframe
%                        of the file, the range will be set to the closest
%                        valid timestamp (e.g. first or last). The range is
%                        inclusive of the beginning and end timestamps. If a
%                        specified timestamp occurs within a record, the entire
%                        record will be extracted. This means that the first
%                        record extracted may have a timestamp that occurs
%                        before the specified start time.
%                        EXAMPLE: [12500 25012] extracts all records that
%                        contain data that occurred between the timestamps
%                        12500 and 25012, inclusive of data at those times.
%                      5 (Extract Timestamp List): A vector of timestamps
%                        indicating individual records to extract. If a
%                        specified timestamp occurs within a record, the entire
%                        record will be extracted. This means that the a record
%                        extracted may have a timestamp that occurs before the
%                        specified timestamp. If there is no data available for
%                        a specified timestamp, the timestamp will be ignored.
%                        Data will be retrieved in the order specified by this
%                        vector.
%                        EXAMPLE: [45032 10125 75000] imports records that
%                        contain data that occurred at timestamp 45035 then
%                        10125 then 75000, it is not sorted temporally.
%
%   Notes on output data:
%   1. Each output variable's Nth element corresponds to the Nth element in
%      all the other output variables with the exception of the header output
%      variable.
%   2. The value of N in the output descriptions below is the total number of
%      records extracted.
%   3. For more information on Neuralynx records see:
%      http://www.neuralynx.com/static/software/NeuralynxDataFileFormats.pdf
%   4. Output data will always be assigned in the order indicated in the
%      FieldSelectionFlags. If data is not imported via a FieldSelectionFlags
%      index being 0, simply omit the output variable from the command.
%      EXAMPLE: FieldSelectionFlags = [1 0 0 0 0 1];
%      [Timestamps,Points] = Nlx2MatVT('test.nvt',FieldSelectionFlags,0,1,[]);
%
%   OUTPUT VARIABLES:
%   Timestamps: A 1xN vector of timestamps.
%   Extracted X: A 1xN vector of the calculated X coordinate for each record.
%   Extracted Y: A 1xN vector of the calculated Y coordinate for each record.
%   Extracted Angle: A 1xN vector of the calculated head direction angle for
%                    each record. This value is in degrees.
%   Targets: A 50xN matrix of the targets found for each frame. These values
%            are encoded using the VT bitfield encoding.
%   Points: A 480xN matrix of the threshold crossings found for each frame.
%           These values are encoded using the VT bitfield encoding.
%   Header: A Mx1 vector of all the text from the Neuralynx file header, where
%           M is the number of lines of text in the header.
%
%
%   EXAMPLE: [Timestamps, X, Y, Angles, Targets, Points, Header] =
%            Nlx2MatVT('test.nvt', [1 1 1 1 1 1], 1, 1, [] );
%   Uses extraction mode 1 to return all of the data from all of the records
%   in the file test.nvt.
%
%   EXAMPLE: [Timestamps, X, Y, Header] = Nlx2MatVT('test.nvt',
%            [1 1 1 0 0 0], 1, 2, [14 30]);
%   Uses extraction mode 2 to return the Timestamps, X and Y coordinates between
%   record index 14 and 30 as well as the complete file header.
%

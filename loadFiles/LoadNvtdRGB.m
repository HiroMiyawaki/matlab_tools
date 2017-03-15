function res = LoadNvtdRGB(nvtFile,useLED,border,tsRange)

prevSize=5;

%maximum movement per frame
moveThresh = 20*(prevSize+1)/2;

%maximum distance betweem LEDs
apartThresh=50;

if nargin<4
    tsRange=[];
    exMode=1;
else
    exMode=4;
    if size(tsRange,2)~=2 || size(tsRange,1)~=1
        sprintf('size of time stamp range must be 1 x 2\n');
        return
    end
end
%%
    %load .nvt file
        [t,nvtX,nvtY,nvtTgt] =Nlx2MatVT_v3(nvtFile,[1,1,1,0,1,0],0,exMode,tsRange);
%%


res=[];

%check the size of useLED;
if size(useLED,2)>2
    return;
end

%%

frame=1;
flag=true;

while(flag)
    if nvtX(frame)==0 & nvtY(frame)==0
        frame=frame+1;
        flag=true;
    else
        for n=useLED
            prev{n}=ones(prevSize,1)*[nvtX(frame),nvtY(frame)];
        end
        flag=false;
    end
end

for n=useLED
    noDitect{n}=1;
end

%to display progress
progress=size(nvtTgt,2)/10*(1:10);
progressCount=1;

%read each points from target 
for pFrame = 1:size(nvtTgt,2)
    
    idx=0;
    flag=true;

    for n=useLED
        temp{n}=[];
    end
    
    %decode position form targets
    while(flag)
        idx=idx+1;
        
        vtVal=nvtTgt(idx,pFrame);
        val=zeros(1,32);
        %obtain bit array
        for n=1:32
            val(n)=mod(vtVal,2);
            vtVal=(vtVal-mod(vtVal,2))/2;
        end
        
        if sum(val([13:16,29:32]))==0
            %skip empty points
            flag=false;
        else
            %obtain x and y positions
            x=val(1:12)*power((2*ones(12,1)),[0:11]');
            y=val(17:28)*power((2*ones(12,1)),[0:11]');
            
            %restrict position inside of given areas
            inArea=ones(size(border,1),1);
            for n=1:size(border,1)
                inArea(n)=inArea(n)*(x>=border(n,1));
                inArea(n)=inArea(n)*(x<=border(n,3));
                inArea(n)=inArea(n)*(y>=border(n,2));
                inArea(n)=inArea(n)*(y<=border(n,4));
            end
            
            %if the decorded position is in side of the border, add the
            %point into candidate points of that frame.
            if(sum(inArea)>0)
                for n=1:3
                    if(val(32-n))
                        temp{n}=[temp{n};x,y];
                    end
                end
            end
        end
    end
    %decode of target file at this time frame finished
    
    %check movement from previous points
    nonDitectFlag=false;
    for n=useLED
        move{n} = [];
        if ~isempty(temp{n})
            
            %get median value of speed
            for cand = 1:size(temp{n},1)
                move{n}(cand)=median(sum([prev{n}-ones(prevSize,1)*temp{n}(cand,:)]'.^2).^0.5);
            end
            [move{n},idx]=sort(move{n});
            temp{n}=temp{n}(idx,:);
            temp{n}=temp{n}(move{n}<moveThresh*noDitect{n},:);
            move{n}=move{n}(move{n}<moveThresh*noDitect{n});
            if isempty(temp{n})
                nonDitectFlag=true;    
            end
        else
            nonDitectFlag=true;
        end
    end
    
    
    if (nonDitectFlag)
    %when only one LED was detected
        for n=useLED           
            if isempty(move{n})
                %put NaN to non detected color
                pos{n}(pFrame,:)=[NaN,NaN];
                noDitect{n}=noDitect{n}+1;
            else
                %update previous points
                prev{n}(1:(end-1),:)=prev{n}(2:end,:);
                prev{n}(end,:)=temp{n}(1,:);
                
                %add closest candidate to the point
                pos{n}(pFrame,:)=temp{n}(1,:);
                noDitect{n}=1;
            end
        end
    else
    %when two LEDs were detected
        cand=[];
        dist=[];
        
       %check distance between them
       for led1=1:size(temp{useLED(1)},1)
            for led2=1:size(temp{useLED(2)},1)
                %Pick up LED pairs which are close enough
                if sum([temp{useLED(1)}(led1,:)-temp{useLED(2)}(led2,:)].^2).^0.5 < apartThresh
                    cand=[cand;led1,led2];
                    dist=[dist;move{useLED(1)}(led1)+move{useLED(2)}(led2)];
                end
            end
        end
        
        if isempty(dist)
        %if none of pairs are close enough, adopt less moved one
            [dummy,adopt]=min([move{useLED(1)}(1),move{useLED(2)}(1)]);
            [dummy,reject]=max([move{useLED(1)}(1),move{useLED(2)}(1)]);
            adopt=useLED(adopt);
            reject=useLED(reject);
                
            %update previous points
            prev{adopt}(1:(end-1),:)=prev{adopt}(2:end,:);
            prev{adopt}(end,:)=temp{adopt}(1,:);

            %add adopted points
            pos{adopt}(pFrame,:)=temp{adopt}(1,:);
            noDitect{adopt}=1;        
            
            pos{reject}(pFrame,:)=[NaN,NaN];
            noDitect{reject}=noDitect{reject}+1;        
        else
            [dummy,minCand]=min(dist);
            for n=1:2
                prev{useLED(n)}(1:(end-1),:)=prev{useLED(n)}(2:end,:);
                prev{useLED(n)}(end,:)=temp{useLED(n)}(cand(minCand,n),:);
                pos{useLED(n)}(pFrame,:)=temp{useLED(n)}(cand(minCand,n),:);
                noDitect{useLED(n)}=1;
            end
        end
               
                

                

    end
    
    %show progress
    if(progress(progressCount)<pFrame)
        display([num2str(progressCount*10), '% finished at ' datestr(now, 'mm/dd HH:MM:SS')])
        progressCount=progressCount+1;
    end
end



%delete rapidly changed points
for led=useLED
    indexX = find(isnan(pos{led}(:,1) ));
    indexY = find(isnan(pos{led}(:,2) ));
    
    mx = medfiltExNaN1D(pos{led}(:,1),151);
    my = medfiltExNaN1D(pos{led}(:,2),151);
    
    mx(indexX)=NaN;
    my(indexY)=NaN;
    
    
    index=find((mx-pos{led}(:,1)).^2+(my-pos{led}(:,2)).^2>100^2);
    pos{led}(index,:)=NaN;
end

res.x=[pos{useLED(1)}(:,1),pos{useLED(2)}(:,1)];
res.y=[pos{useLED(1)}(:,2),pos{useLED(2)}(:,2)];
res.t=t;

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

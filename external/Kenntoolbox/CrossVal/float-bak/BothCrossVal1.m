function Out = BothCrossVal1(Res, BigRes, BigClu, ExcludeClu, Whl, nCrossVal, nFilts, SmoothVals)
%
% Out = BothCrossVal1(Res, BigRes, BigClu, CluNo, Whl, nCrossVal, nFilts, SmoothVals)
% Res - spike times to predict
% BigRes, BigClu - spikes used for prediction.  CluNo - don't use this cluster
% Whl - wheel file 
% nFilts - a set of filter integration times
% SmoothVals - smoothing parameters in the range 0..1 (1=env size)
%
% BigClu and Whl are optional - use [] if you don't want to use that info


% constants
SampScl = 512; % sample rate to whl file conversion
WhlScale = 91 / 255; % 1 yard = 255 .whl units

% check if Whl is empty
if isempty(Whl)
    Whl = 150*ones(1+floor((max(BigRes)-1)/SampScl),3);
end


% FIND VALID TIME SEGMENTS
WhlGood = [0 ; Whl(:,1)~=-1; 0];
dWhlGood = diff(WhlGood);
GoodStart = find(dWhlGood==1);
GoodEnd = find(dWhlGood==-1)-1;
LongEnough = (GoodEnd-GoodStart)>20;
GoodRanges = [GoodStart(LongEnough)-1, GoodEnd(LongEnough)-1]*SampScl; % in .res units, starting from 0
TotTime = sum(diff(GoodRanges, [], 2))/20000;

% CHECK WE HAVE ENOUGH SPIKES
if TotTime==0
	Out.BitsPerSec(1:nCrossVal, 1:length(SmoothVals)) = 0;
	return;
end
GoodRes = Res(find(WithinRanges(Res, GoodRanges)));
if Srange(GoodRes) <= (max(GoodRanges(:,2))-min(GoodRanges(:,1)))/nCrossVal
	% all spikes could lie in one bin
	Out.BitsPerSec(1:nCrossVal, 1:length(SmoothVals)) = 0;
	return;
end

% make spike number array (to be used in predicting activity
SpikeCnt = full(sparse(1+floor((BigRes-1)/SampScl), BigClu, 1, size(Whl,1)+10, max(BigClu)));

% zap any spikes that come after the end of the wheel file
SpikeCnt(size(Whl,1)+1:end,:) = [];

IndVars.t = (0:size(Whl, 1)-1)*SampScl; % t is the start of the bin
IndVars.Whl = Whl;
IndVars.SampScl = SampScl;
IndVars.MapSize = [300 300];
% IndVars.Smooth = 8;
%LikRat = PPCrossVal(Res, IndVars, 'PlaceTrain', 'PlaceTest', nCrossVal, GoodRanges);


%figure(1)
for i=1:length(SmoothVals)
    for j=1:length(nFilts)
        IndVars.Smooth = SmoothVals(i);
        s(i) = IndVars.Smooth;
        nFilt = nFilts(j);
        
        % make array of predictors (other spike trains)
        %IndVars.PredArray = filter([0 ones(1,nFilt)], 1, SpikeCnt);
        IndVars.PredArray = filter([ones(1,nFilt)], 1, SpikeCnt); % NO DELAY!
        IndVars.PredArray(:,1) = 1; % replace noise cluster with constant
        if (size(IndVars.PredArray,2) >=ExcludeClu)
            IndVars.PredArray(:,ExcludeClu) = 0; % wipe this cluster
        end            
		
		LikRat(:,i,j) = PPCrossVal(Res, IndVars, 'BothTrain', 'BothTest', nCrossVal, GoodRanges)';
		drawnow;
    end
end

Out.BitsPerSec = LikRat*nCrossVal/TotTime;
%Out.LikRat = LikRat;
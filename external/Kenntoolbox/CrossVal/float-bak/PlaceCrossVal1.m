% Out = PlaceCrossVal1(Res, Whl, nCrossVal, SmoothVals, PFFn)
% callback function for PlaceCrossVal
%
% tries a SmoothRange of smoothing sizes
% PFFn is the place field calculation function

function Out = PlaceCrossVal1(Res, Whl, nCrossVal, SmoothVals, PFFn)

SampScl = 512; % sample rate to whl file conversion
WhlScale = 91 / 255; % 1 yard = 255 .whl units

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

IndVars.t = (0:size(Whl, 1)-1)*SampScl; % t is the start of the bin
IndVars.Whl = Whl;
IndVars.SampScl = SampScl;
IndVars.MapSize = [300 300];
IndVars.PFFn = PFFn;
% IndVars.Smooth = 8;
IndVars.Shrink = 4;
%LikRat = PPCrossVal(Res, IndVars, 'PlaceTrain', 'PlaceTest', nCrossVal, GoodRanges);

%figure(1)
for i=1:length(SmoothVals)
	IndVars.Smooth = SmoothVals(i);
	s(i) = IndVars.Smooth;
	LikRat(:,i) = PPCrossVal(Res, IndVars, 'PlaceTrain', 'PlaceTest', nCrossVal, GoodRanges)';
	drawnow;
end

figure(2)
clf
semilogx(s*WhlScale, mean(LikRat)*nCrossVal/TotTime)
hold on
plot([s; s]*WhlScale, [mean(LikRat)+std(LikRat)/sqrt(nCrossVal) ; mean(LikRat)-std(LikRat)/sqrt(nCrossVal)]*nCrossVal/TotTime, 'b')
xlim([1 1000]);
plot(xlim, [0 0], 'k--');
ylim([-5 5]);
ylabel('bits/s');
xlabel('smoothing size (cm)');

Out.BitsPerSec = LikRat*nCrossVal/TotTime;

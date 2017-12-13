function Out = PhaseCrossVal1(Res, Whl, Eeg, Par, nCrossVal, SmoothVals)
% callback function for PhaseCrossVal
%
% tries a SmoothRange of smoothing sizes

if 0
AllRes = load('/u15/xaj/Awake/l21-01/f1.res');
Clu = LoadClu('/u15/xaj/Awake/l21-01/f1.clu');
Res = AllRes(find(Clu==20));
Eeg = bload('/u15/xaj/Awake/l21-01/f1.eeg', [16 inf]);
Whl = load('/u15/xaj/Awake/l21-01/f1.whl');
Par = LoadPar('/u15/xaj/Awake/l21-01/f1.par');
nCrossVal = 10;
SmoothVals = [.02:.02:.1];
end

% Need to be careful about sample rates.  There are 3:
% Res - 20kHz
% Whl - Res/512
% Eeg - Res/16.
%
% its is made more complicated by MATLAB's stupid indexing starting at 1.

if Par.SampleTime ~= 50
	error('I expected a sample rate of 20kHz!');
end

% t* is in Res units, but startng at 0. we should really subtract 1 from Res
WhlSampScl = 512; % sample rate to whl file conversion
EegSampScl = 16; %
tWhl = (0:size(Whl, 1)-1)*WhlSampScl; % t is the start of the bin
if ~isempty(Eeg)
	tEeg = (0:size(Eeg, 2)-1)*EegSampScl;
else
	tEeg = (0:size(Whl,1)*WhlSampScl/EegSampScl - 1)*EegSampScl;
end

% FIND VALID TIME SEGMENTS IN WHL FILE
[cWhl GoodRanges] = CleanWhl(Whl, 20);
GoodRanges = (GoodRanges-1)*WhlSampScl;
TotTime = sum(diff(GoodRanges, [], 2))/20000;
% upsample Whl file
cWhl(find(cWhl==-1)) = NaN;
WhlUp = interp1(tWhl, cWhl, tEeg, 'nearest');

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


% COMPUTE PHASES
% sum good channels
if ~isempty(Eeg)
	GoodChans = vertcat(Par.ElecGp{:})+1;
	EEGSum = sum(Eeg(GoodChans,:), 1)';
	FilterLength = 400;
	EEGSum(length(EEGSum)+FilterLength) = 0;
	b = Sfir1(1+2*FilterLength, [6 10]/625);
	Filtered0 = filter(b,1,EEGSum);
	Filtered = Filtered0(1+FilterLength:end);
	Phase = angle(Shilbert(Filtered));
else
	Phase = [];
end

% PREPARE INPUT ARRAY
IndVars.t = tEeg; % t is the start of the bin
IndVars.Whl = WhlUp;
IndVars.MapSize = 300;
IndVars.PFFn = 'PFPhase';
IndVars.Phase = Phase;
%LikRat = PPCrossVal(Res, IndVars, 'PlaceTrain', 'PlaceTest', nCrossVal, GoodRanges);

%figure(1)
for i=1:length(SmoothVals)
	IndVars.Smooth = SmoothVals(i);
	s(i) = IndVars.Smooth;
	LikRat(:,i) = PPCrossVal(Res, IndVars, 'PhaseTrain', 'PhaseTest', nCrossVal, GoodRanges)';
	drawnow;
end

% spatial scale factor
WhlScale = 91 / 255; % 1 yard = 255 .whl units
clf
semilogx(s*WhlScale, mean(LikRat)*nCrossVal/TotTime)
hold on
plot([s; s]*WhlScale, [mean(LikRat)+std(LikRat)/sqrt(nCrossVal) ; mean(LikRat)-std(LikRat)/sqrt(nCrossVal)]*nCrossVal/TotTime, 'b')
xlim([1 1000]);
plot(xlim, [0 0], 'k--');
ylim([-5 5]);
ylabel('bits/s');
xlabel('smoothing size');

Out.BitsPerSec = LikRat*nCrossVal/TotTime;

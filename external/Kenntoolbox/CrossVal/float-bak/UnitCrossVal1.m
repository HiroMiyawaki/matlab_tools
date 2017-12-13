function Out = UnitCrossVal1(Res, Clu, nCrossVal, nFilts)
% callback function for UnitCrossVal

%Res = load('/u15/xaj/Awake/l21-01/f1.res');
%Clu = LoadClu('/u15/xaj/Awake/l21-01/f1.clu');
nCrossVal = 10;
SampScl = 512; % make spike# array same res as wheel file

% make spike number array
SpikeCnt = full(sparse(1+floor((Res-1)/SampScl), Clu, 1));

%nFilts = 2.^(0:4:12);
%nFilt = 40;
%nFilts = 40;
% good range excludes those at the beginning and the very last bin
GoodRanges = SampScl*[max(nFilts) size(SpikeCnt,1)-1];
t = ((1:size(SpikeCnt,1)) - .5)*SampScl; %t contains center point of each bin
TotTime = sum(diff(GoodRanges, [], 2))/20000;

for i=1:length(nFilts)
if 1
    nFilt = nFilts(i);
	% filter spike counts it to make predictor array
	PredArray = filter([0 ones(1,nFilt)], 1, SpikeCnt);
	% replace noise cluster with constant
	PredArray(:,1) = 1;

else % try a double prediction ...
    PredArray = [filter([0 ones(1,nFilt)], 1, SpikeCnt), SpikeCnt];
end
	% now do crossvalidation
	nClu = max(Clu);    
	for TestClu = 2:nClu
        fprintf('Cell %d - Filter %d\n', TestClu, nFilt);
        if 0
            % use all cells, including this one
    		IndVars.PredArray = PredArray;
        else
            % use all but this cell
            IndVars.PredArray = PredArray(:,setdiff(1:nClu,TestClu));
%        IndVars.PredArray = PredArray(:,setdiff(1:nClu*2,[TestClu,nClu+1,nClu+TestClu]));
        end
        IndVars.t = t;
        TestRes = Res(find(Clu==TestClu));
		LikRat(:,TestClu,i) = PPCrossVal(TestRes, IndVars, 'UnitTrain', 'UnitTest', nCrossVal, GoodRanges)';
	end
end

Out.BitsPerSec = LikRat*nCrossVal/TotTime;
Out.FiltTime = nFilts*SampScl/20;
return

for i=2:nClu
    semilogx(nFilts*SampScl/20, sum(sq(LikRat(:,i,:)))*20000/diff(GoodRanges))
    xlabel('Integration time (ms)');
    ylabel('bits/s');
    
    [BestInfo(i) BestTime(i)] = max(sum(sq(LikRat(:,i,:)))*20000/diff(GoodRanges));
    
    pause
end
return



BinSize = 20000;

Sizes = round(2000*1.3.^(1:20));
for b=1:20
	BinSize = Sizes(b);
	% make range divide exactly into nCrossVal sets of bins
	GoodRanges = [0 BinSize*nCrossVal*floor(max(Res)/BinSize/nCrossVal)];
	
	nClu = max(Clu);
	for TestClu = 2:nClu
	%for TestClu = 6
		% prepare data by cell
		TestRes = Res(find(Clu==TestClu));
		OtherCells = find(Clu~=TestClu & Clu~=1);
		IndVars.BinSize = BinSize;
		IndVars.Res = Res(OtherCells);
		IndVars.Clu = Clu(OtherCells);

		LikRat(:,TestClu,b) = PPCrossVal(TestRes, IndVars, 'UnitTrain', 'UnitTest', nCrossVal, GoodRanges)';
	end

	sum(LikRat(:,:,b))*20000/GoodRanges(2)
end
	
return



Res = load('/u15/xaj/Awake/l21-01/f1.res');
Clu = LoadClu('/u15/xaj/Awake/l21-01/f1.clu');
nClu = max(Clu);

tMax = max(Res);

% count spikes per bin
BinCount = full(sparse(1+floor((Res-1)/BinSize), Clu, 1));
nBins = size(BinCount, 1);

TestCell = 20;
y = BinCount(:,TestCell);
x = [ BinCount(:,[2:TestCell-1 TestCell+1:nClu]), ones(nBins, 1)];
t = 1:BinSize:BinSize*nBins;

[beta mu dev df se] = poisson(y, x);

[m Bins] = MeanSmooth(t, y, 50);
clf
plot(t, x*beta, Bins, m)
plot(x*beta)
hold on
plot(Bins, m);

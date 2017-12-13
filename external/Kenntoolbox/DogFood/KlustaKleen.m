% Interactive Cluster cleaner.
% KlustaKleen(FileBase, ElecNo)
%

function KlustaKleen(FileBase, ElecNo)
%function iClusterClean(FetRaw,Clu);

% load files
CluFileName = [FileBase, '.clu.', num2str(ElecNo)];
Clu = LoadClu(CluFileName);
FetFileName = [FileBase, '.fet.', num2str(ElecNo)];
FetRaw = LoadFet(FetFileName);
ResFileName = [FileBase, '.res.', num2str(ElecNo)];
Res = load(ResFileName);

%CluFileName = '564004SP.clu.1'

% main LOOP
while (1)
	
	% get array dimensions
	fprintf('Make-up of cluster file:\n');
	tabulate(Clu);

	fprintf('What do you want to do?\n');
	fprintf('d: Delete Outliers\n');
	fprintf('r: Re-allocate cluster 1\n');
	fprintf('l: Load cluster file\n');
	fprintf('u: Undo last operation\n');
	fprintf('q: Quit\n');
	Action = input('', 's');
	
	switch Action
		case 'd'
			[NewClu Save] = CutClu(FetRaw,Clu,Res);
		case 'r'
			[NewClu Save] = AddMissing(FetRaw,Clu,Res);
		case 'l'
			Clu = LoadClu(CluFileName);
			Save = 0;
		case 'u'
			NewClu = OldClu;
			Save = 0;
		case 'q'
			break;
	end
	
	if ((Save & (Action == 'd' | Action == 'r')) | Action == 'u')
		% save changes
		eval(sprintf('!mv %s %s.bak', CluFileName, CluFileName));
		SaveClu(CluFileName, NewClu);
		fprintf('Saving Cluster File. \n');
		OldClu = Clu;
		Clu = NewClu;
	end

%scatter(Fet(:,1), Fet(:,2), 5, Clu);
	
end

return

function [NewClu, Save] = CutClu(FetRaw,Clu,Res)

	% initialize
	nClusters = max(Clu);
	ChangeClu = ceil(nClusters/10)*10; % this is where deleted spikes go
	nDimsAll = size(FetRaw,2);
	NewClu = Clu;
	[WhichFets, Clu2Clean, CutDist, Bursters] = GetUserInputs(nDimsAll, nClusters);
	Fet = FetRaw(:,WhichFets);
	[nSpikes nDims] = size(Fet);

	[Means, CovMatMH] = CalcStats(Fet,Clu,Bursters);
		
	% calculate mahalanobis distances

	for c=Clu2Clean
		MySpikes = find(Clu==c);
		nMySpikes = length(MySpikes);
		NormVex = (Fet(MySpikes,:) - repmat(Means(c,:),nMySpikes,1)) * CovMatMH(:,:,c);
		Mahals = sum(NormVex.*NormVex,2);
		Outliers = find(Mahals>CutDist);
		fprintf('Cluster %d -> deleting %d outliers out of %d\n', c, length(Outliers), nMySpikes);
		NewClu(MySpikes(Outliers)) = c + ChangeClu;
	end;
	
	DispCCG = NewClu(find(NewClu>ChangeClu));
	DispCCG = union(DispCCG -ChangeClu, DispCCG);
	figure(1);
	CCG(Res, NewClu, 10, 30, 1, DispCCG);
	ok = input('OK (y)?','s');
	if (isempty(ok) | ok(1)=='y')
		NewClu(find(NewClu>ChangeClu)) = 1;
		Save = 1;
	else
		NewClu = Clu;
		Save = 0;
	end;
		
return

function [NewClu, Save] = AddMissing(FetRaw,Clu,Res)

	% initialize
	nClusters = max(Clu);
	ChangeClu = ceil(nClusters/10)*10; % this is where deleted spikes go
	nDimsAll = size(FetRaw,2);
	NewClu = Clu;
	[WhichFets, Clu2Clean, CutDist, Bursters] = GetUserInputs(nDimsAll, nClusters);
	Fet = FetRaw(:,WhichFets);
	[nSpikes nDims] = size(Fet);
	nClu2Clean = length(Clu2Clean);
	
	[Means, CovMatMH] = CalcStats(Fet,Clu,Bursters);

	Clu1 = find(Clu==1);
	nClu1 = length(Clu1);
	
	Mahals = zeros(nClu1, nClusters);
	% caclulate mahalanobis distances
	for c=1:nClusters
		NormVex = (Fet(Clu1,:) - repmat(Means(c,:),nClu1,1)) * CovMatMH(:,:,c);
		Mahals(:,c) = sum(NormVex.*NormVex,2);
	end
	
	for c=Clu2Clean
		% find those within the cut-off distance of cluster c
		MyGuys = find(Mahals(:,c) < CutDist);
		
		% of these, find any that could also belong to another cluster
		OtherClusters = setdiff(2:nClusters, c);
		Exceptions = find(any(Mahals(MyGuys,OtherClusters)<CutDist, 2));
		MyGuys(Exceptions) = [];
		
		fprintf('Cluster %d -> Allocating %d spikes.  %d not allocated because they could also go to another cluster\n',...
				c, length(MyGuys), length(Exceptions));
		
		% now reallocate them
		NewClu(Clu1(MyGuys)) = c+ChangeClu;
	end
	
	figure(1);
	DispCCG = NewClu(find(NewClu>ChangeClu));
	DispCCG = union(DispCCG -ChangeClu, DispCCG);
	CCG(Res, NewClu, 10, 30, 1, DispCCG);
	ok = input('OK (y)?','s');
	if (isempty(ok) | ok(1)=='y')
		NewClu(find(NewClu>ChangeClu)) = NewClu(find(NewClu>ChangeClu)) - ChangeClu;
		Save = 1;
	else
		NewClu = Clu;
		Save = 0;
	end;

		
return

function [Means, CovMatMH] = CalcStats(Fet,Clu,Bursters)
	% Calculate means
	nClusters = max(Clu);
	nDims = size(Fet,2);
	
	Means = zeros(nClusters, nDims);
	for c=2:nClusters
		Means(c,:) = mean(Fet(find(Clu==c),:));
	end

	% Calculate common covariance matrix and -.5 power
	if (length(Bursters) < nClusters-1) % only do it if you need to
		CommonSpikes = find(~ismember(Clu,union(1,Bursters)));
		CommonCovMat = cov(Fet(CommonSpikes,:) - Means(Clu(CommonSpikes),:));
		CommonCovMatMH = CommonCovMat^-0.5;
	end
	
	% Calculate all others
	for c=2:nClusters
		if (ismember(c,Bursters))
			% for bursting cells calculate the covariance matrix individually
			CovMat = cov(Fet(find(Clu==c),:));
			CovMatMH(:,:,c) = CovMat^-0.5;
		else
			% for all others use the common covariance matrix
			CovMatMH(:,:,c) = CommonCovMatMH;
		end
	end
return

% this function gets certain stuff from the user at the start of each operation
function [WhichFets, Clu2Clean, CutDist, Bursters] = GetUserInputs(nDimsAll, nClusters)

	fprintf('Which features to use (1:12)? Use MATLAB format, eg 1:12, [1 4 7 10].\n');
	WhichFets  = input('');
	if (isempty(WhichFets)) 
		WhichFets = 1:12;
	end
		
	Clu2Clean = input('Which clusters do you want to clean (all)?\n');
	if (isempty(Clu2Clean))
		Clu2Clean = 2:nClusters;
	end
	
	Bursters = input('Enter any clusters that you want to have their own covariance matrices (i.e. bursting cells)\n');
	
	pVal = input('Enter cut-off p-value (default 0.99)\n');
	if (isempty(pVal)) 
		pVal = 0.99; 
	end
	CutDist = chi2inv(pVal, length(WhichFets));
return;

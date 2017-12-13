% PredMat = WhichShouldPredict(FileBase, TypeAll, db, options)
%
% makes a matrix which contains ones if one cluster should be used to
% predict another.  Criterion is not to predict if the two channels of
% largest spike amplitude are the same (although they may be swapped)
%
% options = 'trode' means ignore .msua file even if its there 

function CanPred = WhichShouldPredict(FileBase, TypeAll, db, options)

Par = LoadPar([FileBase '.par']);

if FileExists([FileBase '.msua']) & ~strcmp(options, 'trode')
    
    Msua = LoadSpk([FileBase '.msua'], Par.nChannels);

	if nargin<2
        Des = char(textread([FileBase '.des'], '%s'));
        IsPC = [0;Des(:,1)=='p'];
	else
        IsPC = TypeAll=='p';
        IsPC(1) = 0;
	end
	
	nClu = size(Msua,3);
	
	Peak2Peak = sq(max(Msua,[],2) - min(Msua,[],2));
	
	[sorted order] = sort(Peak2Peak);
	
	BiggestAmp = order(Par.nChannels,:);
	SecondBiggest = order(Par.nChannels-1,:);
	
	Mat1 = repmat(BiggestAmp(:),1,nClu);
	Mat2 = repmat(SecondBiggest(:),1,nClu);
	PCMat = repmat(IsPC(:),1,nClu);
	
	%CanPred = (Mat1~=Mat1') & ~(Mat1==Mat2' & Mat2==Mat1') & PCMat & PCMat';
	CanPred = (Mat1 ~= Mat1') & (Mat1 ~= Mat2') & (Mat2~=Mat1') & (Mat2~=Mat2') & PCMat & PCMat';
	CanPred(1,find(IsPC)) = 1; % allow constant term to predict each cell

else
    fprintf('no .msua file, so excluding based on tetrode\n');
    
    sql = ['select GpNo, Type from View where FileBase = "' FileBase '"'];
    [TetNo0 Type] = mysql(sql, db, '%d %c');
    if ~isempty(TypeAll) % override if necessary
        Type=TypeAll(2:end);
    end

    % exclude interneurons
    TetNo = TetNo0;
    TetNo(find(Type~='p')) = -1;
    TetNo = [0;TetNo]; % bias channel
    for c=1:length(TetNo)
        CanPred(:,c) = (TetNo(c)>0 & TetNo(:)~=TetNo(c) & TetNo(:)>=0);
    end
end
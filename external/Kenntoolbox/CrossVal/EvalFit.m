%EvalFit(FileBase)
if 0
% DataFile = '/home/ken/data/pdata/all/_u15_xaj_Awake_l23-02_n2.all.temporal.bpdata';
% OutFile = '/home/ken/data/pout/all/_u15_xaj_Awake_l23-02_n2.all.temporal.bpout';
% 
% DataFile = '/home/ken/data/pdata/all/_u15_xaj_Awake_l23-02_nn1.all.temporal.bpdata';
% OutFile = '/home/ken/data/pout/all/_u15_xaj_Awake_l23-02_nn1.all.temporal.bpout';

DataFile = '/home/ken/code/Assembly/Test/l2101f1Lo.pdata';
OutFile = '/home/ken/code/Assembly/Test/l2101f1Lo.pout';
% 
% DataFile = '/home/ken/code/Assembly/Test/Siml.pdata';
% OutFile = '/home/ken/code/Assembly/Test/Siml.pout';

[Data Par1] = ReadPdataFile(DataFile);
[Out Par2] = ReadPoutFile(OutFile);
end

% make integer positions
Data.iPos = 1+floor([Data.PosX, Data.PosY]*Par1.SpaceGrid);

% loop through cells, smoothing values, and cross-val iterations to display fit qualtiy
cla; hold on;
for c=1:Par1.nCells
    if Par1.TetNo(c)<=0
        continue;
    end
    for ss=1:Par1.nSpaceSm
        for ts=1:Par1.nTimeSm
            
            % temporal smoothing
            sig = Par1.TimeSm(ts);
            if sig>=0
                tr = floor(4*sig); 
                b = exp(-(-tr:tr).^2/(2*sig^2));
                iSpkCnt(Data.tReal,:) = Data.SpkCnt;% NB this is indexed by tReal
                iSmSpkCnt = Filter0(b, iSpkCnt); 
                Data.SmSpkCnt = iSmSpkCnt(Data.tReal,:); % now same indexing again.
            else
                % if sig<0, don't predict at all.
                Data.SmSpkCnt = [];
            end                
            
            for cv=1:Par1.nCrossVal
                Myt = find(Data.CVGroup==cv-1);
                
                % extract place field and weight from Output file.      
                Predictor.Pf = Out.PlaceField(:,:,c,cv,ss);
                PredCells = find(Par1.TetNo>=0 & (~Par1.ExcludeSameTetrode | Par1.TetNo~=Par1.TetNo(c)));
                Predictor.Wt = Out.Weight(PredCells,c,cv,ss,ts);
                
                % compute likelihood and derivatives on training set.
                [L d dd] = CalcL(Par1, Data, Predictor, c, find(Data.CVGroup~=cv-1));
                
                % same on test set
                [Lt dt ddt mu PlaceFac] = CalcL(Par1, Data, Predictor, c, find(Data.CVGroup==cv-1));
                
                fprintf('cell %d ss %f ts %f cv %d --> L=%f (%f as output, rat %f)\n', ...
                    c, Par1.SpaceSm(ss), Par1.TimeSm(ts), cv, L, Out.LogL(c,cv,ss,ts), L/Out.LogL(c,cv,ss,ts));
                fprintf('TestRate %g TrainRate %g Mean PlaceFac %g Mean Mu %g\n', ...
                    sum(Data.SpkCnt(Myt,c))/length(Myt), Out.fRate(c,cv,ss,ts), mean(PlaceFac), mean(mu));
                
                Deriv = Out.Deriv(PredCells,c,cv,ss,ts);
                Hess = Out.Hess(PredCells, PredCells,c,cv,ss,ts);
                fprintf('mean fractional error in Deriv %f in Hess %f in L %f\n', ...
                    mean(abs((d-Deriv')./d)), mean(abs((dd(:)-Hess(:))./dd(:))), abs(Lt-Out.LogL(c,cv,ss,ts))./Lt)

                figure(1); 
                hold on; plot(L, Out.LogL(c,cv,ss,ts), '.')
                figure(2); 
                clf; plot([Data.SpkCnt(Myt,c), PlaceFac*1e3]); hold on; plot(xlim, Out.fRate(c,cv,ss,ts)*[1 1]*1e3);
                                
                fprintf('Wt:\t'); fprintf('%10.3e ', Predictor.Wt); fprintf('\n');
                fprintf('d/dd:\t'); fprintf('%10.3e ', d/dd); fprintf('\n');
                sd = diag(dd).^-0.5;
                fprintf('est sd\t'); fprintf('%10.3e ', sd); fprintf('\n');
                fprintf('p-val\t'); fprintf('%10.3f ', normcdf(-abs(Predictor.Wt./diag(dd).^-0.5))); fprintf('\n');
                fprintf('d*inv(dd)*d:\t%10.3e\n', d*inv(dd)*d');
                
                PredPlus = Predictor; PredPlus.Wt = Predictor.Wt + dd\d';
                PredMinus = Predictor; PredMinus.Wt = Predictor.Wt - dd\d';
                [LPlus] = CalcL(Par1, Data, PredPlus, c, find(Data.CVGroup~=cv-1));
                [LMinus] = CalcL(Par1, Data, PredMinus, c, find(Data.CVGroup~=cv-1));
                
                fprintf('Status %d nIts %d Delta+ %10.3e Delta- %10.3e\n', ...
                    Out.Status(c,cv,ss,ts), Out.nIter(c,cv,ss,ts), LPlus-L, LMinus-L);
                pause
            end
            figure(1);
            axis auto; pause;
        end
    end
end

return
mu0 = load('mu.dump');
Deriv0 = load('Deriv.dump');
Hess0 = load('Hess.dump');
SmSpkCnt0 = load('SmSpkCnt.dump');
% SpkCnt0 = load('SpkCnt.dump');
Wt0 = load('Wt.dump');

HessGuess = SmSpkCnt0(NotMine,:)' * sparse(1:length(NotMine), 1:length(NotMine), mu0(NotMine)) * SmSpkCnt0(NotMine,:)
DerivGuess = (Data.SpkCnt(NotMine,c)' - mu0(NotMine)) * SmSpkCnt0(NotMine,:)
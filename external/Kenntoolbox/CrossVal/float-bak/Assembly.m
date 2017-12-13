%Assembly(FileBase)
% a MATLAB implementation that should do the same as Assembly.cpp
if 0
    % DataFile = '/home/ken/data/pdata/all/_u15_xaj_Awake_l23-02_n2.all.temporal.bpdata';
    % OutFile = '/home/ken/data/pout/all/_u15_xaj_Awake_l23-02_n2.all.temporal.bpout';
    % 
    % DataFile = '/home/ken/data/pdata/all/_u15_xaj_Awake_l23-02_nn1.all.temporal.bpdata';
    % OutFile = '/home/ken/data/pout/all/_u15_xaj_Awake_l23-02_nn1.all.temporal.bpout';
    
    % 
    % DataFile = '/home/ken/code/Assembly/Test/Siml.pdata';
    % OutFile = '/home/ken/code/Assembly/Test/Siml.pout';
    
    DataFile = '/home/ken/code/Assembly/Test/l2101f1Lo.pdata';
    DataFile = '/home/ken/code/Assembly/Test/l2101f1.pdata';
    DataFile = '/home/ken/data/pdata/theta_only/_u15_xaj_Awake_l21-01_f1.theta_only.temporal.pdata';
    DataFile = '/home/ken/data/pdata/theta_only/_u15_xaj_Awake_l23-01_n2.theta_only.temporal.pdata';
    [DataF ParF] = ReadPdataFile(DataFile);
    [DataD ParD] = CreatePdataFile('/u15/xaj/Awake/l23-01/n1', DefaultPPar, {'Theta'}, {})
    ParD.SpaceSm = [-1 0.05]; ParD.PhSm = [-1 0 .05]; ParD.TimeSm = [-1 8]; 
    OldTet = ParD.TetNo; MyCell = 14;
    NewTet = -ones(size(OldTet)); NewTet(MyCell) = 1; 
    NewTet(find(OldTet>=0 & OldTet~=OldTet(MyCell))) = 0;
    ParD.TetNo = NewTet;
    Data = DataD; Par = ParD;
    % Par.UnitAddMult = 2; Par.MaxIter = 100; Par.LinkFn=1; Par.SpaceSm=-1; Par.TimeSm = [-1 8];
end
clear bs *Stow;

% make integer positions
Data.iPos = 1+floor([Data.PosX, Data.PosY]*Par.SpaceGrid);
Data.iPh = 1+floor(mod(Data.Ph,2*pi)*Par.PhGrid/2/pi);

% loop through cells, smoothing values, and cross-val iterations
figure(1); cla; hold off;
%for c=1:Par.nCells
    for c=13
    if Par.TetNo(c)<=0
        continue;
    end
    
    % find predictor cells and initialize weights to 0
    if Par.ExcludeSameTetrode
        PredCells = find(Par.TetNo>=0 &  Par.TetNo~=Par.TetNo(c));
    else
        PredCells = find(Par.TetNo>=0 & ([1:Par.nCells]'~=c));
    end
    
    for ss=1:length(Par.SpaceSm)
        %    for ss=1
        for ts=1:length(Par.TimeSm)
            %        for ts=3
            for phs=1:length(Par.PhSm)
                
                Predictor.Wt = zeros(length(PredCells),1);
                
                % temporal smoothing
                sig = Par.TimeSm(ts);
                if sig>=0
                    tr = floor(4*sig); 
                    b = exp(-(-tr:tr).^2/(2*sig^2));
                    clear iSpkCnt;
                    iSpkCnt(Data.tReal,:) = Data.SpkCnt;% NB this is indexed by tReal
                    iSmSpkCnt = Filter0(b, iSpkCnt); 
                    Data.SmSpkCnt = iSmSpkCnt(Data.tReal,:); % now same indexing again.
                else
                    % if sig<0, don't predict at all.
                    Data.SmSpkCnt = [];
                end                
                
                TotBits = 0;
                for cv=1:Par.nCrossVal
                    %            for cv=2:Par.nCrossVal
                    fprintf('Starting Cell %d SpaceSm %f TimeSm %f PhSm %f CV %d\n', c, Par.SpaceSm(ss), Par.TimeSm(ts), Par.PhSm(phs), cv);
                    Test = find(Data.CVGroup==cv-1); % times of test set
                    Train = find(Data.CVGroup~=cv-1); % times of training set
                    
                    % target to be predicted
                    Target = Data.SpkCnt(Train, c);
                    
                    % make mean rate on training set.
                    Predictor.fRate = sum(Target)/length(Train);
                    
                    % make place field only first time
                    % NB Assembly.cpp calculates them differently, with a "Epsilon" term. - change it if u like
                    %                     if (ts==1)
                    %                         if (Par.SpaceSm(ss)>=0 & Par.PhSm(phs)>=0)
                    [Predictor.Pf, dummy, Predictor.Phf, Predictor.kf]  = ...
                        PPhF([Data.PosX(Train) Data.PosY(Train)], Data.Ph(Train), ...
                        Target, [Par.SpaceSm(ss) Par.PhSm(phs)], Par.SpaceGrid, [Par.Epsilon Par.EpsilonPh]); 
                    %                         elseif (Par.SpaceSm(ss)>=0)
                    %                             Predictor.Pf = repmat(PFClassic([Data.PosX(Train) Data.PosY(Train)], ...
                    %                                 Target, Par.SpaceSm(ss), Par.SpaceGrid), [1 1 Par.PhGrid]); 
                    %                         else
                    %                             % Smooth<0 means just use mean
                    %                             Predictor.Pf = ones(Par.SpaceGrid, Par.SpaceGrid, Par.PhGrid)*Predictor.fRate;
                    %                         end
                    
                    % now make weight vector
                    if Par.TimeSm(ts)>=0
                        
                        % find training cells
                        PredCells = find(Par.TetNo>=0 & (~Par.ExcludeSameTetrode | Par.TetNo~=Par.TetNo(c)));
                        
                        % set up zero weight and calculate original deviance
                        Pred0 = Predictor;
                        Pred0.Wt = zeros(length(PredCells),1);
                        
                        InitDev =  CalcL(Par, Data, Predictor, c, Train);
                        ZeroDev =  CalcL(Par, Data, Pred0, c, Train);
                        
                        for Iter=1:Par.MaxIter
                            [L d dd] =  CalcL(Par, Data, Predictor, c, Train);
                            
                            OldWt = Predictor.Wt;
                            Predictor.Wt = OldWt + dd\d';                        
                            NewL = CalcL(Par, Data, Predictor, c, Train);
                            
                            % did deviance go up?
                            FullStep = 1;
                            %                        UnitAdd = mean(diag(dd));
                            UnitAdd = min(diag(dd));
                            while(NewL<L) 
                                % keep adding diagonals to the hessian until it stops going up
                                dd = dd + eye(length(PredCells))*UnitAdd;
                                
                                Predictor.Wt = OldWt + dd\d'; 
                                %                             d = d/2; Predictor.Wt = OldWt + dd\d'
                                NewL = CalcL(Par, Data, Predictor, c, Train);
                                FullStep = 0;
                                fprintf('Up->%.20f\n', NewL);
                                UnitAdd = UnitAdd*Par.UnitAddMult;
                            end
                            
                            bar(Predictor.Wt); 
                            %ylim([-1 1]); 
                            drawnow
                            fprintf('Iteration %d: L = %.20f\n', Iter, NewL);
                            %                         pause
                            % did we reach convergence threshold?
                            if (abs(NewL-L)<=Par.ConvergeThresh & FullStep) break; end
                            
                            % do we have to give up because we could not lower the deviance when it originally went up?
                            if (~FullStep & abs(NewL-L)<=Par.DevUpTerminateThresh)  break; end
                        end
                        
                        % run it one last time to get standard deviation
                        [L d dd] =  CalcL(Par, Data, Predictor, c, Train);
                        sd = diag(dd).^-0.5;   
                        p = normcdf(-abs(Predictor.Wt./sd));
                        
                        fprintf('Wt, Sd, P\n');
                        [Predictor.Wt' ; sd' ; p']
                        %                     fprintf('p-val\t'); fprintf('%10.3f ', normcdf(-abs(Predictor.Wt./diag(dd).^-0.5))); fprintf('\n');
                        
                    else
                        %                     Predictor.Wt = zeros(length(PredCells),1);
                    end % if Par.TimeSm>0
                    
                    % evaluate on test set
                    [Lt, dt, ddt, mut] = CalcL(Par, Data, Predictor, c, Test);
                    Bits = sum(-(mut - Predictor.fRate) + (log(mut)-log(Predictor.fRate)).*Data.SpkCnt(Test,c))/log(2);
                    fprintf('Cell %d SpaceSm %f TimeSm %f: ', c, Par.SpaceSm(ss), Par.TimeSm(ts));
                    
                    fprintf('Bits/sec %f Bits/spk %f\n', Bits/length(Test)*Par.InternalFreq, Bits/sum(Data.SpkCnt(Test,c)));
                    TotBits = TotBits+Bits;
                    BitStow(cv) = Bits;
                    WtStow(:,cv) = Predictor.Wt;
                    %                 pause
                    
                end % for cv
                fprintf('Bits/sec %f Bits/spk %f\n', TotBits/Par.nData*Par.InternalFreq, TotBits/sum(Data.SpkCnt(:,c)));
                bs(c,ss,ts, phs) = TotBits/Par.nData*Par.InternalFreq;
                sq(bs(c,:,:,:))
            end
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
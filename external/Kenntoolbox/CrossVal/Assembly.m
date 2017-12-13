function Predictor = Assembly(Data,Par,c)
% Assembly(Data,Par,TargetCell)
% a MATLAB implementation that should do the same as Assembly.cpp
% Data and Par are as in WritePdataFile17

% make integer positions
Data.iPos = 1+floor([Data.PosX, Data.PosY]*Par.SpaceGrid);
Data.iPh = 1+floor(mod(Data.Ph,2*pi)*Par.PhGrid/2/pi);

figure(1); cla; hold off;

% find predictor cells and initialize weights to 0
PredCells = find(Par.CanPred(:,c));

if isempty(PredCells) 
    fprintf('No predictor cells');
    Out = [];
    return; 
end

for ss=1:length(Par.SpaceSm)
    for ts=1:length(Par.TimeSm)
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
% keyboard
                
            end % for cv
            fprintf('Bits/sec %f Bits/spk %f\n', TotBits/size(Data.SpkCnt,1)*Par.InternalFreq, TotBits/sum(Data.SpkCnt(:,c)));
            bs(c,ss,ts, phs) = TotBits/size(Data.SpkCnt,1)*Par.InternalFreq;
            sq(bs(c,:,:,:))
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
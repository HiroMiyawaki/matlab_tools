%EvalFit(FileBase)
if 1
% DataFile = '/home/ken/data/pdata/all/_u15_xaj_Awake_l23-02_n2.all.temporal.bpdata';
% OutFile = '/home/ken/data/pout/all/_u15_xaj_Awake_l23-02_n2.all.temporal.bpout';
% 
% DataFile = '/home/ken/data/pdata/all/_u15_xaj_Awake_l23-02_nn1.all.temporal.bpdata';
% OutFile = '/home/ken/data/pout/all/_u15_xaj_Awake_l23-02_nn1.all.temporal.bpout';

% DataFile = 'l2101f1Lo.pdata';
% OutFile = 'l2101f1Lo.pout';

DataFile = 'Siml.pdata';
OutFile = 'Siml.pout';

[Data Par1] = ReadPdataFile(DataFile);
[Out Par2] = ReadPoutFile(OutFile);
end

% make integer positions
iPos = 1+floor([Data.PosX, Data.PosY]*Par1.SpaceGrid);

cla; hold on;
for c=1:Par1.nCells
    if Par1.TetNo(c)<=0
        continue;
    end
    for ss=1:Par1.nSpaceSm
%         for ts=1:Par1.nTimeSm
        for ts=1:Par1.nTimeSm
            
%             if Par1.SpaceSm(ss)<0 %| Par1.TimeSm(ts)<0
%                 continue;
%             end
            % temporal smoothing
            sig = Par1.TimeSm(ts);
            tr = max(floor(4*sig),0); % if ts<0, use no smoothing
            b = exp(-(-tr:tr).^2/(2*sig^2));
            iSpkCnt(Data.tReal,:) = Data.SpkCnt;% NB this is indexed by tReal
            iSmSpkCnt = Filter0(b, iSpkCnt); 
            SmSpkCnt = iSmSpkCnt(Data.tReal,:); % now same indexing again.
            
            for cv=1:Par1.nCrossVal
                % extract stuff from large arrays
                Myt = find(Data.CVGroup==cv-1); % for original Data arrays
                MyPf = Out.PlaceField(:,:,c,cv,ss);
                MyWt = Out.Weight(:,c,cv,ss,ts);
                
                % mean firing rate on training set (should have been output)
                NotMine = find(Data.CVGroup~=cv-1);
%                MeanRate = sum(Data.SpkCnt(NotMine,c))/length(NotMine);
                MeanRate = sum(Data.SpkCnt(:,c))/size(Data.SpkCnt,1);
                
if 0                
                subplot(2,Par1.nCells,c)
                PFn = PFClassic([Data.PosX(NotMine) Data.PosY(NotMine)], Data.SpkCnt(NotMine, c), ...
                    Par1.SpaceSm(ss), Par1.SpaceGrid);
                imagesc(PFn); colorbar
                subplot(2,Par1.nCells,c+Par1.nCells)
                imagesc(MyPf); colorbar
                drawnow
end                
                % compute predicted firing rate
                PlaceFac = MyPf(sub2ind(Par1.SpaceGrid*[1 1], iPos(Myt,1), iPos(Myt,2)));
%                PlaceFac = MyPf(sub2ind(Par1.SpaceGrid*[1 1], iPos(Myt,2), iPos(Myt,1)));
                if sig>0
                    PopFac = exp(SmSpkCnt(Myt,:) * MyWt);
                else
                    PopFac = 1;
                end
                mu = PlaceFac .* PopFac; % predicted mean firing rate
                
                % evaluate
%                L = sum(Data.SpkCnt(Myt,c).*(log(mu)-log(MeanRate)) - (mu-MeanRate));
                L = sum( -(mu-MeanRate) + (log(mu)-log(MeanRate)).*Data.SpkCnt(Myt,c))/log(2);         
                fprintf('cell %d ss %f ts %f cv %d --> L=%f (%f as output, rat %f)\n', ...
                    c, Par1.SpaceSm(ss), Par1.TimeSm(ts), cv, L, Out.LogL(c,cv,ss,ts), L/Out.LogL(c,cv,ss,ts));
                fprintf('TestRate %g\nTrainRate %g\nMeanPF %g\nMean Mu %g\n', ...
                    sum(Data.SpkCnt(Myt,c))/length(Myt), MeanRate, mean(PlaceFac), mean(mu));
                
                figure(1); 
                hold on; plot(L, Out.LogL(c,cv,ss,ts), '.')
                figure(2); 
                clf; plot([Data.SpkCnt(Myt,c), PlaceFac*1e3]); hold on; plot(xlim, MeanRate*[1 1]*1e3);
                
                
                % compute first and second derivatives on training set
                
                % which cells predict?
                PredCells = find(Par1.TetNo>=0 & (~Par1.ExcludeSameTetrode | Par1.TetNo~=Par1.TetNo(c)));
                
                vTrain = SmSpkCnt(NotMine,PredCells);
                PlacePredTrain = MyPf(sub2ind(Par1.SpaceGrid*[1 1], iPos(NotMine,1), iPos(NotMine,2)));
                muTrain = PlacePredTrain .* exp(SmSpkCnt(NotMine,:) * MyWt);
                
                d0 = (Data.SpkCnt(NotMine,c) - PlacePredTrain)' * vTrain; % what it would be if mu = 0
                dNoRidge = (Data.SpkCnt(NotMine,c) - muTrain)' * vTrain;
                d = dNoRidge - 2 * Par1.Ridge * MyWt(PredCells)';
                
                ddNoRidge = vTrain'*sparse(1:length(NotMine),1:length(NotMine),muTrain)*vTrain;
                dd = ddNoRidge + 2*Par1.Ridge*eye(length(PredCells));
                
                fprintf('Wt:\t'); fprintf('%10.3e\t', MyWt(PredCells)); fprintf('\n');
                fprintf('d/dd:\t'); fprintf('%10.3e\t', d/dd); fprintf('\n');
                fprintf('est sd\t'); fprintf('%10.3e\t', diag(dd).^-0.5); fprintf('\n');
                fprintf('d*inv(dd)*d: \t%10.3e\n', d*inv(dd)*d');
                
                L1 = CalcL(Par1, MyPf, iPos, SmSpkCnt(:,PredCells), NotMine, MyWt(PredCells), MeanRate, Data.SpkCnt(:,c));
                L2 = CalcL(Par1, MyPf, iPos, SmSpkCnt(:,PredCells), NotMine, MyWt(PredCells)+dd\d', MeanRate, Data.SpkCnt(:,c));
                L3 = CalcL(Par1, MyPf, iPos, SmSpkCnt(:,PredCells), NotMine, MyWt(PredCells)-dd\d', MeanRate, Data.SpkCnt(:,c));
                
                fprintf('nIts %d Delta+ %10.3e Delta- %10.3e\n', Out.nIter(c,cv,ss,ts), L2-L1, L3-L1);
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
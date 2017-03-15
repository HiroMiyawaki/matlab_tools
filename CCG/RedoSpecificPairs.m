function [ExcPairs,InhPairs,GapPairs,numclu] = RedoFindPairsLS(fileinfo,cellpairs,each_nn,do_cat);

% find excitatory and inhibitory cell pairs on long and short track.
if nargin<3;
    each_nn = 1:4;
end

%% categories to consider
%% do_cat(1) = Excitatory Pairs
% % do_cat(2) = Inhibitory Pairs
% % do_cat(3) = Gap Pairs (i.e. 0 ms)

if nargin<4;
    do_cat = [1 1 1];
end

currentdir = pwd;
FileBase = [currentdir '/' fileinfo.name '/' fileinfo.name];

Par =LoadPar([FileBase '.par']); % either par or xml file needed
EegRate = Par.lfpSampleRate; % sampling rate of eeg file
SampleRate = Par.SampleRate;

one_ms = SampleRate/1000;
BinSize = one_ms;
HalfBins = 25;
alpha = .05;

jscale = 5; % units of ms
njitter = 500; % # of times to jitter

currentdir = pwd; 
directory = fileinfo.name;
FileBase = [currentdir '/' directory '/' directory];

load([FileBase '.spikeII.mat']);

INclu = unique(spike.aclu(spike.qclu==5))';
ncl = [];
for ii = INclu
    shank = spike.shank(find(spike.aclu==ii,1,'first'));
    cluster = spike.cluster(find(spike.aclu==ii,1,'first'));
    ncl = [ncl [shank;cluster;5]];
end

maxp = fileinfo.maxp;

direction = [1 -1 1 -1];
mrv = zeros(1,4);

% for nn = 3:4;
%     nonzero = find(maxp(nn,:)~=0| maxp(nn-2,:)~=0);
%     numclu{nn} = maxp([1:7],nonzero);
%     numclu{nn} = [numclu{nn} [zeros(4,size(ncl,2));ncl]];
%     numclu{nn} = [numclu{nn};1:size(numclu{nn},2)];
%     numclu{nn-2} = numclu{nn};
% end

numclu = [maxp [zeros(4,size(ncl,2));ncl]];
for ii = 1:size(numclu,2);
    numclu(8,ii) = fileinfo.maxelec{numclu(5,ii)}(numclu(6,ii));
end

spacebins = 200;

tR = -HalfBins:HalfBins;
MonoWindow1=find((tR>=1)&(tR<=5));     % Mono Window 1ms ~5ms
MonoWindow2=find((tR>=-5)&(tR<=-1));
MonoWindow3=find((tR>-1)&(tR<1));
% tt=0;
for nn = each_nn
    fprintf(['*nn=' num2str(nn) '* '])
    keepclu = [];
    ExcPairs{nn}=cellpairs.ExcPairs{nn};
    InhPairs{nn} = cellpairs.InhPairs{nn};
    GapPairs{nn} =cellpairs.GapPairs{nn};
    if ~isempty(cellpairs.ExcPairs{nn}) & do_cat(1)
        ExcPairs{nn}=[];
        fprintf(['E' num2str(size(cellpairs.ExcPairs{nn},2)) ' ']) % write updates on progress
        print_ii = round(linspace(1,size(cellpairs.ExcPairs{nn},2),5));
        print_ii = print_ii(2:end);
        for ii = 1:size(cellpairs.ExcPairs{nn},2)
            if ismember(ii,print_ii)
                fprintf(['.' num2str(ii)])
            end
            ii_keeper = cellpairs.ExcPairs{nn}([1 2],ii);
            keeper1 = find(numclu(5,:)==cellpairs.numclu(5,ii_keeper(1)) &...
                numclu(6,:)==cellpairs.numclu(6,ii_keeper(1)));
            keeper2 = find(numclu(5,:)==cellpairs.numclu(5,ii_keeper(2)) &...
                numclu(6,:)==cellpairs.numclu(6,ii_keeper(2)));
            keeper = [keeper1 keeper2];
            if isempty(keeper);
%                 ExcPairs{nn} = 'INVALID: PLEASE REDO FINDPAIRS';
%                 InhPairs{nn} = 'INVALID: PLEASE REDO FINDPAIRS';
                continue
            end
            for cc = keeper;
                shank = numclu(5,cc);
                cluster = numclu(6,cc);
%                 pmap = squeeze(fileinfo.pmat{shank}(cluster,nn,:));
%                 peak = find(pmap==max(pmap),1,'first');
%                 lesspeak = find(pmap<=0.1*max(pmap));
%                 ilp = find(lesspeak<peak,1,'last');
%                 edgein = lesspeak(ilp);
%                 ilp = find(lesspeak>peak,1,'first');
%                 edgeout = lesspeak(ilp);

                cc_keep = find(spike.shank==shank & spike.cluster==cluster ...
                    & spike.traj==nn & spike.speed>2);
%                     & spike.x>=(edgein-1)/spacebins & spike.x<=(edgeout-1)/spacebins ...
%                     ); % ...

                keepclu = [keepclu; [cc_keep cc*ones(size(cc_keep))]];
            end
%             keepclu = sortrows(keepclu);
            res = [spike.t(keepclu(:,1)) keepclu(:,2)];

            
            [GSPE,GSPI,pvalE,pvalI]=CCG_jitter(res(res(:,2)==keeper1,1),res(res(:,2)==keeper2,1),SampleRate,BinSize,HalfBins,jscale,njitter,alpha,0);
%             tt = tt+1;fprintf(num2str(tt));
%             if tt==27
%                 keyboard
%             end
            if any(GSPE(MonoWindow1)==1)
                ExcPairs{nn} = [ExcPairs{nn} [keeper';numclu([5 6],keeper1);numclu([5 6],keeper2);min(pvalE(MonoWindow1))]];
            elseif any(GSPE(MonoWindow2)==1)
                ExcPairs{nn} = [ExcPairs{nn} [keeper([2 1])'; numclu([5 6],keeper2);numclu([5 6],keeper1);min(pvalE(MonoWindow2))]];
            end
        end
    end
    if ~isempty(cellpairs.GapPairs{nn}) & do_cat(3)
        GapPairs{nn}=[];
        fprintf(['G' num2str(size(cellpairs.GapPairs{nn},2)) ' '])
        print_ii = round(linspace(1,size(cellpairs.GapPairs{nn},2),5));
        print_ii = print_ii(2:end);
        for ii = 1:size(cellpairs.GapPairs{nn},2)
            if ismember(ii,print_ii)
                fprintf(['.' num2str(ii)])
            end
            ii_keeper = cellpairs.GapPairs{nn}([1 2],ii);
            keeper1 = find(numclu(5,:)==cellpairs.numclu(5,ii_keeper(1)) &...
                numclu(6,:)==cellpairs.numclu(6,ii_keeper(1)));
            keeper2 = find(numclu(5,:)==cellpairs.numclu(5,ii_keeper(2)) &...
                numclu(6,:)==cellpairs.numclu(6,ii_keeper(2)));
            keeper = [keeper1 keeper2];
            if isempty(keeper);
                continue
            end
            for cc = keeper;
                shank = numclu(5,cc);
                cluster = numclu(6,cc);
%                 pmap = squeeze(fileinfo.pmat{shank}(cluster,nn,:));
%                 peak = find(pmap==max(pmap),1,'first');
%                 lesspeak = find(pmap<=0.1*max(pmap));
%                 ilp = find(lesspeak<peak,1,'last');
%                 edgein = lesspeak(ilp);
%                 ilp = find(lesspeak>peak,1,'first');
%                 edgeout = lesspeak(ilp);

                cc_keep = find(spike.shank==shank & spike.cluster==cluster ...
                    & spike.traj==nn & spike.speed>2 );
%                     & spike.x>=(edgein-1)/spacebins & spike.x<=(edgeout-1)/spacebins...


                keepclu = [keepclu; [cc_keep cc*ones(size(cc_keep))]];
            end
%             keepclu = sortrows(keepclu);
            res = [spike.t(keepclu(:,1)) keepclu(:,2)];

            [GSPE,GSPI,pvalE,pvalI]=CCG_jitter(res(res(:,2)==keeper1,1),res(res(:,2)==keeper2,1),SampleRate,BinSize,HalfBins,jscale,njitter,alpha,0);
            if any(GSPE(MonoWindow3)==1)
                GapPairs{nn} = [GapPairs{nn} [keeper';numclu([5 6],keeper1);numclu([5 6],keeper2);min(pvalE(MonoWindow3))]];
            end
        end
    end
    if ~isempty(cellpairs.InhPairs{nn}) & do_cat(2)
        InhPairs{nn}=[];
        fprintf(['I' num2str(size(cellpairs.InhPairs{nn},2)) ' '])
        print_ii = round(linspace(1,size(cellpairs.InhPairs{nn},2),5));
        print_ii = print_ii(2:end);
        for ii = 1:size(cellpairs.InhPairs{nn},2)
            if ismember(ii,print_ii)
                fprintf(['.' num2str(ii)])
            end
            ii_keeper = cellpairs.InhPairs{nn}([1 2],ii);
            keeper1 = find(numclu(5,:)==cellpairs.numclu(5,ii_keeper(1)) &...
                numclu(6,:)==cellpairs.numclu(6,ii_keeper(1)));
            keeper2 = find(numclu(5,:)==cellpairs.numclu(5,ii_keeper(2)) &...
                numclu(6,:)==cellpairs.numclu(6,ii_keeper(2)));
            keeper = [keeper1 keeper2];
            if isempty(keeper);
%                 ExcPairs{nn} = 'INVALID: PLEASE REDO FINDPAIRS';
%                 InhPairs{nn} = 'INVALID: PLEASE REDO FINDPAIRS';
                continue
            end
            for cc = keeper;
                shank = numclu(5,cc);
                cluster = numclu(6,cc);
%                 pmap = squeeze(fileinfo.pmat{shank}(cluster,nn,:));
%                 peak = find(pmap==max(pmap),1,'first');
%                 lesspeak = find(pmap<=0.1*max(pmap));
%                 ilp = find(lesspeak<peak,1,'last');
%                 edgein = lesspeak(ilp);
%                 ilp = find(lesspeak>peak,1,'first');
%                 edgeout = lesspeak(ilp);

                cc_keep = find(spike.shank==shank & spike.cluster==cluster ...
                    & spike.traj==nn & spike.speed>2 );
%                     & spike.x>=(edgein-1)/spacebins & spike.x<=(edgeout-1)/spacebins...
%                     );% ...

                keepclu = [keepclu; [cc_keep cc*ones(size(cc_keep))]];
            end
%             keepclu = sortrows(keepclu);
            res = [spike.t(keepclu(:,1)) keepclu(:,2)];

            [GSPE,GSPI,pvalE,pvalI]=CCG_jitter(res(res(:,2)==keeper1,1),res(res(:,2)==keeper2,1),SampleRate,BinSize,HalfBins,jscale,njitter,alpha,0);
            if any(GSPI(MonoWindow1)==1)
                InhPairs{nn} = [InhPairs{nn} [keeper';numclu([5 6],keeper1);numclu([5 6],keeper2);min(pvalI(MonoWindow1))]];
            elseif any(GSPI(MonoWindow2)==1)
                InhPairs{nn} = [InhPairs{nn} [keeper([2 1])';numclu([5 6],keeper2);numclu([5 6],keeper1);min(pvalI(MonoWindow2))]];
            end
        end
    end
end

return

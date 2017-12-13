%function Spikes2Spikes(FileBase,Overwrite, States,El)
% Computes the CCG for spikes of each electrode
function s2s = Spikes2Spikes(FileBase,varargin)

par = LoadPar([FileBase '.xml']);
[Overwrite,Periods,El] = DefaultArgs(varargin,{1, {'REM','SWS','RUN'},[1:par.nElecGps]});

EegFs = par.lfpSampleRate; %GetEegFs(FileBase);
SpikesFs = 1e6/par.SampleTime;
SaveFn = [FileBase '.s2s'];
if ~FileExists(SaveFn) | Overwrite
   [ Res,Clu,Map ] = LoadCluRes(FileBase,El);
%    [Res,Clu,nClu,dummy, ClustByEl, cID] = ReadEl4CCG(FileBase, El);
    uClu = unique(Clu);
    nClu = length(uClu);
    nBins = 50;
    nPeriods = length(Periods);
    s2s.ccg =zeros(2*nBins+1,nClu,nClu,nPeriods+1);
    if nPeriods>0
        for where = 1:nPeriods %loop through states

            Segments = SelectStates(FileBase, Periods{where},EegFs*2);
            if isempty(Segments)
                fprintf('State : %s - NONE\n',Periods{where});
                continue;
            end
            Segments = round(Segments/EegFs*SpikesFs);
            Focus = WithinRanges(Res, Segments);
            Focus = (Focus==1); % make it logical to use fast subscription

            %select spikes that are in that State
            myuClu = unique(Clu(Focus));
            mynClu = length(myuClu);

            myClu = find(ismember(uClu,myuClu)); %indexes of clusters that come into CCG computation (present in this state)
            fprintf('State : %s - PROCESSING\n',Periods{where});

            if nClu>0
                %  fprintf('Coh/Spectra btw eeg and cells from electrodes %s\n', num2str(El(:)'));

                if ~isempty(myClu)
                    [ccg, t] = CCG(Res(Focus), Clu(Focus), round(SpikesFs/1000), nBins, SpikesFs, myuClu, 'count');
                    %                       keyboard
                    s2s.ccg(:,myClu,myClu,where) = ccg;
                    
                end
            end
        end% end of loop over the field
    else
        where=0;
    end
    [ccg, t] = CCG(Res, Clu, round(SpikesFs/1000), nBins, SpikesFs, uClu, 'count');
    s2s.ccg(:,:,:,where+1) = ccg;
    s2s.tbin =t;
%    s2s.cID = cID(myClu);
    s2s.ElClu = Map(:,2:3);
    s2s.State = Periods;
    save(SaveFn,'s2s','-v6');

elseif nargout>0
    load(SaveFn,'-MAT');
end


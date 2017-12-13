%function [ChanNumbers Elec] =  GetChannels(FileBase, ChanLabels, WhichParFile)
function [ChanNumbers, el] = GetChannels(FileBase, varargin)
[ChanLabels, WhichParFile ] = DefaultArgs(varargin,{{'c'}, 'eeg.par'});
par = LoadPar([FileBase '.par']);
NonSkipped =[1:par.nChannels];% NonSkippedChannels(FileBase);
if iscell(ChanLabels)
    nChans = length(ChanLabels);
    ChanNumbers =[];

    switch WhichParFile
        case 'eegseg.par'

            % this file has by default: CA1, cx, DG channels (starting from 0)
            tmpChans = load([FileBase '.eegseg.par'])
            for i=1:nChans
                if strcmp(ChanLabels{i},'h1')
                    ChanNumbers(i)=tmpChans(1)+1;
                else %assume cortex
                    ChanNumbers(i)=tmpChans(2)+1;
                end
            end
        case 'eeg.par'
            % use the eeg.par file that has all the lines that .par has
            % at the end (for each electrode) there is a label of where it is (c-cx,h1-CA1,h2-DG)
            for i =1:nChans
                el  = find(strcmp(par.ElecLoc,ChanLabels{i}));
                if ~isempty(el)
                    nEl = length(el);
                    for j=1:nEl
                        allch = par.ElecGp{el(j)}+1;
                        goodch = intersect(allch, NonSkipped);
                        ChanNumbers(end+1)  = goodch(1);
                    end
                else
                    fprintf('no channel for location %s\n', ChanLabels{i});
                end
            end
    end

elseif isstr(ChanLabels)
    switch WhichParFile
        case 'eegseg.par'
            % this file has by default: CA1, cx, DG channels (starting from 0)

            tmpChans = load([FileBase '.eegseg.par']);
            if strcmp(ChanLabels,'h1')
                ChanNumbers=tmpChans(1)+1;
            else %assume cortex
                ChanNumbers=tmpChans(2)+1;
            end

        case 'eeg.par'

            el  = find(strcmp(par.ElecLoc,ChanLabels));
            ChanNumbers =[];
            if ~isempty(el)
                nEl = length(el);
                for j=1:nEl
                    allch = par.ElecGp{el(j)}+1;
                    %		goodch = intersect(allch, NonSkipped);
                    %		ChanNumbers(end+1)  = goodch(1);
                    ChanNumbers(end+1) = allch(1);
                end
            else
                fprintf('no channel for location %s\n', ChanLabels{i});
            end
    end
else
    ChanNumbers = ChanLabels;
end



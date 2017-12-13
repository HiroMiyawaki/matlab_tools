% A script that repeatedly calls CreatePdataFile

%%%%%%%%%%%%%%%%%%
%%% PARAMETERS %%%
%%%%%%%%%%%%%%%%%%

% SpaceSm = [-1 .05];
SpaceSm = 0.05;
% TimeSm = [-1 2.^[-1:7]];
% TimeSm = [-1 2.^[-1:.5:8]];
TimeSm = [-1 8];
PhSm = [-1 0 .05];
% PhSm = -1;
nCrossVal = 10;

Desc = 'phase';
% 1: everything. 2: no ripples.  3: theta only.
Mode = 3;
% .pdata or .bpdata - bpdata is reversed byte order for ibm or sun.
Suffix = '.pdata';
Description = {'Run', 'George', '64trode'};
db = 'extra'; % which ones to do

%%%%%%%%%%%%%%%%%
%%% MAIN CODE %%%
%%%%%%%%%%%%%%%%%

% [FileBases Types] = mysql('SELECT FileBase, Description FROM Files', 'extra', '%s %s');
%[FileBases Types] = mysql('SELECT FileBase, Description FROM Files WHERE FileBase LIKE "%eorge%"', 'extra', '%s %s');
FileBases = RetrieveFileBases(Description, db);
for i=1:length(FileBases)
%for i=96
    FileBase = FileBases{i};
    if FileExists([FileBase '.whl'])
        % what file to write to?
        DataFile = FileBase;
        DataFile(find(DataFile=='/')) = '_';

        switch Mode
        case 1
            DataFile = ['/u5/b/ken-data/pdata/all/' DataFile '.all.' Desc Suffix];
            InEpochs = {}; OutEpochs = {};
        case 2 
            DataFile = ['/u5/b/ken-data/pdata/no_spw/' DataFile '.no_spw.' Desc Suffix];
            InEpochs = {}; OutEpochs = {'Ripple'};            
        case 3
            DataFile = ['/u5/b/ken-data/pdata/theta_only/' DataFile '.theta_only.' Desc Suffix];
            InEpochs = {'Theta'}; OutEpochs = {};
        end

        if FileExists(DataFile) continue; end
        
        fprintf('Making %s\n', DataFile);
                
        [Data Par] = CreatePdataFile17(FileBase, DefaultPPar17, InEpochs, OutEpochs);
        Par.SpaceSm = SpaceSm;
        Par.TimeSm = TimeSm;
        Par.PhSm = PhSm;
        Par.ExcludeSameTetrode=2;
        
        WritePdataFile17(DataFile, Data, Par);

    end
end
return

        
    
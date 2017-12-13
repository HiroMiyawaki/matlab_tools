% A script that repeatedly calls CreatePdataFile

%%%%%%%%%%%%%%%%%%
%%% PARAMETERS %%%
%%%%%%%%%%%%%%%%%%

SpaceSm = [-1 .05];
TimeSm = [-1 2.^[-1:7]];
%TimeSm = -1;
PhSm = [-1 0 .05];
nCrossVal = 10;

% 1: everything. 2: no ripples.  3: theta only.
Mode = 3;
% .pdata or .bpdata - bpdata is reversed byte order for ibm or sun.
Suffix = '.pdata';
Description = '64trode'; 
%Description = {'Run', 'George'};
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
            DataFile = ['/u5/b/ken-data/pdata/all/' DataFile '.all.temporal' Suffix];
            InEpochs = {}; OutEpochs = {};
        case 2 
            DataFile = ['/u5/b/ken-data/pdata/no_spw/' DataFile '.no_spw.temporal' Suffix];
            InEpochs = {}; OutEpochs = {'Ripple'};            
        case 3
            DataFile = ['/u5/b/ken-data/pdata/theta_only/' DataFile '.theta_only.temporal' Suffix];
            InEpochs = {'Theta'}; OutEpochs = {};
        end

        if FileExists(DataFile) continue; end
        
        fprintf('Making %s\n', DataFile);
                
        [Data Par] = CreatePdataFile(FileBase, DefaultPPar, InEpochs, OutEpochs);
        Par.SpaceSm = SpaceSm;
        Par.TimeSm = TimeSm;
        Par.PhSm = PhSm;
        WritePdataFile(DataFile, Data, Par);

    end
end
return

        
    
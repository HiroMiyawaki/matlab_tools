
function [] = writemulti(fname,eeg)
% write back to eeg file

if size(eeg,1)>size(eeg,2);
    eeg = eeg';
end

filetype = fname(end-2:end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SAVE OLD EEG FILE
if ~FileExists([fname '.bak'])
    fprintf(['saving old ' fname ' data...\n']);
    com = ['mv ' fname ' ' fname '.bak'];
    system(com);
end

datafile = fopen(fname,'w');
fwrite(datafile,eeg,'int16');
fclose(datafile);

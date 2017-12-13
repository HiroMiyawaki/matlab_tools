function [returnVar,msg] = modifyDat(dat_fname,bak_fname, n_ch,no_backup)

% USAGE:
%     modifyDat(dat_fname)
%     modifyDat(dat_fname,bak_fname)
%     modifyDat(dat_fname,bak_fname, n_ch)
%     modifyDat(dat_fname,bak_fname, n_ch,no_backup)
%
%     This function makes back up of dat file and then
%     removes DC from the given files by computing the average of
%     the first 1e6 samples (or less if file is smaller)
%
% INPUTS:
%     dat_fname: .dat file name
%     bak_fname (optional): back up file name (default: {dat_fname}.bak)
%     n_ch(optional): total number of channels in dat file. 
%                     when it's not given or set 0, the number is obtained from .meta file
%     no_backup(optional): set 1 if you don't want to make back up 
%     
% 
% Adrien Peyrache 2011, edits by MvdM 2013
% Modified by Hiro Miyawaki 2017


str={
 ' '
 ' '
 'modifyDat'
 '  This function makes back up of dat file and then'
 '  removes DC from the given files by computing the average of'
 '  the first 1e6 samples (or less if file is smaller)'
 ' '
 '  USAGE:'
 '    modifyDat dat_fname'
 '    modifyDat dat_fname bak_fname'
 '    modifyDat dat_fname bak_fname n_ch'
 '    modifyDat dat_fname bak_fname n_ch no_backup'
 '  INPUTS:'
 '    dat_fname: .dat file name'
 '    bak_fname(optional): back up file name (default: {dat_fname}.bak)'
 '    n_ch(optional): total number of channels in dat file. '
 '                    when it''s not given or set 0, the number is obtained from .meta file'
 '    no_backup(optional): set 1 if you don''t want to make back up '
 ' '};


if ~exist('dat_fname','var')
    for idx=1:length(str)
        display(str{idx})
    end
    return
end

%check files
if ~strcmpi(dat_fname(end-3:end),'.dat')
   error('extension must be .dat'); 
end    

if ~exist(dat_fname,'file')
   error('%s not found',dat_fname); 
end

%when nbChan is not given
if ~exist('nbChan','var') || n_ch==0
    % first load .meta file
    meta_fname = [dat_fname(1:end-3),'meta'];

    if ~exist(meta_fname,'file')
       error('%s not found',meta_fname); 
    end

    keys = {'Amplitude range max', ...
            'Amplitude range min', ...
            'File length (Amplipex clock (sec)', ...
            'File size (bytes)', ...
            'TimeStamp of the end of recording (computer clock - ms)', ...
            'TimeStamp of the start of recording (computer clock - ms)', ...
            'Number of recorded channels', ...
            'Recording start date', ...
            'Recording start time', ...
            'Sampling rate', ...
            'Sha1 code for file'};

    values = {'range1_volts', ...
              'range2_volts', ...
              'filelength_sec', ...
              'filesize_bytes', ...
              'end_timestamp', ...
              'start_timestamp', ...
              'nChannels', ...
              'date', ...
              'time', ...
              'Fs', ...
              'SHA1'};

    fid = fopen(meta_fname);

    if fid == -1
       error('Could not open %s',meta_fname); 
    end

    hdr = [];
    iL = 1;
    while 1

       line = fgetl(fid);
       if line == -1
           break;
       end

       hdr.raw{iL} = line;
       iL = iL + 1;

       tokens = regexp(line,'(.*)=(.*)','tokens');
       tokens = strtrim(tokens{1});

       if ~isnan(str2double(tokens{2})) % check if convertible to numeric
           tokens{2} = str2double(tokens{2});
       end

       for iK = 1:length(keys)

           idx = strmatch(tokens{1},keys); % check if this key is on the list

           if ~isempty(idx) % on list, replace
               hdr = setfield(hdr,values{idx},tokens{2});
           else % not on list, use literally
               hdr = setfield(hdr,tokens{1},tokens{2});
           end

       end

    end

    fclose(fid);

    if ~isfield(hdr,'nChannels')
       error('Field ''nChannels'' is not in %s',meta_fname); 
    end

    n_ch = hdr.nChannels;
end

infoFile = dir(dat_fname);
if mod(infoFile.bytes,n_ch*2)~=0
    error('Size of %s does not match with number of channels (%d channels)',dat_fname,n_ch)
end
    
if ~exist('no_backup','var') || no_backup~=1
    if ~exist('bak_fname','var')
        bak_fname=[dat_fname '.bak'];
    end

    if exist(bak_fname,'file')
        n=1;
        while exist([bak_fname num2str(n)],'file')
            n=n+1;
        end
        bak_fname=[bak_fname num2str(n)];
    end

    fprintf([datestr(now) ' Back up %s as %s\n'],dat_fname,bak_fname)

    [status,message]=copyfile(dat_fname,bak_fname);

    if status~=1 || ~isempty(message)
        error('failed to back up: %s',message)
    end
    fprintf('Back up was done\n\n')
end

fprintf('Removing baseline from %s\n',dat_fname)
%try
    
    chunk = 1e6;
    nbChunks = floor(infoFile.bytes/(n_ch*chunk*2));
    warning off
    if nbChunks==0
        chunk = infoFile.bytes/(n_ch*2);
    end
    m = memmapfile(dat_fname,'Format','int16','Repeat',chunk*n_ch,'writable',true);
    d = m.Data;
    d = reshape(d,[n_ch chunk]);
    meanD = mean(d,2);
    d = d-int16(meanD*ones(1,chunk));
    m.Data = d(:);
    clear d m
    
    for ix=1:nbChunks-1
    %    h=waitbar(ix/(nbChunks-1));
        fprintf([datestr(now) ' %d / %d chunks\n'], ix,nbChunks-1)
        m = memmapfile(dat_fname,'Format','int16','Offset',ix*chunk*n_ch*2,'Repeat',chunk*n_ch,'writable',true);
        d = m.Data;
        d = reshape(d,[n_ch chunk]);
        d = d-int16(meanD*ones(1,chunk));
        m.Data = d(:);
        clear d m
    end
    
    
    newchunk = infoFile.bytes/(2*n_ch)-nbChunks*chunk;
    if newchunk
        m = memmapfile(dat_fname,'Format','int16','Offset',nbChunks*chunk*n_ch*2,'Repeat',newchunk*n_ch,'writable',true);
        d = m.Data;
        d = reshape(d,[n_ch newchunk]);
        d = d-int16(meanD*ones(1,newchunk));
        m.Data = d(:);
     clear d m
    end
    warning on
    returnVar = 1;
    msg = '';
    
%catch
%    keyboard
%    returnVar = 0;
%    msg = lasterr; 
%end
clear m


function [res] = cleanbycluHM(electrodes,bad_ones);

% function is to remove zero and 1, noise and artifact clusters from the
% res clu fet and spk files.  In particular, it is designed to handle very
% large files, one data chunk at at time.
[fName, dName, loadFlag] = uigetfile( {'*.clu.*','clu file (*.clu.*)'; '*','any file (*)'}, 'select clu file');
[dName,fName]=fileparts(fullfile(dName,fName));
[dName,fName]=fileparts(fullfile(dName,fName));
FileBase =fullfile(dName,fName);


for electrode = electrodes;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% SAVE OLD res FILE
    if ~FileExists([FileBase '.res.bak.' num2str(electrode)])
            fprintf('save old res/clu/fet data...\n');
            com = ['mv ' FileBase '.res.' num2str(electrode) ' ' FileBase '.res.bak.' num2str(electrode)];
            system(com);
            com = ['mv ' FileBase '.clu.' num2str(electrode) ' ' FileBase '.clu.bak.' num2str(electrode)];
            system(com);
            com = ['mv ' FileBase '.fet.' num2str(electrode) ' ' FileBase '.fet.bak.' num2str(electrode)];
            system(com);
            com = ['mv ' FileBase '.spk.' num2str(electrode) ' ' FileBase '.spk.bak.' num2str(electrode)];
            system(com);
    else
        reply = input('Warning!!  Writing over previous res/clu/fet/spk files.  Continue?')
        if ~isempty(reply)
            return
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% READ IN RES FILE

    clu = [LoadClu([FileBase '.clu.bak.' num2str(electrode)])];
    good = find(~ismember(clu,bad_ones));
    SaveClu([FileBase '.clu.' num2str(electrode)],clu(good));

    res = Loadres([FileBase '.res.bak.' num2str(electrode)]);
    fprintf('save in new res data...');
    Saveres([FileBase '.res.' num2str(electrode)],res(good));
    clear res
    
%     fprintf('load in fet data...');
%     [fet, nfet] = LoadFet([FileBase '.fet.bak.' num2str(electrode)]);  
%     fprintf('save in new fet data...');
%     SaveFet([FileBase '.fet.' num2str(electrode)],fet(good,:));
%     clear fet
    
    fprintf('\n save in new fet data');
    CHUNK = min([200000 length(clu)]);
    BEGIN_AT = 0;
    
    fp = fopen([FileBase '.fet.bak.' num2str(electrode)]);nFet = fscanf(fp, '%d', 1);
    
    formatstring = '%d';
    for ii=2:nFet
        formatstring = [formatstring,'\t%d'];
    end
    formatstring = [formatstring,'\n'];
    
    fw = fopen([FileBase '.fet.' num2str(electrode)], 'w');fprintf(fw, '%d\n', nFet);
    spikes_left = 1;
    while spikes_left;
        fprintf('...');
%         status = fseek(fp,BEGIN_AT*nFet*2 , 'bof');
%         if (status == -1) ferror(fp); end;
        % 	load in wave form
        this_good = good(find(good>BEGIN_AT & good<=CHUNK))-BEGIN_AT;
     	fet = fscanf(fp, '%f', [nFet, (CHUNK-BEGIN_AT)])';
        
        fprintf(fw, formatstring,round(fet(this_good,:)'));
        
        % for next step
        BEGIN_AT = CHUNK;
        spikes_left = max([0 length(clu)-CHUNK]);
        CHUNK = min([CHUNK+200000 length(clu)]);
    end
    clear fet
    fclose(fp);
    fclose(fw);
       
    fprintf('\n save in new spk data');
    nChannels = 8;
    %SpkSampls = 32;54;
    SpkSampls = 30;
    CHUNK = min([200000 length(clu)]);
    BEGIN_AT = 0;
    
    fp = fopen([FileBase '.spk.bak.' num2str(electrode)]);
    fw = fopen([FileBase '.spk.' num2str(electrode)], 'w');
    spikes_left = 1;
    while spikes_left;
        fprintf('...');
        status = fseek(fp, BEGIN_AT*nChannels*SpkSampls*2, 'bof');
        if (status == -1) ferror(fp); end;
        % 	load in wave form
        this_good = good(find(good>BEGIN_AT & good<=CHUNK))-BEGIN_AT;
     	spk = fread(fp, [nChannels, (CHUNK-BEGIN_AT)*SpkSampls], 'short=>single');
        nSpikes = size(spk, 2)/SpkSampls;
        spk = reshape(spk, [nChannels, SpkSampls, nSpikes]);

        fwrite(fw, spk(:,:,this_good), 'short');
        
        % for next step
        BEGIN_AT = CHUNK;
        spikes_left = max([0 length(clu)-CHUNK]);
        CHUNK = min([CHUNK+200000 length(clu)]);
    end
    clear spk
    fclose(fp);
    fclose(fw);
    fprintf('\n');
% for ii=1:nSpikes2Load
% 
% 	go to correct part of file	
% 	status = fseek(fp, (Spikes2Load(ii)-1)*nChannels*SpkSampls*2, 'bof');
% 	if (status == -1) ferror(fp); end;
% 
% 	load in wave form
% 	Spk(:,:,ii) = fread(fp, [nChannels, SpkSampls], 'short=>single');
% end;

end
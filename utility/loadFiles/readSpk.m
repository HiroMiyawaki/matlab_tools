function Spk = readSpk(FileName, nCh, smpPerSpk)

    fh = fopen(FileName);
    Spk = fread(fh, [nCh, Inf],'int16');
    fclose(fh);
    
    nSpikes = size(Spk, 2)/smpPerSpk;

    Spk = reshape(Spk, [nCh, smpPerSpk, nSpikes]);
end


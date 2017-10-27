function Waves=loadWaveForm(FileBase,Shank,Clu,NchPerShank,NsplPerSpk,ReadEvery)

    if(nargin<6)
        ReadEvery=1;
    end
    
    display([datestr(now) '   loading *.clu file'])
    fh = fopen([FileBase,'.clu.' num2str(Shank)], 'r');
    nClusters = fscanf(fh, '%d', 1);
    clu = fscanf(fh, '%d');
    
    fclose(fh);


        
    list=find(clu==Clu)';
    
    readList=list(1:ReadEvery:(floor(size(list,2)/ReadEvery)*ReadEvery));
    
    skip=diff([0,readList])-1;

    display([datestr(now) '   loading *.spk file'])
    fh = fopen([FileBase,'.spk.',num2str(Shank)]);

    Waves=[];
    for n=1:size(readList,2);
        fseek(fh,skip(n)*NchPerShank*NsplPerSpk*2,'cof');
        Waves(n,:,:) = fread(fh, [NchPerShank, NsplPerSpk],'int16');
    end

    fclose(fh);
end
% 
% nCh=size(basics.SpkGrps(shank).Channels,2);
% smpPerSpk=basics.SpkGrps(shank).nSamples;


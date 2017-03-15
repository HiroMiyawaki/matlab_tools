%function data = LoadBinary(FileName, Channels, nChannels, method, intype, outtype, Periods)
% Channels - list of channels to load starting from 1
% nChannels - number of channels in a file, will be read from par/xml file
% if present
% intype/outtype - data types in the file and in the matrix to load to
% by default assume input file is eeg/dat = int16 type (short int), and
% output is single (to save space) unless it is version 6.5 that cannot
% handle single type
function data = LoadBinary(FileName, Channels, varargin)

if ~FileExists(FileName)
    error('File %s does not exist or cannot be open\n',FileName);
end

lastdot =strfind(FileName,'.');
FileBase=FileName(1:lastdot(end)-1);

if FileExists([FileBase '.xml']) || FileExists([FileBase '.par'])
    Par = LoadPar([FileBase '.par']);
    nChannels = Par.nChannels;
else
    nChannels = 0;
end
[nChannels, method, intype, outtype,Periods] = DefaultArgs(varargin,{nChannels,2,'int16','single',[]});

if ~nChannels error('nChannels is not specified and par/xml file is not present'); end

ver = version; ver = str2num(ver(1));
if ver<7 outtype ='double';end

PrecString =[intype '=>' outtype];
fileinfo = dir(FileName);
% get file size, and calculate the number of samples per channel
nSamples = ceil(fileinfo(1).bytes /datatypesize(intype) / nChannels);
filept = fopen(FileName,'r');


%have not fixed the case of method 1 for periods extraction
if ~isempty(Periods)
    method=3;
    data = single(zeros(length(Channels), sum(diff(Periods,1,2)))+size(Periods,1));
else
    data = single(zeros(length(Channels), nSamples));
end

switch method
    case 1

        %compute continuous patches in chselect
        %lazy to do circular continuity search - maybe have patch [nch 1 2 3]
        %sort in case somebody didn't
        [Channels ChanOrd]= sort(Channels(:)');
        dch = diff([Channels(1) Channels]);
        PatchInd = cumsum(dch>1)+1;
        PatchLen = hist(PatchInd,unique(PatchInd));
        PatchSkip = (nChannels - PatchLen)*datatypesize(intype);
        nPatch = length(unique(PatchInd));


        for ii=1:nPatch
            patchch = find(PatchInd==ii);
            patchbeg = Channels(patchch(1));
            PatchPrecString = [num2str(PatchLen(ii)) '*' PrecString];
            fseek(filept,(patchbeg-1)*datatypesize(intype),'bof');

            data(patchch,:) = fread(filept,[PatchLen(ii) nSamples],PatchPrecString,PatchSkip(ii));

        end
        Data = Data(ChanOrd,:);

        
    case 2 %old way - buffered
        buffersize = 4096;
        numel=0;
        numelm=0;
        while ~feof(filept) 
            if numel==nSamples break; end
            [tmp,count] = fread(filept,[nChannels,min(buffersize,nSamples-numel)],PrecString);
            numelm = count/nChannels;
            data(:,numel+1:numel+numelm) = tmp(Channels,:);
            numel = numel+numelm;

        end
        
    case 3 % for periods extraction
        nPeriods = size(Periods,1);
        numel=0;
        for ii=1:nPeriods
            Position = (Periods(ii,1)-1)*nChannels*datatypesize(intype);
            ReadSamples = diff(Periods(ii,:))+1;
            fseek(filept, Position, 'bof');
            
            [tmp count]= fread(filept, [nChannels, ReadSamples], PrecString);
            if count/nChannels ~= ReadSamples
                error('something went wrong!');
            end
            numelm = count/nChannels;
            data(:,numel+1:numel+numelm) = tmp(Channels,:);
            numel = numel+numelm;

        end

end
fclose(filept);




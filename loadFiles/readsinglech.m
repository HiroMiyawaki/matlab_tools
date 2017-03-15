% reads 1 channel recording to a matrix
% function [data1] = readsinglech(fname,numch,chselect,dattype,nsamples)
% algorithm:  1.  check file size
%             2.  calculate the length of a single channel
%             recording
%             3.  make vector of such a length filled with zeros.
%             4.  read file - buffer by buffer and assign the data
%                 to the vector

function [data1] = readsinglech(fname,numch,chselect,varargin)

verbose_mode = 0;

[dattype,nsamples, method] = DefaultArgs(varargin,{'int16',inf,1});


if method==1
    % the real buffer will be buffersize * numch * 2 bytes
    % (short = 2bytes)
    %  if nargin<4 | isempty(dattype)
    %       dattype = 'int16';
    %  end
    buffersize = 4096;

    % get file size, and calculate the number of samples per channel
    fileinfo = dir(fname);
    numel = ceil(fileinfo(1).bytes / 2 / numch);

    datafile = fopen(fname,'r');

    mmm = sprintf('%d elements',numel);
    verdisp(mmm,verbose_mode);

    data1=zeros(1,numel);
    numel=0;
    numelm=0;
    
    while ~feof(datafile),
        [data,count] = fread(datafile,[numch,buffersize],dattype);

    if ~isempty(data);        
%             keyboard
%     else
%         size(data,2)~<buffersize;
        numelm = count/numch;        
        data1(numel+1:numel+numelm) = data(chselect,:);
        numel = numel+numelm;
        if numel>=nsamples
            data1 = data1(1:nsamples);
            break;
        end
    end    
    end
    fclose(datafile);

    if (mean(data1)>2000)
        data1=data1-2048;
    end

else
    data1 = LoadBinary(fname,chselect);
end



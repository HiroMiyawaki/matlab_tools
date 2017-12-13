%function out = PointFFT( Tapers, Res, Clu, nClu, CluInd, nFFT, Fs, MinSpikes,f)
% computes the FFT of the the point process given by Res and Clu
% convolved by Tapers (Time x nTapers)
% output is the FFT matrix of size nFFT x nTapers x nClu
% where nClu is number of clusters
% does the bias correction as in Jarvis and Mitra, 2000
function out = PointFFT( Tapers, Res, Clu, nClu, CluInd, nFFT, Fs, MinSpikes,f)
if nargin<3 | length(Clu)<2
    Clu = 1;
end
method = 2; %CURRENT METHOD
Tapers = Tapers*sqrt(Fs);
nTapers = size(Tapers,2);
nT = size(Tapers,1);
H = fft(Tapers,nFFT);
if method ==1
    %this was early attempt - many things are unclear or wrong
    tmp = repmat(Tapers(Res, :), [1, 1, nFFT]);
    expmultiply = exp(-j*2*pi*[1:nFFT]'*Res(:)')./nFFT;
    expmultiply = permute(repmat(expmultiply, [1 1 nCh]), [2 3 1]);
    tmp = tmp .* expmultiply; % time x tapers x nFFT
    
    %now separate by Clu
    if nClu > 1
        for c = 1:nClu
            thisclu = find(Clu==CluInd(c));
            out(:,:,c) = sq(mean(tmp(thisclu, :, :),1))' - length(thisclu)*H/nT;
        end
    else
        out = sq(mean(tmp,1))';
    end
elseif method ==2
    for c = 1:nClu
        thisclu = find(Clu==CluInd(c));
        if length(thisclu)<MinSpikes
            out(:,:,c) = zeros(nFFT, size(Tapers,2));
        else
            thisres  = Res(thisclu);  
            dN = Accumulate(thisres, 1, nT);  %%% spike train of 0's and 1's
            dN = repmat( dN(:), [ 1 nTapers]);
            out(:,:,c) = fft(dN .* Tapers, nFFT) - repmat(mean(dN),nFFT,1) .* H;
        end
    end
elseif method==3
    dN = sparse(Res,Clu,1,nT,nClu);
    for t=1:nTapers
        out(:,:,t) = fft(dN .* repmat(Tapers(:,t),1,nClu), nFFT) - repmat(full(mean(dN)),nFFT,1) .* H;
    end
    out = permute(out,[1 3 2]);
   
elseif method==4
    %implement it the same way as chronux tbx does
     data_proj=interp1(t',tapers,dtmp);
      exponential=exp(-i*w'*(dtmp-t(1))');
      J(:,:,ch)=exponential*data_proj-H*Msp(ch);
    
end



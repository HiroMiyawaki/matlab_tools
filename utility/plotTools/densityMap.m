function [output,xbin,ybin]=densityMap(input,xbin,ybin,smoothingSigma)

    if size(input,1)==2 && size(input,2)>2
        input=input';
    end
    if size(input,2)~=2
        display('input should have 2 column')
        return
    end
    

    if ~exist('xbin','var')
        temp=input(~isnan(input(:,1))&~isinf(input(:,1)),1);
        xbin=linspace(min(temp),max(temp),50);
    end
    if ~exist('ybin','var')
        temp=input(~isnan(input(:,2))&~isinf(input(:,2)),2);
        ybin=linspace(min(temp),max(temp),50);
    end

    if ~exist('smoothingSigma','var')
        smoothingSigma=1;
    end
    
    output=hist2(input,xbin,ybin);
    smoothingSigma=round(smoothingSigma);
    if smoothingSigma>0
        mu = [0 0];
        Sigma = [smoothingSigma 0; 0 smoothingSigma];
        smoothCoreBin = -3*smoothingSigma:3*smoothingSigma;
        [smoothCoreBin,smoothCoreBin] = meshgrid(smoothCoreBin,smoothCoreBin);
        smoothCore = mvnpdf([smoothCoreBin(:) smoothCoreBin(:)],mu,Sigma);
        smoothCore = reshape(smoothCore,length(smoothCoreBin),length(smoothCoreBin));
        smoothCore=smoothCore/sum(sum(smoothCore));        
        output=conv2(output,smoothCore,'same');
    end

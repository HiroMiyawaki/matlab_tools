function r=zncc(img,template,mask)
% r = zncc(img,template,mask)
%  Zero-mean Normalized Cross-Correlation (ZNCC)
%   Cross correlation of img and template, centered to the mean and normalized by std 
%   
%   img: target image (N x M x C matrix)
%   template: template image (X x Y x C matrix)
%   mask: mask for the template (X x Y x C matrix)
%
%   r : zncc for original and rotated (90, 180,270) template (N x M x 4 matrix)
%
%  by Hiro Miyawaki at the Osaka City Univ, 2019 Mar
%%

if ~exist('mask','var')
    mask=ones(size(template));
end

r=zeros(size(img,1),size(img,2),4);
for rot=1:4
    rotTemp=rot90(template.*mask,rot-1);
    rotMask=rot90(mask,rot-1);
    imgCov=zeros(size(img));
    imgAvg=zeros(size(img));
    imgSqAvg=zeros(size(img));
    for c=1:size(img,3)
        imgCov(:,:,c)=conv2(img(:,:,c),rotTemp(:,:,c),'same')/sum(sum(rotMask(:,:,c)));
        imgAvg(:,:,c)=conv2(img(:,:,c),rotMask(:,:,c),'same')/sum(sum(rotMask(:,:,c)));
        imgSqAvg(:,:,c)=conv2(img(:,:,c).^2,rotMask(:,:,c),'same')/sum(sum(rotMask(:,:,c)));
    end
    imgCov=mean(imgCov,3)-mean(imgAvg,3)*mean(rotTemp(mask>0));
    imgStd=(mean(imgSqAvg,3)-mean(imgAvg,3).^2).^0.5;
    r(:,:,rot)=imgCov./imgStd/std(template(mask>0));
end

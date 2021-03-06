%function ps2pdf(psfile,[options])
% convert psfile to pdf using ps2pdf
%
% psfile: path of target ps file
%
% options
%   remove (false) whether remove ps file after conversion or not
%   rmpath ('/bin/rm') full path of rm command
%   ps2pdfpath ('/usr/local/bin/ps2pdf') full path of ps2pdf command
%
%By Hiro Miyawaki at the Osaka City Univ, 2018
%
function ps2pdf(psfile,varargin)


remove=false;
ps2pdfPath='/usr/local/bin/ps2pdf';
rmPath='/bin/rm';
for n=1:length(varargin)/2
    name=lower(varargin{2*n-1});
    val=varargin{2*n};
    
    switch name
        case 'remove'
            remove=val;
        case 'ps2pdfpath'
            ps2pdfPath=val;
        case 'rmpath'
            rmPath=val;
        otherwise
            error('wrong option')
    end
end
            


[~,temp]=fileattrib(psfile);
fullpath=temp.Name;

if remove
    eval(sprintf('! %s %s %s && %s %s',ps2pdfPath,fullpath,[fullpath(1:end-2) 'pdf'],rmPath,fullpath))
else
    eval(sprintf('! %s %s %s',ps2pdfPath,fullpath,[fullpath(1:end-2) 'pdf']))
end
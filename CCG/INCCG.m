function [ncl] = INCCG(fileinfo,thetafilt,runfilt,ripplefilt);

% calculate and plot the CCG for all the interneurons in fileinfo

BinSize = 32.552;

currentdir = pwd; 
directory = fileinfo.name;
FileBase = [currentdir '/' directory '/' directory];

% load([FileBase '.INspike.mat']);

res = Loadres([FileBase 'IN.5.res']);
clu = LoadClu([FileBase 'IN.5.clu']);
resb = res;
ncl = dlmread([FileBase 'IN.5.numclu']);

if ~isempty(runfilt)
    smoothwin = [ones(15,1)];
    smoothwin = smoothwin/sum(smoothwin);
    xyt = fileinfo.xyt;
    tbegin = fileinfo.tbegin;
    tend = fileinfo.ftend;
    numofbins = round((tend-tbegin)/1e6*120);
    xyt(:,1) = filtfilt(smoothwin,1,xyt(:,1));
    xyt=binpos(xyt,numofbins);
    tt = (xyt(:,3)-tbegin)/1e6*32552;
    diffx = abs(diff(xyt(:,1)));
    speed = interp1(tt(1:end-1),diffx,res);
    running = (speed > 0.00029);
    if runfilt
        res = res(find(running));
        clu = clu(find(running));
    else
        res = res(find(~running));
        clu = clu(find(~running));
    end 
end

if ~isempty(thetafilt);
    sts = dlmread([FileBase '.theta.1'])'*26;
    res_ind = STSfilt(sts,res,thetafilt);
    res = res(res_ind);
    clu = clu(res_ind);
end

if ~isempty(ripplefilt)
    load([FileBase '-rip.mat']) 
    ripple_result = ripple_result(:,[1 3])'/1252*32552;
    res_ind = STSfilt(ripple_result,res,ripplefilt);
    res = res(res_ind);
    clu = clu(res_ind);
end
    
clf    
CCG(res,clu,BinSize,100,32552)
set(gcf,'Position',[20 -100 1500 1200])



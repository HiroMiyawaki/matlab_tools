% nlxvidex.m

% load('C:\yaf01\dirlist')

for ii=1:length(dirlist);
    [tt, xx, yy, cc] = Nlx2MatVT(['E:\' dirlist(ii).name '\VT1.Nvt'],1,0,0,0,1,1,1,0,0);
    xx = xx(1:5,:);
    yy = yy(1:5,:);
    cc = cc(1:5,:);
    mkdir(dirlist(ii).name)
    save(['C:\vvp01\' dirlist(ii).name '\' dirlist(ii).name 'vt' ],'tt','xx','yy','cc')
    
end

exit
% nlxvidex.m

% load('C:\yaf01\dirlist')
for jj = 1:length(dirlist);
    [tt, xx, yy, cc] = Nlx2MatVT(['C:\gor01\two\' dirlist(jj).name '\VT1.Nvt'],1,0,0,0,1,1,1,0,0);
    xx = xx(1:10,:);
    yy = yy(1:10,:);
    cc = cc(1:10,:);
    save(['C:\gor01\two\' dirlist(jj).name '\' dirlist(jj).name 'vt' ],'tt','xx','yy','cc')
end

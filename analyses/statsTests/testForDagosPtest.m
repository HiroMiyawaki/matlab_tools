close all
fh=initFig4Nature(2)
for ite=1:20
    switch ite
        case 1
            x=normrnd(10,5,5000,1);
            tText='Norm dist';
        case 2
            x=normrnd(0,10,5000,1);
            tText='Norm dist';
        case 3
            x=normrnd(-10,10,5000,1);
            tText='Norm dist';
        case 4
            x=normrnd(0,1,5000,1);
            tText='Norm dist';
        case 5
            x=lognrnd(0,1,5000,1);
            tText='Log norm dist';
        case 6
            x=lognrnd(1,1,5000,1);
            tText='Log norm dist';
        case 7
            x=rand(5000,1);
            tText='Uniform dist';            
        case 8
            x=rand(5000,1);
            tText='Uniform dist';            
        case 9
            x=betarnd(2,5,5000,1);
            tText='Beta dist'
        case 10
            x=betarnd(1,3,5000,1);
            tText='Beta dist'
        case 11
            x=gamrnd(9,0.5,5000,1);
            tText='Gamma dist'
        case 12
            x=gamrnd(3,2,5000,1);
            tText='Gamma dist'
        case 13
            x=[normrnd(10,2,2500,1);normrnd(0,2,2500,1)];
            tText='Dual Gaussian';            
        case 14
            x=[normrnd(10,3,2500,1);normrnd(0,3,2500,1)];
            tText='Dual Gaussian';            
        case 15
            x=[normrnd(10,3,4000,1);normrnd(0,3,1000,1)];
            tText='Dual Gaussian';            
        case 16
            x=[normrnd(10,5,2000,1);normrnd(0,5,3000,1)];
            tText='Dual Gaussian';  
        case 17
            x=[normrnd(10,2,2500,1);normrnd(0,2,2500,1)];
            tText='Dual Gaussian';            
        case 18
            x=[normrnd(10,3,2500,1);normrnd(0,3,2500,1)];
            tText='Dual Gaussian';            
        case 19
            x=[normrnd(10,3,4000,1);normrnd(0,3,1000,1)];
            tText='Dual Gaussian';            
        case 20
            x=[normrnd(10,5,2000,1);normrnd(0,5,3000,1)];
            tText='Dual Gaussian';         otherwise
            continue
    end


subplot(5,4,ite)
hist(x,100)
title(tText)
box off
axis tight
ax=fixAxis;
text2(1,1, {'D''Agostino test',['p=' num2str(DagosPtest(x),2)]},ax,...
        {'horizontalALign','right','verticalAlign','top'})

end
addScriptName(mfilename)

print(fh,'~/Dropbox/LOW/preliminary/DAgostinoTest.pdf','-dpdf')



nTone=16;
meanIEI=150;
halfRange=20;
toneDur=30;
shockDur=1;
traceInterval=20;

baseDur=150;
        
IEIrange=meanIEI+halfRange*[-1,1];
temp=round(diff(IEIrange)*rand(1,nTone))+min(IEIrange);
tTime=cumsum(temp)-temp(1)+baseDur;

csP=randperm(nTone,nTone/2);

fh=fopen('~/data/OCU/twoToneCond.txt','w');
fprintf(fh,'name,8CS+&8CS-\n');
fprintf(fh,'tone1,%d\n',toneDur);
fprintf(fh,'tone2,%d\n',toneDur);
fprintf(fh,'shock,%d\n',shockDur);

for n=1:nTone
    if ismember(n,csP)
        fprintf(fh,'%d,t1\n',tTime(n));
        fprintf(fh,'%d,s\n',tTime(n)+toneDur+traceInterval);        
    else
        fprintf(fh,'%d,t2\n',tTime(n));
    end    
end
fclose(fh)
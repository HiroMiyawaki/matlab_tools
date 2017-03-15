function makePosFile(FileBase,x,y)
%make pos file for neuroscope
    display(' ')
    display(' ')
    display(' ')
    display(mfilename)
    display(' ')

    fid = fopen(strcat(FileBase,'.pos'),'w');
    
    ratios=ceil([1:10]/10*length(x));
    m=1;
    points=length(x);
    for n=1:points
        fprintf(fid,'%f %f\n',x(n),y(n));
        if n==ratios(m)
            display([num2str(m*10),'% finished'])
            m=m+1;
        end
    end
    
    fclose(fid);
end
function Output=csvread2(FileName)

fh=fopen(FileName);

cnt=0;
while 1
    temp=fgets(fh);
    if ~ischar(temp); break; end
    cnt=cnt+1;
    
    index=findstr(temp,',');
    index=[0,index,length(temp)];
    for n=1:length(index)-1
        str=temp(index(n)+1:index(n+1)-1);
%         num=str2num(str);
%         if isempty(num)
            Output{cnt,n}=str;
%         else
%             Output{cnt,n}=num;
%         end
    end
end
fclose(fh);

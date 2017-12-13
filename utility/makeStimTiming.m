
clear stimTiming

if FileExists('~/data/OCU/stimTiming.mat')
    load('~/data/OCU/stimTiming.mat')
else
%     type={'conditioning','contextRetention','extinction','cueRetention'};
    type={'extinction'};
    for idx=1:length(type)
        if strcmpi(type{idx},'extinction')
            nTone=30;
            meanIEI=90;
            halfRange=20;            
            toneDur=30;
            shockDur=0;
            traceInterval=0;
        elseif strcmpi(type{idx},'conditioning')
            nTone=4;
            meanIEI=240;
            halfRange=20;
            toneDur=30;
            shockDur=1;
            traceInterval=20;
        elseif strcmpi(type{idx},'contextRetention')
            nTone=0;
            meanIEI=0;
            halfRange=0;
            toneDur=0;
            shockDur=0;
            traceInterval=0;
        elseif strcmpi(type{idx},'cueRetention')
            nTone=4;
            meanIEI=240;
            halfRange=20; 
            toneDur=30;
            shockDur=0;
            traceInterval=0;
        else
            continue
        end

        baseDur=360;
        
        IEIrange=meanIEI+halfRange*[-1,1];
        temp=round(diff(IEIrange)*rand(1,nTone))+min(IEIrange);
        
        if strcmpi(type{idx},'extinction')
            temp(1:4)=temp(1:4)+240-meanIEI;
        end
        
        if isempty(temp)
            stimTiming.(type{idx}).ts=[];
        else
            stimTiming.(type{idx}).ts=baseDur-temp(1)+cumsum(temp);
        end
        stimTiming.(type{idx}).param.meanITI=meanIEI;
        stimTiming.(type{idx}).param.ITIrange=IEIrange;
        stimTiming.(type{idx}).param.baseDur=baseDur;
        stimTiming.(type{idx}).param.toneDur=toneDur;
        stimTiming.(type{idx}).param.shockDur=shockDur;
        stimTiming.(type{idx}).param.traceInterval=traceInterval;
        stimTiming.(type{idx}).param.madeby=mfilename;    
    end
    save('~/data/OCU/stimTiming.mat','stimTiming','-v7.3')
end

type=fieldnames(stimTiming);

clear nEvent
for idx=1:length(type)
    if strcmpi(type{idx},'conditioning')
        nEvent(idx)=length(stimTiming.(type{idx}).ts)*2;
    else
        nEvent(idx)=length(stimTiming.(type{idx}).ts);
    end
end


fh=fopen('~/data/OCU/stimTiming.csv','w');
for idx=1:length(type)
    fprintf(fh,',%s,,',type{idx})
end
fprintf(fh,'\n')

for idx=1:length(type)
    fprintf(fh,'min ITI,%d,,',stimTiming.(type{idx}).param.ITIrange(1))
end
fprintf(fh,'\n')

for idx=1:length(type)
    fprintf(fh,'max ITI,%d,,',stimTiming.(type{idx}).param.ITIrange(2))
end
fprintf(fh,'\n')
for idx=1:length(type)
    fprintf(fh,'trace interval,%d,,',stimTiming.(type{idx}).param.traceInterval)
end
fprintf(fh,'\n')

for idx=1:length(type)
    fprintf(fh,',,,',stimTiming.(type{idx}).param.toneDur)
end
fprintf(fh,'\n')

for idx=1:length(type)
    fprintf(fh,'tone duration,%d,,',stimTiming.(type{idx}).param.toneDur)
end
fprintf(fh,'\n')

for idx=1:length(type)
    fprintf(fh,'shock duration,%d,,',stimTiming.(type{idx}).param.shockDur)
end
fprintf(fh,'\n')
for idx=1:length(type)
    if isempty(stimTiming.(type{idx}).ts)
        fprintf(fh,'recording duration,%d,,',stimTiming.(type{idx}).param.baseDur)
    else        
        fprintf(fh,'recording duration,%d,,',stimTiming.(type{idx}).param.meanITI+max(stimTiming.(type{idx}).ts))
    end
end

for idx=1:length(type)
    fprintf(fh,',,,',stimTiming.(type{idx}).param.toneDur)
end
fprintf(fh,'\n')

fprintf(fh,'\n')
for nEvt=1:max(nEvent)
    for idx=1:length(type)
        if strcmpi(type{idx},'conditioning')
            if nEvt>nEvent(idx)
                fprintf(fh,',,,')
            elseif mod(nEvt,2)==1
                fprintf(fh,'tone,%d,,',stimTiming.(type{idx}).ts((nEvt+1)/2));
            else
                fprintf(fh,'shock,%d,,',stimTiming.(type{idx}).ts(nEvt/2)+...
                            stimTiming.(type{idx}).param.toneDur+stimTiming.(type{idx}).param.traceInterval);
            end
            
        else
            if nEvt>nEvent(idx)
                fprintf(fh,',,,')
            else
                fprintf(fh,'tone,%d,,',stimTiming.(type{idx}).ts(nEvt));
            end
        end
    end
    fprintf(fh,'\n')

end
fprintf(fh,'\n')












for type=5:9
    clear nTone1 nTone2Å@meanIEI halfRange baseDur traceInterval toneDur shockDur settingFile expName
    switch type
        case 1
            toneDur=30; %in sec
            shockDur=2; %in sec
            settingFile='~/data/OCU/01_base+conditioning.txt';
            expName='01 Base&Conditioning';
            
            nTone1(1)=8;
            nTone2(1)=8;
            meanIEI(1)=210; %in sec
            halfRange(1)=30; %in sec
            baseDur(1)=240;  %in sec
            traceInterval(1)=NaN;  %in sec
            
            nTone1(2)=16; 
            nTone2(2)=0;
            meanIEI(2)=meanIEI(1);  %in sec
            halfRange(2)=halfRange(1); %in sec
            baseDur(2)=0; %in sec
            traceInterval(2)=20; %in sec
    
        case 2
            toneDur=0; %in sec
            shockDur=0; %in sec
            settingFile='~/data/OCU/02_context.txt';
            expName='02 Context Retention';
            
            nTone1(1)=0;
            nTone2(1)=0;
            meanIEI(1)=0; %in sec
            halfRange(1)=0; %in sec
            baseDur(1)=240;  %in sec
            traceInterval(1)=NaN;  %in sec
        case 3
            toneDur=30; %in sec
            shockDur=2; %in sec
            settingFile='~/data/OCU/03_cue+extinction.txt';
            expName='03 Cue&Extinction';
            
            nTone1(1)=8;
            nTone2(1)=8;
            meanIEI(1)=210; %in sec
            halfRange(1)=30; %in sec
            baseDur(1)=240;  %in sec
            traceInterval(1)=NaN;  %in sec
            
            nTone1(2)=32; 
            nTone2(2)=0;
            meanIEI(2)=90;  %in sec
            halfRange(2)=30; %in sec
            baseDur(2)=0; %in sec
            traceInterval(2)=NaN; %in sec
        case 4
            toneDur=30; %in sec
            shockDur=2; %in sec
            settingFile='~/data/OCU/04_extRetention.txt';
            expName='04 Ext Retention';
            
            nTone1(1)=8;
            nTone2(1)=8;
            meanIEI(1)=210; %in sec
            halfRange(1)=30; %in sec
            baseDur(1)=240;  %in sec
            traceInterval(1)=NaN;  %in sec   
            
        case 5
            toneDur=30; %in sec
            shockDur=2; %in sec
            settingFile='~/data/OCU/00001_base.txt';
            expName='02 Conditioning';
            
            nTone1(1)=4;
            nTone2(1)=0;
            meanIEI(1)=210; %in sec
            halfRange(1)=30; %in sec
            baseDur(1)=240;  %in sec
            traceInterval(1)=NaN;  %in sec
            
%             nTone1(2)=16; 
%             nTone2(2)=0;
%             meanIEI(2)=meanIEI(1);  %in sec
%             halfRange(2)=halfRange(1); %in sec
%             baseDur(2)=0; %in sec
%             traceInterval(2)=20; %in sec            
        case 6
            toneDur=30; %in sec
            shockDur=2; %in sec
            settingFile='~/data/OCU/00002_conditioning.txt';
            expName='01 Baseline';
            
            nTone1(1)=12;
            nTone2(1)=0;
            meanIEI(1)=210; %in sec
            halfRange(1)=30; %in sec
            baseDur(1)=240;  %in sec
            traceInterval(1)=-2;  %in sec
            
%             nTone1(2)=16; 
%             nTone2(2)=0;
%             meanIEI(2)=meanIEI(1);  %in sec
%             halfRange(2)=halfRange(1); %in sec
%             baseDur(2)=0; %in sec
%             traceInterval(2)=20; %in sec            
        case 7
            toneDur=0; %in sec
            shockDur=0; %in sec
            settingFile='~/data/OCU/00003_context.txt';
            expName='03 Context Retention';
            
            nTone1(1)=0;
            nTone2(1)=0;
            meanIEI(1)=0; %in sec
            halfRange(1)=0; %in sec
            baseDur(1)=240;  %in sec
            traceInterval(1)=NaN;  %in sec          
        case 8
            toneDur=30; %in sec
            shockDur=0; %in sec
            settingFile='~/data/OCU/00004_cue+extinction.txt';
            expName='04 Cue&Extinction';
            
            nTone1(1)=8;
            nTone2(1)=0;
            meanIEI(1)=210; %in sec
            halfRange(1)=30; %in sec
            baseDur(1)=240;  %in sec
            traceInterval(1)=NaN;  %in sec
            
            nTone1(2)=32; 
            nTone2(2)=0;
            meanIEI(2)=90;  %in sec
            halfRange(2)=30; %in sec
            baseDur(2)=0; %in sec
            traceInterval(2)=NaN; %in sec
        case 9
            toneDur=30; %in sec
            shockDur=0; %in sec
            settingFile='~/data/OCU/00005_extRetention.txt';
            expName='05 Ext Retention';
            
            nTone1(1)=8;
            nTone2(1)=0;
            meanIEI(1)=210; %in sec
            halfRange(1)=30; %in sec
            baseDur(1)=240;  %in sec
            traceInterval(1)=NaN;  %in sec   
            
        otherwise
            break
    end
    
    

    
    offset=0;
    dur=0;
    tTime=[];
    tType=[];
    sTime=[];
    for idx=1:size(nTone1,2)
        
        IEIrange=meanIEI(idx)+halfRange(idx)*[-1,1];
        temp=round(abs(diff(IEIrange))*rand(1,nTone1(idx)+nTone2(idx)))+min(IEIrange);
        if ~isempty(temp)
            tTimeTemp=cumsum(temp)-temp(1)+baseDur(idx)+offset;
            tTime=[tTime,tTimeTemp];

            tTypeTemp=2*ones(size(temp));
            tTypeTemp(randperm(nTone1(idx)+nTone2(idx),nTone1(idx)))=1;
            tType=[tType,tTypeTemp];

            if ~isnan(traceInterval(idx))
                sTime=[sTime,tTimeTemp(tTypeTemp==1)+toneDur+traceInterval(idx)];
            end
        else
            tTimeTemp=[];
        end
        
        if isempty(tTimeTemp)
            dur=offset+baseDur(idx);
        else
            dur=tTimeTemp(end)+meanIEI(idx);
        end
        
        if isempty(temp)
            offset=dur;
        else
            offset=tTime(end)+temp(1);
        end
        
    end
    
    evt=sortrows([tTime',tType';sTime',3*ones(size(sTime'))]);
        
    fh=fopen(settingFile,'w');
    fprintf(fh,'%s\r\n',expName);
    fprintf(fh,'tone1,%d\r\n',toneDur);
    fprintf(fh,'tone2,%d\r\n',toneDur);
    fprintf(fh,'shock,%d\r\n',shockDur);    
    fprintf(fh,'duration,%d\r\n',dur);
    evtType={'t1','t2','s'};
    for n=1:size(evt,1)
        fprintf(fh,'%d,%s\r\n',evt(n,1),evtType{evt(n,2)});
    end
    
    
    fclose(fh);
    
end
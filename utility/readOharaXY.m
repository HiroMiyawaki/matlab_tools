function [Results,Headers,Parameters,Data]=readOharaXY(File,MinFreezeSec)
    fh=fopen(File);
    tline = fgetl(fh);
    
    if nargin<2
        MinFreezeSec=5;
    end
    
    idx=0;
    inHeader=false;
    inParam=false;
    while ischar(tline)
        if length(tline)>6 && strcmpi(tline(1:7),'TimeFZ1')
            idx=idx+1;
            Data(idx).value=[];
            inHeader=true;
            inParam=false;
            tline = fgetl(fh);
            continue
        end    
        if inHeader
            if length(tline)>9 && strcmpi(tline(1:10),'Parameters')
                inHeader=false;
                inParam=true;
            else
                entry=strsplit(tline,'\t');
                Headers(idx).(stripStr(entry{1}))=entry{2};                
            end
            tline = fgetl(fh);            
            continue
        end


        if inParam
            if length(tline)>5 && strcmpi(tline(1:5),'slice')
                inParam=false;
                Data(idx).name=strsplit(tline,'\t');
            else
                entry=strsplit(tline,'\t');
                entry{1}=stripStr(entry{1});
                
                if isempty(entry{1})
                    Parameters(idx).Referece_File{end+1}=entry{2};
                elseif strcmpi(entry{1},'Referece_File')
                    Parameters(idx).Referece_File{1}=entry{2};
                else
                    val=str2num(entry{2});
                    if isempty(val)
                        Parameters(idx).(entry{1})=entry{2};
                    else
                        Parameters(idx).(entry{1})=val;
                    end
                end
            end
            tline = fgetl(fh);
            continue
        end    
        Data(idx).value(end+1,:)=cellfun(@(x) str2num(x),strsplit(tline,'\t'));
        tline = fgetl(fh);                
    end
    fclose(fh);
    
    for idx=1:length(Data)

        sliceIdx=find(strcmpi(Data(idx).name,'Slice'));
        toneIdx=find(strcmpi(Data(idx).name,'Tone'));
        shockIdx=find(strcmpi(Data(idx).name,'Shock'));
        fzIdx=find(strcmpi(Data(idx).name,'Fz'));
        tsIdx=find(strcmpi(Data(idx).name,'Timestamp'));

        
        imm=Data(idx).value(:,fzIdx);
        fzStr=find(diff(imm)==1)+1;
        fzEnd=find(diff(imm)==-1);
        if imm(1)==1; fzStr=[1;fzStr]; end
        if imm(end)==1; fzEnd=[fzEnd;size(imm,1)]; end

        threshold=Parameters(idx).rate_frame_sec * MinFreezeSec;
        
        fzCand=[fzStr,fzEnd];
        fzCand=fzCand(diff(fzCand,1,2)>threshold,:);

        temp=zeros(size(imm,1),1);
        for fzIdx=1:size(fzCand,1)
            temp(fzCand(fzIdx,1):fzCand(fzIdx,2))=1;
        end

        Results(idx).time=Data(idx).value(:,sliceIdx)/Parameters(idx).rate_frame_sec;
        Results(idx).freeze=temp;
        
        if isempty(toneIdx)
            Results(idx).tone=zeros(size(imm,1),1);
        else
            Results(idx).tone=Data(idx).value(:,toneIdx);
        end
        
        if isempty(shockIdx)
            Results(idx).shock=zeros(size(imm,1),1);
        else
            Results(idx).shock=Data(idx).value(:,shockIdx);
        end
        Results(idx).immobile=imm;
        Results(idx).fps=Parameters(idx).rate_frame_sec;

        if ~isempty(tsIdx)
            Results(idx).timestamp=Data(idx).value(:,tsIdx);
        end
        
    end
    
    
    
    
end
        
        
function output=stripStr(string)
    lastLet=find(~ismember(string,' :)'),1,'last');
    if length(string)>lastLet; string(lastLet+1:end)=[]; end
    string(ismember(string,' /+!@#$%^&*()<>,.:;=\-'))='_';
    output=regexprep(string,'_+','_');
end    

            
        
        
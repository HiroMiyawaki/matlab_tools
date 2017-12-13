clear

dataDir='~/data/OCU/traceCond_test/';
saveDir='~/data/OCU/traceCond_test/movieWithDetection/';

setName={};
ratName={};
sessionType={};
% 
% setName{end+1}='20170306';
% ratName{end+1}='HR0003';
% sessionType{end+1}='Habituation';
% 
% setName{end+1}='20170306';
% ratName{end+1}='HR0004';
% sessionType{end+1}='Habituation';
% 
% setName{end+1}='20170307';
% ratName{end+1}='HR0003';
% sessionType{end+1}='Conditioning';
% 
% setName{end+1}='20170307';
% ratName{end+1}='HR0004';
% sessionType{end+1}='Conditioning';
% 
% setName{end+1}='20170307-1';
% ratName{end+1}='HR0004';
% sessionType{end+1}='Context_01h';
% 
% setName{end+1}='20170307-2';
% ratName{end+1}='HR0004';
% sessionType{end+1}='Cue_01h';
% 
% setName{end+1}='20170307-3';
% ratName{end+1}='HR0003';
% sessionType{end+1}='Context_06h';
% 
% setName{end+1}='20170307-4';
% ratName{end+1}='HR0003';
% sessionType{end+1}='Cue_06h';
% 
% setName{end+1}='20170307-5';
% ratName{end+1}='HR0004';
% sessionType{end+1}='Context_06h';
% 
% setName{end+1}='20170307-6';
% ratName{end+1}='HR0004';
% sessionType{end+1}='Cue_06h';
% 
% setName{end+1}='20170308';
% ratName{end+1}='HR0003';
% sessionType{end+1}='Context_24h';
% 
% setName{end+1}='20170308-1';
% ratName{end+1}='HR0003';
% sessionType{end+1}='Cue_24h';
% 
% setName{end+1}='20170308-2';
% ratName{end+1}='HR0004';
% sessionType{end+1}='Context_24h';
% 
% setName{end+1}='20170308-3';
% ratName{end+1}='HR0004';
% sessionType{end+1}='Cue_24h';



%%

for idx=1:length(setName)

    rat=ratName{idx};
    ses=sessionType{idx};

    fh=fopen([dataDir '/' setName{idx} '/XYdata/' ratName{idx} '_XY.txt']);
    tline = fgetl(fh);
    while ischar(tline)
        if length(tline)>7 && strcmpi(tline(1:7),'TimeFZ1')
            data=[];
            inHeader=true;
            tline = fgetl(fh);
            continue
        end

        if inHeader
            if length(tline)>5 && strcmpi(tline(1:5),'slice')
                inHeader=false;
                fieldName=strsplit(tline,'\t');
            end
            tline = fgetl(fh);
            continue
        end


        data(end+1,:)=cellfun(@(x) str2num(x),strsplit(tline,'\t'));
        tline = fgetl(fh);
    end

    fclose(fh);

    immIdx=find(strcmpi(fieldName,'FZ'));
    imm=data(:,immIdx);

    toneIdx=find(strcmpi(fieldName,'Tone'));
    if isempty(toneIdx)
        tone.(rat).(ses)=zeros(size(data,1),1);
    else
        tone.(rat).(ses)=data(:,toneIdx);
    end

    shockIdx=find(strcmpi(fieldName,'Shock'));
    if isempty(toneIdx)
        shock.(rat).(ses)=zeros(size(data,1),1);
    else
        shock.(rat).(ses)=data(:,shockIdx);
    end

    fzStr=find(diff(imm)==1)+1;
    fzEnd=find(diff(imm)==-1);

    if imm(1)==1; fzStr=[1;fzStr]; end
    if imm(end)==1; fzEnd=[fzEnd;size(imm,1)]; end

    fzCand=[fzStr,fzEnd];
    fzCand=fzCand(diff(fzCand,1,2)>50,:);

    fz.(rat).(ses)=zeros(size(data,1),1);
    for fzIdx=1:size(fzCand,1)
        fz.(rat).(ses)(fzCand(fzIdx,1):fzCand(fzIdx,2))=1;
    end

    t.(rat).(ses)=data(:,1)/10;

end

%%
col.tone=[1,0.7,0];
col.shock=[1,0,0];
col.freeze=[0,0,1];

close all
doAppend='';
psFileName='~/data/OCU/traceCond_test/freezeSummary.ps';
for page=1:2
    
    fh=initFig4Nature(2);
    ratList={'HR0003','HR0004'};
    if page==1
        sessionList={'Habituation','Conditioning','Context_01h','Context_06h','Context_24h'};
    else
        sessionList={'Habituation','Conditioning','Cue_01h','Cue_06h','Cue_24h'};
    end
    cnt=-1;
    for rIdx=1:length(ratList)
        rat=ratList{rIdx}
        cnt=cnt+1;
        for sIdx=1:length(sessionList)
            session=sessionList{sIdx};
            if ~isfield(tone.(rat),session)
                continue
            end
            cnt=cnt+1;
            
            subplot(10,1,cnt)
            hold on
            plot(t.(rat).(session),tone.(rat).(session),'-','color',col.tone)
            plot(t.(rat).(session),shock.(rat).(session)-0.1,'-','color',col.shock)
            plot(t.(rat).(session),fz.(rat).(session)/2-0.05,'-','color',col.freeze)
            axis tight
            ylim([-0.2,1.1])
            xlabel('Time (s)')
            set(gca,'ytick','');
            ax=fixAxis;
            text2(0.01,1,session,ax,...
                {'horizontalALign','left','verticalAlign','top','interpreter','none','fontsize',7})
            if sIdx==1
                text2(-0.03,1.02,['Rat:' rat],ax,...
                    {'horizontalAlign','left','verticalAlign','bottom','fontsize',9})
            end
            
            text2(1,1.01,...
                ['\color[rgb]{' num2str(col.tone) '}Tone ' ...
                 '\color[rgb]{' num2str(col.shock) '}Shock ' ...
                 '\color[rgb]{' num2str(col.freeze) '}Freeze '],ax,...
                 {'horizontalAlign','right','verticalAlign','bottom','fontsize',7})
        end
    end
    addScriptName(mfilename)
    print(fh,psFileName,'-dpsc',doAppend,'-painters')
    doAppend='-append'
    
end










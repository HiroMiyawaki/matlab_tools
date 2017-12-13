function makeFreezeMov(dataDir,setName,ratName,saveFileName,speed)

    if ~exist('speed','var')
        speed=3;
    end
    
    display(['   ' datestr(now) ' start for session:' setName ' animal: ' ratName])
    display(['   ' datestr(now) ' loading the log file'])
    
    fh=fopen([dataDir '/' setName '/XYdata/' ratName '_XY.txt']);
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
    %%

    immIdx=find(strcmpi(fieldName,'FZ'));    
    imm=data(:,immIdx);
    
    toneIdx=find(strcmpi(fieldName,'Tone'));     
    if isempty(toneIdx)
        tone=zeros(size(data,1),1);
    else
    tone=data(:,toneIdx);
    end
    
    shockIdx=find(strcmpi(fieldName,'Shock'));     
    if isempty(toneIdx)
        shock=zeros(size(data,1),1);
    else
        shock=data(:,shockIdx);
    end
    
    frame=data(:,1);


    fzStr=find(diff(imm)==1)+1;
    fzEnd=find(diff(imm)==-1);

    if imm(1)==1; fzStr=[1;fzStr]; end
    if imm(end)==1; fzEnd=[fzEnd;size(imm,1)]; end

    fzCand=[fzStr,fzEnd];
    fzCand=fzCand(diff(fzCand,1,2)>50,:);

    fz=zeros(size(data,1),1);
    for idx=1:size(fzCand,1)
        fz(fzCand(idx,1):fzCand(idx,2))=1;
    end


    %%

    
    vIn=VideoReader([dataDir '/' setName '/Images/' ratName '.avi']);
    
    tickGap=floor(vIn.Duration/6/60)*60;
    
    
    
    vOut=VideoWriter(saveFileName,'MPEG-4');
    vOut.FrameRate=    vIn.FrameRate*speed;

    nFrame=vIn.Duration*vIn.FrameRate;
    prog=ceil(nFrame/10*(1:10));

    n=0;
    m=1;
    
    heightAppendWin=ceil(vIn.Height/8);
    
    outputSize=[vIn.Width,vIn.Height+heightAppendWin];
    
    fig=figure();
    fig.Position=[100,1000,outputSize];


    display(['   ' datestr(now) ' start making movie'])
    open(vOut)
    while vIn.hasFrame
        n=n+1;
        clf
        subplot('position',[0.25,0.25,0.5,0.5])
        img=vIn.readFrame;


        imagesc(img)
        colormap(gray)
        set(gca,'clim',[0,256])
        
        ylim([-heightAppendWin,vIn.Height])
        rectangle('position',[0,-heightAppendWin,vIn.Width,heightAppendWin],'linestyle','none','faceColor','k')
        hold on
        plot(frame/frame(end)*vIn.Width,(-0.3-0.6*tone)*heightAppendWin,'y')
        plot(frame/frame(end)*vIn.Width,(-0.35-0.6*shock)*heightAppendWin,'r')
        plot(frame/frame(end)*vIn.Width,(-0.4-0.3*fz)*heightAppendWin,'c')
        plot(n/frame(end)*vIn.Width*[1,1],-[0.28,1]*heightAppendWin,'w')


        for xVal=0:tickGap:vIn.Duration
            text(xVal*vIn.FrameRate/frame(end)*vIn.Width,1,num2str(xVal),...
                'fontsize',6,'verticalAlign','top','color','k')
        end

        if tone(n)==1
            text(10,vIn.Height-5,'Tone','color','y','fontsize',10,'verticalAlign','bottom')
        end
        if shock(n)==1
            text(10,vIn.Height-19,'Shock','color','r','fontsize',10,'verticalAlign','bottom')
        end
        if imm(n)==1
            text(10,vIn.Height-33,'Immobility','color','g','fontsize',10,'verticalAlign','bottom')
        end
        if fz(n)==1
            text(10,vIn.Height-47,'Freeze','color','c','fontsize',10,'verticalAlign','bottom')
        end
        
        
        text(vIn.Width*0.98,10,[num2str(n/vIn.FrameRate,'%.1f') ' s'],...
            'color','k','fontsize',10,'verticalAlign','top','horizontalAlign','right')
        if speed~=1
            text(vIn.Width*0.98,24,['x' num2str(speed)],...
                'color','k','fontsize',8,'verticalAlign','top','horizontalAlign','right')
        end
        axis off
        videoFrame=getframe;
        writeVideo(vOut,videoFrame);
        
        if n>=prog(m)
            display(['   ' '   ' datestr(now) ' ' num2str(m*10) '% finished'])
            m=m+1;
        end
        
    end
    close(vOut);

end




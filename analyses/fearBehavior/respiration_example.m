clear

dur=18;
close all
doAppend='';
psFileName='~/data/OCU/eyelid_pip_2CS/respiration_example.ps';
nExp=6;
for fIdx=1:3
    if fIdx==1
        rootDir='~/data/OCU/eyelid_pip_2CS/HR0040/2017-11-28_08-03-39';
        example=120+80*(0:nExp-1);
        peakDir=-1;
        titleText='AP 11.1 mm, ML 1.0 mm (Rat HR0040)';
    elseif fIdx==2
        rootDir='~/data/OCU/eyelid_pip_2CS/HR0041/2017-11-29_11-08-39';
        example=90+80*(0:nExp-1);
        peakDir=1;
        titleText='AP 7.5 mm, ML 1.3 mm (Rat HR0041)';
    else
        rootDir='~/data/OCU/eyelid_pip_2CS/HR0043/2017-12-08_11-00-00';
        example=315+80*(0:nExp-1);
        peakDir=-1;
        titleText='AP 7.5 mm, ML 1.0 mm, 0.6 mm from the surface (Rat HR0043)';
    end
    
    lfpFile=dir(fullfile(rootDir,'*.lfp'));

    nCh=15;
    obCh=3;
    sampFreq=1250;
    nFrame=lfpFile.bytes/2/nCh;



    lfp=memmapfile(fullfile(lfpFile.folder, lfpFile.name),'format',{'int16',[nCh,nFrame],'raw'});

    % datFile=dir(fullfile(rootDir,'*.dat'));
    % nFrameDat=datFile.bytes/2/nCh;
    % 
    % dat=memmapfile(fullfile(datFile.folder, datFile.name),'format',{'int16',[nCh,nFrameDat],'raw'});
    % 
    % shkCh=11;
    % ttlShk=dat.Data.raw(shkCh,:)>2^14;

%     onset=find(diff(ttlShk)==1)+1;
%     offset=find(diff(ttlShk)==-1);
%     shock=[onset',offset'];
% 
%     shock=shock/(20000/1250);
%     shock=[floor(shock(:,1)),ceil(shock(:,2))];

    ob=single(lfp.Data.raw(obCh,:));

    % tail=ceil(1250*0.8)
    % 
    % for idx=1:size(shock,1)
    %     ob(shock(idx,1):shock(idx,2)+tail)=interp1(shock(idx,:)+[-1,tail+1],ob(shock(idx,:)+[-1,tail+1]),shock(idx,1):shock(idx,2)+tail);
    % end

    % %%
    % [obWavelet,freq]=HM_eegWavelet(fullfile(lfpFile.folder, lfpFile.name),nCh,obCh,sampFreq,[0.1,20],[1,nFrame],0.05);
    % %%
    % ax1=subplot(2,1,1);
    % plot((0:size(obWavelet,2)-1)/sampFreq,ob,'k-')
    % ax2=subplot(2,1,2);
    % imagesc([0,(size(obWavelet,2)-1)/sampFreq],[1,size(obWavelet,1)],zscore((abs(obWavelet)),0,2))
    % 
    % linkaxes([ax1,ax2],'x')
    % 
    % set(gca,'clim',[-2.5,3])
    % set(gca,'YTick',20:20:140,'YTickLabel',freq(20:20:140))
    % % ylim([1,15])
    %
    % filtb=fir1(500,[2,20]/2/sampFreq);
    filtb=fir1(500,100/2/sampFreq,'low');
    filOB=Filter0(filtb,ob);    
    [val,loc]=findpeaks(peakDir*filOB,'minPeakDistance',1250/10);

    val2=ob(loc);
    
    
    if mod(fIdx,2)==1
        fh=initFig4Nature(2);
    end
    for idx=1:nExp
        subplot(nExp*2+1,1,idx+(nExp+1)*(mod(fIdx-1,2)))
        frm=(1:dur*sampFreq)+example(idx)*sampFreq;
        % plot((0:size(ob,2)-1)/sampFreq,ob);
        hold on
        plot(loc(loc>frm(1)&loc<frm(end))/sampFreq,val2(loc>frm(1)&loc<frm(end)),'ro','markersize',1);
        plot((frm-1)/sampFreq,ob(frm),'k-','linewidth',0.1);
        % xlim([0,10])
        box off
        axis off
        ylim(2000*[-1,1.5])
        ax=fixAxis;
        if idx==1
            text2(0,1.1,titleText,ax,{'horizontalAlign','left','verticalAlign','bottom','fontsize',10})
        end
        
        if idx==nExp
            xPos=ax(2)-dur/50-[0,1];
            yPos=ax(3)+50*[1,1];
            plot(xPos, yPos,'k-')
            text(mean(xPos),mean(yPos),'1 sec','verticalAlign','top','horizontalALign','center')

            xPos=ax(2)-dur/50-[1,1];
            yPos=ax(3)+50+[0,200/0.195];
            plot(xPos, yPos,'k-')
            text(mean(xPos),mean(yPos),'0.2 mV','verticalAlign','middle','horizontalALign','right')
        end
        
    end
    if fIdx>1
        addScriptName(mfilename)
        print(fh,psFileName,'-dpsc','-painters',doAppend) 
        doAppend='-append';
    end
end

ps2pdf(psFileName,'remove',true)

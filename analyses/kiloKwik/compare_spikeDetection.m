% % nSpk=[	2140034 %spikes found in shank 0,
% % 	2183156 %spikes found in shank 1, 
% % 	2833203 %spikes found in shank 2, 
% % 	2582136 %spikes found in shank 3, 
% % 	13075834 %spikes found in shank 4, 
% % 	14818884 %spikes found in shank 5, 
% % 	12157985 %spikes found in shank 6, 
% % 	7860361 %spikes found in shank 7, 
% % 	7641543 %spikes found in shank 8, 
% % 	12942134 %spikes found in shank 9
% %     ];
% % 
% % temp=dir('~/data/OCU/implanted/magician/magician_2017-09-19_06-10-17/magician_2017-09-19_06-10-17.dat');
% % dur=temp.bytes/20e3/112/2
% % 
% % 
% % sum(nSpk)/dur
% % 
% % 
% % clear spk;
% %%
% kwikFile='~/data/OCU/implanted/magician/magician_2017-09-19_06-10-17/SpikeDetekt/magician_2017-09-19_06-10-17.kwik';
% 
% for n=1:10;
%     spk.kwik{n}=double(hdf5read(kwikFile,['/channel_groups/' num2str(n-1) '/spikes/time_samples']));
% end
% 
% %%
% for n=1:3
%     switch n
%         case 1
%             rootDir='/Volumes/RAID_HDD/data/OCU/implanted/magician/magician_2017-09-19_06-10-17/magician_lam-15-40-40_Th-3-6-6_Nfilt-512/';
%             name='low';
%         case 2
%             rootDir='/Volumes/RAID_HDD/data/OCU/implanted/magician/magician_2017-09-19_06-10-17/magician_lam-15-40-40_Th-3-9-9_Nfilt-512/';
%             name='middle';
%         case 3
%             roottDir='/Volumes/RAID_HDD/data/OCU/implanted/magician/magician_2017-09-19_06-10-17/magician_Nfilt-512/';
%             name='high';
%     end
% 
%     pcFeatureInds=npy2mat(fullfile(rootDir,'pc_feature_ind.npy'));
% 
%     spikeTemplates=npy2mat(fullfile(rootDir,'spike_templates.npy'))+1;
%     spikeTimes=npy2mat(fullfile(rootDir,'spike_times.npy'));
% 
%     channelPosition=npy2mat(fullfile(rootDir,'channel_positions.npy'));
% 
%     kcoords=channelPosition(:,1);
% 
%     templateShank=kcoords(pcFeatureInds'+1);
%     templateShank=templateShank(1,:);
% 
% 
%     spikeShank=templateShank(spikeTemplates);
% 
%     for m=1:10
%         spk.(name){m}=spikeTimes(spikeShank==m);
%     end
% end
% 
% %%
% datFile=dir('/Volumes/RAID_HDD/data/OCU/implanted/magician/magician_2017-09-19_06-10-17/*.dat')
% nSample=datFile.bytes/112/2;
% dat=memmapfile(fullfile(datFile.folder,datFile.name),'Format', {'int16', [112, nSample], 'val'});

%%
close all

    col.kwik='m';
    col.low='r';
    col.middle='r';
    col.high='r';

for p=3
    fh=initFig4letter(true);
    switch p
        case 3
            frameRange=[1,3e3]+117e3;
%             frameRange=frameRange+1e3;
            shank=3;
        case 4
            frameRange=[1,3e3]+200126e3;
            shank=3;
        case 1
            frameRange=[1,3e3]+101e3;
            shank=5;
        case 2
            frameRange=[1,3e3]+200119e3;
            shank=5;
    end

    chList=find(kcoords==shank);

    typeList=fieldnames(spk);

    lfp=double(dat.Data.val(chList,frameRange(1):frameRange(2))');




    titleText.kwik='klusta';
    titleText.low='Th=[3,3,6]';
    titleText.middle='Th=[3,3,9]';
    titleText.high='Th=[6,6,12]';

    for n=1:4
        subplotInMM(5,5+55*(n-1),270,45,true)
        typeName=typeList{n};
        clear subSpk
        subSpk=spk.(typeName){shank}(spk.(typeName){shank}>frameRange(1)&spk.(typeName){shank}<frameRange(2))-frameRange(1)+1;

        plot((1:size(lfp,1))/20e3,lfp-500*repmat(1:size(lfp,2),size(lfp,1),1),'k-','linewidth',0.5)
        axis tight
        ax=axis;
        hold on
        barX=(size(lfp,1)-20-[0,20*5])/20e3
        plot(barX,(ax(3)-50)*[1,1],'k-')
        text(mean(barX),(ax(3)-50),'5 ms','horizontalAlign','center','verticalAlign','bottom')
        ylim([ax(3)-50,ax(4)])
        axis off
        if ~isempty(subSpk)
        plot([subSpk,subSpk]'/20e3,ax(3:4)-n*10,'-','color',col.(typeName),'linewidth',0.5)
        end
        title([titleText.(typeName),', shank' num2str(shank) ', ' num2str(frameRange(1)/20e3) '-' num2str(frameRange(2)/20e3) ' sec'])
    end
%     print(['/Volumes/RAID_HDD/data/OCU/implanted/magician/detectCompare-' num2str(p) '.png'] ,'-dpng','-r600')
end


% %%
% close all
% fh=initFig4letter(true);
% 
% bin=0.5:1:nSample/20e3/60;
% 
% col.kwik=[1,0,1];
% col.low=[0,0,1];
% col.middle=[0,1,0];
% col.high=[1,0,0];
% 
% subplot(3,1,1)
% hold on
% legendText={};
% for n=1:4
%     typeName=typeList{n};
% 
%     rate=hist(cat(1,spk.(typeName){1:4})/20e3/60,bin)/60;
% 
%     plot(bin,rate,'color',col.(typeName))
%     
%     legendText{n}=['\color[rgb]{' num2str(col.(typeName)),'}' titleText.(typeName)];
%     
% end
% axis tight
% ax=axis;
% ylim([0,ax(4)])
% xlabel('Time (min)')
% ylabel('MUA (Hz)')
% title('Amy')
% ax=fixAxis;
% text2(1,1,legendText,ax,{'horizontalAlign','left','verticalAlign','top'})
% 
% subplot(3,1,2)
% hold on
% 
% for n=1:4
%     typeName=typeList{n};
% 
%     rate=hist(cat(1,spk.(typeName){5:10})/20e3/60,bin)/60;
% 
%     plot(bin,rate,'color',col.(typeName))
% end
% axis tight
% ax=axis;
% ylim([0,ax(4)])
% 
% xlabel('Time (min)')
% ylabel('MUA (Hz)')
% title('PFC')
% 
% print(['/Volumes/RAID_HDD/data/OCU/implanted/magician/meanFR.png'] ,'-dpng','-r600')
% 
% %%
% lfpFile=dir('/Volumes/RAID_HDD/data/OCU/eyelid_pip/HR0033/2017-10-03_15-28-52/*.dat')
% nLFPSample=lfpFile.bytes/14/2;
% lfp=memmapfile(fullfile(lfpFile.folder,lfpFile.name),'Format', {'int16', [14, nLFPSample], 'val'});
% close all
% fh=initFig4letter(true);
% 
% for n=1:2
%     subplot(3,1,n)
%     
%     if n==1
%     fRante=20e3*((8*60)+[0,10])+[1,0];
%     titleText='Baseline';
%     else
%     fRante=20e3*((8*60+24)+[0,10])+[1,0];
%     titleText='Freezing';
%     end
%     wav=double(lfp.Data.val([2],fRante(1):fRante(2)));
%     plot(wav(1,:),'k-')
%     hold on
%     plot(diff(fRante)-[10e3,20e3],-3000*[1,1],'k-')
%     text(mean(diff(fRante)-[10e3,20e3]),-3000,'0.5 s','horizontalAlign','center','verticalAlign','top')
%     axis off
%     title(titleText)
%     if n==2
%     plot([15,38,56,75,92,115,138,160,178,196]*1e3,8000,'rv')
%     end
%     ylim([-3100,9000])
% end
% 
% print(['/Volumes/RAID_HDD/data/OCU/eyelid_pip/ECG.png'] ,'-dpng','-r600')
% 
% 
% 



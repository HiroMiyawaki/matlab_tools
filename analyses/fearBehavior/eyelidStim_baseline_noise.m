% clear 
% 
% fileList={'experiment1_101_0','experiment1_101_1','experiment1_101_2','experiment1_101_3'};
% condition={'floating shield','grounded shield','disconnected','grounded shield & shielded cage'};
% dataDir='~/data/OCU/HR0016/2017-06-05_16-40-39/';
% 
% nCh=21;
% ch=1;
% 
% for fIdx=1:length(fileList)
%     dName=fileList{fIdx};
% 
%     DatFile=[dataDir dName '.dat'];
%     FileInfo = dir(DatFile);
%     clear temp
%     temp = memmapfile(DatFile, 'Format', {'int16', [nCh, (FileInfo.bytes/nCh/2)], 'x'});    
%     lfp{fIdx}=double(temp.Data.x(ch,:))*0.195;
%     
% end    
% 
% 
% %%
% for idx=1:length(lfp)
%     y=fft(lfp{idx}(20e3:20e3*50+1));
%     len=size(lfp{idx}(20e3:20e3*50+1),2);
%     pow2=abs(y/len);
%     pow{idx}=pow2(1:len/2+1);
%     pow{idx}(2:end-1)=2*pow{idx}(2:end-1);
% 
%     freq{idx}=20e3*(0:(len/2))/len;
% 
% end
% 
% %%
% close all
% fh=initFig4Nature(2);
% hold on
% col=eye(3);
% col(4,:)=[0,0,0];
% dur=1;
% 
% for idx=1:length(lfp)
%     subplot(6,4,4*idx+(-3:-1))
%     plot((1:dur*20e3)/20e3,lfp{idx}(38*20e3+(1:dur*20e3)),'k-','linewidth',0.1)
%     title(condition{idx})
%     xlabel('Time (s)')
%     ylabel('LFP (\muV)')
%     ylim([-500,500])
%     box off
% 
%     subplot(6,4,4*idx)
%     plot(freq{idx}(freq{idx}<101),pow{idx}(freq{idx}<101),'k-','linewidth',0.5)
%     set(gca,'yscale','log')
%     xlim([0,100])
%     ylim(10.^[-3,2])
%     box off
% end
% addScriptName(mfilename)
% 
% print(fh,[dataDir 'baseNoiseSummary.pdf'],'-dpdf')
% 
% %%
% 
% clear 
% 
% fileList={'experiment1_101_0'};
% dataDir='~/data/OCU/HR0016/2017-06-08_17-25-25/';
% 
% nCh=21;
% ch=1;
% condition={'grounded shield','floating shield','disconnected'};
% 
% for fIdx=1:length(fileList)
%     dName=fileList{fIdx};
% 
%     DatFile=[dataDir dName '.dat'];
%     FileInfo = dir(DatFile);
%     clear temp
%     temp = memmapfile(DatFile, 'Format', {'int16', [nCh, (FileInfo.bytes/nCh/2)], 'x'});    
%     lfp{fIdx}=double(temp.Data.x(ch,:))*0.195;
%     
% end    
% 
% period=[10,50;
%         76, 116;
%         125, 165];
% 
% for idx=1:size(period,1)
%     y=fft(lfp{1}(period(idx,1)*20e3+1:period(idx,2)*20e3));
%     len=length(y);
%     pow2=abs(y/len);
%     pow{idx}=pow2(1:len/2+1);
%     pow{idx}(2:end-1)=2*pow{idx}(2:end-1);
% 
%     freq{idx}=20e3*(0:(len/2))/len;
% end
% 
% 
% close all
% fh=initFig4Nature(2);
% hold on
% col=eye(3);
% col(4,:)=[0,0,0];
% dur=1;
% 
% for idx=1:length(pow)
%     subplot(6,4,4*idx+(-3:-1))
%     plot((1:dur*20e3)/20e3,lfp{1}(period(idx,1)*20e3+(1:dur*20e3)),'k-','linewidth',0.1)
%     title(condition{idx})
%     xlabel('Time (s)')
%     ylabel('LFP (\muV)')
%     ylim([-500,500])
%     box off
% 
%     subplot(6,4,4*idx)
%     plot(freq{idx}(freq{idx}<101),pow{idx}(freq{idx}<101),'k-','linewidth',0.5)
%     set(gca,'yscale','log')
%     xlim([0,100])
%     ylim(10.^[-3,2])
%     box off
% end
% 
% for idx=1:length(pow)
%     hum(idx)=sum(pow{idx}(freq{idx}>55&freq{idx}<65));
% end
% subplot2(6,4,4,4)
% bar(1:3,hum,'facecolor','k')
% box off
% ylabel('Pow in 55-65 Hz')
% xlabel('')
% set(gca,'xtick',1:3,'xticklabel',condition,'XTickLabelRotation',-30)
% 
% addScriptName(mfilename)
% 
% print(fh,[dataDir 'baseNoiseSummary2.pdf'],'-dpdf')

%%
clear 

fileList={'experiment1_101_0','experiment1_101_1','experiment1_101_2','experiment1_101_3'};
condition={'floating','grobal grounded shield','local grounded shield','local grounded shield, thin stim wires'};
dataDir='~/data/OCU/HR0016/2017-06-09_15-41-30/';

nCh=21;
ch=1;

for fIdx=1:length(fileList)
    dName=fileList{fIdx};

    DatFile=[dataDir dName '.dat'];
    FileInfo = dir(DatFile);
    clear temp
    temp = memmapfile(DatFile, 'Format', {'int16', [nCh, (FileInfo.bytes/nCh/2)], 'x'});    
    lfp{fIdx}=double(temp.Data.x(ch,:))*0.195;
    
end    



for idx=1:length(lfp)
    y=fft(lfp{idx}(20e3:20e3*20+1));
    len=size(lfp{idx}(20e3:20e3*20+1),2);
    pow2=abs(y/len);
    pow{idx}=pow2(1:len/2+1);
    pow{idx}(2:end-1)=2*pow{idx}(2:end-1);

    freq{idx}=20e3*(0:(len/2))/len;

end


close all
fh=initFig4Nature(2);
hold on
col=eye(3);
col(4,:)=[0,0,0];
dur=1;

for idx=1:length(lfp)
    subplot(6,4,4*idx+(-3:-1))
    plot((1:dur*20e3)/20e3,lfp{idx}(:,10*20e3+(1:dur*20e3)),'k-','linewidth',0.1)
    title(condition{idx})
    xlabel('Time (s)')
    ylabel('LFP (\muV)')
    ylim([-500,500])
    box off
    subplot(6,4,4*idx)
    plot(freq{idx}(freq{idx}<101),pow{idx}(freq{idx}<101),'k-','linewidth',0.5)
    set(gca,'yscale','log')
    xlabel('Hz')
    ylabel('\muV^2/Hz')
    xlim([0,100])
    ylim(10.^[-3,2])
    box off
end
addScriptName(mfilename)

print(fh,[dataDir 'baseNoiseSummary3.pdf'],'-dpdf')
clear
basepath='/Volumes/RAID_HDD/data/OCU/implanted/magician/magician_2017-09-19_06-10-17/';
rezDir='magician_Th-3-6-6'
basename='magician_2017-09-19_06-10-17';
idx=2;

spk=npy2mat(fullfile(basepath,rezDir,'spike_times.npy'));
clu=npy2mat(fullfile(basepath,rezDir,'spike_clusters.npy'));

FileName=[basepath basename]
fh = fopen([FileName,'.clu.' num2str(idx)],'w');
fprintf(fh,'%d\n',length(unique(clu)));
fprintf(fh,'%d\n',clu);
fclose(fh);

fh = fopen([FileName,'.res.' num2str(idx)],'w');
fprintf(fh,'%d\n',spk);
fclose(fh);

load([basepath rezDir '/rez.mat']);
ConvertKilosort2Neurosuite_KSW([basepath rezDir],basename,rez)
%%

% basepath='~/data/OCU/implanted/magician/magician_2017-09-19_06-10-17/';
basepath='/Volumes/RAID_HDD/data/OCU/implanted/magician/magician_2017-09-19_06-10-17/';
basename='magician_2017-09-19_06-10-17';
% load(fullfile(basepath,'rez.mat'))


spk=npy2mat(fullfile(basepath,'spike_times.npy'));
clu=npy2mat(fullfile(basepath,'spike_clusters.npy'));
% 
% FileName=[basepath basename]
% fh = fopen([FileName,'.clu.1'],'w');
% fprintf(fh,'%d\n',length(unique(clu)));
% fprintf(fh,'%d\n',clu);
% fclose(fh);
% 
% fh = fopen([FileName,'.res.1'],'w');
% fprintf(fh,'%d\n',spk);
% fclose(fh);
    
fid = fopen(fullfile(basepath,'cluster_groups.csv'),'r');
csv = textscan(fid,'%s %s');
fclose(fid);

id = cellfun(@str2num,csv{1,1}(2:end));
groupTmp = csv{1,2}(2:end);

n = length(groupTmp);
group = nan(n,1);
for ii=1:n
    switch groupTmp{ii}
        case 'noise'
            group(ii) = 0;
        case 'mua'
            group(ii) = 1;
        case 'good'
            group(ii) = 2;
        case 'unsorted'
            group(ii) = 3;
        otherwise
            group(ii)= 4;
    end
end



noiseClu=id(group==0);

spk(ismember(clu,noiseClu))=[];
clu(ismember(clu,noiseClu))=[];

% ConvertKilosort2Neurosuite_KSW(basepath,basename,rez)
%%
close all
fh=initFig4letter()

% % tOnset=524*60+16;
% % tOnset=524*60+20.8;
% REM
% tOnset=418*60+1;
subplot(3,3,1:2)
tOnset=552*60+50.5;
% tOnset=358*60+56.415;
dur=0.5;

tRange=(tOnset+[0,dur])*20e3-[0,1];

datFile=fullfile(basepath,[basename '.dat']);
nCh=112;
FileInfo = dir(datFile);
dat = memmapfile(datFile, 'Format', {'int16', [nCh, (FileInfo.bytes/nCh/2)], 'val'});   

offsets=[1:32,(33:92)+2.5,93+8,94+10,95+15]*0.9;
scale=0.195*eye(95);
scale(93,93)=0.195*1/3;
scale(94,94)=0.195*1/3;
scale(95,95)=1;

showScale=1*eye(size(scale));
showScale(95,95)=20;
offsets=offsets*showScale(1,1)*100;
offsets=-offsets+max(offsets);
val=double(dat.Data.val([1:32+60,98,97],tRange(1):tRange(2))');

%288*60+27 - REM sleep
accBase=mean(sqrt(sum(double(dat.Data.val(99:101,(288*60+27)*20e3+(0:3*20e3))).^2)));

acc=sqrt(sum(double(dat.Data.val(99:101,tRange(1):tRange(2))).^2))/accBase*9.80665;
acc2=sqrt(sum(double(dat.Data.val(102:104,tRange(1):tRange(2))).^2));

acc=acc'-mean(acc);
acc2=acc2'-mean(acc2);

val=val-repmat(mean(val),size(val,1),1);
val=[val,acc];

plot((0:diff(tRange))/20e3,val*scale*showScale+repmat(offsets,diff(tRange)+1,1),'k-','linewidth',0.1)

hold on
% % plot([1;1]*(spk(spk>tRange(1)& spk<tRange(2))-tRange(1))',-[clu(spk>tRange(1)& spk<tRange(2));clu(spk>tRange(1)& spk<tRange(2))+1],...
% %     'k-','linewidth',2)
% tempS=(spk(spk>tRange(1)& spk<tRange(2))-tRange(1))'/20e3;
% tempC=clu(spk>tRange(1)& spk<tRange(2));
% 
% % cluList=unique(tempC);
% % cluMap=[];
% % for n=1:length(cluList)
% %     cluMap(cluList(n))=n;
% % end
% cluMap=0:max(tempC);
% 
% plot(tempS,-cluMap(tempC)-28,...
%     'k.','markersize',1)
axis tight
axis off
% scaleX=0.44+50e-3*[0,0,1]
% scaleY=-600+500*showScale(1,1)*[1,0,0]
% plot(scaleX,scaleY,'k-','linewidth',2)
% text(scaleX(1),mean(scaleY(1)),{'0.5 mV ','1.5 mV ' '25 m/s^2 '}, 'verticalAlign','top','horizontalAlign','right','fontsize',9)
% text(mean(scaleX(2:3)),scaleY(3),' 50 ms', 'verticalAlign','top','horizontalAlign','center','fontsize',9)

scaleX=0.44+50e-3*[0,1]
plot(scaleX,-300*[1,1],'k-','linewidth',2)
text(mean(scaleX),-300,' 50 ms', 'verticalAlign','top','horizontalAlign','center','fontsize',9)

scaleY=500*showScale(1,1)*[1,0];
scaleX=0.505;
yOffset=offsets(32);
plot(scaleX*[1,1],scaleY+yOffset,'k-','linewidth',2)
text(scaleX,mean(scaleY)+yOffset,' 0.5 mV', 'verticalAlign','middle','horizontalAlign','left','fontsize',9)

yOffset=offsets(92);
plot(scaleX*[1,1],scaleY+yOffset,'k-','linewidth',2)
text(scaleX,mean(scaleY)+yOffset,' 0.5 mV', 'verticalAlign','middle','horizontalAlign','left','fontsize',9)

yOffset=offsets(93)*0.25+offsets(94)*0.75;
scaleY=1000/3*showScale(1,1)*[1,0];
plot(scaleX*[1,1],scaleY+yOffset,'k-','linewidth',2)
text(scaleX,mean(scaleY)+yOffset,' 1.0 mV', 'verticalAlign','middle','horizontalAlign','left','fontsize',9)

yOffset=offsets(95)-50;
scaleY=20*20*showScale(1,1)*[1,0];
plot(scaleX*[1,1],scaleY+yOffset,'k-','linewidth',2)
text(scaleX,mean(scaleY)+yOffset,' 20 m/s^2', 'verticalAlign','middle','horizontalAlign','left','fontsize',9)

ax=fixAxis;
text2(0,1,'A',ax,{'horizontalAlign','right','verticalAlign','bottom','fontsize',14})


% stim
subplot(3,3,3)
tOnset=358*60+51.415;
dur=5;
tRange=(tOnset+[0,dur])*20e3-[0,1];

tempS=(spk(spk>tRange(1)& spk<tRange(2))-tRange(1))'/20e3;
tempC=clu(spk>tRange(1)& spk<tRange(2));

ttl=double(dat.Data.val(112+(-7:0),tRange(1):tRange(2)))/1e4;

% plot((0:diff(tRange))/20e3,ttl-8*repmat((1:size(ttl,1))',1,size(ttl,2))+50,'k-')
plot((0:diff(tRange))/20e3,ttl(4,:)*2,'k-')
hold on
cluList=unique(tempC);
% cluMap=[];
% for n=1:length(cluList)
%     cluMap(cluList(n)+1)=n;
% end
cluMap=0:max(tempC);
plot(tempS,-cluMap(tempC+1)-15,...
    'k.','markersize',1)
axis tight
axis off

scaleX=3.8+[0,1];
scaleY=-280*[1,1];
plot(scaleX,scaleY,'k-','lineWidth',2)
text(mean(scaleX),scaleY(1),{'1 s'}, 'horizontalAlign','center','verticalAlign','top','fontsize',9)

ax=fixAxis;
text2(0,1,'B',ax,{'horizontalAlign','right','verticalAlign','bottom','fontsize',14})

print(['~/Dropbox/Proposal/VŠwp2017/' 'example.png'],'-dpng','-r300')
print(['~/Dropbox/Proposal/VŠwp2017/' 'example.eps'],'-depsc','-painters')
%%
close all
fh=initFig4letter();

width=75;
hight=50;
rHight=15;
xMargin=30;
margin=12.5;

% % tOnset=524*60+16;
% % tOnset=524*60+20.8;
% REM
% tOnset=418*60+1;
a=a+0.2;
for ii=1:2
% subplot(3,2,ii)
subplotInMM(xMargin+(width+margin)*(ii-1),20,width,hight,true)
switch ii
    case 1
    tOnset=552*60+50.1;
    
    case 2
        tOnset=122*60+29.78;
end
    
% tOnset=358*60+56.415;
dur=0.75;

tRange=(tOnset+[0,dur])*20e3-[0,1];

datFile=fullfile(basepath,[basename '.dat']);
nCh=112;
FileInfo = dir(datFile);
dat = memmapfile(datFile, 'Format', {'int16', [nCh, (FileInfo.bytes/nCh/2)], 'val'});   

offsets=[1:32,(33:92)+10,93+20,94+22,95+25];
scale=0.195*eye(95);
scale(93,93)=0.195*1/3;
scale(94,94)=0.195*1/3;
scale(95,95)=1;

showScale=0.5*eye(size(scale));
showScale(95,95)=20;
offsets=offsets*showScale(1,1)*100;
offsets=-offsets+max(offsets);
val=double(dat.Data.val([1:32+60,98,97],tRange(1):tRange(2))');

%288*60+27 - REM sleep
accBase=mean(sqrt(sum(double(dat.Data.val(99:101,(288*60+27)*20e3+(0:3*20e3))).^2)));

acc=sqrt(sum(double(dat.Data.val(99:101,tRange(1):tRange(2))).^2))/accBase*9.80665;
acc2=sqrt(sum(double(dat.Data.val(102:104,tRange(1):tRange(2))).^2));

acc=acc'-mean(acc);
acc2=acc2'-mean(acc2);

val=val-repmat(mean(val),size(val,1),1);
val=[val,acc];

plot((0:diff(tRange))/20e3,val*scale*showScale+repmat(offsets,diff(tRange)+1,1),'k-','linewidth',0.1)

hold on
% % plot([1;1]*(spk(spk>tRange(1)& spk<tRange(2))-tRange(1))',-[clu(spk>tRange(1)& spk<tRange(2));clu(spk>tRange(1)& spk<tRange(2))+1],...
% %     'k-','linewidth',2)
% tempS=(spk(spk>tRange(1)& spk<tRange(2))-tRange(1))'/20e3;
% tempC=clu(spk>tRange(1)& spk<tRange(2));
% 
% % cluList=unique(tempC);
% % cluMap=[];
% % for n=1:length(cluList)
% %     cluMap(cluList(n))=n;
% % end
% cluMap=0:max(tempC);
% 
% plot(tempS,-cluMap(tempC)-28,...
%     'k.','markersize',1)
axis tight
axis off
% scaleX=0.44+50e-3*[0,0,1]
% scaleY=-600+500*showScale(1,1)*[1,0,0]
% plot(scaleX,scaleY,'k-','linewidth',2)
% text(scaleX(1),mean(scaleY(1)),{'0.5 mV ','1.5 mV ' '25 m/s^2 '}, 'verticalAlign','top','horizontalAlign','right','fontsize',9)
% text(mean(scaleX(2:3)),scaleY(3),' 50 ms', 'verticalAlign','top','horizontalAlign','center','fontsize',9)

scaleY=500*showScale(1,1)*[1,0];
scaleX=dur*1.01;
yOffset=offsets(32);
plot(scaleX*[1,1],scaleY+yOffset,'k-','linewidth',2)
text(scaleX,mean(scaleY)+yOffset,' 0.5 mV', 'verticalAlign','middle','horizontalAlign','left','fontsize',9)

yOffset=offsets(92);
plot(scaleX*[1,1],scaleY+yOffset,'k-','linewidth',2)
text(scaleX,mean(scaleY)+yOffset,' 0.5 mV', 'verticalAlign','middle','horizontalAlign','left','fontsize',9)

yOffset=offsets(93)*0.25+offsets(94)*0.75;
scaleY=1000/3*showScale(1,1)*[1,0];
plot(scaleX*[1,1],scaleY+yOffset,'k-','linewidth',2)
text(scaleX,mean(scaleY)+yOffset,' 1.0 mV', 'verticalAlign','middle','horizontalAlign','left','fontsize',9)

yOffset=offsets(95)-50;
scaleY=20*20*showScale(1,1)*[1,0];
plot(scaleX*[1,1],scaleY+yOffset,'k-','linewidth',2)
text(scaleX,mean(scaleY)+yOffset,' 20 m/s^2', 'verticalAlign','middle','horizontalAlign','left','fontsize',9)

ax=fixAxis;
text2(0,1,alphabet(ii,true),ax,{'horizontalAlign','right','verticalAlign','bottom','fontsize',14})


% subplot(6,2,4+ii)
subplotInMM(xMargin+(width+margin)*(ii-1),20+hight+1,width,rHight,true)

% tOnset=358*60+51.415;
% dur=5;
% tRange=(tOnset+[0,dur])*20e3-[0,1];
% 
tempS=(spk(spk>tRange(1)& spk<tRange(2))-tRange(1))'/20e3;
tempC=clu(spk>tRange(1)& spk<tRange(2));
% 
% ttl=double(dat.Data.val(112+(-7:0),tRange(1):tRange(2)))/1e4;
% 
% % plot((0:diff(tRange))/20e3,ttl-8*repmat((1:size(ttl,1))',1,size(ttl,2))+50,'k-')
% plot((0:diff(tRange))/20e3,ttl(4,:)*2,'k-')
% hold on
cluList=unique(tempC);
% % cluMap=[];
% % for n=1:length(cluList)
% %     cluMap(cluList(n)+1)=n;
% % end
cluMap=0:max(tempC);
plot(tempS,-cluMap(tempC+1)-15,...
    'k.','markersize',1)
axis tight
axis off
hold on
scaleX=dur*0.9+50e-3*[0,1]
plot(scaleX,-300*[1,1],'k-','linewidth',2)
text(mean(scaleX),-300,' 50 ms', 'verticalAlign','top','horizontalAlign','center','fontsize',9)

% 
% scaleX=3.8+[0,1];
% scaleY=-280*[1,1];
% plot(scaleX,scaleY,'k-','lineWidth',2)
% text(mean(scaleX),scaleY(1),{'1 s'}, 'horizontalAlign','center','verticalAlign','top','fontsize',9)
% 
% ax=fixAxis;
% text2(0,1,'B',ax,{'horizontalAlign','right','verticalAlign','bottom','fontsize',14})

end
% 
% % stim
% subplot(3,3,3)
% tOnset=358*60+51.415;
% dur=5;
% tRange=(tOnset+[0,dur])*20e3-[0,1];
% 
% tempS=(spk(spk>tRange(1)& spk<tRange(2))-tRange(1))'/20e3;
% tempC=clu(spk>tRange(1)& spk<tRange(2));
% 
% ttl=double(dat.Data.val(112+(-7:0),tRange(1):tRange(2)))/1e4;
% 
% % plot((0:diff(tRange))/20e3,ttl-8*repmat((1:size(ttl,1))',1,size(ttl,2))+50,'k-')
% plot((0:diff(tRange))/20e3,ttl(4,:)*2,'k-')
% hold on
% cluList=unique(tempC);
% % cluMap=[];
% % for n=1:length(cluList)
% %     cluMap(cluList(n)+1)=n;
% % end
% cluMap=0:max(tempC);
% plot(tempS,-cluMap(tempC+1)-15,...
%     'k.','markersize',1)
% axis tight
% axis off
% 
% scaleX=3.8+[0,1];
% scaleY=-280*[1,1];
% plot(scaleX,scaleY,'k-','lineWidth',2)
% text(mean(scaleX),scaleY(1),{'1 s'}, 'horizontalAlign','center','verticalAlign','top','fontsize',9)
% 
% ax=fixAxis;
% text2(0,1,'B',ax,{'horizontalAlign','right','verticalAlign','bottom','fontsize',14})

print(['~/Dropbox/Proposal/VŠwp2017/' 'example2.png'],'-dpng','-r300')
% print(['~/Dropbox/Proposal/VŠwp2017/' 'example.eps'],'-depsc','-painters')

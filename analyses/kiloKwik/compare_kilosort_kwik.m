% clear
% clc
% %%
% FileInfo=dir(fullfile('/Users/miyawaki/Desktop/removeNoise/','*dat'));
% NChInDat=112;
% dat = memmapfile(fullfile(FileInfo.folder,FileInfo.name), 'Format', {'int16', [NChInDat, (FileInfo.bytes/NChInDat/2)], 'data'});
% 
% 
% tBin=30:60:size(dat.Data.data,2)/20e3;
% nSpk=10000;
% 
% for n=1:4
%     chMap{n}=(1:8)+8*(n-1);
% end
% for n=5:10
%     chMap{n}=(1:10)+32+10*(n-5);
% end
% 
% nBef=16;
% nAft=24;
% nFil=33;
% %%
% path='/Users/miyawaki/Desktop/removeNoise/';
% 
% spk=double(npy2mat(fullfile(path,'spike_times.npy')));
% clu=npy2mat(fullfile(path,'spike_clusters.npy'));
% 
% fh = fopen(fullfile(path,'cluster_groups.csv'),'r');
% cluGrp = textscan(fh,'%s %s');
% fclose(fh);
% 
% temp=cluGrp{1}(~strcmpi(cluGrp{2},'noise'));
% cluList=cellfun(@str2num,temp(2:end));
% cluGrp=cluGrp{2}(~strcmpi(cluGrp{2},'noise'))
% cluGrp(1)=[];
% 
% usedCh=cat(2,chMap{:});
% 
% cnt=0;
% for cIdx=1:length(cluList)
%     disp([datestr(now) sprintf(' %d/%d of kilosort cluster', cIdx,length(cluList))])
%     cluID=cluList(cIdx);    
%     subset=spk(clu==cluID);
%     
%     tempAcg=CCG(subset,1,20,30,20e3);
% 
%     if ~strcmpi(cluGrp{cIdx},'good') && ...
%             (mean(tempAcg(31+(-2:2)))>=mean(tempAcg) || length(subset)<2000 || ...
%              mean(tempAcg)<2 || max(tempAcg)<5)
%         continue
%     end
%     
%     cnt=cnt+1;
%         
%     unitInfo.kilo(cnt).id=cluID;
%     unitInfo.kilo(cnt).acg=tempAcg;    
%     unitInfo.kilo(cnt).n=length(subset);
%     unitInfo.kilo(cnt).rate=hist(subset/20e3,tBin)/60;
%     unitInfo.kilo(cnt).type=lower(cluGrp{cIdx});
%     
%     if length(subset)>nSpk
%         example=sort(subset(randperm(length(subset),nSpk)));
%     else
%         example=subset;
%     end
%     
%     wave=double(dat.Data.data(usedCh,example+(-nBef-nFil:nAft+nFil)));
%     wave=double(reshape(wave,size(wave,1),size(example,1),[]));
%     wave=wave-medfilt1(wave,nFil*2+1,[],3);
%     wave(:,:,[1:nFil,end-nFil+1:end])=[];        
%       
%     tempMean=squeeze(mean(wave,2));
%     [unitInfo.kilo(cnt).amp,unitInfo.kilo(cnt).ch]=max(range(tempMean,2));
%     
%     wave=wave(chMap{cellfun(@(x) ismember(unitInfo.kilo(cnt).ch,x),chMap)},:,:);
%     unitInfo.kilo(cnt).wave.mean=squeeze(mean(wave,2))';
%     unitInfo.kilo(cnt).wave.std=squeeze(std(wave,0,2))';
% end
% %%
% filename='/Users/miyawaki/Desktop/kwik/magician_2017-09-19_06-10-17.kwik'
% cnt=0;
% 
% for shankIdx=1:10
%     disp([datestr(now) sprintf(' %d/%d of kwik shank', shankIdx,10)])
%     spk=double(h5read(filename, sprintf('/channel_groups/%d/spikes/time_samples',shankIdx-1)));
%     clu=h5read(filename, sprintf('/channel_groups/%d/spikes/clusters/main',shankIdx-1));
% 
%     cluList=unique(clu);
%     cluGrp={};
%     for cIdx=1:length(cluList)
%         temp=h5readatt(filename, sprintf('/channel_groups/%d/clusters/main/%d/',shankIdx-1,cluList(cIdx)),'cluster_group');
% 
%         cluGrp(cIdx)=h5readatt(filename,sprintf('/channel_groups/%d/cluster_groups/main/%d/',shankIdx-1,temp),'name');    
%     end
% 
%     cluList=cluList(~strcmpi(cluGrp,'noise'));
%     cluGrp=cluGrp(~strcmpi(cluGrp,'noise'));
% 
% 
%     for cIdx=1:length(cluList)
%         disp(['    ' datestr(now) sprintf(' %d/%d of %d shank', cIdx,length(cluList),shankIdx)])
% 
%         cluID=cluList(cIdx);
%         subset=spk(clu==cluID);
%         tempAcg=CCG(subset,1,20,30,20e3);
% 
%         if ~strcmpi(cluGrp{cIdx},'good') && ...
%                 (mean(tempAcg(31+(-2:2)))>=mean(tempAcg) || length(subset)<2000 || ...
%                  mean(tempAcg)<2 || max(tempAcg)<5)
%             continue
%         end
%         
%         cnt=cnt+1;
%         cluID=cluList(cIdx);
%         subset=spk(clu==cluID);
%         unitInfo.kwik(cnt).id=[shankIdx,cluID];
%         unitInfo.kwik(cnt).acg=tempAcg;    
%         unitInfo.kwik(cnt).n=length(subset);
%         unitInfo.kwik(cnt).rate=hist(subset/20e3,tBin)/60;
%         unitInfo.kwik(cnt).type=lower(cluGrp{cIdx});
% 
%         if length(subset)>nSpk
%             example=sort(subset(randperm(length(subset),nSpk)));
%         else
%             example=subset;
%         end
% 
%         example(example<nBef+nFil | example>size(dat.Data.data,2)-nAft-nFil)=[];
%         
%         wave=double(dat.Data.data(chMap{shankIdx},example+(-nBef-nFil:nAft+nFil)));
%         wave=double(reshape(wave,size(wave,1),size(example,1),[]));
%         wave=wave-medfilt1(wave,nFil*2+1,[],3);
%         wave(:,:,[1:nFil,end-nFil+1:end])=[];
% 
%         unitInfo.kwik(cnt).wave.mean=squeeze(mean(wave,2))';
%         unitInfo.kwik(cnt).wave.std=squeeze(std(wave,0,2))';
% 
%         [unitInfo.kwik(cnt).amp,idx]=max(range(unitInfo.kwik(cnt).wave.mean,1));
%         unitInfo.kwik(cnt).ch=chMap{shankIdx}(idx);
%     end
% end
% %%

% save('~/data/OCU/implanted/magician/unitInfo.mat','unitInfo','-v7.3')
% %%
% % for shankIdx=1:10
% %     fet=h5read(kwxfile, sprintf('/channel_groups/%d/features_masks',shankIdx-1));
% %     clu=h5read(kwikfile, sprintf('/channel_groups/%d/spikes/clusters/main',shankIdx-1));
% % 
% % 
% %     cluList=unique(clu);
% %     cluGrp={};
% %     for cIdx=1:length(cluList)
% %         temp=h5readatt(kwikfile, sprintf('/channel_groups/%d/clusters/main/%d/',shankIdx-1,cluList(cIdx)),'cluster_group');
% % 
% %         cluGrp(cIdx)=h5readatt(kwikfile,sprintf('/channel_groups/%d/cluster_groups/main/%d/',shankIdx-1,temp),'name');    
% %     end
% % 
% %     cluList=cluList(~strcmpi(cluGrp,'noise'));
% %     % cluGrp=cluGrp(~strcmpi(cluGrp,'noise'));
% % 
% % 
% %     fet=double(squeeze(fet(1,:,ismember(clu,cluList))));
% %     clu=clu(ismember(clu,cluList));
% % 
% %     targets=unitIDList(unitIDList(:,1)==shankIdx,2);
% %     
% %     for cIdx=1:length(targets);
% %         cID=targets(cIdx);
% % 
% %         inFet=fet(:,clu==cID)';
% %         outFet=fet(:,clu~=cID)';
% % 
% %         md=mahal(outFet,inFet);
% %         Lratio=sum(chi2cdf(md,size(inFet,2),'upper'))/size(inFet,1);
% % 
% %         md=sort(md,'ascend');
% %         isoDist=md(size(inFet,1));
% % 
% %         unitInfo.kwik(unitIDList(:,1)==shankIdx&unitIDList(:,2)==cID).Lratio=Lratio;
% %         unitInfo.kwik(unitIDList(:,1)==shankIdx&unitIDList(:,2)==cID).isoDist=isoDist;    
% %     end
% % 
% % end
% % 
% % save('~/data/OCU/implanted/magician/unitInfo.mat','unitInfo','-v7.3')
%%
% clear
% 
% for n=1:4
%     chMap{n}=(1:8)+8*(n-1);
% end
% for n=5:10
%     chMap{n}=(1:10)+32+10*(n-5);
% end
% 
% 
% rootDir='~/data/OCU/implanted/magician/';
% load(fullfile(rootDir,'unitInfo.mat'));
% for typeIdx=2
%     if typeIdx==1
%         type='kilo';
% 
%         temp=zeros(size(unitInfo.(type)));
%         for sh=1:10
%             temp=temp+sh*ismember([unitInfo.(type).ch],chMap{sh});
%         end
%         target=[temp',[unitInfo.(type).id]'];        
%     
%     elseif typeIdx==2
%         type='kwik';
%         
%         target=cat(1,unitInfo.(type).id);    
%     else
%         continue
%     end
%     for sh=1:10
%         fprintf('%s processing shank %d of %s\n', datestr(now), sh, type)
%         load(fullfile(rootDir,sprintf('magician-%s_shank%02d.mat',type,sh)))
%         
%         subTarget=target(target(:,1)==sh,2);
% 
%         for cIdx=1:length(subTarget)
%             fprintf('    %s processing cluster %d of %d\n', datestr(now), cIdx, length(subTarget))
%             cID=subTarget(cIdx);
% 
%             inFet=fet(clu==cID,:);
%             outFet=fet(clu~=cID,:);
% 
%             md=mahal(outFet,inFet);
%             Lratio=sum(chi2cdf(md,size(inFet,2),'upper'))/size(inFet,1);
% 
%             md=sort(md,'ascend');
%             if length(md)<size(inFet,1)
%                 isoDist=max(md);
%             else
%                 isoDist=md(size(inFet,1));
%             end
%             
%             uIdx=find(target(:,1)==sh & target(:,2)==cID);
%             
%             unitInfo.(type)(uIdx).Lratio=Lratio;
%             unitInfo.(type)(uIdx).isoDist=isoDist;    
%         end    
%     end
% end
% save(fullfile(rootDir,'unitInfo.mat'),'unitInfo','-v7.3')
%%
clear

for n=1:4
    chMap{n}=(1:8)+8*(n-1);
end
for n=5:10
    chMap{n}=(1:10)+32+10*(n-5);
end
usedCh=[chMap{:}];
nBef=16;
nAft=24;

rootDir='~/data/OCU/implanted/magician/';
load(fullfile(rootDir,'unitInfo.mat'));

FileInfo=dir(fullfile('/Users/miyawaki/Desktop/removeNoise/','*dat'));
NChInDat=112;
tBin=30:60:(FileInfo.bytes/NChInDat/2)/20e3;



nRow=5;
nCol=2;

typeList=fieldnames(unitInfo);

doAppend='';
psFile='~/data/OCU/implanted/magician/kilo-vs-kwik.ps';


close all
fh=initFig4Nature(2);

waveWidth=9;
innerGapX=8;
innerGapY=8;
frHight=8;
frWidth=12;
acgHeight=10;
waveHeight=innerGapY+frHight+acgHeight;
marginX=8;
marginY=20;

interGapX=waveWidth+innerGapX+frWidth+innerGapX*2;
interGapY=innerGapY*2+waveHeight;

for ch=usedCh
    unitList={};
    for typeIdx=1:length(typeList)
        type=typeList{typeIdx};
        temp=find([unitInfo.(typeList{typeIdx}).ch]==ch);
        
        if length(temp)>nCol*nRow
            [~,order]=sort([unitInfo.(type)(temp).n],'descend');
            temp=temp(order);
            temp=temp(1:nCol*nRow);
        end
        
        [~,order]=sort([unitInfo.(type)(temp).amp],'descend');
        unitList{typeIdx}=temp(order);
    end

    nPage=ceil(max(cellfun(@length,unitList))/nRow/nCol);
    for page=1:nPage

        clf
        for typeIdx=1:length(typeList)      
            type=typeList{typeIdx};
                        
            for n=1:min(length(unitList{typeIdx})-nRow*nCol*(page-1),nRow*nCol)               
                
                totalGapX=(nCol*(typeIdx-1)+ceil(n/nRow)-1)*interGapX;
                totalGapY=mod(n-1,nRow)*interGapY;
                
                cIdx=unitList{typeIdx}(n+nRow*(page-1));
                
                subplotInMM(marginX+totalGapX,marginY+totalGapY,waveWidth,waveHeight,true)
                hold on

                waveT=(-nBef:nAft)/20;
                nCh=size(unitInfo.(type)(cIdx).wave.mean,2);

                meanWave=unitInfo.(type)(cIdx).wave.mean*0.195-(0:nCh-1)*200;
                
                for subCh=1:nCh
                    fill([waveT,flip(waveT)],...
                        [meanWave(:,subCh)+unitInfo.(type)(cIdx).wave.std(:,subCh)*0.195;
                         flip(meanWave(:,subCh)-unitInfo.(type)(cIdx).wave.std(:,subCh)*0.195)],0.5*[1,1,1],...
                         'edgeColor','none')                    
                end
                plot(waveT,meanWave,'k-')
                plot(nAft/20-[0,0.5,0.5],-10.3*200+[0,0,100],'k-')
                text(mean(nAft/20-[0,0.5]),-10.3*200,'0.5 ms','horizontalALign','center','verticalALign','top','fontsize',4)
                text(mean(nAft/20-0.5-0.05),mean(-10.3*200+[0,100]),'0.1 mV','horizontalALign','right','verticalALign','middle','fontsize',4)
                xlim(waveT([1,end]))
                ylim(200*[-10.5,1])
                axis off
                
                if length(unitInfo.(type)(cIdx).id)==2
                    title({sprintf('%s shank %d cluster %d',type,unitInfo.(type)(cIdx).id),[num2str(unitInfo.(type)(cIdx).n) ' spikes']})
                else
                    title({sprintf('%s cluster %d',type,unitInfo.(type)(cIdx).id),[num2str(unitInfo.(type)(cIdx).n) ' spikes']})
                end
                

                subplotInMM(marginX+waveWidth+innerGapX+totalGapX,marginY+totalGapY,frWidth,frHight,true)
                plot(tBin/60,unitInfo.(type)(cIdx).rate,'k-','linewidth',0.25)
                box off
                xlabel('time (min)')
                ylabel('FR (Hz)')
                title(sprintf('Mean = %4.2f Hz', mean(unitInfo.(type)(cIdx).rate)))

                subplotInMM(marginX+waveWidth+innerGapX+totalGapX,marginY+waveHeight-acgHeight+totalGapY,frWidth,acgHeight,true)
                bar(-30:30,unitInfo.(type)(cIdx).acg,1,'facecolor','k','linestyle','none')
                axis tight
                xlim(30*[-1,1])
                box off     
                xlabel('ms')
                ax=fixAxis;
                text2(1.1,1,...
                    {'IsoDist'
                    sprintf('%0.1f',unitInfo.(type)(cIdx).isoDist)
                    },ax,...
                    {'horizontalAlign','left','verticalAlign','bottom'});
                text2(1.1,0.9,...
                    {'L ratio'
                    sprintf('%0.2f',unitInfo.(type)(cIdx).Lratio)
                    },ax,...
                    {'horizontalAlign','left','verticalAlign','top'});
            end
        end
        
       subplotInMM(marginX+interGapX*nCol-innerGapX,marginY,1,interGapY*nRow,true)
        plot([0,0],[0,1],'k-')
        axis tight
        axis off
        
%         textInMM(marginX/2,marginY/2,sprintf('Units on ch %d (%d of %d)',ch,page,nPage),{'fontsize',12,'horizontalAlign','left','verticalAlign','bottom'})
        textInMM(marginX/2,marginY/2,sprintf('Units on ch %d',ch),{'fontsize',12,'horizontalAlign','left','verticalAlign','bottom'})
        
        addScriptName(mfilename);
        print(fh,psFile,'-dpsc',doAppend,'-painters')
        doAppend='-append';
    end
end

[~,temp]=fileattrib(psFile)
psFile=temp.Name;

eval(sprintf('! /usr/local/bin/ps2pdf %s %s && /bin/rm %s',psFile,[psFile(1:end-2) 'pdf'],psFile))

%%

    
     
    
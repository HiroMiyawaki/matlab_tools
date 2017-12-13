clear 

dataDir='~/data/OCU/Chamber_shockTest/shock_test/';

coreName='shockTest';

fh=fopen([dataDir 'shockTest.lfp']);
lfp=fread(fh,[32,inf],'int16');
fclose(fh);

%%

% 
% %%
% clf
% hold on
% for n=1:32
% plot(lfp(n,1:10000)-n*1000)
% end
varList={};


%%
clear basics
basics = LoadXml([dataDir coreName]);
varList{end+1}='basics';

%%
Window=1;
lfpSampleRate=basics.lfpSampleRate;
nFFT = 2^round(log2(2^11)); %compute nFFT according to different sampling rates
SpecWindow = 2^round(log2(Window*lfpSampleRate));% choose window length as power of two
FreqRange=[1,25];

clear wPxxAll PxxAll
for shIdx=1:length(basics.ElecGp)
    ChList=basics.ElecGp{shIdx}+1;
    for n=1:length(ChList)
        display([num2str(n) '/' num2str(length(ChList))])
        weeg = WhitenSignal(lfp(ChList(n),:),[],1);
        [wPxxAll{shIdx}(:,:,n),f,t]=mtcsglong(weeg,nFFT,lfpSampleRate,SpecWindow,[],2,'linear',[],FreqRange);
        [PxxAll{shIdx}(:,:,n),f2,t2]=mtcsglong(lfp(ChList(n),:),nFFT,lfpSampleRate,SpecWindow,[],2,'linear',[],FreqRange);
    end
end    

inRange=find(f>4 &f<10);
% outRange=find((f>1 &f<3)|(f>12 &f<15));
%%
thetaPow=cellfun(@(x) squeeze(mean(mean(x(:,inRange,:),2))),PxxAll,'uniformoutput',false);
[val,order]=cellfun(@(x) max(x), thetaPow);

clear Pxx
for shIdx=1:length(basics.ElecGp)
    ch(shIdx)=basics.ElecGp{shIdx}(order(shIdx))+1;
    Pxx(:,:,shIdx)=wPxxAll{shIdx}(:,:,order(shIdx));
end
[~,wholeOrder]=sort(val,'descend');    
% val(wholeOrder)
% ch(wholeOrder)

Pxx=Pxx(:,:,wholeOrder);
basics.Ch.theta=ch(wholeOrder);

imagescXY(t,f,squeeze(log(Pxx(:,:,1))));set(gca,'ylim',[0,80],'clim',[6,11]);colormap(jet);

save([basics.FileName '.eegseg.mat'],'Pxx','f','t','-v7.3');

%%
onset(1)=672991;
onset(2)=973623;
onset(3)=1274255;

% for n=1:3
%     subplot(1,3,n)
%     plot((-1250:2500)/1250,lfp(1,onset(n)+(-1250:2500)))
%     xlim([-0.5,1.5])
% end


eventTime.shock=[(onset/1250)',(onset/1250)'+1]*1e6;
eventTime.tone=[(onset/1250)'-30,(onset/1250)'-20]*1e6;

eventTime.badeby=mfilename;
varList{end+1}='eventTime';


for varIdx=1:length(varList)
    varName=varList{varIdx};
    save([basics.FileName '-' varName '.mat'],varName,'-v7.3')
end












clear
dataDir='~/data/OCU/tone24h/';
load([dataDir 'tone24hr-' 'behavior.mat']);


binSize=30;

sName='conditioning';

col.eachRat=0.5*[1,1,1];
col.tone=[1,0.8,0.3];
col.shock=[1,0,0];

close all
fh=initFig4JNeuro(2);

sesList=fieldnames(behavior);


titleText.habituation='Habituation';
titleText.conditioning='Conditioning';
titleText.context='Context retention';
titleText.extinction='Extinction';

legendText={['\color[rgb]{' num2str(col.tone) '}' 'Tone'],...
    ['\color[rgb]{' num2str(col.shock) '}' 'Shock'],...
    ['\color[rgb]{0,0,0}' 'Mean']};

nRaw=7;
eachRatCol=summer(6);

for sIdx=1:length(sesList)+1
    
    if sIdx==length(sesList)+1
        sName=sesList{sIdx-1};
    else
        sName=sesList{sIdx};
    end
    
    subplot(nRaw,1,sIdx)
    hold on
    t=behavior.(sName).time(1,:);
    tone=behavior.(sName).tone(1,:);
    tone=t([find(diff(tone)==1);find(diff(tone)==-1)]');
    
    shock=behavior.(sName).shock(1,:);
    shock=t([find(diff(shock)==1);find(diff(shock)==-1)]');
    
    clear temp
    
    for idx=1:size(tone,1)
        rectangle('position',[tone(idx,1),0,diff(tone(idx,:)),100],'facecolor',col.tone,'linestyle','none')
    end
    
    for idx=1:size(shock,1)
        rectangle('position',[shock(idx,1),0,diff(shock(idx,:)),100],'facecolor',col.shock,'linestyle','none')
    end
    
    for idx=1:3
        frameBin=binSize*behavior.(sName).fps(idx);
        
        target=behavior.(sName).freeze(idx,:);
        temp(idx,:)=mean(reshape(target(1:floor(length(target)/frameBin)*frameBin),frameBin,[]))*100;
        
        if behavior.(sName).ratName{idx}(end-1)=='_';
            behavior.(sName).ratName{idx}(end-1:end)=[];
        end
        
        plot((0.5:size(temp,2))*binSize,temp(idx,:),...
            '-',...
            ...
            'color',eachRatCol(idx,:))
        
    end
    
    hold on
    plot((0.5:size(temp,2))*binSize,mean(temp),'k-','linewidth',2)
    xlim([0,binSize*size(temp,2)])
    ylim([0,100])
    title(titleText.(sName))
    xlabel('Time (s)')
    ylabel('Freezing time (%)')
        
    ax=fixAxis;
    
    if sIdx==length(sesList)+1
        xlim([0,1300])
    end

    if sIdx==1
        text2(1.01,1,legendText,ax,{'horizontalAlign','left','verticalAlign','top'})
    end
end

subplot(nRaw,1,7)
text(0,1,{
    'Tone: 55 dB white noise, 10 sec, Shock: 18.5 KHz tone (max amp.), 1.0sec, Trace: 20 sec'
    'Context A: transparent square box on shock grid, 100 lux. Context B: white tube on smooth floor, 20 lux.'
    ['Freezing time were measured in ' num2str(binSize) ' s bins']
    'Rats explored in context A for 6 min > 24 Hr before contditioning (habituation).'
    'After 6 min base line periods, tone and shock were paired 4 times (ITI =  240 +/- 20 sec) in context A (conditioning)'
    '24 hr after conditioning, rats were returned to context A. (context retention)'
    'Then rats exposed to 30 sec white nose 30 times (ITI = 240 +/- 20 sec for first 3 times, ITI = 90 +/- 20 sec for remainings) in contextB (extinction)'
    },'verticalAlign','top')
axis off
addScriptName(mfilename)

print(fh,[dataDir 'tone24hr_summary.pdf'],'-dpdf')


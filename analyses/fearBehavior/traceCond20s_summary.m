clear
dataDir='~/data/OCU/20s_traceCond/';
load([dataDir 'traceCond-' 'behavior.mat']);


binSize=30;

sName='conditioning';

col.morning=[1,0.6,0.4];
col.evening=[0.4,0.4,1];
col.tone=[0.6,1,0.6];
col.shock=[1,0,0];

close all
fh=initFig4JNeuro(2);

sesList=fieldnames(behavior);

sesList=sesList(~strcmpi(sesList,'extinction'));

titleText.habituation='Habituation';
titleText.conditioning='Conditioning';
titleText.retention='Cue retention';
titleText.exRetention='Retention of extinction';
    
legendText={['\color[rgb]{' num2str(col.morning) '}' 'Morning'],...
            ['\color[rgb]{' num2str(col.evening) '}' 'Evening'],...
            ['\color[rgb]{' num2str(col.tone) '}' 'Tone'],...
            ['\color[rgb]{' num2str(col.shock) '}' 'Shock'],...
            ['\color[rgb]{0,0,0}' 'Mean']};

nRaw=6;
        
for sIdx=1:length(sesList)
    sName=sesList{sIdx};
    

    subplot(nRaw,1,sIdx)
    hold on
    t=behavior.(sName).time(1,:);
    tone=behavior.(sName).tone(1,:);
    tone=t([find(diff(tone)==1);find(diff(tone)==-1)]');

    shock=behavior.(sName).shock(1,:);
    shock=t([find(diff(shock)==1);find(diff(shock)==-1)]');

    marker.HR0005='^';
    marker.HR0006='v';
    marker.HR0007='o';
    marker.HR0008='s';

    clear temp

    for idx=1:size(tone,1)
        rectangle('position',[tone(idx,1),0,diff(tone(idx,:)),100],'facecolor',col.tone,'linestyle','none')
    end

    for idx=1:size(shock,1)
        rectangle('position',[shock(idx,1),0,diff(shock(idx,:)),100],'facecolor',col.shock,'linestyle','none')
    end

    for idx=1:4
    frameBin=binSize*behavior.(sName).fps(idx);

    target=behavior.(sName).freeze(idx,:);
    temp(idx,:)=mean(reshape(target(1:floor(length(target)/frameBin)*frameBin),frameBin,[]))*100;

    if behavior.(sName).ratName{idx}(end-1)=='_';
        behavior.(sName).ratName{idx}(end-1:end)=[];
    end

    plot((0.5:size(temp,2))*binSize,temp(idx,:),...
        '-','marker',marker.(behavior.(sName).ratName{idx}),...
        'markersize',4,...
        'color',col.(behavior.(sName).circadian{idx}))

    end

    hold on
    plot((0.5:size(temp,2))*binSize,mean(temp),'k-','linewidth',2)
    xlim([0,binSize*size(temp,2)])
    ylim([0,100])
    title(titleText.(sName))
    xlabel('Time (s)')
    ylabel('Freezing time (%)')
    ax=fixAxis;
    if sIdx==1
        text2(1.01,1,legendText,ax,{'horizontalAlign','left','verticalAlign','top'})
    end
end

subplot(nRaw,1,5)
text(0,1,{
        'Tone: 55 dB white noise, 10 sec, Shock: 0.2 mA, 1.0sec, Trace: 20 sec'
        'Context A: transparent square box on shock grid, 100 lux. Context B: white tube on smooth floor, 20 lux.' 
        ['Freezing time were measured in ' num2str(binSize) ' s bins']
        'Rats explored in context A for 6 min > 24 Hr before contditioning (habituation).'
        'After 6 min base line periods, tone and shock were paired 3 times in context A (conditioning)'
        '24 hr after conditioning, 10 sec white noise was presented in context B. (cue retention)'
        '24 hr after cue rtention test, rats exposed to 30 sec white nose 60 times (IEI = 90 sec ) in contextB (extinction)'
        '24 hr after extinction, cue retention was tested in different context B (retention of extinction)'
        'Experiment was done around 9:30 am (morning rat, n=2) or 6:00 pm (evening rats, n=2) '
        },'verticalAlign','top')
    axis off
addScriptName(mfilename)

print(fh,[dataDir 'traceCond20s_summary.pdf'],'-dpdf')


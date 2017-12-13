clear

dataDir='~/data/OCU/20s_traceCond/';

session=[];

idx=0;

idx=idx+1;
session(idx).name='20170327';
session(idx).rat='HR0005';
session(idx).type='habituation';
session(idx).circadian='morning';

idx=idx+1;
session(idx).name='20170327-1';
session(idx).rat='HR0006';
session(idx).type='habituation';
session(idx).circadian='evening';

idx=idx+1;
session(idx).name='20170328';
session(idx).rat='HR0005_2';
session(idx).type='conditioning';
session(idx).circadian='morning';

idx=idx+1;
session(idx).name='20170328-1';
session(idx).rat='HR0006';
session(idx).type='conditioning';
session(idx).circadian='evening';

idx=idx+1;
session(idx).name='20170329';
session(idx).rat='HR0005';
session(idx).type='retention';
session(idx).circadian='morning';

idx=idx+1;
session(idx).name='20170329-1';
session(idx).rat='HR0006';
session(idx).type='retention';
session(idx).circadian='evening';

idx=idx+1;
session(idx).name='20170330';
session(idx).rat='HR0005';
session(idx).type='extinction';
session(idx).circadian='morning';

idx=idx+1;
session(idx).name='20170330-1';
session(idx).rat='HR0006';
session(idx).type='extinction';
session(idx).circadian='evening';

idx=idx+1;
session(idx).name='20170331';
session(idx).rat='HR0005';
session(idx).type='exRetention';
session(idx).circadian='morning';

idx=idx+1;
session(idx).name='20170331-2';
session(idx).rat='HR0006';
session(idx).type='exRetention';
session(idx).circadian='evening';

idx=idx+1;
session(idx).name='20170331-1';
session(idx).rat='HR0007';
session(idx).type='habituation';
session(idx).circadian='morning';

idx=idx+1;
session(idx).name='20170331-1';
session(idx).rat='HR0008';
session(idx).type='habituation';
session(idx).circadian='evening';

idx=idx+1;
session(idx).name='20170404';
session(idx).rat='HR0007';
session(idx).type='conditioning';
session(idx).circadian='morning';

idx=idx+1;
session(idx).name='20170404-1';
session(idx).rat='HR0008';
session(idx).type='conditioning';
session(idx).circadian='evening';

idx=idx+1;
session(idx).name='20170405';
session(idx).rat='HR0007';
session(idx).type='retention';
session(idx).circadian='morning';

idx=idx+1;
session(idx).name='20170405-1';
session(idx).rat='HR0008';
session(idx).type='retention';
session(idx).circadian='evening';

idx=idx+1;
session(idx).name='20170406';
session(idx).rat='HR0007';
session(idx).type='extinction';
session(idx).circadian='morning';

idx=idx+1;
session(idx).name='20170406-1';
session(idx).rat='HR0008';
session(idx).type='extinction';
session(idx).circadian='evening';

idx=idx+1;
session(idx).name='20170407';
session(idx).rat='HR0007';
session(idx).type='exRetention';
session(idx).circadian='morning';

idx=idx+1;
session(idx).name='20170407-2';
session(idx).rat='HR0008';
session(idx).type='exRetention';
session(idx).circadian='evening';

for idx=1:length(session);
    [res,header,param,data]=readOharaXY([dataDir session(idx).name '/XYdata/' session(idx).rat '_XY.txt']);    

    rat=session(idx).rat;
    if strcmpi(rat,'HR0005_2'); rat='HR0005'; end
    id=(str2num(rat(3:end))-4);        
    behavior.(session(idx).type).freeze(id,:)=res.freeze;
    behavior.(session(idx).type).tone(id,:)=res.tone;
    behavior.(session(idx).type).shock(id,:)=res.shock;
    behavior.(session(idx).type).immobile(id,:)=res.immobile;
    behavior.(session(idx).type).time(id,:)=res.time;
    behavior.(session(idx).type).fps(id,:)=res.fps;
    behavior.(session(idx).type).circadian{id}=session(idx).circadian;
    behavior.(session(idx).type).ratName{id}=header.Animal_ID;
    behavior.(session(idx).type).date{id}=[header.Exp_Date ' ' header.Start_Time];
    behavior.(session(idx).type).madeby=mfilename;
end

save([dataDir 'traceCond-' 'behavior.mat'],'behavior','-v7.3');
    

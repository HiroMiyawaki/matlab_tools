clear

dataDir='~/data/OCU/4FPS_trace20s_x4/';

session=[];

idx=0;

idx=idx+1;
session(idx).name='20170417';
session(idx).rat='HR0009';
session(idx).type='habituation';

idx=idx+1;
session(idx).name='20170417';
session(idx).rat='HR0010';
session(idx).type='habituation';

idx=idx+1;
session(idx).name='20170417';
session(idx).rat='HR0011';
session(idx).type='habituation';

idx=idx+1;
session(idx).name='20170417';
session(idx).rat='HR0012';
session(idx).type='habituation';

idx=idx+1;
session(idx).name='20170417';
session(idx).rat='HR0013';
session(idx).type='habituation';

idx=idx+1;
session(idx).name='20170418';
session(idx).rat='HR0009';
session(idx).type='conditioning';

idx=idx+1;
session(idx).name='20170418';
session(idx).rat='HR0010';
session(idx).type='conditioning';

idx=idx+1;
session(idx).name='20170418-1';
session(idx).rat='HR0011';
session(idx).type='conditioning';

idx=idx+1;
session(idx).name='20170418-1';
session(idx).rat='HR0012';
session(idx).type='conditioning';

idx=idx+1;
session(idx).name='20170418-1';
session(idx).rat='HR0013';
session(idx).type='conditioning';

idx=idx+1;
session(idx).name='20170419';
session(idx).rat='HR0009';
session(idx).type='cue';

idx=idx+1;
session(idx).name='20170419-1';
session(idx).rat='HR0009';
session(idx).type='context';

idx=idx+1;
session(idx).name='20170419-3';
session(idx).rat='HR0010';
session(idx).type='cue';

idx=idx+1;
session(idx).name='20170419-2';
session(idx).rat='HR0010';
session(idx).type='context';

idx=idx+1;
session(idx).name='20170419-5';
session(idx).rat='HR0011';
session(idx).type='cue';

idx=idx+1;
session(idx).name='20170419-6';
session(idx).rat='HR0011';
session(idx).type='context';

idx=idx+1;
session(idx).name='20170419-8';
session(idx).rat='HR0012';
session(idx).type='cue';

idx=idx+1;
session(idx).name='20170419-7';
session(idx).rat='HR0012';
session(idx).type='context';

idx=idx+1;
session(idx).name='20170419-9';
session(idx).rat='HR0013';
session(idx).type='cue';

idx=idx+1;
session(idx).name='20170419-10';
session(idx).rat='HR0013';
session(idx).type='context';

idx=idx+1;
session(idx).name='20170420';
session(idx).rat='HR0009';
session(idx).type='extinction';

idx=idx+1;
session(idx).name='20170420';
session(idx).rat='HR0010';
session(idx).type='extinction';

idx=idx+1;
session(idx).name='20170420';
session(idx).rat='HR0011';
session(idx).type='extinction';

idx=idx+1;
session(idx).name='20170420';
session(idx).rat='HR0012';
session(idx).type='extinction';

idx=idx+1;
session(idx).name='20170420';
session(idx).rat='HR0013';
session(idx).type='extinction';

idx=idx+1;
session(idx).name='20170421';
session(idx).rat='HR0009';
session(idx).type='exRetention';

idx=idx+1;
session(idx).name='20170421';
session(idx).rat='HR0010';
session(idx).type='exRetention';

idx=idx+1;
session(idx).name='20170421';
session(idx).rat='HR0011';
session(idx).type='exRetention';

idx=idx+1;
session(idx).name='20170421';
session(idx).rat='HR0012';
session(idx).type='exRetention';

idx=idx+1;
session(idx).name='20170421';
session(idx).rat='HR0013';
session(idx).type='exRetention';


for idx=1:length(session);
    [res,header,param,data]=readOharaXY([dataDir session(idx).name '/XYdata/' session(idx).rat '_XY.txt']);    

    rat=session(idx).rat;

    id=(str2num(rat(3:end))-8);        
    behavior.(session(idx).type).freeze(id,:)=res.freeze;
    behavior.(session(idx).type).tone(id,:)=res.tone;
    behavior.(session(idx).type).shock(id,:)=res.shock;
    behavior.(session(idx).type).immobile(id,:)=res.immobile;
    behavior.(session(idx).type).time(id,:)=res.time;
    behavior.(session(idx).type).fps(id,:)=res.fps;
    behavior.(session(idx).type).ratName{id}=header.Animal_ID;
    behavior.(session(idx).type).date{id}=[header.Exp_Date ' ' header.Start_Time];
    behavior.(session(idx).type).madeby=mfilename;
end

save([dataDir 'twentyFour-' 'behavior.mat'],'behavior','-v7.3');
    

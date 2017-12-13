clear

dataDir='~/data/OCU/tone24h/';

session=[];

idx=0;

idx=idx+1;
session(idx).name='20170508';
session(idx).rat='HR0016';
session(idx).type='habituation';

idx=idx+1;
session(idx).name='20170508';
session(idx).rat='HR0017';
session(idx).type='habituation';

idx=idx+1;
session(idx).name='20170508';
session(idx).rat='HR0018';
session(idx).type='habituation';

idx=idx+1;
session(idx).name='20170509';
session(idx).rat='HR0016';
session(idx).type='conditioning';

idx=idx+1;
session(idx).name='20170509';
session(idx).rat='HR0017';
session(idx).type='conditioning';

idx=idx+1;
session(idx).name='20170509';
session(idx).rat='HR0018';
session(idx).type='conditioning';

idx=idx+1;
session(idx).name='20170510';
session(idx).rat='HR0016';
session(idx).type='context';

idx=idx+1;
session(idx).name='20170510-1';
session(idx).rat='HR0016';
session(idx).type='extinction';

idx=idx+1;
session(idx).name='20170510-2';
session(idx).rat='HR0017';
session(idx).type='context';

idx=idx+1;
session(idx).name='20170510-3';
session(idx).rat='HR0017';
session(idx).type='extinction';

idx=idx+1;
session(idx).name='20170510-4';
session(idx).rat='HR0018';
session(idx).type='context';

idx=idx+1;
session(idx).name='20170510-5';
session(idx).rat='HR0018';
session(idx).type='extinction';



for idx=1:length(session);
    [res,header,param,data]=readOharaXY([dataDir session(idx).name '/XYdata/' session(idx).rat '_XY.txt']);    

    rat=session(idx).rat;

    id=(str2num(rat(3:end))-15);        
    behavior.(session(idx).type).freeze(id,:)=res.freeze;
    behavior.(session(idx).type).tone(id,:)=res.tone;
    behavior.(session(idx).type).shock(id,:)=res.shock;
    behavior.(session(idx).type).immobile(id,:)=res.immobile;
    behavior.(session(idx).type).time(id,:)=res.time;
    if isfield(res,'timestamp')
        behavior.(session(idx).type).timestamp(id,:)=res.timestamp;
    end
    behavior.(session(idx).type).fps(id,:)=res.fps;
    behavior.(session(idx).type).ratName{id}=header.Animal_ID;
    behavior.(session(idx).type).date{id}=[header.Exp_Date ' ' header.Start_Time];
    behavior.(session(idx).type).madeby=mfilename;
end

save([dataDir 'tone24hr-' 'behavior.mat'],'behavior','-v7.3');
    

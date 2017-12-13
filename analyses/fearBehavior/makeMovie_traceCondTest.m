clear

dataDir='~/data/OCU/traceCond_test/';
saveDir='~/data/OCU/traceCond_test/movieWithDetection/';

setName={};
ratName={};
saveFileName={};
% 
% setName{end+1}='20170306';
% ratName{end+1}='HR0003';
% saveFileName{end+1}='Habituation';
% 
% setName{end+1}='20170306';
% ratName{end+1}='HR0004';
% saveFileName{end+1}='Habituation';
% 
% setName{end+1}='20170307';
% ratName{end+1}='HR0003';
% saveFileName{end+1}='Conditioning';
% 
% setName{end+1}='20170307';
% ratName{end+1}='HR0004';
% saveFileName{end+1}='Conditioning';
% 
% setName{end+1}='20170307-1';
% ratName{end+1}='HR0004';
% saveFileName{end+1}='01h_ContextRetention';
% 
% setName{end+1}='20170307-2';
% ratName{end+1}='HR0004';
% saveFileName{end+1}='01h_CueRetention';
% 
% setName{end+1}='20170307-3';
% ratName{end+1}='HR0003';
% saveFileName{end+1}='06h_ContextRetention';
% 
% setName{end+1}='20170307-4';
% ratName{end+1}='HR0003';
% saveFileName{end+1}='06h_CueRetention';
% 
% setName{end+1}='20170307-5';
% ratName{end+1}='HR0004';
% saveFileName{end+1}='06h_ContextRetention';
% 
% setName{end+1}='20170307-6';
% ratName{end+1}='HR0004';
% saveFileName{end+1}='06h_CueRetention';
% 
% setName{end+1}='20170308';
% ratName{end+1}='HR0003';
% saveFileName{end+1}='24h_ContextRetention';
% 
% setName{end+1}='20170308-1';
% ratName{end+1}='HR0003';
% saveFileName{end+1}='24h_CueRetention';
% 
% setName{end+1}='20170308-2';
% ratName{end+1}='HR0004';
% saveFileName{end+1}='24h_ContextRetention';
% 
% setName{end+1}='20170308-3';
% ratName{end+1}='HR0004';
% saveFileName{end+1}='24h_CueRetention';

% setName{end+1}='20170312';
% ratName{end+1}='HR0003';
% saveFileName{end+1}='00h_Extinction';
% 
% setName{end+1}='20170312-1';
% ratName{end+1}='HR0003';
% saveFileName{end+1}='01h_extRetention';
% 
% setName{end+1}='20170312-2';
% ratName{end+1}='HR0003';
% saveFileName{end+1}='06h_extRetention';
% 
% setName{end+1}='20170313';
% ratName{end+1}='HR0003';
% saveFileName{end+1}='24h_extRetention';

for idx=1:length(setName)
    clear err
%     try
        close all
        makeFreezeMov(dataDir,setName{idx},ratName{idx},[saveDir  ratName{idx} '_' saveFileName{idx} '.mp4'],4)

%     catch err
%         txt = [datestr(now),'\n'];
%         
%         display(' ')
%         display(' ')
%         display([datestr(now) 'clashed ' saveFileName{idx} '-' ratName{idx}])
%         for n=1:size(err.stack,1)
%             txt=[txt,'\n', err.stack(n).file , ' at line' , num2str(err.stack(n).line)];
%             display(['      ' err.stack(n).file , ' at line' , num2str(err.stack(n).line)])
%         end
%         display(' ')
%         display(' ')
%         
%         mail(txt,['Crashed: '  saveFileName{idx} '-' ratName{idx}])
%     end
% 
%     if ~exist('err','var')
%         mail(datestr(now),['Finished: ' saveFileName{idx} '-' ratName{idx}])
%         
%         display(' ')
%         display(' ')
%         display([datestr(now) 'finish ' saveFileName{idx} '-' ratName{idx}])
%         display(' ')
%         display(' ')
%     end
end






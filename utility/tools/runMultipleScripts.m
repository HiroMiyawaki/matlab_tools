function runMultipleScripts(scriptList)

scriptIndex=0;
save('~/Desktop/runMultipleScriptsTemp.mat','-v7.3','scriptList','scriptIndex')

for n=1:length(scriptList)
    load('~/Desktop/runMultipleScriptsTemp.mat');
    scriptIndex=scriptIndex+1;
    save('~/Desktop/runMultipleScriptsTemp.mat','-v7.3','scriptList','scriptIndex')
    
    if scriptIndex>length(scriptList)
        display('All Done')
        pID=num2str(feature('getpid'));
        unix(['rm ~/Desktop/runMultipleScriptsTemp_' pID '.mat']);
        unix('rm ~/Desktop/runMultipleScriptsTemp.mat');
        return
    end
    
    pID=num2str(feature('getpid'));
    save(['~/Desktop/runMultipleScriptsTemp_' pID '.mat'],'-v7.3','scriptList','scriptIndex')
    clear err
    try
        display([datestr(now) ' start '  scriptList{scriptIndex}])
        eval(scriptList{scriptIndex})
    catch err
        dumpFileName=['~/Desktop/dump-' datestr(now,'yymmdd-HHMM-SS.FFF') '.mat'];
        save(dumpFileName);
%         load('~/Desktop/runMultipleScriptsTemp.mat');
        pID=num2str(feature('getpid'));
        load(['~/Desktop/runMultipleScriptsTemp_' pID '.mat'])
        txt = [datestr(now),'\n'];
        for n=1:size(err.stack,1)
            txt=[txt,'\n', err.stack(n).file , ' at line' , num2str(err.stack(n).line)];
        end
        
        if FileExists('~/Desktop/runMultipleScriptsResults.mat')
            load('~/Desktop/runMultipleScriptsResults.mat')
        end
        res.(scriptList{scriptIndex}).status=false;
        res.(scriptList{scriptIndex}).date=datestr(now);
        res.(scriptList{scriptIndex}).massage=err;
        res.(scriptList{scriptIndex}).dumpfile=dumpFileName;
        save('~/Desktop/runMultipleScriptsResults.mat','-v7.3','res')
        
        display([datestr(now) ' crashed: '  scriptList{scriptIndex}])
        mail(txt,['crashed: ' scriptList{scriptIndex}]);

    end
    if ~exist('err','var')
        
%         load('~/Desktop/runMultipleScriptsTemp.mat');
        pID=num2str(feature('getpid'));
        load(['~/Desktop/runMultipleScriptsTemp_' pID '.mat'])
        if FileExists('~/Desktop/runMultipleScriptsResults.mat')
            load('~/Desktop/runMultipleScriptsResults.mat');
        end
        res.(scriptList{scriptIndex}).status=true;
        res.(scriptList{scriptIndex}).date=datestr(now);
        res.(scriptList{scriptIndex}).massage='';
        save('~/Desktop/runMultipleScriptsResults.mat','-v7.3','res');
        
        display([datestr(now) ' finished: '  scriptList{scriptIndex}])
        mail([datestr(now),' finished'],['finished:' scriptList{scriptIndex}]);
    end
end
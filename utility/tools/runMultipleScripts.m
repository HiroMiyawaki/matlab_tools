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
        %         mail(txt,['crashed: ' scriptList{scriptIndex}]);
        sendResult(['crashed: ' scriptList{scriptIndex}],txt,'miyawaki625@gmail.com')
        
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
        %         mail([datestr(now),' finished'],['finished:' scriptList{scriptIndex}]);
        sendResult([datestr(now),' finished'],['finished:' scriptList{scriptIndex}],'miyawaki625@gmail.com')
    end
end
end
function sendResult(mailTitle,mailBody,address)
fprintf('%s\n',mailTitle)
fprintf(mailBody)
fprintf('\n\n')
try
    setpref('Internet','E_mail','mizusekilab@gmail.com');
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username','mizusekilab');
    setpref('Internet','SMTP_Password','OsakaCityUniv2015');
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    sendmail(address,mailTitle,sprintf(mailBody));
catch
    disp('Failed to send e-mail... anyway, the show must go on.')
end

end

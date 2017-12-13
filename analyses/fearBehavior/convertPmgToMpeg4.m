rootDir='~/data/OCU/eyelid_2CS/HR0025';

temp=dir(rootDir);
filenameList={temp([temp.isdir]).name};
filenameList=filenameList(~(strcmp(filenameList,'.')|strcmp(filenameList,'..')));

% filenameList={'HR0025_2017-08-24-084034'
% 'HR0025_2017-08-24-124034'
% 'HR0025_2017-08-24-1709'};

for fIdx=1:length(filenameList)
    filename=filenameList{fIdx};
    fList=dir([rootDir '/' filename '/' filename '*.pgm']);
    nFile=length(fList);

    videoName=[rootDir '/' filename '.mp4'];


    v = VideoWriter(videoName,'MPEG-4');
    v.FrameRate=25;

    open(v);
    prog=0.05;

    disp([datestr(now) ' Processsing ' filename]) 
    for idx=0:nFile-1
        if idx/nFile>prog
            disp(['    ' datestr(now) ' ' num2str(prog*100) ' % of ' filename ' was done']) 
            prog=prog+0.05;
        end 
        fName=[rootDir '/' filename '/' filename '-' num2str(idx,'%04d') '.pgm'];

        frame=imread(fName);
        writeVideo(v,frame);
    end
    close(v)
    disp([datestr(now) ' ' filename ' was generated']) 
end


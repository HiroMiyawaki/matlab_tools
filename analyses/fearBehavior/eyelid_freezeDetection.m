videoFolderList={};
videofileList={};
for n=1:2
    switch n
        case 1
            dataDirRoot='~/data/OCU/eyelid_behavior/HR0020/';
        case 2
            dataDirRoot='~/data/OCU/eyelid_behavior/HR0021/';
    end
    temp=dir([dataDirRoot '*mp4']);
    videoFolderList={videoFolderList{:},temp.folder};
    videofileList={videofileList{:},temp.name};
end
%%
imageRange={};
for idx=1:length(videofileList)
    vr=VideoReader(fullfile(videoFolderList{idx},videofileList{idx}));
    fr=readFrame(vr);
    close all
    fh=figure('position',[200,1000,1280,960]);
    imagesc(fr(:,:,1));
    axis equal
    set(gca,'clim',[0,255]);
    colormap(gray);
    title('Select area to show')
    [y,x]=ginput(2);
    xRange=[floor(min(x)),ceil(max(x))];
    yRange=[floor(min(y)),ceil(max(y))];
    imageRange{idx}=[xRange,yRange];
end

%%
for idx=1:length(videofileList)
    freezeDetectionColor(fullfile(videoFolderList{idx},videofileList{idx}),imageRange{idx})
end


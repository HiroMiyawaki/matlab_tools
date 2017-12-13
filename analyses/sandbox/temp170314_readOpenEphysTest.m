clear

fileName='/Volumes/USBMEM/openephys_2017-03-14_14-18-17/110_CH1.continuous';


[data, timestamps, info]=load_open_ephys_data_faster(fileName);
plot((1:length(data))/info.header.sampleRate,data,'k-')

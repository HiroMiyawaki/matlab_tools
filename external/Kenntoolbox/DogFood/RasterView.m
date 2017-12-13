function RasterView(Eeg, Crossings, Whl, Res, Clu, MyClu, TimeSeg, Colors, fs)
% RasterView(Eeg0, Crossings, Whl, Res, Clu, MyClu, TimeSeg, Colors, fs)
% plots eeg and a raster of spikes in time windown
% TimeSeg is [Start End] in .res units
% fs is sample rate.

ResInRange = (Res>=TimeSeg(1) & Res<=TimeSeg(2));

if isempty(MyClu)
    MyClu = intersect(unique(Clu(find(ResInRange))), 2:max(Clu));
end   

if nargin<8 | isempty(Colors)
    ColorOrder = get(gca, 'colororder');
    ColorNo = mod(1:length(MyClu), size(ColorOrder,1))+1;
    Colors = ColorOrder(ColorNo,:);
end

hold off
if length(Crossings)>0
    MyCrossings = find(Crossings>=TimeSeg(1) & Crossings<=TimeSeg(2));
    plot(repmat(Crossings(MyCrossings)/fs,1,2), [-6 length(MyClu)+1], 'color', [1 1 1]*.7);
end

hold on
for c=1:length(MyClu)
    MyRes = Res(find(ResInRange & Clu==MyClu(c)));
    plot(repmat(MyRes(:)',2,1)/fs, repmat(c+[0;.6],1,length(MyRes)), 'color', Colors(c,:), 'linewidth', 3);
end    

% set(gca, 'ytick', 1.45:length(MyClu)+.45);
% set(gca, 'yticklabel', MyClu);
set(gca, 'ytick', []);
set(gca, 'xtick', []);

if ~isempty(Eeg)
    er = TimeSeg(1)/16:TimeSeg(2)/16;
    plot(er/fs*16, Eeg(1+er)/2000 - 3, 'k', 'linewidth', 1);
end

% wr = 1+floor(TimeSeg(1)/512):1+floor(TimeSeg(2)/512);
% plot(wr*512/20000, -2+Whl(wr,:)/300);

ylim([-6 length(MyClu)+1]);
xlim(TimeSeg/fs);


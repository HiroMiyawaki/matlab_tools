% Peaks = ExamineTemporal(Out, Par, CellNo);
%
% looks at time domain smoothing of a .pout file
%
% returns peak value and location (interpolated) for both spatial
% and non-spatial, then non-spatial and spatial prediction at ts=6 
% (should be 8 or 25ms) and space-only.
% [pValNS pPosNS pValS pPosS ValNS8 ValS8 ValSO], 1 row per cell.
%
%
% See LoadPoutFile.

function [Peaks, Gains] = ExamineTemporal(Out, Par, c);

Predicted = find(Par.TetNo>0);

SpaceScale = 91/256*350;
TimeScale = 1000/Par.InternalFreq;
ss = 2;
Peaks = [];
%Converged = permute(all(all(Out.nIter>=0 & Out.nIter<=100, 2), 3), [1 4 2 3]);
% Converged = permute(all(all(Out.Status>=0, 2), 3), [1 4 2 3]);

IntRange = Par.TimeSm(2)*TimeScale:.1:max(Par.TimeSm)*TimeScale;
    
%if they didn't all converge, go on
% if ~all(Converged(c,:))
%     fprintf('not all converged!\n');
% %    return; 
% end;

if all(~isfinite(Out.TotBitsSec(c,:)))
    fprintf('All values NaN\n');
    return;
end

[nCells nTimeSm nSpaceSm nPhSm] = size(Out.TotBitsSec);
SqArray = reshape(Out.TotBitsSec(c,:,:,:),[nTimeSm nSpaceSm*nPhSm]);
% find peaks in interpolated data.
yl = [nanmin(Out.TotBitsSec(c,:)) nanmax(Out.TotBitsSec(c,:))+eps];
figure(1)
for p=1:nPhSm
    subplot(1,nPhSm,p);
	hold off
%	plot(Par.TimeSm(2:end)*TimeScale, SqArray(2:end,1:2)', '.-');
	plot(Par.TimeSm(2:end)*TimeScale, sq(Out.TotBitsSec(c,2:end,1:2,p))', '.-');
	hold on
	plot(xlim, [1;1]*sq(Out.TotBitsSec(c,1,1:2,p))');
     drawnow
    ylim(yl);
end

figure(2)
[dummy t25] = min(abs(Par.TimeSm/Par.InternalFreq - 0.025));
PopGainNoPh = Out.TotBitsSec(:,t25,2,1)-Out.TotBitsSec(:,1,2,1);
PopGainMeanPh = Out.TotBitsSec(:,t25,2,2)-Out.TotBitsSec(:,1,2,2);
PopGainPh = Out.TotBitsSec(:,t25,2,3)-Out.TotBitsSec(:,1,2,3);
gr = [min([PopGainNoPh;PopGainMeanPh;PopGainPh]) max([PopGainNoPh;PopGainMeanPh;PopGainPh])]
br = [min(Out.TotBitsSec(:)) max(Out.TotBitsSec(:))];
subplot(2,2,1);
plot(PopGainNoPh, PopGainMeanPh, 'o', gr, gr);
xlabel('gain over space'); ylabel('gain over space+mean phase');
subplot(2,2,2);
plot(PopGainNoPh, PopGainPh, 'o', gr, gr);
xlabel('gain over space'); ylabel('gain over space*phase');

subplot(2,2,3);
plot(Out.TotBitsSec(:,1,2,3), Out.TotBitsSec(:,t25,2,3), '.', br, br);
xlabel('bits from phase*space'); ylabel('bits from pop + phase*space');

subplot(2,2,4);
plot(Out.TotBitsSec(:,1,2,3)-Out.TotBitsSec(:,1,2,1), Out.TotBitsSec(:,t25,2,3)-Out.TotBitsSec(:,1,2,3), '.');
xlabel('gain from phase over space'); ylabel('additional gain from population');


Gains = [PopGainNoPh PopGainMeanPh PopGainPh];


% return

intbits1 = interp1(Par.TimeSm(2:end)*TimeScale, sq(Out.TotBitsSec(c,1,2:end)), IntRange, 'spline', NaN);
intbits2 = interp1(Par.TimeSm(2:end)*TimeScale, sq(Out.TotBitsSec(c,2,2:end)), IntRange, 'spline', NaN);
[Peak1 Pos1] = max(intbits1);
[Peak2 Pos2] = max(intbits2);
Peaks = [Peaks ; [Peak1, IntRange(Pos1), Peak2, IntRange(Pos2) ...
            , Out.TotBitsSec(c,1,6), Out.TotBitsSec(c,2,6), Out.TotBitsSec(c,2,1)]];
return
hold off
plot(IntRange, [intbits1' intbits2'], '-');
hold on
plot(xlim, [1;1]*Out.TotBitsSec(c,:,1));
 drawnow
%     pause;
    

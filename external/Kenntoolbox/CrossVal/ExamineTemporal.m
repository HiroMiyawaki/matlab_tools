% [Gains Peaks] = ExamineTemporal(Out, Par, CellNo);
%
% looks at time domain smoothing of a .pout file
%
% returns info gains and peak value and location (interpolated) for both spatial
% and non-spatial, then non-spatial and spatial prediction at ts=6 
% (should be 8 or 25ms) and space-only.
% [pValNS pPosNS pValS pPosS ValNS8 ValS8 ValSO], 1 row per cell.
%
%
% See LoadPoutFile.

function [Gains, Peaks] = ExamineTemporal(Out, Par, c);

if (Par.VersionNumber<17) 
    Predicted = find(Par.TetNo>0);
else
    Predicted = find(any(Par.CanPred,1));
end

SpaceScale = 91/256*350;
TimeScale = 1000/Par.InternalFreq;
%Converged = permute(all(all(Out.nIter>=0 & Out.nIter<=100, 2), 3), [1 4 2 3]);
% Converged = permute(all(all(Out.Status>=0, 2), 3), [1 4 2 3]);

    
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
if nPhSm==1
    % pad it with zeros in phase
    Out.TotBitsSec(:,:,:,2:3) = 0;
    nPhSm = 3;
end
SqArray = reshape(Out.TotBitsSec(c,:,:,:),[nTimeSm nSpaceSm*nPhSm]);
% find peaks in interpolated data.
yl = [nanmin(Out.TotBitsSec(c,:)) nanmax(Out.TotBitsSec(c,:))+eps];
figure(1)
for p=1:nPhSm
    subplot(1,nPhSm,p);
	hold off
%	plot(Par.TimeSm(2:end)*TimeScale, SqArray(2:end,1:2)', '.-');
	plot(Par.TimeSm(2:end)*TimeScale, sq(Out.TotBitsSec(c,2:end,1:nSpaceSm,p))', '.-');
	hold on
	plot(xlim, [1;1]*sq(Out.TotBitsSec(c,1,1:nSpaceSm,p))');
     drawnow
    ylim(yl);
end

figure(2)
[dummy t25] = min(abs(Par.TimeSm/Par.InternalFreq - 0.025));
PopGainNoPh = Out.TotBitsSec(:,t25,2,1)-Out.TotBitsSec(:,1,2,1);
PopGainMeanPh = Out.TotBitsSec(:,t25,2,2)-Out.TotBitsSec(:,1,2,2);
PopGainPh = Out.TotBitsSec(:,t25,2,3)-Out.TotBitsSec(:,1,2,3);
gr = [min([PopGainNoPh;PopGainMeanPh;PopGainPh]) max([PopGainNoPh;PopGainMeanPh;PopGainPh])];
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

if nargout>=2
	figure(3)
	IntRange = Par.TimeSm(2)*TimeScale:.1:max(Par.TimeSm)*TimeScale;
    Peaks = NaN*ones(Par.nCells, 2, 4);
	
	for c=Predicted(:)'
        for gp=1:4
            SpaceSm=1+(gp>1);
            PhSm=gp-(gp>1);
            % peaks returned: 1) Pop only 2) Pop over space 3) Pop over space+const ph 4) Pop over phase shift
            intbits = interp1(Par.TimeSm(2:end)*TimeScale, sq(Out.TotBitsSec(c,2:end,SpaceSm,PhSm)), ...
                IntRange, 'spline', NaN);
            
            [Peak1 Pos1] = max(intbits);
            Peaks(c,1,gp) = IntRange(Pos1);
            Peaks(c,2,gp) = Peak1;
        end
	end
end

return
hold off
plot(IntRange, [intbits1' intbits2'], '-');
hold on
plot(xlim, [1;1]*Out.TotBitsSec(c,:,1));
 drawnow
%     pause;
    

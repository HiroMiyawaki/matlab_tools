% [ThetaPh ThetaAmp TotPhase] = ThetaPhase(Eeg, FreqRange, FilterOrd, Ripple)
%
% takes a 1-channel Eeg file (assumes 1252 Hz) and produces
% instantaneous theta phase and amplitude.  TotPhase is
% unwrapped phase.
%
% Theta is filtered with filtfilt and a cheby2 filter with parameters
% FreqRange, FilterOrd, Ripple defautls [4 10], 4, 20.
% good values for gamma are [40 100], 8, 20.
%
% if no args are provided, will plot some diagnostics

function [ThetaPh, ThetaAmp, TotPhase] = ThetaPhase(Eeg, FreqRange, FilterOrd, EegRate)

if nargin<2, FreqRange = [4 11]; end
if nargin<3, FilterOrd = 4; end;		
if nargin<4, EegRate = 1252; end;

% if min(size(Eeg)>1)
% 	error('Eeg should be 1 channel only!');
% elseif size(Eeg,1)==1
%     Eeg = Eeg(:);
% end

NFreq = EegRate/2;
Eegf = ButFilter(Eeg,FilterOrd,FreqRange/NFreq,'bandpass');

% remove constant term to avoid bias
% Eegf = Eegf - mean(Eegf);
if nargout>0, clear Eeg; end;
Hilb = Shilbert(Eegf);
if nargout>0, clear Eegf; end;
ThetaPh = angle(Hilb);

if nargout>=2
	ThetaAmp = abs(Hilb);
end
if nargout>=3
	TotPhase = unwrap(ThetaPh);
end

if nargout==0
    subplot(3,1,1);
    [h w s] = freqz(b, a, 2048, EegRate);
    plot(w,abs(h));
    grid on
    title('frequncy response of filter');
    
    subplot(3,1,2)
    xr = (1:length(Eeg))*1000/EegRate;
    plot(xr, [Eeg, Eegf]);
    title('eeg');
    legend('raw', 'filtered');
    
    subplot(3,1,3);
    plot(xr, [Eegf, ThetaPh*std(Eegf)]);
    clear ThetaPh
    title('extracted phase');
    legend('filtered wave', 'phase');
end

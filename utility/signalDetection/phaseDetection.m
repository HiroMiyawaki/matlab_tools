% [ThetaPhase ThetaAmp TotPhase] = ThetaPhase(Eeg, FreqRange, FilterOrd, Ripple)
%
% takes a 1-channel Eeg file (assumes 1250 Hz) and produces
% instantaneous theta phase and amplitude.  TotPhase is
% unwrapped phase.
%
% Theta is filtered with filtfilt and a cheby2 filter with parameters
% FreqRange, FilterOrd, Ripple defautls [4 10], 4, 20.
% good values for gamma are [40 100], 8, 20.
%
% if no args are provided, will plot some diagnostics

function [ThetaPhase, ThetaAmp, TotPhase] = phaseDetection(Eeg, FreqRange,sampleFreq,FilterLength)

    % if nargin<2, FreqRange = [4 10]; end
    % if nargin<3, FilterOrd = 4; end;		
    % if nargin<4, Ripple = 20; end;

    if min(size(Eeg)>1)
        error('Eeg should be 1 channel only!');
    elseif size(Eeg,1)==1
        Eeg = Eeg(:);
    end


    %[b a] = Scheby2(FilterOrd, Ripple, FreqRange/625);
    %Eegf = Sfiltfilt(b,a,Eeg);
    % remove constant term to avoid bias

    BPfil = fir1(FilterLength,FreqRange*2/sampleFreq);

    fprintf('start filtering EEG at%d-%d-%d %d:%d:%d \n\n', fix(clock))

    Eegf =Filter0(BPfil,Eeg);

    % [b,a]=cheby2(FilterOrd,Ripple,FreqRange/sampleFreq,'bandpass');
    % [Eegf, z] = filter(b,a,Eeg);
    % shift = (length(b)-1)/2;
    % Eegf = [Eegf(shift+1:end,:) ; z(1:shift,:)];

    Eegf = Eegf - mean(Eegf);
    if nargout>0, clear Eeg; end;

    fprintf('start Hilbert transform at%d-%d-%d %d:%d:%d \n\n', fix(clock))
    
    Hilb = Shilbert(Eegf);
    
    if nargout>0, clear Eegf; end;
    ThetaPhase = angle(Hilb);

    if nargout>=2
        ThetaAmp = abs(Hilb);
    end
    if nargout>=3
        TotPhase = unwrap(ThetaPhase);
    end

    if nargout==0
        subplot(3,1,1);
        [h w s] = freqz(b, a, 2048, 1250);
        plot(w,abs(h));
        grid on
        title('frequncy response of filter');

        subplot(3,1,2)
        xr = (1:length(Eeg))*1000/1250;
        plot(xr, [Eeg, Eegf]);
        title('eeg');
        legend('raw', 'filtered');

        subplot(3,1,3);
        plot(xr, [Eegf, ThetaPhase*std(Eegf)]);
        clear ThetaPhase
        title('extracted phase');
        legend('filtered wave', 'phase');
    end
end
function [correlationOutput, lags, ...
    peakValue, peakLag, estimatedBurstStart] = ...
    find_burst(receivedSignal, referenceBurst)

% Correlate received signal with known reference
[correlationOutput, lags] = ...
    xcorr(receivedSignal, referenceBurst);

% Find strongest match
[peakValue, peakIndex] = ...
    max(abs(correlationOutput));

peakLag = lags(peakIndex);

% Convert lag into estimated burst start
estimatedBurstStart = peakLag + 1;

end
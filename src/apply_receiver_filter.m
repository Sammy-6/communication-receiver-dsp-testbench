function [filteredAligned, filteredSignal, b] = ...
    apply_receiver_filter(rxSignal, Fs, ...
    cutoffFrequency, filterOrder)

% Normalize cutoff
normalizedCutoff = cutoffFrequency / (Fs/2);

% Design FIR low-pass filter
b = fir1(filterOrder, normalizedCutoff, 'low');

% Apply filter
filteredSignal = filter(b, 1, rxSignal);

% Compensate linear-phase FIR delay
filterDelay = filterOrder / 2;

filteredAligned = [ ...
    filteredSignal(filterDelay+1:end), ...
    zeros(1, filterDelay)];

end
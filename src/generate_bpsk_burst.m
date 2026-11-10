function [burst, symbols, samplesPerSymbol] = ...
    generate_bpsk_burst(bits, Fs, Rs)

samplesPerSymbol = Fs / Rs;

% Map bits:
% 1 --> +1
% 0 --> -1
symbols = 2*bits - 1;

% Represent each symbol with multiple samples
burst = repelem(symbols, samplesPerSymbol);

end
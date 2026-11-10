function [rxSignal, noisySignal, noise, interference] = ...
    add_channel_impairments(txSignal, burst, Fs, ...
    SNR_dB, interferenceFrequency, interferenceAmplitude)

% Signal power based on transmitted BPSK burst
signalPower = mean(burst.^2);

% Noise power required for desired SNR
noisePower = signalPower / (10^(SNR_dB/10));

% Generate AWGN
noise = sqrt(noisePower) * randn(size(txSignal));

% Add noise
noisySignal = txSignal + noise;

% Time axis
t = (0:length(txSignal)-1) / Fs;

% Narrowband interference
interference = interferenceAmplitude * ...
    sin(2*pi*interferenceFrequency*t);

% Final received signal
rxSignal = noisySignal + interference;

end
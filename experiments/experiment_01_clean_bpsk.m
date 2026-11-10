%% Experiment 01 - Generate a clean BPSK signal

clear;
clc;
close all;

%% Results folder

projectRoot = fileparts(fileparts(mfilename('fullpath')));
resultsDir = fullfile(projectRoot, 'results', 'matlab');

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

%% 1. Basic system settings

Fs = 20000;     % Sampling frequency = 20,000 samples/second
Rs = 1000;      % Symbol rate = 1,000 symbols/second

samplesPerSymbol = Fs / Rs;

%% 2. Create some information bits

bits = [1 0 1 1 0 0 1 0 1 0];

%% 3. Convert the bits into BPSK symbols
% BPSK mapping:
% bit 1 --> +1
% bit 0 --> -1

symbols = 2*bits - 1;

%% 4. Represent each symbol using several samples

txSignal = repelem(symbols, samplesPerSymbol);

%% 5. Create a time axis

t = (0:length(txSignal)-1) / Fs;

%% 6. Display useful information

fprintf('Sampling frequency = %.0f Hz\n', Fs);
fprintf('Symbol rate = %.0f symbols/s\n', Rs);
fprintf('Samples per symbol = %.0f\n', samplesPerSymbol);

%% 7. Plot the transmitted signal

fig1 = figure;

plot(t, txSignal, 'LineWidth', 1.5);

xlabel('Time (seconds)');
ylabel('Amplitude');
title('Clean BPSK Transmitted Signal');

grid on;

ylim([-1.5 1.5]);

%% Save figure

exportgraphics( ...
    fig1, ...
    fullfile(resultsDir, '01_clean_bpsk_signal.png'), ...
    'Resolution', 300);
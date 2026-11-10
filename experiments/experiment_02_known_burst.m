%% Experiment 02 - Place a known BPSK burst inside a longer frame

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

Fs = 20000;     % Sampling frequency
Rs = 1000;      % Symbol rate

samplesPerSymbol = Fs / Rs;

%% 2. Known bit sequence

bits = [1 0 1 1 0 0 1 0 1 0];

%% 3. Convert bits to BPSK symbols
% 1 --> +1
% 0 --> -1

symbols = 2*bits - 1;

%% 4. Convert symbols to sampled waveform

burst = repelem(symbols, samplesPerSymbol);

%% 5. Create a longer empty observation frame

frameLength = 1000;

txFrame = zeros(1, frameLength);

%% 6. Choose where the burst will begin

burstStart = 350;

burstEnd = burstStart + length(burst) - 1;

%% 7. Insert the known burst into the frame

txFrame(burstStart:burstEnd) = burst;

%% 8. Create time axis

t = (0:frameLength-1) / Fs;

%% 9. Plot the complete transmitted frame

fig1 = figure;

plot(t, txFrame, 'LineWidth', 1.4);

xlabel('Time (seconds)');
ylabel('Amplitude');
title('Known BPSK Burst Inside Observation Frame');

grid on;
ylim([-1.5 1.5]);

%% 10. Display useful information

fprintf('Frame length = %d samples\n', frameLength);
fprintf('Burst length = %d samples\n', length(burst));
fprintf('Burst starts at sample = %d\n', burstStart);
fprintf('Burst ends at sample = %d\n', burstEnd);

%% Save figure

exportgraphics( ...
    fig1, ...
    fullfile(resultsDir, '02_known_bpsk_burst_in_frame.png'), ...
    'Resolution', 300);
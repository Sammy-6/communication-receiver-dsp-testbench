%% Experiment 10 - Signal absent test

clear;
clc;
close all;

rng(10);


%% Results folder

projectRoot = fileparts(fileparts(mfilename('fullpath')));
resultsDir = fullfile(projectRoot, 'results', 'matlab');

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end
%% Make src functions available

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'src'));

%% 1. System settings

Fs = 20000;
Rs = 1000;

bits = [1 0 1 1 0 0 1 0 1 0];

%% 2. Generate known reference burst

burst = generate_bpsk_burst(bits, Fs, Rs);

%% 3. Create EMPTY observation frame
% No useful BPSK burst is transmitted

frameLength = 1000;

txFrame = zeros(1, frameLength);

%% 4. Channel conditions

SNR_dB = 10;

interferenceFrequency = 4000;
interferenceAmplitude = 0.8;

[rxSignal, ~, ~, ~] = ...
    add_channel_impairments( ...
    txFrame, burst, Fs, ...
    SNR_dB, interferenceFrequency, ...
    interferenceAmplitude);

%% 5. Receiver filtering

cutoffFrequency = 2000;
filterOrder = 80;

[filteredAligned, ~, ~] = ...
    apply_receiver_filter( ...
    rxSignal, Fs, ...
    cutoffFrequency, filterOrder);

%% 6. Search for the known burst

[correlationOutput, lags, ...
    peakValue, peakLag, ...
    estimatedBurstStart] = ...
    find_burst(filteredAligned, burst);

%% 7. Detection decision

thresholdFraction = 0.60;

[decision, threshold, burstEnergy] = ...
    detect_signal( ...
    peakValue, burst, thresholdFraction);

%% 8. Plot

fig1 = figure;

plot(lags, abs(correlationOutput), ...
    'LineWidth', 1.2);

hold on;

yline(threshold, '--', ...
    ['Threshold = ' num2str(threshold)]);
ylim([0 threshold*1.1]);

plot(peakLag, peakValue, ...
    'o', ...
    'MarkerSize', 8, ...
    'LineWidth', 2);

hold off;

xlabel('Lag (samples)');
ylabel('|Correlation|');

title('Signal-Absent Detection Test');

grid on;

%% 9. Display result

fprintf('\n--- Signal Absent Test ---\n');

fprintf('Burst energy         = %.2f\n', ...
    burstEnergy);

fprintf('Detection threshold  = %.2f\n', ...
    threshold);

fprintf('Largest peak         = %.2f\n', ...
    peakValue);

fprintf('Peak location        = %d\n', ...
    estimatedBurstStart);

fprintf('Decision             = %s\n', ...
    decision);

%% Hide axes toolbars

allAxes = findall(fig1, 'Type', 'axes');

for ax = allAxes'
    ax.Toolbar.Visible = 'off';
end

drawnow;

%% Save figure

exportgraphics( ...
    fig1, ...
    fullfile(resultsDir, '10_signal_absent_test.png'), ...
    'Resolution', 300);
%% Experiment 09 - Correlation and threshold detection

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

%% 2. Generate known BPSK burst

burst = generate_bpsk_burst(bits, Fs, Rs);

%% 3. Create observation frame

frameLength = 1000;

txFrame = zeros(1, frameLength);

burstStart = 350;
burstEnd = burstStart + length(burst) - 1;

txFrame(burstStart:burstEnd) = burst;

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

[filteredSignal, ~, ~] = ...
    apply_receiver_filter( ...
    rxSignal, Fs, ...
    cutoffFrequency, filterOrder);

%% 6. Search for known burst

[correlationOutput, lags, ...
    peakValue, peakLag, ...
    estimatedBurstStart] = ...
    find_burst(filteredSignal, burst);

%% 7. Detection decision

thresholdFraction = 0.60;

[decision, threshold, burstEnergy] = ...
    detect_signal( ...
    peakValue, burst, thresholdFraction);

%% 8. Plot detection result

fig1 = figure;

plot(lags, abs(correlationOutput), ...
    'LineWidth', 1.2);

hold on;

yline(threshold, '--', ...
    ['Threshold = ' num2str(threshold)]);

plot(peakLag, peakValue, ...
    'o', ...
    'MarkerSize', 8, ...
    'LineWidth', 2);

hold off;

xlabel('Lag (samples)');
ylabel('|Correlation|');

title('Correlation-Based Signal Detection');

grid on;

%% 9. Display results

fprintf('\n--- Detection Result ---\n');

fprintf('True burst start       = %d\n', ...
    burstStart);

fprintf('Estimated burst start  = %d\n', ...
    estimatedBurstStart);

fprintf('Timing error            = %d samples\n', ...
    estimatedBurstStart - burstStart);

fprintf('Burst energy            = %.2f\n', ...
    burstEnergy);

fprintf('Detection threshold     = %.2f\n', ...
    threshold);

fprintf('Peak correlation        = %.2f\n', ...
    peakValue);

fprintf('Decision                = %s\n', ...
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
    fullfile(resultsDir, '09_threshold_detection.png'), ...
    'Resolution', 300);
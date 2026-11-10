%% Experiment 12 - Interference frequency challenge

clear;
clc;
close all;


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

burst = generate_bpsk_burst(bits, Fs, Rs);

%% 2. Observation frame

frameLength = 1000;

burstStart = 350;
burstEnd = burstStart + length(burst) - 1;

txFrame = zeros(1, frameLength);
txFrame(burstStart:burstEnd) = burst;

%% 3. Channel settings

SNR_dB = 10;

interferenceAmplitude = 0.8;

%% Frequencies to test

interferenceFrequencies = ...
    [1000 1500 2000 2500 3000 4000];

%% 4. Receiver filter

cutoffFrequency = 2000;
filterOrder = 80;

%% 5. Detection threshold

thresholdFraction = 0.60;

%% 6. Store results

filterAttenuation_dB = ...
    zeros(size(interferenceFrequencies));

correlationPeaks = ...
    zeros(size(interferenceFrequencies));

timingErrors = ...
    zeros(size(interferenceFrequencies));

detected = ...
    false(size(interferenceFrequencies));

%% 7. Test each interference frequency

for k = 1:length(interferenceFrequencies)

    interferenceFrequency = ...
        interferenceFrequencies(k);

    % Reset random generator so every test
    % uses the same noise realization
    rng(10);

    %% Add noise and interference

    [rxSignal, ~, ~, ~] = ...
        add_channel_impairments( ...
        txFrame, burst, Fs, ...
        SNR_dB, ...
        interferenceFrequency, ...
        interferenceAmplitude);

    %% Apply FIR filter

    [filteredAligned, ~, b] = ...
        apply_receiver_filter( ...
        rxSignal, Fs, ...
        cutoffFrequency, ...
        filterOrder);

    %% Measure filter response at interferer frequency

    [H, fResponse] = ...
        freqz(b, 1, 4096, Fs);

    [~, index] = ...
        min(abs(fResponse - interferenceFrequency));

    filterAttenuation_dB(k) = ...
        20*log10(abs(H(index)) + eps);

    %% Search for BPSK burst

    [~, ~, peakValue, ~, ...
        estimatedBurstStart] = ...
        find_burst(filteredAligned, burst);

    correlationPeaks(k) = peakValue;

    timingErrors(k) = ...
        estimatedBurstStart - burstStart;

    %% Detection decision

    [decision, threshold, ~] = ...
        detect_signal( ...
        peakValue, ...
        burst, ...
        thresholdFraction);

    detected(k) = ...
        decision == "SIGNAL DETECTED";

    %% Display result

    fprintf(['Interferer = %.1f kHz | ' ...
        'Filter response = %.2f dB | ' ...
        'Peak = %.2f | ' ...
        'Timing error = %d | ' ...
        'Detected = %d\n'], ...
        interferenceFrequency/1000, ...
        filterAttenuation_dB(k), ...
        correlationPeaks(k), ...
        timingErrors(k), ...
        detected(k));

end

%% 8. Plot filter attenuation

fig1 = figure;

plot( ...
    interferenceFrequencies/1000, ...
    filterAttenuation_dB, ...
    '-o', ...
    'LineWidth', 1.5, ...
    'MarkerSize', 7);

xlabel('Interference Frequency (kHz)');
ylabel('Filter Response (dB)');

title('FIR Suppression versus Interference Frequency');

grid on;

%% 9. Plot detector correlation peak

fig2 = figure;

plot( ...
    interferenceFrequencies/1000, ...
    correlationPeaks, ...
    '-o', ...
    'LineWidth', 1.5, ...
    'MarkerSize', 7);

hold on;

yline(threshold, '--', ...
    ['Detection Threshold = ' num2str(threshold)]);

hold off;

xlabel('Interference Frequency (kHz)');
ylabel('Peak Correlation');

title('Detection Strength versus Interference Frequency');

grid on;

%% Hide axes toolbars

figures = [fig1 fig2];

for k = 1:length(figures)

    allAxes = findall(figures(k), 'Type', 'axes');

    for ax = allAxes'
        ax.Toolbar.Visible = 'off';
    end

end

drawnow;

%% Save figures

exportgraphics( ...
    fig1, ...
    fullfile(resultsDir, '12a_filter_response_vs_interference_frequency.png'), ...
    'Resolution', 300);

exportgraphics( ...
    fig2, ...
    fullfile(resultsDir, '12b_detection_strength_vs_interference_frequency.png'), ...
    'Resolution', 300);
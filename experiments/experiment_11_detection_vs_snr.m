%% Experiment 11 - Detection performance versus SNR

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

burst = generate_bpsk_burst(bits, Fs, Rs);

%% 2. Observation frame

frameLength = 1000;

burstStart = 350;
burstEnd = burstStart + length(burst) - 1;

%% 3. Interference settings

interferenceFrequency = 4000;
interferenceAmplitude = 0.8;

%% 4. Receiver filter settings

cutoffFrequency = 2000;
filterOrder = 80;

%% 5. Detection threshold

burstEnergy = sum(burst.^2);

thresholdFraction = 0.60;

threshold = thresholdFraction * burstEnergy;

%% 6. SNR conditions

SNR_values = [-20 -15 -10 -5 0 5 10];

%% 7. Number of trials at each SNR

numTrials = 500;

%% 8. Storage for results

Pd = zeros(size(SNR_values));
Pfa = zeros(size(SNR_values));

%% 9. Monte Carlo experiment

for k = 1:length(SNR_values)

    SNR_dB = SNR_values(k);

    successfulDetections = 0;
    falseAlarms = 0;

    for trial = 1:numTrials

        %% ---------------------------
        % SIGNAL PRESENT CASE
        %% ---------------------------

        txPresent = zeros(1, frameLength);

        txPresent(burstStart:burstEnd) = burst;

        [rxPresent, ~, ~, ~] = ...
            add_channel_impairments( ...
            txPresent, burst, Fs, ...
            SNR_dB, ...
            interferenceFrequency, ...
            interferenceAmplitude);

        [filteredPresent, ~, ~] = ...
            apply_receiver_filter( ...
            rxPresent, Fs, ...
            cutoffFrequency, ...
            filterOrder);

        [~, ~, peakPresent, ~, ~] = ...
            find_burst(filteredPresent, burst);

        if peakPresent > threshold
            successfulDetections = ...
                successfulDetections + 1;
        end

        %% ---------------------------
        % SIGNAL ABSENT CASE
        %% ---------------------------

        txAbsent = zeros(1, frameLength);

        [rxAbsent, ~, ~, ~] = ...
            add_channel_impairments( ...
            txAbsent, burst, Fs, ...
            SNR_dB, ...
            interferenceFrequency, ...
            interferenceAmplitude);

        [filteredAbsent, ~, ~] = ...
            apply_receiver_filter( ...
            rxAbsent, Fs, ...
            cutoffFrequency, ...
            filterOrder);

        [~, ~, peakAbsent, ~, ~] = ...
            find_burst(filteredAbsent, burst);

        if peakAbsent > threshold
            falseAlarms = falseAlarms + 1;
        end

    end

    %% Calculate probabilities

    Pd(k) = successfulDetections / numTrials;

    Pfa(k) = falseAlarms / numTrials;

    fprintf(['SNR = %5.1f dB | ' ...
        'Pd = %.3f | Pfa = %.3f\n'], ...
        SNR_dB, Pd(k), Pfa(k));

end

%% 10. Plot probability of detection

fig1 = figure;

plot(SNR_values, Pd, ...
    '-o', ...
    'LineWidth', 1.5, ...
    'MarkerSize', 7);

xlabel('SNR (dB)');
ylabel('Probability of Detection');

title('Detection Probability versus SNR');

grid on;

ylim([0 1.05]);

%% 11. Plot probability of false alarm

fig2 = figure;

plot(SNR_values, Pfa, ...
    '-o', ...
    'LineWidth', 1.5, ...
    'MarkerSize', 7);

xlabel('Nominal SNR Condition (dB)');
ylabel('Probability of False Alarm');

title('False Alarm Probability versus Noise Level');

grid on;

ylim([0 1.05]);

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
    fullfile(resultsDir, '11a_probability_of_detection_vs_snr.png'), ...
    'Resolution', 300);

exportgraphics( ...
    fig2, ...
    fullfile(resultsDir, '11b_false_alarm_probability_vs_snr.png'), ...
    'Resolution', 300);
%% Final numerical results summary

clear;
clc;

%% Project paths

projectRoot = fileparts(mfilename('fullpath'));

% If this script is inside validation/, uncomment this instead:
% projectRoot = fileparts(fileparts(mfilename('fullpath')));

resultsDir = fullfile(projectRoot, 'results');

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

%% --------------------------------------------------------
% 1. Headline receiver results
%% --------------------------------------------------------

Metric = {
    "Measured 4 kHz interference attenuation"
    "True burst start"
    "Estimated burst start"
    "Baseline timing error"
    "Signal-present correlation peak"
    "Detection threshold"
    "Signal-absent largest correlation peak"
    };

Value = [
    -69.78
    350
    350
    0
    189.16
    120
    11.62
    ];

Unit = {
    "dB"
    "samples"
    "samples"
    "samples"
    "correlation magnitude"
    "correlation magnitude"
    "correlation magnitude"
    };

headlineResults = table(Metric, Value, Unit);

writetable( ...
    headlineResults, ...
    fullfile(resultsDir, 'headline_results.csv'));

%% --------------------------------------------------------
% 2. Detection performance versus SNR
%% --------------------------------------------------------

SNR_dB = [-20; -15; -10; -5; 0; 5; 10];

Pd = [
    1.000
    1.000
    0.978
    0.990
    1.000
    1.000
    1.000
    ];

Pfa = [
    1.000
    1.000
    0.562
    0.000
    0.000
    0.000
    0.000
    ];

snrResults = table(SNR_dB, Pd, Pfa);

writetable( ...
    snrResults, ...
    fullfile(resultsDir, 'detection_vs_snr.csv'));

%% --------------------------------------------------------
% 3. Interference-frequency sensitivity
%% --------------------------------------------------------

InterferenceFrequency_kHz = [
    1.0
    1.5
    2.0
    2.5
    3.0
    4.0
    ];

FilterResponse_dB = [
    -0.00
    -0.03
    -5.99
    -52.64
    -60.42
    -63.63
    ];

CorrelationPeak = [
    189.16
    205.40
    189.16
    189.18
    189.16
    189.16
    ];

TimingError_samples = [
     0
    -1
     0
     0
     0
     0
    ];

Detected = [
    true
    true
    true
    true
    true
    true
    ];

interferenceResults = table( ...
    InterferenceFrequency_kHz, ...
    FilterResponse_dB, ...
    CorrelationPeak, ...
    TimingError_samples, ...
    Detected);

writetable( ...
    interferenceResults, ...
    fullfile(resultsDir, ...
    'interference_frequency_sensitivity.csv'));

%% --------------------------------------------------------
% Display summaries
%% --------------------------------------------------------

fprintf('\n=== HEADLINE RESULTS ===\n');
disp(headlineResults);

fprintf('\n=== DETECTION VS SNR ===\n');
disp(snrResults);

fprintf('\n=== INTERFERENCE FREQUENCY SENSITIVITY ===\n');
disp(interferenceResults);

fprintf('\nFinal numerical result files saved successfully.\n');
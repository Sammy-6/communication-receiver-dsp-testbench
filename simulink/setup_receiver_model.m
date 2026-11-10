%% Setup signal for Simulink receiver model

clear;
clc;

%% Make src functions available

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'src'));

%% System settings

Fs = 20000;
Rs = 1000;

bits = [1 0 1 1 0 0 1 0 1 0];

%% Generate BPSK burst

burst = generate_bpsk_burst(bits, Fs, Rs);

burst = burst(:);   % Make it a column vector

%% Create observation frame

frameLength = 1000;

txFrame = zeros(frameLength, 1);

burstStart = 350;
burstEnd = burstStart + length(burst) - 1;

txFrame(burstStart:burstEnd) = burst;

%% Time vector

tSim = (0:frameLength-1)' / Fs;

%% Create Simulink input signal

txInput = timeseries(txFrame, tSim);

%% Display information

fprintf('Simulink BPSK source prepared.\n');
fprintf('Sampling frequency = %.0f Hz\n', Fs);
fprintf('Frame samples      = %d\n', frameLength);
fprintf('Burst start        = %d\n', burstStart);
fprintf('Burst end          = %d\n', burstEnd);
fprintf('Simulation time    = %.5f s\n', tSim(end));

%% FIR receiver filter

cutoffFrequency = 2000;
filterOrder = 80;

normalizedCutoff = cutoffFrequency / (Fs/2);

firCoefficients = ...
    fir1(filterOrder, normalizedCutoff, 'low');

fprintf('FIR filter prepared.\n');

%% Matched-filter coefficients

% For our real-valued BPSK burst:
% matched filter = time-reversed reference signal

matchedFilterCoefficients = flip(burst).';

fprintf('Matched filter prepared.\n');
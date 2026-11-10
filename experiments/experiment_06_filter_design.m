%% Experiment 06 - Design low-pass FIR filter

clear;
clc;
close all;

%% Results folder

projectRoot = fileparts(fileparts(mfilename('fullpath')));
resultsDir = fullfile(projectRoot, 'results', 'matlab');

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end
%% Basic settings

Fs = 20000;             % Sampling frequency

%% Filter specifications

cutoffFrequency = 2000; % Keep frequencies below about 2 kHz
filterOrder = 80;

%% Normalize cutoff frequency

normalizedCutoff = cutoffFrequency / (Fs/2);

%% Design FIR low-pass filter

b = fir1(filterOrder, normalizedCutoff, 'low');

%% Examine frequency response

fig1 = figure;

freqz(b, 1, 2048, Fs);

sgtitle('Frequency Response of FIR Low-Pass Filter');

%% Hide axes toolbars

allAxes = findall(fig1, 'Type', 'axes');

for ax = allAxes'
    ax.Toolbar.Visible = 'off';
end

drawnow;

%% Save figure

exportgraphics( ...
    fig1, ...
    fullfile(resultsDir, '06_fir_lowpass_filter_response.png'), ...
    'Resolution', 300);
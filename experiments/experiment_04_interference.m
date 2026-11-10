%% Experiment 04 - Add narrowband interference

clear;
clc;
close all;


%% Results folder

projectRoot = fileparts(fileparts(mfilename('fullpath')));
resultsDir = fullfile(projectRoot, 'results', 'matlab');

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end
%% 1. Basic settings

Fs = 20000;
Rs = 1000;

samplesPerSymbol = Fs / Rs;

%% 2. Generate BPSK burst

bits = [1 0 1 1 0 0 1 0 1 0];

symbols = 2*bits - 1;

burst = repelem(symbols, samplesPerSymbol);

%% 3. Put burst inside observation frame

frameLength = 1000;

txFrame = zeros(1, frameLength);

burstStart = 350;
burstEnd = burstStart + length(burst) - 1;

txFrame(burstStart:burstEnd) = burst;

%% 4. Time axis

t = (0:frameLength-1) / Fs;

%% 5. Add AWGN

SNR_dB = 10;

signalPower = mean(burst.^2);

noisePower = signalPower / (10^(SNR_dB/10));

noise = sqrt(noisePower) * randn(size(txFrame));

noisySignal = txFrame + noise;

%% 6. Generate narrowband interference

interferenceFrequency = 4000;   % 4 kHz
interferenceAmplitude = 0.8;

interference = interferenceAmplitude * ...
    sin(2*pi*interferenceFrequency*t);

%% 7. Add interference to received signal

rxSignal = noisySignal + interference;

%% 8. Zoom around burst

zoomStart = (burstStart - 50) / Fs;
zoomEnd = (burstEnd + 50) / Fs;

%% 9. Plot

fig1 = figure;

subplot(2,1,1);

plot(t, txFrame, 'LineWidth', 1.5);

title('Original Clean BPSK Signal');
xlabel('Time (s)');
ylabel('Amplitude');

grid on;
xlim([zoomStart zoomEnd]);
ylim([-3 3]);

subplot(2,1,2);

plot(t, rxSignal);

title('Received Signal with AWGN + 4 kHz Interference');
xlabel('Time (s)');
ylabel('Amplitude');

grid on;
xlim([zoomStart zoomEnd]);
ylim([-3 3]);

sgtitle('Effect of Narrowband Interference on BPSK Reception');

%% Hide axes toolbar

allAxes = findall(fig1, 'Type', 'axes');

for ax = allAxes'
    ax.Toolbar.Visible = 'off';
end

drawnow;

%% Save figure

exportgraphics( ...
    fig1, ...
    fullfile(resultsDir, '04_awgn_and_4kHz_interference.png'), ...
    'Resolution', 300);
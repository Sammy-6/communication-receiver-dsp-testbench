%% Experiment 08 - Detect known BPSK burst using correlation

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
%% 1. Basic settings

Fs = 20000;
Rs = 1000;

samplesPerSymbol = Fs / Rs;

%% 2. Known BPSK burst

bits = [1 0 1 1 0 0 1 0 1 0];

symbols = 2*bits - 1;

burst = repelem(symbols, samplesPerSymbol);

%% 3. Insert burst into frame

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

%% 6. Add 4 kHz interference

interferenceFrequency = 4000;
interferenceAmplitude = 0.8;

interference = interferenceAmplitude * ...
    sin(2*pi*interferenceFrequency*t);

rxSignal = noisySignal + interference;

%% 7. Design and apply FIR filter

cutoffFrequency = 2000;
filterOrder = 80;

normalizedCutoff = cutoffFrequency / (Fs/2);

b = fir1(filterOrder, normalizedCutoff, 'low');

filteredSignal = filter(b, 1, rxSignal);

%% 8. Compensate known FIR delay

filterDelay = filterOrder / 2;

filteredAligned = [ ...
    filteredSignal(filterDelay+1:end), ...
    zeros(1, filterDelay)];

%% 9. Correlate received signal with known burst

[correlationOutput, lags] = xcorr(filteredAligned, burst);

%% 10. Find strongest correlation peak

[peakValue, peakIndex] = max(abs(correlationOutput));

peakLag = lags(peakIndex);

estimatedBurstStart = peakLag + 1;

%% 11. Plot filtered received signal

fig1 = figure;

subplot(2,1,1);

plot(t, filteredAligned);

title('Filtered Received Signal');
xlabel('Time (s)');
ylabel('Amplitude');

grid on;

xlim([(burstStart-100)/Fs ...
      (burstEnd+100)/Fs]);

%% 12. Plot correlation output

subplot(2,1,2);

plot(lags, abs(correlationOutput), 'LineWidth', 1.2);

hold on;

plot(peakLag, peakValue, ...
    'o', ...
    'MarkerSize', 8, ...
    'LineWidth', 2);

hold off;

title('Correlation with Known BPSK Burst');

xlabel('Lag (samples)');
ylabel('|Correlation|');

grid on;

sgtitle('Known-Signal Detection Using Correlation');

%% 13. Display detection result

fprintf('True burst start      = %d\n', burstStart);
fprintf('Estimated burst start = %d\n', estimatedBurstStart);
fprintf('Timing error           = %d samples\n', ...
    estimatedBurstStart - burstStart);

fprintf('Peak correlation value = %.2f\n', peakValue);

%% Hide axes toolbars

allAxes = findall(fig1, 'Type', 'axes');

for ax = allAxes'
    ax.Toolbar.Visible = 'off';
end

drawnow;

%% Save figure

exportgraphics( ...
    fig1, ...
    fullfile(resultsDir, '08_correlation_burst_localization.png'), ...
    'Resolution', 300);
%% Experiment 07 - Apply FIR filter to received signal

clear;
clc;
close all;

rng(10);   % Repeatable noise


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

%% 2. Generate baseband BPSK burst

bits = [1 0 1 1 0 0 1 0 1 0];

symbols = 2*bits - 1;

burst = repelem(symbols, samplesPerSymbol);

%% 3. Insert burst into observation frame

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

%% 7. Design the FIR low-pass filter

cutoffFrequency = 2000;
filterOrder = 80;

normalizedCutoff = cutoffFrequency / (Fs/2);

b = fir1(filterOrder, normalizedCutoff, 'low');

%% 8. Apply the filter

filteredSignal = filter(b, 1, rxSignal);

%% 9. Compensate filter delay for DISPLAY

filterDelay = filterOrder / 2;

filteredAligned = [ ...
    filteredSignal(filterDelay+1:end), ...
    zeros(1, filterDelay)];

%% 10. Zoom around the burst

zoomStart = (burstStart - 50) / Fs;
zoomEnd   = (burstEnd + 50) / Fs;

%% 11. Time-domain comparison

fig1 = figure;

subplot(2,1,1);

plot(t, rxSignal);

title('Before Filtering: BPSK + AWGN + 4 kHz Interference');
xlabel('Time (s)');
ylabel('Amplitude');

grid on;
xlim([zoomStart zoomEnd]);
ylim([-3 3]);

subplot(2,1,2);

plot(t, filteredAligned);

title('After FIR Low-Pass Filtering');
xlabel('Time (s)');
ylabel('Amplitude');

grid on;
xlim([zoomStart zoomEnd]);
ylim([-3 3]);

sgtitle('Time-Domain Effect of Interference Suppression');

%% 12. Calculate spectra

N = length(rxSignal);

f = Fs*(0:(N/2))/N;

% Before filtering
X_before = fft(rxSignal);

P2_before = abs(X_before/N);
P1_before = P2_before(1:N/2+1);
P1_before(2:end-1) = 2*P1_before(2:end-1);

% After filtering
X_after = fft(filteredSignal);

P2_after = abs(X_after/N);
P1_after = P2_after(1:N/2+1);
P1_after(2:end-1) = 2*P1_after(2:end-1);

%% 13. Spectrum comparison

fig2 = figure;

subplot(2,1,1);

plot(f, P1_before, 'LineWidth', 1.3);

title('Spectrum Before Filtering');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

grid on;
xlim([0 5000]);

subplot(2,1,2);

plot(f, P1_after, 'LineWidth', 1.3);

title('Spectrum After Filtering');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

grid on;
xlim([0 5000]);

sgtitle('Frequency-Domain Effect of FIR Filtering');

%% 14. Measure 4 kHz component before and after filtering

[~, index4k] = min(abs(f - interferenceFrequency));

before4k = P1_before(index4k);
after4k  = P1_after(index4k);

attenuation_dB = ...
    20*log10(after4k / before4k);

fprintf('4 kHz magnitude before filtering = %.4f\n', before4k);
fprintf('4 kHz magnitude after filtering  = %.4f\n', after4k);
fprintf('Measured 4 kHz attenuation       = %.2f dB\n', ...
    attenuation_dB);

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
    fullfile(resultsDir, '07a_filtering_time_domain.png'), ...
    'Resolution', 300);

exportgraphics( ...
    fig2, ...
    fullfile(resultsDir, '07b_filtering_spectrum_before_after.png'), ...
    'Resolution', 300);
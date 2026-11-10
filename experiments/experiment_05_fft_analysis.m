%% Experiment 05 - Compare spectra at each receiver stage

clear;
clc;
close all;

rng(10);   % Keep the noise repeatable


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

%% 6. Add narrowband interference

interferenceFrequency = 4000;
interferenceAmplitude = 0.8;

interference = interferenceAmplitude * ...
    sin(2*pi*interferenceFrequency*t);

rxSignal = noisySignal + interference;

%% 7. Frequency axis

N = frameLength;

f = Fs*(0:(N/2))/N;

%% 8. FFT of clean BPSK frame

X_clean = fft(txFrame);

P2_clean = abs(X_clean/N);
P1_clean = P2_clean(1:N/2+1);
P1_clean(2:end-1) = 2*P1_clean(2:end-1);

%% 9. FFT of BPSK + AWGN

X_noisy = fft(noisySignal);

P2_noisy = abs(X_noisy/N);
P1_noisy = P2_noisy(1:N/2+1);
P1_noisy(2:end-1) = 2*P1_noisy(2:end-1);

%% 10. FFT of BPSK + AWGN + interference

X_rx = fft(rxSignal);

P2_rx = abs(X_rx/N);
P1_rx = P2_rx(1:N/2+1);
P1_rx(2:end-1) = 2*P1_rx(2:end-1);

%% 11. Clean BPSK spectrum

fig1 = figure;

plot(f, P1_clean, 'LineWidth', 1.4);

title('Spectrum of Clean Baseband BPSK Signal');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

grid on;
xlim([0 5000]);

%% 12. BPSK + AWGN spectrum

fig2 = figure;

plot(f, P1_noisy, 'LineWidth', 1.4);

title('Spectrum of BPSK Signal with AWGN');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

grid on;
xlim([0 5000]);

%% 13. BPSK + AWGN + interference spectrum

fig3 = figure;

plot(f, P1_rx, 'LineWidth', 1.4);

title('Spectrum of BPSK + AWGN + 4 kHz Interference');
xlabel('Frequency (Hz)');
ylabel('Magnitude');

grid on;
xlim([0 5000]);

%% Hide axes toolbars

figures = [fig1 fig2 fig3];

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
    fullfile(resultsDir, '05a_spectrum_clean_bpsk.png'), ...
    'Resolution', 300);

exportgraphics( ...
    fig2, ...
    fullfile(resultsDir, '05b_spectrum_bpsk_awgn.png'), ...
    'Resolution', 300);

exportgraphics( ...
    fig3, ...
    fullfile(resultsDir, '05c_spectrum_bpsk_awgn_interference.png'), ...
    'Resolution', 300);
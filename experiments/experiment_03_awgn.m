%% Experiment 03 - Clear AWGN comparison using separate figures

clear;
clc;
close all;


%% Results folder

projectRoot = fileparts(fileparts(mfilename('fullpath')));
resultsDir = fullfile(projectRoot, 'results', 'matlab');

if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end
%% 1. System settings

Fs = 20000;
Rs = 1000;

samplesPerSymbol = Fs / Rs;

%% 2. Information bits

bits = [1 0 1 1 0 0 1 0 1 0];

%% 3. BPSK mapping

symbols = 2*bits - 1;

%% 4. Create sampled BPSK burst

burst = repelem(symbols, samplesPerSymbol);

%% 5. Create observation frame

frameLength = 1000;

txFrame = zeros(1, frameLength);

burstStart = 350;

burstEnd = burstStart + length(burst) - 1;

txFrame(burstStart:burstEnd) = burst;

%% 6. Signal power

signalPower = mean(burst.^2);

%% 7. SNR values

SNR_values = [20 10 0 -5];

%% 8. Generate one reference noise waveform

baseNoise = randn(size(txFrame));

%% 9. Time axis

t = (0:frameLength-1) / Fs;

%% 10. Time range around the burst

zoomStart = (burstStart - 50) / Fs;
zoomEnd   = (burstEnd + 50) / Fs;

%% 11. Plot clean signal in its own window

figure;

plot(t, txFrame, 'LineWidth', 1.5);

title('Clean BPSK Burst');
xlabel('Time (s)');
ylabel('Amplitude');

grid on;

xlim([zoomStart zoomEnd]);
ylim([-4 4]);

%% 12. Generate separate figure for every SNR

for k = 1:length(SNR_values)

    SNR_dB = SNR_values(k);

    noisePower = signalPower / (10^(SNR_dB/10));
    noise = sqrt(noisePower) * baseNoise;

    rxFrame = txFrame + noise;

    fig = figure;

    % Clean signal
    subplot(2,1,1);
    plot(t, txFrame, 'LineWidth', 1.5);
    title('Original Clean BPSK Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    xlim([zoomStart zoomEnd]);
    ylim([-5 5]);

    % Noisy received signal
    subplot(2,1,2);
    plot(t, rxFrame);
    title(['Received Signal with AWGN - SNR = ' ...
        num2str(SNR_dB) ' dB']);
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    xlim([zoomStart zoomEnd]);
    ylim([-5 5]);


    %% Hide axes toolbar before export

    allAxes = findall(fig, 'Type', 'axes');

    for ax = allAxes'
        ax.Toolbar.Visible = 'off';
    end

    drawnow;
    
    filename = sprintf( ...
        '03_awgn_snr_%+ddB.png', ...
        SNR_dB);

    exportgraphics( ...
        fig, ...
        fullfile(resultsDir, filename), ...
        'Resolution', 300);

end
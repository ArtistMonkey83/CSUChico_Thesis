% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-22-2025

clear all; clc; close all;

% *********** Number of collections to process ***********
NumCollects = 10;

% *********** Load .txt data ***********
dataFiles = {
    '25uMA_1_7v.txt', '25uMA_1_8v.txt','25uMA_1_91v.txt', '25uMA_2_16v.txt', ...
    '25uMA_2_20v.txt','25uMA_2_2v.txt', '25uMA_2_22v.txt', '25uMA_2_30v.txt', ...
    '25uMA_2_3v.txt', '25uMA_2_41v.txt'
};

voltages = {'1.7V','1.8V','1.91V', '2.16V', '2.20V', '2.22V','2.30V', '2.30V', '2.41V', '2.41V'};

% Ensure valid collection count
NumCollects = min(NumCollects, length(dataFiles));
dataFiles = dataFiles(1:NumCollects);
voltages = voltages(1:NumCollects);

% *********** Custom color maps ***********
customColorsTnP = [...
    9, 110, 106;
    10, 153, 148;
    39, 214, 208;
    100, 250, 245;
    162, 247, 245;
    68, 10, 107;
    100, 12, 158;
    139, 31, 212;
    199, 123, 250;
    220, 182, 245
] / 255;

% *********** Plot Style ***********
thick  = 2.5;
fsize  = 14;
fsizet = 18;
fname = 'Futura';

% *********** Estimate dynamic offsets (based on range instead of max) ***********
zmodRange = zeros(1, NumCollects);
zimagRange = zeros(1, NumCollects);

for i = 1:NumCollects
    T = readtable(dataFiles{i}, 'FileType', 'text');
    zmodData = T{:,2};
    zimagData = T{:,5};
    zmodRange(i) = range(zmodData(~isnan(zmodData)));
    zimagRange(i) = range(zimagData(~isnan(zimagData)));
end

% Use scaled offset steps relative to the average range
bodeStep = mean(zmodRange) * .5;
nyquistStep = mean(zimagRange) * 1.25;

bodeOffsets = bodeStep * (0:NumCollects-1);
nyquistOffsets = nyquistStep * (0:NumCollects-1);

% *********** Prepare figure ***********
figure('Units','normalized','Position',[0.1, 0.1, 0.85, 0.75]);

% *********** Subplot 1: Bode Plot ***********
subplot(2, 1, 1); hold on;

for i = 1:NumCollects
    T = readtable(dataFiles{i}, 'FileType', 'text');

    freq  = T{:,1};
    zmod  = T{:,2};
    zphz  = T{:,3};

    modOut = isoutlier(zmod, 'movmedian', 3);
    clean_freq = freq(~modOut);
    clean_zmod = zmod(~modOut);
    clean_zphz = zphz(~modOut);

    offset = bodeOffsets(i);
    color  = customColorsTnP(i,:);

    loglog(clean_freq, clean_zmod + offset, '-', ...
        'Color', color, 'LineWidth', thick, ...
        'DisplayName', ['|Z| @ ', voltages{i}]);

    semilogx(clean_freq, clean_zphz + offset, ':', ...
        'Color', color, 'LineWidth', thick, ...
        'DisplayName', ['Phase @ ', voltages{i}]);
end

xlabel('Frequency (Hz)', 'FontSize', fsize, 'FontName', fname);
ylabel('|Z| and Phase (offset)', 'FontSize', fsize, 'FontName', fname);
title('Bode Plots (Log Scale) with Vertical Offsets', 'FontSize', fsizet, 'FontName', fname);
legend('show', 'Location', 'eastoutside');
grid on;
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'linear');

% *********** Subplot 2: Nyquist Plot ***********
subplot(2, 1, 2); hold on;

for i = 1:NumCollects
    T = readtable(dataFiles{i}, 'FileType', 'text');

    zreal = T{:,4};
    zimag = T{:,5};

    nyqOut = isoutlier(zreal, 'movmedian', 3);
    clean_zreal = zreal(~nyqOut);
    clean_zimag = zimag(~nyqOut);

    offset = nyquistOffsets(i);
    color  = customColorsTnP(i,:);

    plot(clean_zreal, clean_zimag + offset, '-', ...
        'Color', color, 'LineWidth', thick, ...
        'DisplayName', ['Nyquist @ ', voltages{i}]);
end

xlabel('Z_{real} (\\Omega)', 'FontSize', fsize, 'FontName', fname);
ylabel('-Z_{imag} (offset)', 'FontSize', fsize, 'FontName', fname);
title('Nyquist Plots with Vertical Offsets', 'FontSize', fsizet, 'FontName', fname);
legend('show', 'Location', 'eastoutside');
axis tight;
grid on;

sgtitle('Offset Bode and Nyquist Plots (Log Scale)', 'FontSize', 20, 'FontWeight', 'bold');

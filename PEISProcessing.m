% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-27-2025

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

% Trim to NumCollects
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
thick  = 2.0;
fsize  = 12;
fsizet = 16;
fname  = 'Futura';

% *********** Estimate spacing for Nyquist offsets only ***********
zimagRange = zeros(1, NumCollects);
for i = 1:NumCollects
    T = readtable(dataFiles{i}, 'FileType', 'text');
    zimagRange(i) = range(T{:,5}, 'omitnan');
end

nyquistStep = mean(zimagRange) * 1.25;
nyquistOffsets = nyquistStep * (0:NumCollects-1);

% *********** Prepare tiled layout ***********
figure('Units','normalized','Position',[0.1, 0.1, 0.95, 0.85]);
tiledlayout(ceil(NumCollects/2), 3, 'Padding', 'compact', 'TileSpacing', 'compact');

% *********** Shared Nyquist subplot (first col) ***********
nexttile(1, [ceil(NumCollects/2),1]); hold on;
for i = 1:NumCollects
    T = readtable(dataFiles{i}, 'FileType', 'text');
    zreal = T{:,4};
    zimag = T{:,5};

    valid = ~isoutlier(zreal, 'movmedian', 3);
    clean_zreal = zreal(valid);
    clean_zimag = zimag(valid);
    offset = nyquistOffsets(i);
    color = customColorsTnP(i,:);

    plot(clean_zreal, clean_zimag + offset, '-', ...
        'Color', color, 'LineWidth', thick, ...
        'DisplayName', ['Nyquist @ ', voltages{i}]);
end
xlabel('Z_{real} (Ω)', 'FontSize', fsize, 'FontName', fname);
ylabel('-Z_{imag} + offset', 'FontSize', fsize, 'FontName', fname);
title('Nyquist Plots (Offset)', 'FontSize', fsizet, 'FontName', fname);
set(gca, 'XLim', [0 inf]);
legend('show', 'Location', 'eastoutside');
grid on;

% *********** Bode plots (cols 2 and 3) ***********
for i = 1:NumCollects
    col = 2 + mod(i-1,2); % col 2 or 3
    row = ceil(i/2);
    tileIndex = (row - 1) * 3 + col;
    nexttile(tileIndex); hold on;

    T = readtable(dataFiles{i}, 'FileType', 'text');
    freq  = T{:,1};
    zmod  = T{:,2};
    zphz  = T{:,3};

    valid = ~isoutlier(zmod, 'movmedian', 3);
    clean_freq = freq(valid);
    clean_zmod = zmod(valid);
    clean_zphz = zphz(valid);
    color = customColorsTnP(i,:);

    yyaxis left
    semilogx(clean_freq, clean_zmod, '-', 'Color', color, 'LineWidth', thick);
    ylabel('|Z| (Ω)', 'FontSize', fsize, 'FontName', fname);
    set(gca, 'YColor', color);

    yyaxis right
    semilogx(clean_freq, clean_zphz, ':', 'Color', color, 'LineWidth', thick);
    ylabel('Phase (°)', 'FontSize', fsize, 'FontName', fname);
    set(gca, 'YColor', color);

    xlabel('Frequency (Hz)', 'FontSize', fsize, 'FontName', fname);
    title(['Bode @ ', voltages{i}], 'FontSize', fsize, 'FontName', fname);
    grid on;
end

sgtitle('Bode and Nyquist Plots by Collection (No Offset for Bode)', ...
    'FontSize', 20, 'FontWeight', 'bold', 'FontName', fname);

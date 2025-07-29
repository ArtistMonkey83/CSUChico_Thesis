% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-28-2025
% One Nyquist Figure individual Bode plots

clear all; clc; close all;

% *********** Number of collections to process ***********
NumCollects = 8;

% *********** Load .txt data ***********
dataFiles = {
    '25uMA_1_7v.txt','25uMA_1_91v.txt', '25uMA_2_16v.txt', ...
    '25uMA_2_20v.txt','25uMA_2_2v.txt', '25uMA_2_22v.txt', '25uMA_2_30v.txt', ...
    '25uMA_2_3v.txt', '25uMA_2_41v.txt'
};

voltages = {'1.7V','1.91V', '2.16V', '2.20V', '2.22V','2.30V', '2.30V', '2.41V'};

% Trim to NumCollects
NumCollects = min(NumCollects, length(dataFiles));
dataFiles = dataFiles(1:NumCollects);
voltages = voltages(1:NumCollects);

% *********** Custom color map ***********
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

% *********** Plot style ***********
thick  = 2.5;
fsize  = 16;
fsizet = 20;
fname  = 'Futura';

% *********** Estimate Nyquist offset ***********
zimagRange = zeros(1, NumCollects);
for i = 1:NumCollects
    T = readtable(dataFiles{i}, 'FileType', 'text');
    zimagRange(i) = range(T{:,5}, 'omitnan');
end
nyquistStep = mean(zimagRange) * 1.25;
nyquistOffsets = nyquistStep * (0:NumCollects-1);

% *********** Nyquist Figure ***********
figure('Name', 'Nyquist Offset Plot', 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.2 0.6 0.6]); hold on;
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

% *********** Individual Bode Figures (with yyaxis) ***********
for i = 1:NumCollects
    T = readtable(dataFiles{i}, 'FileType', 'text');
    freq  = T{:,1};
    zmod  = T{:,2};
    zphz  = T{:,3};

    outlierIdx = isoutlier(zmod, 'movmedian', 3);
    clean_freq = freq(~outlierIdx);
    clean_zmod = zmod(~outlierIdx);
    clean_zphz = zphz(~outlierIdx);
    color = customColorsTnP(i,:);

    % Create new figure
    fig = figure('Name', ['Bode @ ', voltages{i}], 'Color', 'w', ...
        'Units', 'normalized', 'Position', [0.2 0.2 0.6 0.5]);

    % Plot |Z| on left y-axis
    yyaxis left
    semilogx(clean_freq, clean_zmod, '-', ...
        'Color', color, 'LineWidth', thick, 'DisplayName', '|Z|');
    ylabel('|Z| (Ohms)', 'FontSize', fsize, 'FontName', fname);
    ax = gca; ax.YColor = color;

    % Plot Phase on right y-axis
    yyaxis right
    semilogx(clean_freq, clean_zphz, ':', ...
        'Color', color, 'LineWidth', thick, 'DisplayName', 'Phase');
    ylabel('Phase (°)', 'FontSize', fsize, 'FontName', fname);
    ax = gca; ax.YColor = color;

    xlabel('Frequency (Hz)', 'FontSize', fsize, 'FontName', fname);
    title(['Bode Plot @ ', voltages{i}], 'FontSize', fsizet, 'FontName', fname);
    legend({'|Z|','Phase'}, 'Location', 'northeast');
    grid on;
end


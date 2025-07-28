% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-22-2025

clear; clc; close all;

% *********** Number of collections to process ***********
NumCollects = 10;

% *********** Load .txt data ***********
dataFiles = {
    '25uMA_1_7v.txt', '25uMA_1_8v.txt','25uMA_1_91v.txt', '25uMA_2_16v.txt', ...
    '25uMA_2_20v.txt','25uMA_2_2v.txt', '25uMA_2_22v.txt', '25uMA_2_30v.txt', ...
    '25uMA_2_3v.txt', '25uMA_2_41v.txt'
};

voltages = {'1.7V','1.8V','1.91V', '2.16V', '2.20V', '2.22V','2.30V', '2.30V', '2.41V', '2.41V'};

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
thick  = 2.0;
fsize  = 18;
fsizet = 20;
fname  = 'Futura';

% *********** Estimate spacing for Nyquist offsets ***********
zimagRange = zeros(1, NumCollects);
for i = 1:NumCollects
    T = readtable(dataFiles{i}, 'FileType', 'text');
    zimagRange(i) = range(T{:,5}, 'omitnan');
end

nyquistStep = max(zimagRange) * 2;  % Increase spacing based on worst case
nyquistOffsets = nyquistStep * (0:NumCollects-1);

% *********** Nyquist Plot (All in One Figure) ***********
figure('Name', 'Nyquist Offset Plot', 'Color', 'w', ...
       'Units', 'normalized', 'Position', [0.1 0.2 0.6 0.6]); 
hold on;

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
title('Glow Grid 2.5 \muM: Battery A Nyquist Plots', 'FontSize', fsizet, 'FontName', fname);
legend('show', 'Location', 'eastoutside');
grid on;

% *********** Bode Plots: 5 per Figure ***********
plotsPerFig = 5;
numFigs = ceil(NumCollects / plotsPerFig);

for figIdx = 1:numFigs
    figure('Name', ['Bode Group ', num2str(figIdx)], 'Color', 'w', ...
           'Units', 'normalized', 'Position', [0.2 0.2 0.7 0.8]);

    for plotIdx = 1:plotsPerFig
        i = (figIdx - 1) * plotsPerFig + plotIdx;
        if i > NumCollects, break; end

        % Load and clean data
        T = readtable(dataFiles{i}, 'FileType', 'text');
        freq  = T{:,1};
        zmod  = T{:,2};
        zphz  = T{:,3};

        validZ = ~isoutlier(zmod, 'movmedian', 3);
        validP = ~isoutlier(zphz, 'movmedian', 3);
        valid = validZ & validP;

        clean_freq = freq(valid);
        clean_zmod = zmod(valid);
        clean_zphz = zphz(valid);
        color = customColorsTnP(i,:);

        % Subplot
        subplot(5, 1, plotIdx);

        yyaxis left
        semilogx(clean_freq, clean_zmod, '-', ...
            'Color', color, 'LineWidth', thick, 'DisplayName', '|Z|');
        ylabel('|Z| (Ω)', 'FontSize', fsize, 'FontName', fname);
        ax = gca; ax.YColor = color;

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
end


% sgtitle('Grouped Bode Plots by Voltage', ...
%     'FontSize', 14, 'FontWeight', 'bold', 'FontName', fname);

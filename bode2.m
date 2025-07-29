% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-28-2025
% One Nyquist Figure; individual Bode plots from all .txt files in directory

clear; clc; close all;

% *********** Load .txt files ***********
files = dir('*.txt');
NumCollects = length(files);

% *********** Custom color map ***********
customColorsTnP = [...
    9, 110, 106; 10, 153, 148; 39, 214, 208; 100, 250, 245; 162, 247, 245;
    68, 10, 107; 100, 12, 158; 139, 31, 212; 199, 123, 250; 220, 182, 245;
    186, 120, 6; 214, 140, 13; 242, 166, 34; 245, 191, 97; 245, 214, 161;
    16, 67, 158; 27, 93, 207; 48, 118, 240; 94, 152, 252; 169, 200, 255
] / 255;

% *********** Style ***********
thick  = 2.5;
fsize  = 16;
fsizet = 20;
fname  = 'Futura';

% *********** Estimate Nyquist offset ***********
zimagRange = zeros(1, NumCollects);
for i = 1:NumCollects
    T = readtable(files(i).name, 'FileType', 'text');
    zimagRange(i) = range(T{:,5}, 'omitnan');
end
nyquistStep = mean(zimagRange) * 1.25;
nyquistOffsets = nyquistStep * (0:NumCollects-1);

% *********** Nyquist Figure ***********
figure('Name', 'Nyquist Offset Plot', 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.2 0.6 0.6]); hold on;
for i = 1:NumCollects
    T = readtable(files(i).name, 'FileType', 'text');
    zreal = T{:,4};
    zimag = T{:,5};

    valid = ~isoutlier(zreal, 'movmedian', 3);
    clean_zreal = zreal(valid);
    clean_zimag = zimag(valid);
    offset = nyquistOffsets(i);
    color = customColorsTnP(mod(i-1, size(customColorsTnP,1)) + 1, :);

    % Extract voltage label from filename (e.g., 2_41v --> 2.41V)
    match = regexp(files(i).name, '_([\d]+)_([\d]+)v', 'tokens');
    if ~isempty(match)
        voltageLabel = [match{1}{1}, '.', match{1}{2}, 'V'];
    else
        voltageLabel = erase(files(i).name, '.txt');
    end

    plot(clean_zreal, clean_zimag + offset, '-', ...
        'Color', color, 'LineWidth', thick, ...
        'DisplayName', ['Nyquist @ ', voltageLabel]);
end
xlabel('Z_{real} (\Omega)', 'FontSize', fsize, 'FontName', fname);
ylabel('-Z_{imag} + offset', 'FontSize', fsize, 'FontName', fname);
title('Nyquist Plots (Offset)', 'FontSize', fsizet, 'FontName', fname);
set(gca, 'XLim', [0 inf]);
legend('show', 'Location', 'eastoutside');
grid on;

% *********** Bode Figures ***********
for i = 1:NumCollects
    T = readtable(files(i).name, 'FileType', 'text');
    freq  = T{:,1};
    zmod  = T{:,2};
    zphz  = T{:,3};

    outlierIdx = isoutlier(zmod, 'movmedian', 3);
    clean_freq = freq(~outlierIdx);
    clean_zmod = zmod(~outlierIdx);
    clean_zphz = zphz(~outlierIdx);
    color = customColorsTnP(mod(i-1, size(customColorsTnP,1)) + 1, :);

    % Extract voltage label
    match = regexp(files(i).name, '_([\d]+)_([\d]+)v', 'tokens');
    if ~isempty(match)
        voltageLabel = [match{1}{1}, '.', match{1}{2}, 'V'];
    else
        voltageLabel = erase(files(i).name, '.txt');
    end

    % Create new figure
    fig = figure('Name', ['Bode @ ', voltageLabel], 'Color', 'w', ...
        'Units', 'normalized', 'Position', [0.2 0.2 0.6 0.5]);

    % |Z| on left y-axis
    yyaxis left;
    semilogx(clean_freq, clean_zmod, '-', ...
        'Color', color, 'LineWidth', thick, 'DisplayName', '|Z|');
    ylabel('|Z| (Ohms)', 'FontSize', fsize, 'FontName', fname);
    ax = gca; ax.YColor = color;

    % Phase on right y-axis
    yyaxis right;
    semilogx(clean_freq, clean_zphz, ':', ...
        'Color', color, 'LineWidth', thick, 'DisplayName', 'Phase');
    ylabel('Phase (°)', 'FontSize', fsize, 'FontName', fname);
    ax = gca; ax.YColor = color;

    xlabel('Frequency (Hz)', 'FontSize', fsize, 'FontName', fname);
    title(['Bode Plot @ ', voltageLabel], 'FontSize', fsizet, 'FontName', fname);
    legend({'|Z|','Phase'}, 'Location', 'northeast');
    grid on;
end

% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-28-2025
% Processes all files in the current directory, one Bode and Nyquist in
% each figure

clear; clc; close all;

% *********** Get all .txt data files in directory ***********
files = dir('*.txt');

% *********** Custom color map ***********
customColors = [...
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

% *********** Process each file ***********
for i = 1:length(files)
    filename = files(i).name;
    data = readtable(filename, 'FileType', 'text', 'Delimiter', '\t', 'VariableNamingRule', 'preserve');

    % *********** Extract all columns ***********
    try
        freq  = data.("Freq (Hz)");
        zmod  = data.("Zmod (ohm)");
        zphz  = data.("Zphz (°)");
        zreal = data.("Zreal (ohm)");
        zimag = data.("-Zimag (ohm)");
    catch
        warning('Skipping file %s: Required columns not found.', filename);
        continue;
    end

    % *********** Remove outliers ***********
    outlierIdxMod = isoutlier(zmod, 'movmedian', 3);
    outlierIdxReal = isoutlier(zreal, 'movmedian', 3);

    clean_freq  = freq(~outlierIdxMod);
    clean_zmod  = zmod(~outlierIdxMod);
    clean_zphz  = zphz(~outlierIdxMod);
    clean_zreal = zreal(~outlierIdxReal);
    clean_zimag = zimag(~outlierIdxReal);

    % *********** Choose color ***********
    colorIdx = mod(i-1, size(customColors,1)) + 1;
    plotColor = customColors(colorIdx,:);

    % *********** Parse title: Format as 'X.XXV' ***********
    filenameStr = string(filename); % Ensure it's a string for regex
    match = regexp(filenameStr, '_([\d]+)_([\d]+)v', 'tokens');

    if ~isempty(match)
        token = match{1}; % token{1} = major voltage, token{2} = minor voltage
        titleLabel = token{1} + "." + token{2} + "V";
    else
        titleLabel = erase(filenameStr, '.txt');
    end

    % *********** Generate figure ***********
    figure('Name', titleLabel, 'Color', 'w', 'Units', 'normalized', 'Position', [0.2 0.2 0.6 0.6]);

    % --- Subplot 1: Bode Plot (|Z| and Phase)
    subplot(2,1,1);
    yyaxis left;
    semilogx(clean_freq, clean_zmod, '-', ...
        'Color', plotColor, 'LineWidth', thick, 'DisplayName', '|Z|');
    ylabel('|Z| (Ohms)', 'FontSize', fsize, 'FontName', fname);
    ax = gca; ax.YColor = plotColor;

    yyaxis right;
    semilogx(clean_freq, clean_zphz, ':', ...
        'Color', plotColor, 'LineWidth', thick, 'DisplayName', 'Phase');
    ylabel('Phase (°)', 'FontSize', fsize, 'FontName', fname);
    ax = gca; ax.YColor = plotColor;

    xlabel('Frequency (Hz)', 'FontSize', fsize, 'FontName', fname);
    title('Bode Plot: '+ titleLabel, 'FontSize', fsizet, 'FontName', fname);
    legend('show');
    grid on;

    % --- Subplot 2: Nyquist Plot
    subplot(2,1,2);
    plot(clean_zreal, clean_zimag, '-', ...
        'Color', plotColor, 'LineWidth', thick, 'DisplayName', 'Nyquist');
    xlabel('Z_{real} (\Omega)', 'FontSize', fsize, 'FontName', fname);
    ylabel('-Z_{imag} (\Omega)', 'FontSize', fsize, 'FontName', fname);
    title('Nyquist Plot', 'FontSize', fsizet, 'FontName', fname);
    axis equal;
    grid on;
    legend('show');
end

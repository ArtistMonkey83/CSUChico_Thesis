% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-28-2025
% Raman Processing + Annotated Peaks + Adjusted Label Position + Extended Y-axis

clear; clc; close all;

% *********** Custom color map ***********
customColorsT = [...
    9,110,106;10,153,148;39,214,208;100,250,245;162,247,245;
    68,10,107;100,12,158;139,31,212;199,123,250;220,182,245;
    186,120,6;214,140,13;242,166,34;245,191,97;245,214,161;
    16,67,158;27,93,207;48,118,240;94,152,252;169,200,255
] / 255;

% *********** Plot Styling ***********
thick = 2.5;
fsize = 16;
fsizet = 20;
fname = 'Futura';
offsetStep = 1.5;

% *********** Vertical Line Styling ***********
peakIndicator = [108, 119, 184, 206, 215, 219, 227, 260, 355, 363, 402, 415, 445, 461, 477, 486];
DFTcalculated = [136, 146, 156, 184, 328, 423, 455, 500, 507, 522, 543, 551];

% *********** Label Text ***********
dotPeakLabel = {
    'S_{5}^{-} + S_{7}^{-}', 'S_{8}^{-}', 'S_{5}^{-} + S_{8}^{-}', 'S_{8}^{-}', ...
    'S_{6}^{-}', 'S_{6}^{-}', 'S_{4}^{-}', 'S_{8}^{-}', 'S_{7}^{-}', 'S_{3}^{-}', ...
    'S_{6}^{-}', 'S_{5}^{-}', 'S_{5}^{-}', 'S_{6}^{-}', 'S_{5}^{-}', 'S_{7}^{-} + S_{8}^{-}'};
solidPeakLabel = {
    'S_{7}^{2-}', 'S_{6}^{2-}', 'S_{5}^{2-}', 'S_{3}^{2-}', 'S_{8}^{2-}', ...
    'S_{8}^{2-}', 'S_{5}^{2-}', 'S_{6}^{2-}', 'S_{6}^{2-}', 'S_{8}^{2-}', ...
    'S_{7}^{2-}', 'S_{4}^{2-} + S_{6}^{2-}', 'S_{3}^{2-} + S_{4}^{2-}', ...
    'S_{4}^{2-}', 'S_{5}^{2-}', 'S_{7}^{2-} + S_{8}^{2-}'};

% *********** Label Styling ***********
labelFont = 'Futura';
labelFontsize = 10;
thickSolid = 2;
thickDot = 2;
colorSolid = [145, 143, 153]/255;
colorSolid = [179, 177, 186]/255;
colorDot = [64, 64, 64]/255;
labelOffsetY = 0.02;
labelOffsetX = 3;  % Now LEFT of the line
ylimBoostFactor = 1.10;

% *********** Normalization ***********
minmax_norm = @(x) (x - min(x)) / (max(x) - min(x));

% *********** Load sulfur reference ***********
RdataS8 = load('S8_1800_1.txt');
x_sulfur = RdataS8(:,1);
y_sulfur = RdataS8(:,2);

% *********** Load Raman Files ***********
files = dir('*.txt');
files = files(~contains({files.name}, 'S8'));

% *********** Initialize Figures ***********
figure(1); hold on;
titleStr1 = 'Glow Grid 2.5\muM: Battery B (Sulfur-Subtracted)';

figure(2); hold on;
titleStr2 = 'Glow Grid 2.5\muM: Battery B (Raw Spectra)';

% *********** Process and Plot ***********
for k = 1:length(files)
    data = load(files(k).name);
    x = data(:,1);
    y = data(:,2);

    y_s8_interp = interp1(x_sulfur, y_sulfur, x, 'linear', 'extrap');
    y_sub = y - y_s8_interp;

    y_norm_sub = minmax_norm(y_sub);
    y_norm_raw = minmax_norm(y);
    offset = (k-1) * offsetStep;

    parts = split(files(k).name, '_');
    if length(parts) >= 3
        label = strrep(parts{2}, 'uMA', '') + " " + strrep(parts{3}, 'v', '') + " V";
    else
        label = files(k).name;
    end

    colorIdx = mod(k-1, size(customColorsT,1)) + 1;
    thisColor = customColorsT(colorIdx,:);

    figure(1); plot(x, y_norm_sub + offset, '-', ...
        'Color', thisColor, 'LineWidth', thick, 'DisplayName', label);

    figure(2); plot(x, y_norm_raw + offset, '-', ...
        'Color', thisColor, 'LineWidth', thick, 'DisplayName', label);
end

% ======= Annotate Peaks and Format Figures =======
for figNum = [1, 2]
    figure(figNum);
    yLimits = ylim;
    yRange = yLimits(2) - yLimits(1);
    ylim([yLimits(1), yLimits(2) + yRange * (ylimBoostFactor - 1)]); % Extend top by ~10%

    hold on;

    for i = 1:length(peakIndicator)
        letter = char('A' + i - 1);
        xval = peakIndicator(i);
        xline(xval, '-', 'Color', colorSolid, 'LineWidth', thickSolid, ...
            'DisplayName', [letter ': ' solidPeakLabel{i}]);
        text(xval - labelOffsetX, yLimits(2) + yRange * 0.02, letter, ...
            'FontSize', labelFontsize, 'FontName', labelFont, ...
            'Color', colorSolid, 'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'bottom');
    end

    for i = 1:length(DFTcalculated)
        letter = char('a' + i - 1);
        xval = DFTcalculated(i);
        xline(xval, ':', 'Color', colorDot, 'LineWidth', thickDot, ...
            'DisplayName', [letter ': ' dotPeakLabel{i}]);
        text(xval - labelOffsetX, yLimits(2) + yRange * 0.02, letter, ...
            'FontSize', labelFontsize, 'FontName', labelFont, ...
            'Color', colorDot, 'HorizontalAlignment', 'right', ...
            'VerticalAlignment', 'bottom');
    end

    xlabel('Raman Shift (cm^{-1})', 'FontName', fname, 'FontSize', fsize);
    ylabel('Normalized Intensity + Offset', 'FontName', fname, 'FontSize', fsize);
    if figNum == 1
        title(titleStr1, 'FontName', fname, 'FontSize', fsizet);
    else
        title(titleStr2, 'FontName', fname, 'FontSize', fsizet);
    end
    legend('show', 'FontSize', 8, 'NumColumns', 3, 'Location', 'southoutside');
    grid on;
end

% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-29-2025
% Hybrid Background Removal: Normalized Sulfur, Baseline-Constrained Subtraction

clear; clc; close all;

% *********** Custom color map ***********
customColorsT = [...
    9,110,106;10,153,148;39,214,208;100,250,245;162,247,245;
    68,10,107;100,12,158;139,31,212;199,123,250;220,182,245;
    186,120,6;214,140,13;242,166,34;245,191,97;245,214,161;
    16,67,158;27,93,207;48,118,240;94,152,252;169,200,255
] / 255;

% *********** Plot Styling ***********
thick = 2.5; fsize = 16; fsizet = 20; fname = 'Futura'; offsetStep = 1.5;
minmax_norm = @(x) (x - min(x)) / (max(x) - min(x));

% *********** Load and normalize sulfur reference ***********
RdataS8 = load('S8_1800_1.txt');
x_sulfur = RdataS8(:,1);
y_sulfur = minmax_norm(RdataS8(:,2));  % normalize now

% *********** List all Raman files except sulfur ***********
files = dir('*.txt');
files = files(~contains({files.name}, 'S8'));

% *********** Initialize Figures ***********
figure(1); hold on;
titleStr1 = 'Glow Grid 2.5\muM: Battery A Location 1 (Constrained Sulfur Subtracted)';
figure(2); hold on;
titleStr2 = 'Glow Grid 2.5\muM: Battery A Location 1 (Raw Spectra)';

for k = 1:length(files)
    data = load(files(k).name);
    x = data(:,1);
    y = minmax_norm(data(:,2));  % normalize sample early

    % --- Interpolate sulfur to match x ---
    y_sulfur_interp = interp1(x_sulfur, y_sulfur, x, 'linear', 'extrap');

    % --- Subtract sulfur without going below baseline ---
    y_temp = y - y_sulfur_interp;

    % --- Polynomial baseline (exclude sulfur peak region) ---
    poly_mask = (x < 260) | (x > 360);
    if sum(poly_mask) > 20
        p = polyfit(x(poly_mask), y_temp(poly_mask), 3);
        baseline_poly = polyval(p, x);
    else
        baseline_poly = zeros(size(x));
    end

    % --- Constraint: remove sulfur peaks only above baseline ---
    y_corrected = max(y_temp, baseline_poly);  % no dip below baseline
    y_norm_sub = minmax_norm(y_corrected);     % final normalization

    % --- Offset & color ---
    offset = (k-1) * offsetStep;
    colorIdx = mod(k-1, size(customColorsT,1)) + 1;
    thisColor = customColorsT(colorIdx,:);

    % --- Extract label from filename ---
    parts = split(files(k).name, '_');
    if length(parts) >= 3
        label = strrep(parts{2}, 'uMA', '') + " " + strrep(parts{3}, 'v', '') + " V";
    else
        label = files(k).name;
    end

    % --- Plot constrained sulfur subtraction ---
    figure(1);
    plot(x, y_norm_sub + offset, '-', 'Color', thisColor, ...
        'LineWidth', thick, 'DisplayName', label);

    % --- Plot raw spectrum ---
    figure(2);
    plot(x, y + offset, '-', 'Color', thisColor, ...
        'LineWidth', thick, 'DisplayName', label);
end

% ======= Formatting Figure 1 =======
figure(1);
xlabel('Raman Shift (cm^{-1})', 'FontName', fname, 'FontSize', fsize);
ylabel('Normalized Intensity + Offset', 'FontName', fname, 'FontSize', fsize);
title(titleStr1, 'FontName', fname, 'FontSize', fsizet);
legend('show'); grid on;
ylim([-0.1, (length(files)-1)*offsetStep + 1.5]);

% ======= Formatting Figure 2 =======
figure(2);
xlabel('Raman Shift (cm^{-1})', 'FontName', fname, 'FontSize', fsize);
ylabel('Normalized Intensity + Offset', 'FontName', fname, 'FontSize', fsize);
title(titleStr2, 'FontName', fname, 'FontSize', fsizet);
legend('show'); grid on;
ylim([-0.1, (length(files)-1)*offsetStep + 1.5]);

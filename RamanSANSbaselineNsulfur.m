% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-2-2025
% Sulfur + Background Subtraction with Manual Background Tuning

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

% *********** User-adjustable tuning variable ***********
tuneBG = 0.04;  % Adjust this between 0.6–1.2 depending on visual output

% *********** Load and normalize background ***********
bg = load('coated_mesh_1800_1.txt');
bg_mask = (bg(:,1) >= 0) & (bg(:,1) <= 700);
bg_x = bg(bg_mask,1);
bg_y = minmax_norm(bg(bg_mask,2));
background = interp1(bg_x, bg_y, bg_x, 'linear', 'extrap');

% *********** Load sulfur reference ***********
RdataS8 = load('S8_1800_1.txt');
x_sulfur = RdataS8(:,1);
y_sulfur = minmax_norm(RdataS8(:,2));

% *********** List Raman data files (exclude sulfur and background) ***********
files = dir('*.txt');
files = files(~contains({files.name}, 'S8'));
files = files(~contains({files.name}, 'coated_mesh'));

% *********** Initialize Figures ***********
figure(1); hold on;
titleStr1 = 'Glow Grid 2.5\muM: Battery D (Sulfur + Tuned BG Subtracted)';
figure(2); hold on;
titleStr2 = 'Glow Grid 2.5\muM: Battery D (Raw Spectra)';
figure(3); hold on;
titleStr3 = 'Tuned Coated Mesh Background';

% *********** Process Raman Spectra ***********
for k = 1:length(files)
    data = load(files(k).name);
    x = data(:,1);
    y = minmax_norm(data(:,2));  % Normalize Raman signal

    % Interpolate background and sulfur to match x
    y_s8_interp = interp1(x_sulfur, y_sulfur, x, 'linear', 'extrap');
    bg_interp = interp1(bg_x, background, x, 'linear', 'extrap');

    % Scale background based on 290–320 cm⁻¹ and apply manual tuning
    bg_range = (x >= 290) & (x <= 320);
    if any(bg_range)
        scale_factor = mean(y(bg_range)) / mean(bg_interp(bg_range));
    else
        scale_factor = .03;
    end
    bg_scaled = bg_interp * scale_factor * tuneBG;

    % Subtract sulfur peaks within ±5 cm⁻¹
    peak_indices = ismembertol(x, x_sulfur, 1);
    y_corrected = y;
    y_corrected(peak_indices) = y_corrected(peak_indices) - y_s8_interp(peak_indices);
    y_corrected(y_corrected < 0) = 0;

    % Subtract scaled + tuned background
    y_final = y_corrected - bg_scaled;
    y_final(y_final < 0) = 0;

    % Offset and color
    offset = (k-1) * offsetStep;
    parts = split(files(k).name, '_');
    if length(parts) >= 3
        label = strrep(parts{2}, 'uMA', '') + " " + strrep(parts{3}, 'v', '') + " V";
    else
        label = files(k).name;
    end
    colorIdx = mod(k-1, size(customColorsT,1)) + 1;
    thisColor = customColorsT(colorIdx,:);

    % Plot final result
    figure(1);
    plot(x, y_final + offset, '-', 'Color', thisColor, ...
        'LineWidth', thick, 'DisplayName', label);

    % Plot raw result
    figure(2);
    plot(x, y + offset, '-', 'Color', thisColor, ...
        'LineWidth', thick, 'DisplayName', label);

    % Plot background once
    if k == 1
        figure(3);
        plot(x, bg_scaled, 'k-', 'LineWidth', thick, ...
            'DisplayName', sprintf('Tuned BG (%.2f)', tuneBG));
    end
end

% *********** Formatting: Subtracted ***********
figure(1);
xlabel('Raman Shift (cm^{-1})', 'FontName', fname, 'FontSize', fsize);
ylabel('Processed Intensity + Offset', 'FontName', fname, 'FontSize', fsize);
title(titleStr1, 'FontName', fname, 'FontSize', fsizet);
legend('show'); grid on;
ylim([-0.1, (length(files)-1)*offsetStep + 1.5]);

% *********** Formatting: Raw ***********
figure(2);
xlabel('Raman Shift (cm^{-1})', 'FontName', fname, 'FontSize', fsize);
ylabel('Normalized Intensity + Offset', 'FontName', fname, 'FontSize', fsize);
title(titleStr2, 'FontName', fname, 'FontSize', fsizet);
legend('show'); grid on;
ylim([-0.1, (length(files)-1)*offsetStep + 1.5]);

% *********** Formatting: Background ***********
figure(3);
xlabel('Raman Shift (cm^{-1})', 'FontName', fname, 'FontSize', fsize);
ylabel('Intensity (Tuned Background)', 'FontName', fname, 'FontSize', fsize);
title(titleStr3, 'FontName', fname, 'FontSize', fsizet);
legend('show'); grid on;

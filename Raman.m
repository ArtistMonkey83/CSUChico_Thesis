% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-28-2025
% Processes All Raman in the current directory 
% Two figures one with sulfur subtracted and one as collected

clear; clc; close all;

% *********** Custom color map ***********
customColorsT = [...
    9, 110, 106; 10, 153, 148; 39, 214, 208; 100, 250, 245; 162, 247, 245;
    68, 10, 107; 100, 12, 158; 139, 31, 212; 199, 123, 250; 220, 182, 245;
    186, 120, 6; 214, 140, 13; 242, 166, 34; 245, 191, 97; 245, 214, 161;
    16, 67, 158; 27, 93, 207; 48, 118, 240; 94, 152, 252; 169, 200, 255
] / 255;

% *********** Plot Styling ***********
thick  = 2.5;
fsize  = 16;
fsizet = 20;
fname  = 'Futura';
offsetStep = 1.5;

% *********** Min-max normalization function ***********
minmax_norm = @(x) (x - min(x)) / (max(x) - min(x));

% *********** Load sulfur reference ***********
RdataS8 = load('S8_1800_1.txt');
x_sulfur = RdataS8(:,1);
y_sulfur = RdataS8(:,2);

% *********** Find all .txt files except sulfur reference ***********
files = dir('*.txt');
files = files(~contains({files.name}, 'S8'));

% *********** Initialize figure 1: Sulfur-subtracted ***********
figure(1); hold on;
titleStr1 = 'Glow Grid 2.5\muM: Battery A (Sulfur-Subtracted)';
% *********** Initialize figure 2: Raw spectra ***********
figure(2); hold on;
titleStr2 = 'Glow Grid 2.5\muM: Battery A (Raw Spectra)';

for k = 1:length(files)
    data = load(files(k).name);
    x = data(:,1);
    y = data(:,2);

    % Interpolate sulfur reference to match x
    y_s8_interp = interp1(x_sulfur, y_sulfur, x, 'linear', 'extrap');

    % Subtracted and normalized
    y_sub = y - y_s8_interp;
    y_norm_sub = minmax_norm(y_sub);

    % Raw normalized
    y_norm_raw = minmax_norm(y);

    % Offset
    offset = (k-1) * offsetStep;

    % Extract label from filename
    parts = split(files(k).name, '_');
    if length(parts) >= 3
        label = strrep(parts{2}, 'uMA', '') + " " + strrep(parts{3}, 'v', '') + " V";
    else
        label = files(k).name;
    end

    % Assign color
    colorIdx = mod(k-1, size(customColorsT,1)) + 1;
    thisColor = customColorsT(colorIdx,:);

    % ---- Plot sulfur-subtracted in Figure 1 ----
    figure(1); 
    plot(x, y_norm_sub + offset, '-', ...
        'Color', thisColor, ...
        'LineWidth', thick, ...
        'DisplayName', label);

    % ---- Plot raw in Figure 2 ----
    figure(2);
    plot(x, y_norm_raw + offset, '-', ...
        'Color', thisColor, ...
        'LineWidth', thick, ...
        'DisplayName', label);
end

% ======= Formatting Figure 1 =======
figure(1);
xlabel('Raman Shift (cm^{-1})', 'FontName', fname, 'FontSize', fsize);
ylabel('Normalized Intensity + Offset', 'FontName', fname, 'FontSize', fsize);
title(titleStr1, 'FontName', fname, 'FontSize', fsizet);
legend('show');
grid on;
ylim([-0.1, (length(files)-1)*offsetStep + 1.5]);

% ======= Formatting Figure 2 =======
figure(2);
xlabel('Raman Shift (cm^{-1})', 'FontName', fname, 'FontSize', fsize);
ylabel('Normalized Intensity + Offset', 'FontName', fname, 'FontSize', fsize);
title(titleStr2, 'FontName', fname, 'FontSize', fsizet);
legend('show');
grid on;
ylim([-0.1, (length(files)-1)*offsetStep + 1.5]);

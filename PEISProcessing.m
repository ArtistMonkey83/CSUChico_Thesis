% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-25-2025

clear; clc; close all;

% *********** Load .txt data ***********
filename = 'Batt25uMA_2_22v_bode.txt';
data = readtable(filename, 'FileType', 'text', 'Delimiter', '\t', 'VariableNamingRule', 'preserve');

% *********** Extract all columns ***********
freq  = data.("Freq (Hz)");
zmod  = data.("Zmod (ohm)");
zphz  = data.("Zphz (°)");
zreal = data.("Zreal (ohm)");
zimag = data.("-Zimag (ohm)");

% *********** Custom color map (DT, MDT, T, MLT, LT) ***********
customColorsT = [...
    9, 110, 106;    % DT
    10, 153, 148;   % MDT
    39, 214, 208;   % Teal
    100, 250, 245;  % MLT
    162, 247, 245   % LT
] / 255;

% *********** Plot Line Thickness and Font Sizes ***********
thick  = 2.5;
fsize  = 16;
fsizet = 20;
fname = 'Futura';

% *********** Remove outliers ***********
outlierIdx_mod = isoutlier(zmod, 'movmedian', 3);
outlierIdx_nyq = isoutlier(zreal, 'movmedian', 3);  % for Nyquist

% Cleaned data for Bode
clean_freq  = freq(~outlierIdx_mod);
clean_zmod  = zmod(~outlierIdx_mod);
clean_zphz  = zphz(~outlierIdx_mod);

% Cleaned data for Nyquist
clean_zreal = zreal(~outlierIdx_nyq);
clean_zimag = zimag(~outlierIdx_nyq);

% *********** Plot Bode and Nyquist in one figure ***********
figure;

% --- Subplot 1: Bode Plot (|Z| and Phase vs Frequency)
subplot(2,1,1);

% Left axis (|Z|)
yyaxis left;
ax = gca;
ax.YColor = customColorsT(1,:);  % match y-axis color to |Z| line
semilogx(clean_freq, clean_zmod,...
    'Color', customColorsT(1,:), ...
    'LineWidth', thick, ...
    'DisplayName', '|Z|');
ylabel('|Z| (Ohms)', 'FontSize', fsize, 'FontName', 'fname');

% Right axis (Phase)
yyaxis right;
ax = gca;
ax.YColor = customColorsT(3,:);  % match y-axis color to Phase line
semilogx(clean_freq, clean_zphz,...
    'Color', customColorsT(3,:), ...
    'LineWidth', thick, ...
    'DisplayName', 'Phase');
ylabel('Phase (°)', 'FontSize', fsize, 'FontName', 'fname');

xlabel('Frequency (Hz)', 'FontSize', fsize, 'FontName', 'fname');
title('Bode Plot: |Z| and Phase vs Frequency', 'FontSize', fsizet, 'FontName', 'fname');
xlim([min(clean_freq) max(clean_freq)]);
legend('show');
grid on;

% --- Subplot 2: Nyquist Plot (Zreal vs -Zimag)
subplot(2,1,2);
plot(clean_zreal, clean_zimag,...
    'Color', customColorsT(2,:), ...
    'LineWidth', thick, ...
    'DisplayName', 'Nyquist');
xlabel('Z_{real} (\Omega)', 'FontSize', fsize, 'FontName', 'fname');
ylabel('-Z_{imag} (\Omega)', 'FontSize', fsize, 'FontName', 'fname');
title('Nyquist Plot', 'FontSize', fsizet, 'FontName', 'fname');
xlim([min(clean_zreal) max(clean_zreal)]);
axis equal;
grid on;



% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-22-2025

% clear all; clc; close all;

% *********** Load data ***********
Rdata_1_91v = load('batt25uMA_1_91v_1800.txt');
Rdata_2_09v = load('batt25uMA_2_09v_1800_2.txt');
Rdata_2_22v = load('batt25uMA_2_22v_1800_1.txt');
Rdata_2_3v  = load('batt25uMA_2_3v_1800_2.txt');
Rdata_2_49v = load('25uMA_2_49v_1800.txt');

RdataS8 = load('S8_1800_1.txt')
% *********** Custom color map ***********
customColorsT = [...
    9, 110, 106;    % DT
    10, 153, 148;   % MDT
    39, 214, 208;   % T
    100, 250, 245;  % MLT
    162, 247, 245   % LT

    68, 10, 107;    % DP
    100, 12, 158;   % MDP
    139, 31, 212;   % PURPLE
    199, 123, 250;  % MLP
    220, 182, 245;   % LP

    186, 120, 6;    % DO
    214, 140, 13;   % MDO
    242, 166, 34;   % ORANGE
    245, 191, 97;  % MLO
    245, 214, 161;   % LO

    16, 67, 158;    % DB
    27, 93, 207;   % MDB
    48, 118, 240;   % BLUE
    94, 152, 252;  % MLB
    169, 200, 255   % LB
] / 255;


% *********** Plot Line Thickness and Font Sizes ***********
thick  = 2.5;
fsize  = 16;
fsizet = 20;
fname = 'Futura';

% *********** Define min-max normalization ***********
minmax_norm = @(x) (x - min(x)) / (max(x) - min(x));

% *********** Extract x (cm^-1) and normalized y (Intensity) ***********
x_data = {
    Rdata_1_91v(:,1), Rdata_2_09v(:,1), Rdata_2_22v(:,1), Rdata_2_3v(:,1), Rdata_2_49v(:,1)
};
y_data = {
    minmax_norm(Rdata_1_91v(:,2)),
    minmax_norm(Rdata_2_09v(:,2)),
    minmax_norm(Rdata_2_22v(:,2)),
    minmax_norm(Rdata_2_3v(:,2)),
    minmax_norm(Rdata_2_49v(:,2))
};

labels = {'1.91 V', '2.09 V', '2.22 V', '2.3 V', '2.49 V'};

% *********** Vertical offsets ***********
offsetStep = 0.5;
offsets = offsetStep * (0:length(x_data)-1);

% *********** Plot Raman with offsets ***********
figure;
hold on;
for k = 1:length(x_data)
    colorIdx = min(k, size(customColorsT,1)); % avoid index error
    plot(x_data{k}, y_data{k} + offsets(k), '-', ...
        'Color', customColorsT(colorIdx,:), ...
        'LineWidth', thick, ...
        'DisplayName', labels{k});
end
hold off;

% *********** Title and Axis Labels ***********
titleStr = 'Glow Grid 2.5 \muM: Battery A';
h_title  = title(titleStr);
h_xlabel = xlabel('Raman Shift (cm^{-1})');
h_ylabel = ylabel('Normalized Intensity (counts) with 0.5 offset');
set([h_xlabel h_ylabel h_title], 'FontName', fname, 'FontSize', fsize);

legend('show');
grid on;

% *********** Adjust y-limits ***********
ylim([-0.1, max(offsets) + 1.0]);


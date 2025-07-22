% Load data
data_2_22v = load('batt25uMA_2_22v_1800_1.txt');
data_2_3v  = load('batt25uMA_2_3v_1800_3.txt');
data_2_97v = load('batt25uM_2_97v_1800_3.txt');

% Custom color map (DT, MDT, T, MLT, LT)
customColorsT = [...
    9, 110, 106;    % DT
    10, 153, 148;   % MDT
    39, 214, 208;   % T
    100, 250, 245;  % MLT
    162, 247, 245   % LT
] / 255;

% Line thickness
thick = 2.5;

% Define min-max normalization
minmax_norm = @(x) (x - min(x)) / (max(x) - min(x));

% Extract x (cm^-1) and normalized y (Intensity)
x_2_22v = data_2_22v(:,1);
x_2_3v  = data_2_3v(:,1);
x_2_97v = data_2_97v(:,1);

v2_22vnorm = minmax_norm(data_2_22v(:,2));
v2_3vnorm  = minmax_norm(data_2_3v(:,2));
v2_97vnorm = minmax_norm(data_2_97v(:,2));

% Vertical offsets
offsetStep = 0.5; % Amount of space between traces (change if you want)
offsets = [0, offsetStep, 2*offsetStep];

% Title variable
titleStr = 'Glow Grid 2.5 \muM: Battery A';

% Plot with offsets
figure;
plot(x_2_22v, v2_22vnorm + offsets(1), '-', 'Color', customColorsT(1,:), 'LineWidth', thick, 'DisplayName', '2.22 V'); hold on;
plot(x_2_3v,  v2_3vnorm  + offsets(2), '-', 'Color', customColorsT(2,:), 'LineWidth', thick, 'DisplayName', '2.3 V');
plot(x_2_97v, v2_97vnorm + offsets(3), '-', 'Color', customColorsT(3,:), 'LineWidth', thick, 'DisplayName', '2.97 V');
hold off;

xlabel('Raman Shift (cm^{-1})');
ylabel('Normalized Intensity (counts) with 0.5 offset');
title(titleStr);
legend('show');
grid on;

% Optional: adjust y-limits to fit all traces nicely
ylim([-0.1, 2*offsetStep + 1.07]);

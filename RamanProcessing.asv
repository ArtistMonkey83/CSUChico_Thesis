% Load data
data_2_22v = load('batt25uMA_2_22v_1800_1.txt');
data_2_3v  = load('batt25uMA_2_3v_1800_3.txt');
data_2_97v = load('batt25uM_2_97v_1800_3.txt');

% Define min-max normalization
minmax_norm = @(x) (x - min(x)) / (max(x) - min(x));

% Extract time and normalize measurement columns
time_2_22v = data_2_22v(:,1);
time_2_3v  = data_2_3v(:,1);
time_2_97v = data_2_97v(:,1);

v2_22vnorm = minmax_norm(data_2_22v(:,2));
v2_3vnorm  = minmax_norm(data_2_3v(:,2));
v2_97vnorm = minmax_norm(data_2_97v(:,2));

% Plot all on one graph
figure;
plot(time_2_22v, v2_22vnorm, 'b-', 'DisplayName', '2.22 V'); hold on;
plot(time_2_3v,  v2_3vnorm,  'r-', 'DisplayName', '2.3 V');
plot(time_2_97v, v2_97vnorm, 'g-', 'DisplayName', '2.97 V');
hold off;
xlabel('Time (s)');
ylabel('Normalized Measurement');
title('Min-Max Normalized Measurements');
legend('show');
grid on;

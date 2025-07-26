% EECE 699T Applied MS Thesis
% ID # 011234614 Yolie Reyes 7-25-2025

% clear; clc; close all;
% 
% % *********** Load .txt data ***********
% filename = 'ChargingBatt25uMA_2_3v_bode.txt';
% data = readtable(filename, 'FileType', 'text', 'Delimiter', '\t', 'VariableNamingRule', 'preserve');
% 
% % *********** Extract all columns ***********
% freq  = data.("Freq (Hz)");
% zmod  = data.("Zmod (ohm)");
% zphz  = data.("Zphz (°)");
% zreal = data.("Zreal (ohm)");
% zimag = data.("-Zimag (ohm)");

% *********** Remove outliers from |Z| ***********
outlierIdx = isoutlier(zmod, 'movmedian',3);
outlierIdx2 = isoutlier(zreal, 'movmedian',3);
clean_freq  = freq(~outlierIdx);
clean_zmod  = zmod(~outlierIdx);
clean_zphz  = zphz(~outlierIdx);
clean_zreal = zreal(~outlierIdx2);
clean_zimag = zimag(~outlierIdx2);

% *********** Plot Bode and Nyquist in one figure ***********
figure;

% --- Subplot 1: Bode Plot (|Z| and Phase vs Frequency)
subplot(2,1,1);
yyaxis left;
semilogx(clean_freq, clean_zmod, 'DisplayName', '|Z|');
ylabel('|Z| (Ohms)', 'FontSize', 8, 'FontName', 'Times New Roman');

yyaxis right;
semilogx(clean_freq, clean_zphz, 'DisplayName', 'Phase');
ylabel('Phase (°)', 'FontSize', 8, 'FontName', 'Times New Roman');

xlabel('Frequency (Hz)', 'FontSize', 8, 'FontName', 'Times New Roman');
title('Bode Plot: |Z| and Phase vs Frequency', 'FontSize', 8, 'FontName', 'Times New Roman');
legend('show');
grid on;

% --- Subplot 2: Nyquist Plot (Zreal vs -Zimag)
subplot(2,1,2);
plot(clean_zreal, clean_zimag, 'DisplayName', 'Nyquist');
xlabel('Z_{real} (\Omega)', 'FontSize', 8, 'FontName', 'Times New Roman');
ylabel('-Z_{imag} (\Omega)', 'FontSize', 8, 'FontName', 'Times New Roman');
title('Nyquist Plot', 'FontSize', 8, 'FontName', 'Times New Roman');
axis equal;
grid on;
legend show;

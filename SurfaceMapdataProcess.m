
clear all; clc;close all;
% === User Configuration ===
battToPlot = 'GlowGrid25uM_BattA';
basePath = '/Users/scholar/Desktop/Chico State/Graduate School/Thesis Proposal/ThesisBatteries/Processed Data';
ramanPath = fullfile(basePath, battToPlot, 'Raman');
eisPath   = fullfile(basePath, battToPlot, 'EIS');

% === Define Custom Colors ===
customColorsT = [9,110,106; 10,153,148; 39,214,208; 100,250,245; 162,247,245] / 255;
customColorsP = [68,10,107; 100,12,158; 139,31,212; 199,123,250; 220,182,245] / 255;

% === Load Raman Data ===
ramanFiles = dir(fullfile(ramanPath, '*.txt'));
RamanData = {};
for k = 1:length(ramanFiles)
    try
        T = readtable(fullfile(ramanPath, ramanFiles(k).name), 'FileType', 'text');
        A = table2array(T);
        A = A(~any(isnan(A), 2), :); % remove rows with NaNs
        if size(A,2) >= 2
            RamanData{end+1} = A(:, 1:2);
        end
    catch
        fprintf('Error reading Raman file: %s\n', ramanFiles(k).name);
    end
end

% === Load EIS Data ===
eisFiles = dir(fullfile(eisPath, '*.txt'));
EISData = {};
for k = 1:length(eisFiles)
    try
        T = readtable(fullfile(eisPath, eisFiles(k).name), 'FileType', 'text');
        A = table2array(T);
        A = A(~any(isnan(A), 2), :); % remove rows with NaNs
        if size(A,2) >= 2
            EISData{end+1} = A(:, 1:2); % Use Freq, Zmod
        end
    catch
        fprintf('Error reading EIS file: %s\n', eisFiles(k).name);
    end
end

% === Raman Plot ===
figure; hold on;
for k = 1:length(RamanData)
    data = RamanData{k};
    x = data(:,1); z = data(:,2); y = ones(size(x)) * k;

    if isempty(x) || isempty(z), continue; end

    if k <= 5
        c = customColorsT(k,:);
    else
        c = customColorsP(min(k - 5, size(customColorsP, 1)), :);
    end

    surf([x'; x'], [y'; y'], [z'; z'], 'FaceColor', c, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
end
view(3); grid on;
xlabel('Raman Shift (cm^{-1})'); ylabel('Sample Index'); zlabel('Intensity (a.u.)');
title('Raman 3D Surface Map');

% === EIS Plot ===
figure; hold on;
for k = 1:length(EISData)
    data = EISData{k};
    x = data(:,1); z = data(:,2); y = ones(size(x)) * k;

    if isempty(x) || isempty(z), continue; end

    if k <= 5
        c = customColorsT(k,:);
    else
        c = customColorsP(min(k - 5, size(customColorsP, 1)), :);
    end

    surf([x'; x'], [y'; y'], [z'; z'], 'FaceColor', c, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
end
view(3); grid on;
xlabel('Frequency (Hz)'); ylabel('Sample Index'); zlabel('Zmod (Ω)');
title('EIS 3D Surface Map');


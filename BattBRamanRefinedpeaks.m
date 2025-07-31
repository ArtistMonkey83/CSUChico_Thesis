% EECE 699T MS Thesis
% ID # 011234614 Yolie Reyes 7-30-2025
% Raman Processing Battery 25µM B, ALL Annotated Peaks
% Centered Labels, Tight Y-Limits

clear; clc; close all;

% *********** Custom color map ***********
customColorsT = [...
    9,110,106;10,153,148;39,214,208;100,250,245;162,247,245;
    68,10,107;100,12,158;139,31,212;199,123,250;220,182,245;
    186,120,6;214,140,13;242,166,34;245,191,97;245,214,161;
    16,67,158;27,93,207;48,118,240;94,152,252;169,200,255
] / 255;

% *********** Plot Styling ***********
thick      = 2.5;
fsize      = 16;
fsizet     = 20;
fname      = 'Futura';
offsetStep = 1.5;

% *********** Peak Positions ***********
peakIndicator  = [108, 184, 219, 246, 289, 435, 461, 472, 486];
DFTcalculated  = [ 146, 156, 184, 328, 423, 455, 500];

% *********** Peak Labels ***********
solidPeakLabel = {
    'S_{7}^{2-}', 'S_{3}^{2-} ', 'S_{8}^{2-}', 'S_{7}^{2-} & S_{8}^{2-}', 'LiTFSI'...
    'S_{4}^{2-}+S_{6}^{2-}', ...
    '  S_{4}^{2-}', 'S_{5}^{2-}', '   S_{7}^{2-}+S_{8}^{2-}'};
dotPeakLabel   = {
    '   S_{5}^{-}+S_{7}^{-}   S_{5}^{-}+S_{8}^{-}', ' ', ...
    '          & S_{8}^{-}', 'S_{6}^{-}', '    S_{6}^{-}', '  S_{4}^{-}', 'S_{8}^{-}'};

% *********** Label Styling ***********
labelFont     = 'Futura';
labelFontsize = 10;
thickSolid    = 2;
thickDot      = 2;
colorSolid    = [179, 177, 186]/255;
colorDot      = [64, 64, 64]/255;

% *********** Normalize Function ***********
minmax_norm = @(x) (x - min(x)) / (max(x) - min(x));

% *********** Load Sulfur Reference ***********
RdataS8    = load('S8_1800_1.txt');
x_sulfur   = RdataS8(:,1);
y_sulfur   = RdataS8(:,2);

% *********** Load Raman Files ***********
files = dir('*.txt');
files = files(~contains({files.name}, 'S8'));

% *********** Prepare Figures ***********
figure(1); hold on;
title('Glow Grid 2.5\muM: Battery B (Sulfur-Subtracted)', ...
    'FontName', fname, 'FontSize', fsizet);
figure(2); hold on;
title('Glow Grid 2.5\muM: Battery B (Raw Spectra)', ...
    'FontName', fname, 'FontSize', fsizet);

% *********** Plot Spectra ***********
for k = 1:numel(files)
    d      = load(files(k).name);
    x      = d(:,1);
    y      = d(:,2);
    y_s8_i = interp1(x_sulfur, y_sulfur, x, 'linear', 'extrap');
    
    y_sub     = y - y_s8_i;
    y_norm_sub= minmax_norm(y_sub);
    y_norm_raw= minmax_norm(y);
    offset    = (k-1)*offsetStep;
    
    parts = split(files(k).name,'_');
    if numel(parts)>=3
        lbl = strrep(parts{2},'uMA','') + "." + strrep(parts{3},'v','') + " V";
    else
        lbl = files(k).name;
    end
    
    colIdx    = mod(k-1, size(customColorsT,1)) + 1;
    thisColor = customColorsT(colIdx,:);
    
    figure(1);
    plot(x, y_norm_sub+offset, '-', ...
        'Color', thisColor, 'LineWidth', thick, ...
        'DisplayName', lbl);    % for legend only
    
    figure(2);
    plot(x, y_norm_raw+offset, '-', ...
        'Color', thisColor, 'LineWidth', thick, ...
        'DisplayName', lbl);
end

% *********** Annotate Peaks & Tighten Y ***********
labelGap = 0.2;  % room for labels above
for figNum = [1,2]
    figure(figNum);
    ax = gca; hold(ax,'on');
    
    % compute top of spectra
    maxOffset = (numel(files)-1)*offsetStep;
    topData   = maxOffset + 1;
    
    % expand y‐limits
    ylim([0, topData+.8 + labelGap]);
    
    % solid peaks
    for i = 1:numel(peakIndicator)
        xval = peakIndicator(i);
        txt  = solidPeakLabel{i};
        
        % draw line up to topData
        plot([xval xval], [0 topData+.4], '-', ...
            'Color', colorSolid, ...
            'LineWidth', thickSolid, ...
            'HandleVisibility','off');
        
        % place label in the gap
        text(xval, topData+.6 + labelGap/2, txt, ...
            'FontSize',     labelFontsize, ...
            'FontName',     labelFont, ...
            'Color',        colorSolid, ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'Interpreter','tex', ...
            'HandleVisibility','off');
    end
    
    % dotted peaks
    for i = 1:numel(DFTcalculated)
        xval = DFTcalculated(i);
        txt  = dotPeakLabel{i};
        plot([xval xval], [0 topData+.2], ':', ...
            'Color', colorDot, ...
            'LineWidth', thickDot, ...
            'HandleVisibility','off');
        text(xval, topData+.3 + labelGap/2, txt, ...
            'FontSize',     labelFontsize, ...
            'FontName',     labelFont, ...
            'Color',        colorDot, ...
            'HorizontalAlignment','center', ...
            'VerticalAlignment','middle', ...
            'Interpreter','tex', ...
            'HandleVisibility','off');
    end
    
    % finalize
    xlabel('Raman Shift (cm^{-1})',         ...
        'FontName', fname, 'FontSize', fsize);
    ylabel('Normalized Intensity + Offset', ...
        'FontName', fname, 'FontSize', fsize);
    grid(ax,'on');
    legend(ax,'show', ...
        'Location','southoutside', ...
        'NumColumns',3, ...
        'FontSize',8);
end

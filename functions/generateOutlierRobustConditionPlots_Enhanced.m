function generateOutlierRobustConditionPlots_Enhanced(conditionDataStructure, conditions, participant, outputDir)
% ENHANCED VERSION - Create condition plots with voice type differentiation
% Now shows separate boxes for natural vs synthetic voices with visual grouping

try
    % Create main figure
    fig = figure('Position', [100, 100, 1800, 1400]); % Wider for more conditions

    % Define metrics to plot (same as your original)
    metrics = {'StableMeanDisplacement', 'StableMaxDisplacement', 'ROIFlowMagnitude', 'Entropy', ...
        'PeakVelocities', 'MeanVelocities'};
    metricTitles = {'Mean Displacement', 'Max Displacement', 'Flow Magnitude', 'Entropy', ...
        'Peak Velocities', 'Mean Velocities'};
    metricUnits = {'(pixels)', '(pixels)', '(pixels/frame)', '(bits)', ...
        '(pixels/frame)', '(pixels/frame)'};

    % Calculate subplot layout
    numMetrics = length(metrics);
    cols = 4;
    rows = ceil(numMetrics / cols);

    % Initialize outlier summary
    outlierSummary = struct();

    for metricIdx = 1:numMetrics
        subplot(rows, cols, metricIdx);

        try
            % Extract data for this metric across conditions WITH OUTLIER REMOVAL
            metricName = metrics{metricIdx};
            [conditionData, conditionLabels, outlierInfo] = extractConditionDataWithOutlierRemoval_Direct(conditionDataStructure, conditions, metricName);

            % Store outlier information
            outlierSummary.(metricName) = outlierInfo;

            if length(conditionData) >= 2
                % Create enhanced boxplot with voice type grouping
                createEnhancedVoiceTypeBoxplot(conditionData, conditionLabels, metricTitles{metricIdx}, outlierInfo);

                % Add units to the plot
                title([metricTitles{metricIdx}, ' ', metricUnits{metricIdx}], 'FontSize', 12);
                ylabel(['Value ', metricUnits{metricIdx}], 'FontSize', 10);
                xlabel('Voice Type + Emotion', 'FontSize', 10);

            else
                % Not enough data for comparison
                text(0.5, 0.5, ['Insufficient data for ', metricTitles{metricIdx}], ...
                    'HorizontalAlignment', 'center', 'Units', 'normalized');
                title([metricTitles{metricIdx}, ' ', metricUnits{metricIdx}], 'FontSize', 12);
            end

        catch ME
            disp(['Enhanced boxplot failed for ', metrics{metricIdx}, ': ', ME.message]);
            text(0.5, 0.5, ['Error: ', ME.message], 'HorizontalAlignment', 'center', 'Units', 'normalized');
            title([metricTitles{metricIdx}, ' ', metricUnits{metricIdx}, ' (Error)'], 'FontSize', 12);
        end
    end

    sgtitle(['Enhanced Voice Type + Emotion Analysis (Outliers Removed) - ', participant], 'FontSize', 16, 'FontWeight', 'bold');

    % Save figure in enhanced format
    outputDir_plots = fullfile(outputDir, 'ConditionAnalysis');
    if ~exist(outputDir_plots, 'dir')
        mkdir(outputDir_plots);
    end

    % Define base filename
    baseName = ['EnhancedVoiceTypeConditionAnalysis_', participant];
    pngFile = fullfile(outputDir_plots, [baseName, '.png']);
    svgFile = fullfile(outputDir_plots, [baseName, '.svg']);

    try
        % Set figure properties for better quality
        set(fig, 'PaperPositionMode', 'auto');
        set(fig, 'InvertHardcopy', 'off');
        set(fig, 'Color', 'white');

        % Save PNG (high-resolution raster)
        print(fig, pngFile, '-dpng', '-r300');
        disp(['✓ Enhanced PNG saved: ', pngFile]);

        % Try SVG (scalable vector graphics)
        try
            print(fig, svgFile, '-dsvg');
            disp(['✓ Enhanced SVG vector saved: ', svgFile]);
        catch svgError
            disp(['SVG save failed: ', svgError.message]);
        end

    catch saveError
        disp(['Enhanced save failed: ', saveError.message]);
        saveas(fig, pngFile, 'png');
        disp(['✓ Fallback PNG save completed']);
    end

    close(fig);

    % Generate enhanced outlier summary report
    generateEnhancedOutlierSummaryReport(outlierSummary, participant, outputDir, conditions);

    disp(['✅ Enhanced voice type condition analysis completed for: ', participant]);

catch ME
    disp(['❌ Error in enhanced voice type condition plots: ', ME.message]);
    if exist('fig', 'var')
        close(fig);
    end
end
end

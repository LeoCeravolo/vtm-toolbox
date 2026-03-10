function generateOutlierRobustConditionPlots(conditionDataStructure, conditions, participant, outputDir)
% GENERATEOUTLIERROBUSTCONDITIONPLOTS - Adapted from your original plotting function
% Now uses direct data access but keeps all outlier removal functionality

try
    % Create main figure
    fig = figure('Position', [100, 100, 1600, 1200]);

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
                % Create boxplot with outlier-cleaned data (using your function)
                createOutlierRobustBoxplot(conditionData, conditionLabels, metricTitles{metricIdx}, outlierInfo);

                % Add units to the plot
                title([metricTitles{metricIdx}, ' ', metricUnits{metricIdx}], 'FontSize', 12);
                ylabel(['Value ', metricUnits{metricIdx}], 'FontSize', 10);
                xlabel('Emotional Condition', 'FontSize', 10);

            else
                % Not enough data for comparison
                text(0.5, 0.5, ['Insufficient data for ', metricTitles{metricIdx}], ...
                    'HorizontalAlignment', 'center', 'Units', 'normalized');
                title([metricTitles{metricIdx}, ' ', metricUnits{metricIdx}], 'FontSize', 12);
            end

        catch ME
            disp(['Boxplot failed for ', metrics{metricIdx}, ': ', ME.message]);
            text(0.5, 0.5, ['Error: ', ME.message], 'HorizontalAlignment', 'center', 'Units', 'normalized');
            title([metricTitles{metricIdx}, ' ', metricUnits{metricIdx}, ' (Error)'], 'FontSize', 12);
        end
    end

    sgtitle(['Enhanced Condition Analysis (Outliers Removed) - ', participant], 'FontSize', 16, 'FontWeight', 'bold');

    % Save figure in BOTH formats (same as your original)
    outputDir_plots = fullfile(outputDir, 'ConditionAnalysis');
    if ~exist(outputDir_plots, 'dir')
        mkdir(outputDir_plots);
    end

    % Define base filename
    baseName = ['OutlierRobustConditionAnalysis_', participant];
    pngFile = fullfile(outputDir_plots, [baseName, '.png']);
    svgFile = fullfile(outputDir_plots, [baseName, '.svg']);

    try
        % Set figure properties for better quality
        set(fig, 'PaperPositionMode', 'auto');
        set(fig, 'InvertHardcopy', 'off');
        set(fig, 'Color', 'white');

        % Save PNG (high-resolution raster)
        print(fig, pngFile, '-dpng', '-r300');
        disp(['✓ PNG saved: ', pngFile]);

        % Try SVG (scalable vector graphics)
        try
            print(fig, svgFile, '-dsvg');
            disp(['✓ SVG vector saved: ', svgFile]);
        catch svgError
            disp(['SVG save failed: ', svgError.message]);

            % Try super high-resolution PNG as backup (600 DPI)
            pngHiResFile = fullfile(outputDir_plots, [baseName, '_HighRes.png']);
            try
                print(fig, pngHiResFile, '-dpng', '-r600');
                disp(['✓ High-res PNG saved instead (600 DPI): ', pngHiResFile]);
            catch hiResError
                disp(['High-res PNG also failed - standard PNG available']);
            end
        end

    catch saveError
        % Fallback to basic save if everything fails
        disp(['Primary save failed, using fallback: ', saveError.message]);
        saveas(fig, pngFile, 'png');
        disp(['✓ Fallback PNG save completed']);
    end

    close(fig);

    % Generate outlier summary report (using your function)
    generateOutlierSummaryReport(outlierSummary, participant, outputDir);

    disp(['✅ Outlier-robust condition analysis completed for: ', participant]);

catch ME
    disp(['❌ Error in outlier-robust condition plots: ', ME.message]);
    if exist('fig', 'var')
        close(fig);
    end
end
end

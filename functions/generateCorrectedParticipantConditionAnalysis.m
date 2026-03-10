function generateCorrectedParticipantConditionAnalysis(participantConditionData, participant, conditions, mimicryConfig, qualityControlPath)
% function generateCorrectedParticipantConditionAnalysis(participantConditionData, participant, conditions, mimicryConfig)
% Generate corrected participant-level condition analysis with OUTLIER REMOVAL
try
    % Create main figure
    fig = figure('Position', [100, 100, 1600, 1200]); %, 'Name', ['Enhanced Condition Analysis with Outlier Removal - ', participant]);

    % Define metrics to plot with corresponding units
    metrics = {'StableMeanDisplacement', 'StableMaxDisplacement', 'ROIFlowMagnitude', 'Entropy', ...
        'PeakVelocities', 'MeanVelocities'};
    metricTitles = {'Mean Displacement', 'Max Displacement', 'Flow Magnitude', 'Entropy', ...
        'Peak Velocities', 'Mean Velocities'};
    metricUnits = {'(pixels)', '(pixels)', '(pixels/frame)', '(bits)', ...
        '(pixels/frame)', '(pixels/frame)'}; % , '(pixels)', '(pixels/frame)'

    % Calculate subplot layout
    numMetrics = length(metrics);
    cols = 4;
    rows = ceil(numMetrics / cols);

    % Initialize outlier summary
    outlierSummary = struct();

    for metricIdx = 1:numMetrics
        subplot(rows, cols, metricIdx);

        try
            % Extract data for this metric across conditions
            metricName = metrics{metricIdx};
            [conditionData, conditionLabels, outlierInfo] = extractConditionDataWithOutlierRemoval(participantConditionData, conditions, metricName);

            % Store outlier information
            outlierSummary.(metricName) = outlierInfo;

            if length(conditionData) >= 2
                % Create boxplot with outlier-cleaned data
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

    %     sgtitle(['Enhanced Condition Analysis (Outliers Removed) - ', participant], 'FontSize', 16, 'FontWeight', 'bold');

    % Save figure in BOTH formats - correct folder structure
    baseDir = 'E:\Dropbox\LeuchterGrandjean_lc_sg';
    outputDir = fullfile(baseDir, participant, 'ConditionAnalysis');
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % Define base filename
    baseName = ['OutlierRobustConditionAnalysis_', participant];
    pngFile = fullfile(outputDir, [baseName, '.png']);
    svgFile = fullfile(outputDir, [baseName, '.svg']);

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
            pngHiResFile = fullfile(outputDir, [baseName, '_HighRes.png']);
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

    % Generate outlier summary report
    %     generateOutlierSummaryReport(outlierSummary, participant, outputDir);
    generateOutlierSummaryReport(outlierSummary, participant, qualityControlPath);

catch ME
    disp(['Enhanced condition analysis error: ', ME.message]);
    if exist('fig', 'var')
        close(fig);
    end
end
end
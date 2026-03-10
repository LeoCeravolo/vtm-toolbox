function generateConditionPlotsFromData(conditionTrials, allTrialData, participant, outputDir)
% GENERATECONDITIONPLOTSFROMDATA - Generate plots using direct data access
try
    % Create figure
    fig = figure('Position', [100, 100, 1600, 1200]);

    % Define metrics to analyze
    metrics = {'StableMeanDisplacement', 'MaxVelocity', 'ROIFlowMagnitude'};
    metricTitles = {'Mean Displacement', 'Peak Velocity', 'Flow Magnitude'};
    metricUnits = {'(pixels)', '(pixels)', '(pixels/frame)', '(pixels/frame)'};

    conditions = fieldnames(allTrialData);

    for metricIdx = 1:length(metrics)
        subplot(2, 2, metricIdx);

        try
            metricName = metrics{metricIdx};

            % Extract data for this metric across all conditions
            plotData = [];
            groupLabels = [];
            conditionNames = {};

            for condIdx = 1:length(conditions)
                conditionType = conditions{condIdx};
                conditionInfo = allTrialData.(conditionType);

                % Extract metric values from all trials in this condition
                metricValues = [];
                for trialIdx = 1:length(conditionInfo.data)
                    trialData = conditionInfo.data{trialIdx};
                    value = extractMetricFromTrial(trialData, metricName);

                    if isfinite(value) && value > 0
                        metricValues(end+1) = value;
                    end
                end

                if ~isempty(metricValues)
                    plotData = [plotData; metricValues(:)];
                    groupLabels = [groupLabels; repmat(condIdx, length(metricValues), 1)];
                    conditionNames{end+1} = conditionType;

                    disp(['  📊 ', conditionType, ': ', num2str(length(metricValues)), ' valid values for ', metricName]);
                end
            end

            % Create plot
            if length(plotData) >= 3 && length(unique(groupLabels)) >= 2
                % Create boxplot
                boxplot(plotData, groupLabels, 'Colors', 'k');
                hold on;

                % Add individual points with jitter
                colors = [0.8, 0.2, 0.2; 0.2, 0.6, 0.8; 0.2, 0.8, 0.2; 0.9, 0.6, 0.2];

                for condIdx = 1:length(conditionNames)
                    conditionMask = groupLabels == condIdx;
                    if any(conditionMask)
                        conditionValues = plotData(conditionMask);
                        jitter = (rand(length(conditionValues), 1) - 0.5) * 0.2;
                        x_pos = condIdx + jitter;

                        color_idx = mod(condIdx-1, size(colors, 1)) + 1;
                        scatter(x_pos, conditionValues, 60, colors(color_idx, :), 'filled', ...
                            'MarkerEdgeColor', 'k', 'LineWidth', 0.5, 'MarkerFaceAlpha', 0.7);
                    end
                end

                hold off;
                set(gca, 'XTickLabel', conditionNames);
                title([metricTitles{metricIdx}, ' ', metricUnits{metricIdx}]);
                ylabel(['Value ', metricUnits{metricIdx}]);
                xlabel('Condition');
                grid on;

                % Add sample sizes
                ylims = ylim;
                y_text = ylims(2) * 0.95;
                for condIdx = 1:length(conditionNames)
                    conditionMask = groupLabels == condIdx;
                    n = sum(conditionMask);
                    text(condIdx, y_text, ['n=', num2str(n)], ...
                        'HorizontalAlignment', 'center', 'FontSize', 8, ...
                        'BackgroundColor', 'white');
                end

            else
                text(0.5, 0.5, ['Insufficient data for ', metricTitles{metricIdx}], ...
                    'HorizontalAlignment', 'center', 'Units', 'normalized');
                title([metricTitles{metricIdx}, ' (Insufficient Data)']);
            end

        catch plotError
            text(0.5, 0.5, ['Plot error: ', plotError.message], ...
                'HorizontalAlignment', 'center', 'Units', 'normalized');
            title([metricTitles{metricIdx}, ' (Error)']);
        end
    end

    sgtitle(['Condition Analysis (Direct Data Access) - ', participant], 'FontSize', 16);

    % Save figure
    outputFile = fullfile(outputDir, ['DirectConditionAnalysis_', participant, '.png']);

    set(fig, 'PaperPositionMode', 'auto');
    set(fig, 'InvertHardcopy', 'off');
    set(fig, 'Color', 'white');

    print(fig, outputFile, '-dpng', '-r300');
    disp(['✅ Condition plot saved: ', outputFile]);

    close(fig);

catch ME
    disp(['❌ Error generating condition plots: ', ME.message]);
    if exist('fig', 'var')
        close(fig);
    end
end
end

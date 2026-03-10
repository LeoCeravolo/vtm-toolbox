function createVelocityProfileComparison(velocityData, validConditions)
% Create velocity profile comparison plot

conditionColors = [
    0.2, 0.6, 1.0;    % Blue for neutral
    0.9, 0.6, 0.1;    % Orange for pleasure
    0.2, 0.8, 0.2;    % Green for happiness
    0.8, 0.2, 0.2     % Red for anger
    ];

hold on;
legendEntries = {};

for condIdx = 1:length(validConditions)
    condName = validConditions{condIdx};

    % Combine all velocity metrics for this condition
    allVelocities = [];
    if isfield(velocityData.(condName), 'peakVelocities')
        allVelocities = [allVelocities, velocityData.(condName).peakVelocities];
    end
    if isfield(velocityData.(condName), 'meanVelocities')
        allVelocities = [allVelocities, velocityData.(condName).meanVelocities];
    end

    if ~isempty(allVelocities)
        validVelocities = allVelocities(isfinite(allVelocities) & allVelocities > 0);

        if length(validVelocities) >= 2
            % Create histogram/density plot
            [counts, centers] = hist(validVelocities, 10);
            counts = counts / sum(counts); % Normalize

            colorIdx = mod(condIdx-1, size(conditionColors, 1)) + 1;
            plot(centers, counts, 'LineWidth', 2, 'Color', conditionColors(colorIdx, :));
            legendEntries{end+1} = condName;
        end
    end
end

if ~isempty(legendEntries)
    legend(legendEntries, 'Location', 'best');
    title('Velocity Distribution Comparison', 'FontSize', 10, 'FontWeight', 'bold');
    xlabel('Velocity (pixels/s)', 'FontSize', 9);
    ylabel('Normalized Frequency', 'FontSize', 9);
    grid on;
else
    text(0.5, 0.5, 'No Data Available', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    title('Velocity Distribution Comparison', 'FontSize', 10, 'FontWeight', 'bold');
end
end
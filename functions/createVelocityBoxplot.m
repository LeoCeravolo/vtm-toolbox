function createVelocityBoxplot(velocityData, validConditions, metricName, yLabel)
% Helper function to create velocity boxplots

groupData = [];
groupLabels = {};

conditionColors = [
    0.2, 0.6, 1.0;    % Blue for neutral
    0.9, 0.6, 0.1;    % Orange for pleasure
    0.2, 0.8, 0.2;    % Green for happiness
    0.8, 0.2, 0.2     % Red for anger
    ];

hasData = false;
for condIdx = 1:length(validConditions)
    condName = validConditions{condIdx};
    if isfield(velocityData.(condName), metricName) && ~isempty(velocityData.(condName).(metricName))
        data = velocityData.(condName).(metricName);
        validData = data(isfinite(data) & data > 0);

        if ~isempty(validData)
            groupData = [groupData; validData(:)];
            groupLabels = [groupLabels; repmat({condName}, length(validData), 1)];
            hasData = true;
        end
    end
end

if hasData && ~isempty(groupData)
    boxplot(groupData, groupLabels, 'Colors', 'k');

    % Overlay data points
    hold on;
    uniqueLabels = unique(groupLabels);
    for labelIdx = 1:length(uniqueLabels)
        label = uniqueLabels{labelIdx};
        labelData = groupData(strcmp(groupLabels, label));

        if ~isempty(labelData)
            x = labelIdx + (rand(length(labelData), 1) - 0.5) * 0.2;
            colorIdx = find(strcmp(validConditions, label));
            if ~isempty(colorIdx)
                colorIdx = mod(colorIdx-1, size(conditionColors, 1)) + 1;
                scatter(x, labelData, 30, conditionColors(colorIdx, :), 'filled', 'Alpha', 0.6);
            end
        end
    end
    hold off;

    title(yLabel, 'FontSize', 10, 'FontWeight', 'bold');
    ylabel(yLabel, 'FontSize', 9);
    xlabel('Condition', 'FontSize', 9);
    xtickangle(45);
    grid on;
else
    text(0.5, 0.5, 'No Data Available', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    title(yLabel, 'FontSize', 10, 'FontWeight', 'bold');
end
end

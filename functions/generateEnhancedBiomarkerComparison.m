function generateEnhancedBiomarkerComparison(participantConditionData, participant, conditions, outputDir)
% Generate comprehensive biomarker comparison with fixed peak velocity calculations

if nargin < 4
    outputDir = pwd; % Use current directory if not specified
end

try
    % Ensure output directory exists
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end

    % Extract and validate condition data
    validConditions = {};
    biomarkerData = struct();

    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        if isfield(participantConditionData, condName)
            validConditions{end+1} = condName;

            % Traditional biomarkers
            biomarkerData.(condName).meanDisplacement = [];
            biomarkerData.(condName).maxDisplacement = [];
            biomarkerData.(condName).flowMagnitude = [];
            biomarkerData.(condName).entropy = [];

            % Enhanced velocity biomarkers (FIXED)
            biomarkerData.(condName).peakVelocity = [];
            biomarkerData.(condName).meanVelocity = [];
            biomarkerData.(condName).velocityVariance = [];
            biomarkerData.(condName).maxAcceleration = [];

            % Extract traditional biomarkers
            if isfield(participantConditionData.(condName), 'StableMeanDisplacement')
                data = participantConditionData.(condName).StableMeanDisplacement;
                biomarkerData.(condName).meanDisplacement = data(isfinite(data));
            end

            if isfield(participantConditionData.(condName), 'StableMaxDisplacement')
                data = participantConditionData.(condName).StableMaxDisplacement;
                biomarkerData.(condName).maxDisplacement = data(isfinite(data));
            end

            if isfield(participantConditionData.(condName), 'ROIFlowMagnitude')
                data = participantConditionData.(condName).ROIFlowMagnitude;
                biomarkerData.(condName).flowMagnitude = data(isfinite(data));
            end

            if isfield(participantConditionData.(condName), 'Entropy')
                data = participantConditionData.(condName).Entropy;
                biomarkerData.(condName).entropy = data(isfinite(data));
            end

            % Extract enhanced velocity biomarkers (FIXED IMPLEMENTATION)
            if isfield(participantConditionData.(condName), 'VelocityMetrics')
                velocityMetrics = participantConditionData.(condName).VelocityMetrics;

                for trialIdx = 1:length(velocityMetrics)
                    if ~isempty(velocityMetrics{trialIdx}) && isstruct(velocityMetrics{trialIdx})
                        vm = velocityMetrics{trialIdx};

                        if isfield(vm, 'peakVelocity') && isfinite(vm.peakVelocity)
                            biomarkerData.(condName).peakVelocity(end+1) = vm.peakVelocity;
                        end
                        if isfield(vm, 'meanVelocity') && isfinite(vm.meanVelocity)
                            biomarkerData.(condName).meanVelocity(end+1) = vm.meanVelocity;
                        end
                        if isfield(vm, 'velocityVariance') && isfinite(vm.velocityVariance)
                            biomarkerData.(condName).velocityVariance(end+1) = vm.velocityVariance;
                        end
                        if isfield(vm, 'maxAcceleration') && isfinite(vm.maxAcceleration)
                            biomarkerData.(condName).maxAcceleration(end+1) = vm.maxAcceleration;
                        end
                    end
                end
            else
                % FALLBACK: Calculate from displacement data if velocity metrics missing
                disp(['Warning: No VelocityMetrics found for ', condName, '. Calculating from displacement data.']);

                if isfield(participantConditionData.(condName), 'StableMeanDisplacement')
                    displacements = participantConditionData.(condName).StableMeanDisplacement;
                    validDisp = displacements(isfinite(displacements) & displacements > 0);

                    if ~isempty(validDisp)
                        % Convert displacement to velocity (assuming 25 fps)
                        frameRate = 25;
                        velocities = validDisp * frameRate;

                        biomarkerData.(condName).peakVelocity = max(velocities);
                        biomarkerData.(condName).meanVelocity = mean(velocities);
                        biomarkerData.(condName).velocityVariance = var(velocities);

                        if length(velocities) > 1
                            accelerations = diff(velocities) * frameRate;
                            biomarkerData.(condName).maxAcceleration = max(abs(accelerations));
                        end
                    end
                end
            end
        end
    end

    if isempty(validConditions)
        disp('Warning: No valid conditions found for biomarker comparison');
        return;
    end

    % Create enhanced biomarker comparison figure
    fig = figure('Position', [100, 100, 1400, 1000], 'Name', ['Enhanced Biomarker Comparison - ', participant]);

    % Define biomarker types and their properties
    biomarkerTypes = {
        'meanDisplacement', 'Mean Displacement (pixels)', 'Traditional';
        'maxDisplacement', 'Max Displacement (pixels)', 'Traditional';
        'flowMagnitude', 'Flow Magnitude', 'Traditional';
        'entropy', 'Entropy', 'Traditional';
        'peakVelocity', 'Peak Velocity (pixels/s)', 'Enhanced';
        'meanVelocity', 'Mean Velocity (pixels/s)', 'Enhanced';
        'velocityVariance', 'Velocity Variance', 'Enhanced';
        'maxAcceleration', 'Max Acceleration (pixels/s²)', 'Enhanced'
        };

    % Create subplots
    numBiomarkers = size(biomarkerTypes, 1);
    numCols = 4;
    numRows = ceil(numBiomarkers / numCols);

    for bioIdx = 1:numBiomarkers
        biomarkerName = biomarkerTypes{bioIdx, 1};
        biomarkerLabel = biomarkerTypes{bioIdx, 2};
        biomarkerCategory = biomarkerTypes{bioIdx, 3};

        subplot(numRows, numCols, bioIdx);

        % Collect data for this biomarker across conditions
        groupData = [];
        groupLabels = {};
        colors = [];

        % Define colors for conditions
        conditionColors = [
            0.2, 0.6, 1.0;    % Blue for neutral
            0.9, 0.6, 0.1;    % Orange for pleasure
            0.2, 0.8, 0.2;    % Green for happiness
            0.8, 0.2, 0.2     % Red for anger
            ];

        hasData = false;
        for condIdx = 1:length(validConditions)
            condName = validConditions{condIdx};

            if isfield(biomarkerData.(condName), biomarkerName) && ~isempty(biomarkerData.(condName).(biomarkerName))
                data = biomarkerData.(condName).(biomarkerName);
                validData = data(isfinite(data) & data > 0);

                if ~isempty(validData)
                    groupData = [groupData; validData(:)];
                    groupLabels = [groupLabels; repmat({condName}, length(validData), 1)];

                    % Use condition-specific color
                    colorIdx = mod(condIdx-1, size(conditionColors, 1)) + 1;
                    colors = [colors; repmat(conditionColors(colorIdx, :), length(validData), 1)];
                    hasData = true;
                end
            end
        end

        if hasData && ~isempty(groupData)
            % Create boxplot
            try
                h = boxplot(groupData, groupLabels, 'Colors', 'k', 'Symbol', '');

                % Overlay individual data points with condition colors
                hold on;
                uniqueLabels = unique(groupLabels);
                for labelIdx = 1:length(uniqueLabels)
                    label = uniqueLabels{labelIdx};
                    labelData = groupData(strcmp(groupLabels, label));

                    if ~isempty(labelData)
                        % Add jitter for visibility
                        x = labelIdx + (rand(length(labelData), 1) - 0.5) * 0.2;
                        colorIdx = find(strcmp(validConditions, label));
                        if ~isempty(colorIdx)
                            colorIdx = mod(colorIdx-1, size(conditionColors, 1)) + 1;
                            scatter(x, labelData, 30, conditionColors(colorIdx, :), 'filled', 'Alpha', 0.6);
                        end
                    end
                end
                hold off;

                % Customize plot
                title([biomarkerLabel, ' (', biomarkerCategory, ')'], 'FontSize', 10, 'FontWeight', 'bold');
                ylabel(biomarkerLabel, 'FontSize', 9);
                xlabel('Condition', 'FontSize', 9);

                % Improve readability
                set(gca, 'FontSize', 8);
                xtickangle(45);
                grid on;

                % Add sample size annotations
                for labelIdx = 1:length(uniqueLabels)
                    label = uniqueLabels{labelIdx};
                    labelData = groupData(strcmp(groupLabels, label));
                    n = length(labelData);

                    % Position annotation
                    yPos = min(labelData) - 0.05 * (max(groupData) - min(groupData));
                    text(labelIdx, yPos, ['n=' num2str(n)], 'HorizontalAlignment', 'center', 'FontSize', 7);
                end

            catch ME
                % Fallback to simple bar plot if boxplot fails
                disp(['Boxplot failed for ', biomarkerName, ': ', ME.message]);

                meanValues = [];
                errorValues = [];
                conditionNames = {};

                for condIdx = 1:length(validConditions)
                    condName = validConditions{condIdx};
                    if isfield(biomarkerData.(condName), biomarkerName) && ~isempty(biomarkerData.(condName).(biomarkerName))
                        data = biomarkerData.(condName).(biomarkerName);
                        validData = data(isfinite(data) & data > 0);

                        if ~isempty(validData)
                            meanValues(end+1) = mean(validData);
                            errorValues(end+1) = std(validData) / sqrt(length(validData)); % SEM
                            conditionNames{end+1} = condName;
                        end
                    end
                end

                if ~isempty(meanValues)
                    b = bar(meanValues);
                    hold on;
                    errorbar(1:length(meanValues), meanValues, errorValues, 'k', 'LineStyle', 'none');
                    hold off;

                    set(gca, 'XTickLabel', conditionNames);
                    title([biomarkerLabel, ' (', biomarkerCategory, ')'], 'FontSize', 10, 'FontWeight', 'bold');
                    ylabel(biomarkerLabel, 'FontSize', 9);
                    xtickangle(45);
                    grid on;
                end
            end
        else
            % No data available
            text(0.5, 0.5, 'No Data Available', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 12);
            set(gca, 'XTick', [], 'YTick', []);
            title([biomarkerLabel, ' (', biomarkerCategory, ')'], 'FontSize', 10, 'FontWeight', 'bold');
        end
    end

    % Add overall title
    sgtitle(['Enhanced Biomarker Comparison - ', participant], 'FontSize', 14, 'FontWeight', 'bold');

    % Save figure
    outputFile = fullfile(outputDir, ['EnhancedBiomarkerComparison_', participant, '.png']);
    saveas(fig, outputFile);
    close(fig);

    disp(['✓ Enhanced biomarker comparison saved: ', outputFile]);

catch ME
    disp(['Enhanced biomarker comparison error: ', ME.message]);
    if exist('fig', 'var')
        close(fig);
    end
end
end

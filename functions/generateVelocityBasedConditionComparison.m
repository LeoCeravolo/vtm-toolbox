function generateVelocityBasedConditionComparison(participantConditionData, participant, conditions, outputDir)
% Generate velocity-focused condition comparison

try
    fig = figure('Position', [100, 100, 1200, 800], 'Name', ['Velocity-Based Condition Analysis - ', participant]);

    % Extract velocity data
    velocityData = struct();
    validConditions = {};

    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        if isfield(participantConditionData, condName)
            validConditions{end+1} = condName;

            % Initialize velocity metrics
            velocityData.(condName).peakVelocities = [];
            velocityData.(condName).meanVelocities = [];
            velocityData.(condName).velocityVariances = [];

            % Extract velocity data (with fallback calculation)
            if isfield(participantConditionData.(condName), 'VelocityMetrics')
                velocityMetrics = participantConditionData.(condName).VelocityMetrics;
                for trialIdx = 1:length(velocityMetrics)
                    if ~isempty(velocityMetrics{trialIdx}) && isstruct(velocityMetrics{trialIdx})
                        vm = velocityMetrics{trialIdx};
                        if isfield(vm, 'peakVelocity') && isfinite(vm.peakVelocity)
                            velocityData.(condName).peakVelocities(end+1) = vm.peakVelocity;
                        end
                        if isfield(vm, 'meanVelocity') && isfinite(vm.meanVelocity)
                            velocityData.(condName).meanVelocities(end+1) = vm.meanVelocity;
                        end
                        if isfield(vm, 'velocityVariance') && isfinite(vm.velocityVariance)
                            velocityData.(condName).velocityVariances(end+1) = vm.velocityVariance;
                        end
                    end
                end
            else
                % Calculate from displacement data as fallback
                if isfield(participantConditionData.(condName), 'StableMeanDisplacement')
                    displacements = participantConditionData.(condName).StableMeanDisplacement;
                    validDisp = displacements(isfinite(displacements) & displacements > 0);

                    if ~isempty(validDisp)
                        frameRate = 25; % Default frame rate
                        velocities = validDisp * frameRate;
                        velocityData.(condName).peakVelocities = max(velocities);
                        velocityData.(condName).meanVelocities = mean(velocities);
                        velocityData.(condName).velocityVariances = var(velocities);
                    end
                end
            end
        end
    end

    % Create velocity comparison subplots
    subplot(2, 2, 1);
    createVelocityBoxplot(velocityData, validConditions, 'peakVelocities', 'Peak Velocity (pixels/s)');

    subplot(2, 2, 2);
    createVelocityBoxplot(velocityData, validConditions, 'meanVelocities', 'Mean Velocity (pixels/s)');

    subplot(2, 2, 3);
    createVelocityBoxplot(velocityData, validConditions, 'velocityVariances', 'Velocity Variance');

    % Velocity profile comparison (subplot 4)
    subplot(2, 2, 4);
    if ~isempty(validConditions)
        createVelocityProfileComparison(velocityData, validConditions);
    end

    sgtitle(['Velocity-Based Condition Comparison - ', participant], 'FontSize', 14, 'FontWeight', 'bold');

    % Save figure
    outputFile = fullfile(outputDir, ['VelocityBasedConditionComparison_', participant, '.png']);
    saveas(fig, outputFile);
    close(fig);

    disp(['✓ Velocity-based condition comparison saved: ', outputFile]);

catch ME
    disp(['Velocity-based condition comparison error: ', ME.message]);
    if exist('fig', 'var')
        close(fig);
    end
end
end

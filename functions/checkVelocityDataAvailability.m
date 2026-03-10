function checkVelocityDataAvailability(participantConditionData, participant, conditions)
    % Debug function to check velocity data availability
    
    disp(['=== VELOCITY DATA AVAILABILITY CHECK: ', participant, ' ===']);
    
    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        if isfield(participantConditionData, condName)
            condData = participantConditionData.(condName);
            
            disp(['Condition: ', condName]);
            
            % Check PeakVelocities
            if isfield(condData, 'PeakVelocities')
                validPeak = condData.PeakVelocities(isfinite(condData.PeakVelocities));
                disp(['  PeakVelocities: ', num2str(length(validPeak)), ' valid values, range: [', num2str(min(validPeak)), '-', num2str(max(validPeak)), ']']);
            else
                disp('  PeakVelocities: NOT FOUND');
            end
            
            % Check MeanVelocities
            if isfield(condData, 'MeanVelocities')
                validMean = condData.MeanVelocities(isfinite(condData.MeanVelocities));
                disp(['  MeanVelocities: ', num2str(length(validMean)), ' valid values, range: [', num2str(min(validMean)), '-', num2str(max(validMean)), ']']);
            else
                disp('  MeanVelocities: NOT FOUND');
            end
            
            % Check VelocityMetrics
            if isfield(condData, 'VelocityMetrics')
                disp(['  VelocityMetrics: ', num2str(length(condData.VelocityMetrics)), ' trial structures']);
                
                % Check first trial structure
                if ~isempty(condData.VelocityMetrics) && isstruct(condData.VelocityMetrics{1})
                    vm = condData.VelocityMetrics{1};
                    fields = fieldnames(vm);
                    disp(['    First trial fields: ', strjoin(fields, ', ')]);
                end
            else
                disp('  VelocityMetrics: NOT FOUND');
            end
            
            disp(' ');
        end
    end
end

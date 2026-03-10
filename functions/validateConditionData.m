function validateConditionData(participantConditionData, participant, conditions)
% Validate that condition data has been properly aggregated

try
    disp(['=== VALIDATING CONDITION DATA FOR: ', participant, ' ===']);
    
    % Check if participantConditionData exists and is a structure
    if ~isstruct(participantConditionData)
        disp(['❌ participantConditionData is not a structure for: ', participant]);
        return;
    end
    
    % Validate each condition
    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        
        disp(['--- Validating condition: ', condName, ' ---']);
        
        if ~isfield(participantConditionData, condName)
            disp(['⚠ Missing condition field: ', condName]);
            continue;
        end
        
        condData = participantConditionData.(condName);
        
        if ~isstruct(condData)
            disp(['❌ Condition data is not a structure: ', condName]);
            continue;
        end
        
        % Check for required fields and validate their content
        requiredFields = {'trials', 'StableMeanDisplacement', 'StableMaxDisplacement', ...
                         'PeakVelocities', 'MeanVelocities', 'ROIFlowMagnitude', 'Entropy'};
        
        fieldStatus = struct();
        
        for fieldIdx = 1:length(requiredFields)
            fieldName = requiredFields{fieldIdx};
            
            if isfield(condData, fieldName)
                fieldValue = condData.(fieldName);
                
                if strcmp(fieldName, 'trials')
                    % Trials should be a cell array
                    if iscell(fieldValue)
                        fieldStatus.(fieldName) = ['✓ (', num2str(length(fieldValue)), ' trials)'];
                    else
                        fieldStatus.(fieldName) = '⚠ (not cell array)';
                    end
                else
                    % Other fields should be numeric arrays
                    if isnumeric(fieldValue)
                        validValues = fieldValue(isfinite(fieldValue) & fieldValue > 0);
                        if ~isempty(validValues)
                            fieldStatus.(fieldName) = ['✓ (', num2str(length(validValues)), ' values)'];
                        else
                            fieldStatus.(fieldName) = '⚠ (no valid values)';
                        end
                    else
                        fieldStatus.(fieldName) = '⚠ (not numeric)';
                    end
                end
            else
                fieldStatus.(fieldName) = '❌ (missing)';
            end
        end
        
        % Display field status
        fieldNames = fieldnames(fieldStatus);
        for fieldIdx = 1:length(fieldNames)
            fieldName = fieldNames{fieldIdx};
            status = fieldStatus.(fieldName);
            disp(['  ', fieldName, ': ', status]);
        end
        
        % Check for ML-specific fields
                hasMLData = false;
        
        for mlFieldIdx = 1:length(mlFields)
            mlFieldName = mlFields{mlFieldIdx};
            if isfield(condData, mlFieldName)
                mlFieldValue = condData.(mlFieldName);
                if isnumeric(mlFieldValue) && ~isempty(mlFieldValue)
                    validMLValues = mlFieldValue(isfinite(mlFieldValue));
                    if ~isempty(validMLValues)
                        hasMLData = true;
                        disp(['  ', mlFieldName, ': ✓ (', num2str(length(validMLValues)), ' values)']);
                    end
                end
            end
        end
        
        if hasMLData
            disp(['  ML Data Status: ✅ Available']);
        else
            disp(['  ML Data Status: ⚠ Limited or missing']);
        end
        
        % Check for anatomical movement data
        if isfield(condData, 'AnatomicalMovement') && isstruct(condData.AnatomicalMovement)
            anatFields = fieldnames(condData.AnatomicalMovement);
            if ~isempty(anatFields)
                anatCount = 0;
                for anatIdx = 1:length(anatFields)
                    anatData = condData.AnatomicalMovement.(anatFields{anatIdx});
                    if isnumeric(anatData) && ~isempty(anatData)
                        validAnatData = anatData(isfinite(anatData) & anatData > 0);
                        if ~isempty(validAnatData)
                            anatCount = anatCount + 1;
                        end
                    end
                end
                disp(['  Anatomical regions: ✓ (', num2str(anatCount), '/', num2str(length(anatFields)), ' regions with data)']);
            else
                disp(['  Anatomical regions: ⚠ (no regions defined)']);
            end
        else
            disp(['  Anatomical regions: ❌ (missing structure)']);
        end
        
        % Overall condition validation summary
        if isfield(condData, 'trials') && iscell(condData.trials) && length(condData.trials) > 0
            disp(['  📊 CONDITION SUMMARY: ', num2str(length(condData.trials)), ' trials aggregated']);
            
            % Check data consistency
            expectedTrials = length(condData.trials);
            actualDataPoints = 0;
            
            if isfield(condData, 'StableMeanDisplacement') && isnumeric(condData.StableMeanDisplacement)
                actualDataPoints = length(condData.StableMeanDisplacement(isfinite(condData.StableMeanDisplacement)));
            end
            
            if actualDataPoints == expectedTrials
                disp(['  🎯 Data consistency: ✅ Perfect match']);
            elseif actualDataPoints > 0
                disp(['  🎯 Data consistency: ⚠ Partial (', num2str(actualDataPoints), '/', num2str(expectedTrials), ')']);
            else
                disp(['  🎯 Data consistency: ❌ No valid data']);
            end
        else
            disp(['  📊 CONDITION SUMMARY: ❌ No trials found']);
        end
        
        disp(['----------------------------------------']);
    end
    
    % Overall participant validation summary
    totalConditions = length(conditions);
    validConditions = 0;
    
    for condIdx = 1:length(conditions)
        condName = conditions{condIdx};
        if isfield(participantConditionData, condName) && ...
           isfield(participantConditionData.(condName), 'trials') && ...
           iscell(participantConditionData.(condName).trials) && ...
           length(participantConditionData.(condName).trials) > 0
            validConditions = validConditions + 1;
        end
    end
    
    disp(['=== PARTICIPANT VALIDATION SUMMARY ===']);
    disp(['Participant: ', participant]);
    disp(['Valid conditions: ', num2str(validConditions), '/', num2str(totalConditions)]);
    
    if validConditions == totalConditions
        disp(['✅ EXCELLENT: All conditions have data']);
    elseif validConditions >= totalConditions/2
        disp(['✓ GOOD: Most conditions have data']);
    elseif validConditions > 0
        disp(['⚠ PARTIAL: Some conditions have data']);
    else
        disp(['❌ POOR: No conditions have valid data']);
    end
    
    disp(['=====================================']);
    
catch ME
    disp(['Validation error for ', participant, ': ', ME.message]);
end
end
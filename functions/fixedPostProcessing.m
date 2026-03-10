function [participantConditionData] = fixedPostProcessing(data, run, conditionName, participantConditionData, groupData)
% Fixed post-processing with enhanced bounds checking and error handling

try
    % Flow summaries with bounds checking
    if isfield(data.(run).(conditionName), 'ROIFlowMagnitude') && ~isempty(data.(run).(conditionName).ROIFlowMagnitude)
        flowMag = data.(run).(conditionName).ROIFlowMagnitude;
        
        % Remove any invalid values
        flowMag = flowMag(isfinite(flowMag));
        
        if ~isempty(flowMag)
            data.(run).(conditionName).FlowSummary.meanMagnitude = mean(flowMag);
            data.(run).(conditionName).FlowSummary.maxMagnitude = max(flowMag);
            data.(run).(conditionName).FlowSummary.stdMagnitude = std(flowMag);
            data.(run).(conditionName).FlowSummary.totalMotion = sum(flowMag);
        else
            data.(run).(conditionName).FlowSummary.meanMagnitude = NaN;
            data.(run).(conditionName).FlowSummary.maxMagnitude = NaN;
            data.(run).(conditionName).FlowSummary.stdMagnitude = NaN;
            data.(run).(conditionName).FlowSummary.totalMotion = NaN;
        end
        
        % Handle flow components safely
        if isfield(data.(run).(conditionName), 'FlowVx') && ~isempty(data.(run).(conditionName).FlowVx)
            flowVx = data.(run).(conditionName).FlowVx;
            flowVx = flowVx(isfinite(flowVx));
            if ~isempty(flowVx)
                data.(run).(conditionName).FlowSummary.meanHorizontal = mean(flowVx);
            else
                data.(run).(conditionName).FlowSummary.meanHorizontal = NaN;
            end
        else
            data.(run).(conditionName).FlowSummary.meanHorizontal = NaN;
        end
        
        if isfield(data.(run).(conditionName), 'FlowVy') && ~isempty(data.(run).(conditionName).FlowVy)
            flowVy = data.(run).(conditionName).FlowVy;
            flowVy = flowVy(isfinite(flowVy));
            if ~isempty(flowVy)
                data.(run).(conditionName).FlowSummary.meanVertical = mean(flowVy);
            else
                data.(run).(conditionName).FlowSummary.meanVertical = NaN;
            end
        else
            data.(run).(conditionName).FlowSummary.meanVertical = NaN;
        end
        
        if isfield(data.(run).(conditionName), 'ROIFlowDirection') && ~isempty(data.(run).(conditionName).ROIFlowDirection)
            flowDir = data.(run).(conditionName).ROIFlowDirection;
            flowDir = flowDir(isfinite(flowDir));
            if ~isempty(flowDir)
                data.(run).(conditionName).FlowSummary.predominantDirection = mean(flowDir);
            else
                data.(run).(conditionName).FlowSummary.predominantDirection = NaN;
            end
        else
            data.(run).(conditionName).FlowSummary.predominantDirection = NaN;
        end
    end

    % Entropy summaries with bounds checking
    if isfield(data.(run).(conditionName), 'Entropy') && ~isempty(data.(run).(conditionName).Entropy)
        entropyData = data.(run).(conditionName).Entropy;
        entropyData = entropyData(isfinite(entropyData));
        
        if ~isempty(entropyData)
            data.(run).(conditionName).EntropyAvg = mean(entropyData);
            data.(run).(conditionName).EntropyVar = var(entropyData);
            data.(run).(conditionName).EntropyMax = max(entropyData);
        else
            data.(run).(conditionName).EntropyAvg = NaN;
            data.(run).(conditionName).EntropyVar = NaN;
            data.(run).(conditionName).EntropyMax = NaN;
        end
    end

    % ENHANCED CONDITION-LEVEL AGGREGATION with bounds checking
    conditionType = determineConditionType(conditionName);
    if ~isempty(conditionType)
        % Initialize condition data if it doesn't exist
        if ~isfield(participantConditionData, conditionType)
            participantConditionData.(conditionType) = struct();
            participantConditionData.(conditionType).trials = {};
            participantConditionData.(conditionType).StableMeanDisplacement = [];
            participantConditionData.(conditionType).StableMaxDisplacement = [];
            participantConditionData.(conditionType).StablePointCount = [];
            participantConditionData.(conditionType).PointCount = [];
            participantConditionData.(conditionType).ROIFlowMagnitude = [];
            participantConditionData.(conditionType).Entropy = [];
            participantConditionData.(conditionType).FlowSummary = struct();
        end
        
        participantConditionData.(conditionType).trials{end+1} = conditionName;

        % FIXED: Enhanced aggregation with comprehensive bounds checking
        if isfield(data.(run).(conditionName), 'StableMeanDisplacement') && ~isempty(data.(run).(conditionName).StableMeanDisplacement)
            meanDispData = data.(run).(conditionName).StableMeanDisplacement;
            
            % Remove NaN and infinite values, keep only positive values
            validDisp = meanDispData(isfinite(meanDispData) & meanDispData > 0);
            
            if ~isempty(validDisp) && length(validDisp) > 0
                participantConditionData.(conditionType).StableMeanDisplacement = ...
                    [participantConditionData.(conditionType).StableMeanDisplacement; mean(validDisp)];
                disp(['Added mean displacement for ', conditionType, ': ', num2str(mean(validDisp))]);
            else
                disp(['No valid displacement data for ', conditionType]);
            end
        end

        if isfield(data.(run).(conditionName), 'StableMaxDisplacement') && ~isempty(data.(run).(conditionName).StableMaxDisplacement)
            maxDispData = data.(run).(conditionName).StableMaxDisplacement;
            validMaxDisp = maxDispData(isfinite(maxDispData) & maxDispData > 0);
            
            if ~isempty(validMaxDisp) && length(validMaxDisp) > 0
                participantConditionData.(conditionType).StableMaxDisplacement = ...
                    [participantConditionData.(conditionType).StableMaxDisplacement; mean(validMaxDisp)];
            end
        end

        if isfield(data.(run).(conditionName), 'StablePointCount') && ~isempty(data.(run).(conditionName).StablePointCount)
            pointCountData = data.(run).(conditionName).StablePointCount;
            
            % FIXED: Enhanced bounds checking for point count
            if isnumeric(pointCountData) && ~isempty(pointCountData)
                % Remove NaN values and keep only non-negative values
                validPtCount = pointCountData(isfinite(pointCountData) & pointCountData >= 0);
                
                if ~isempty(validPtCount) && length(validPtCount) > 0
                    participantConditionData.(conditionType).StablePointCount = ...
                        [participantConditionData.(conditionType).StablePointCount; mean(validPtCount)];
                end
            end
        end

        if isfield(data.(run).(conditionName), 'PointCount') && ~isempty(data.(run).(conditionName).PointCount)
            totalPointData = data.(run).(conditionName).PointCount;
            
            if isnumeric(totalPointData) && ~isempty(totalPointData)
                validCount = totalPointData(isfinite(totalPointData) & totalPointData > 0);
                
                if ~isempty(validCount) && length(validCount) > 0
                    participantConditionData.(conditionType).PointCount = ...
                        [participantConditionData.(conditionType).PointCount; mean(validCount)];
                end
            end
        end

        if isfield(data.(run).(conditionName), 'ROIFlowMagnitude') && ~isempty(data.(run).(conditionName).ROIFlowMagnitude)
            flowData = data.(run).(conditionName).ROIFlowMagnitude;
            
            if isnumeric(flowData) && ~isempty(flowData)
                validFlow = flowData(isfinite(flowData) & flowData >= 0);
                
                if ~isempty(validFlow) && length(validFlow) > 0
                    participantConditionData.(conditionType).ROIFlowMagnitude = ...
                        [participantConditionData.(conditionType).ROIFlowMagnitude; mean(validFlow)];
                end
            end
        end

        if isfield(data.(run).(conditionName), 'Entropy') && ~isempty(data.(run).(conditionName).Entropy)
            entropyData = data.(run).(conditionName).Entropy;
            
            if isnumeric(entropyData) && ~isempty(entropyData)
                validEntropy = entropyData(isfinite(entropyData) & entropyData >= 0);
                
                if ~isempty(validEntropy) && length(validEntropy) > 0
                    participantConditionData.(conditionType).Entropy = ...
                        [participantConditionData.(conditionType).Entropy; mean(validEntropy)];
                end
            end
        end

        % FIXED: Enhanced flow summary aggregation with bounds checking
        if isfield(data.(run).(conditionName), 'FlowSummary') && ~isempty(data.(run).(conditionName).FlowSummary)
            if ~isfield(participantConditionData.(conditionType).FlowSummary, 'meanMagnitude')
                participantConditionData.(conditionType).FlowSummary.meanMagnitude = [];
                participantConditionData.(conditionType).FlowSummary.maxMagnitude = [];
                participantConditionData.(conditionType).FlowSummary.stdMagnitude = [];
                participantConditionData.(conditionType).FlowSummary.totalMotion = [];
            end

            flowSummary = data.(run).(conditionName).FlowSummary;
            
            % Add each field if it exists and is valid
            if isfield(flowSummary, 'meanMagnitude') && isfinite(flowSummary.meanMagnitude)
                participantConditionData.(conditionType).FlowSummary.meanMagnitude = ...
                    [participantConditionData.(conditionType).FlowSummary.meanMagnitude; flowSummary.meanMagnitude];
            end
            
            if isfield(flowSummary, 'maxMagnitude') && isfinite(flowSummary.maxMagnitude)
                participantConditionData.(conditionType).FlowSummary.maxMagnitude = ...
                    [participantConditionData.(conditionType).FlowSummary.maxMagnitude; flowSummary.maxMagnitude];
            end
            
            if isfield(flowSummary, 'stdMagnitude') && isfinite(flowSummary.stdMagnitude)
                participantConditionData.(conditionType).FlowSummary.stdMagnitude = ...
                    [participantConditionData.(conditionType).FlowSummary.stdMagnitude; flowSummary.stdMagnitude];
            end
            
            if isfield(flowSummary, 'totalMotion') && isfinite(flowSummary.totalMotion)
                participantConditionData.(conditionType).FlowSummary.totalMotion = ...
                    [participantConditionData.(conditionType).FlowSummary.totalMotion; flowSummary.totalMotion];
            end
        end
    end

catch ME
    disp(['FIXED Post-processing error handled: ', ME.message]);
    disp(['Error occurred in condition: ', conditionName]);
    disp(['Stack trace: ']);
    for i = 1:length(ME.stack)
        disp(['  ', ME.stack(i).file, ' line ', num2str(ME.stack(i).line), ': ', ME.stack(i).name]);
    end
    
    % Return the participantConditionData even if there was an error
    % This prevents the analysis from completely failing
end

disp(['Post-processing completed for: ', conditionName]);
end
function generateConditionSummaryStats(participantConditionData, participant, conditions, outputDir)
    % Generate comprehensive condition summary statistics
    
    try
        % Create summary table
        summaryStats = table();
        
        for condIdx = 1:length(conditions)
            condName = conditions{condIdx};
            
            if isfield(participantConditionData, condName)
                condData = participantConditionData.(condName);
                
                % Initialize row data
                rowData = struct();
                rowData.Condition = {condName};
                rowData.NumTrials = {length(condData.trials)};
                
                % Traditional metrics
                if isfield(condData, 'StableMeanDisplacement') && ~isempty(condData.StableMeanDisplacement)
                    validDisp = condData.StableMeanDisplacement(isfinite(condData.StableMeanDisplacement));
                    rowData.MeanDisplacement_Mean = {mean(validDisp)};
                    rowData.MeanDisplacement_Std = {std(validDisp)};
                else
                    rowData.MeanDisplacement_Mean = {NaN};
                    rowData.MeanDisplacement_Std = {NaN};
                end
                
                if isfield(condData, 'ROIFlowMagnitude') && ~isempty(condData.ROIFlowMagnitude)
                    validFlow = condData.ROIFlowMagnitude(isfinite(condData.ROIFlowMagnitude));
                    rowData.FlowMagnitude_Mean = {mean(validFlow)};
                    rowData.FlowMagnitude_Std = {std(validFlow)};
                else
                    rowData.FlowMagnitude_Mean = {NaN};
                    rowData.FlowMagnitude_Std = {NaN};
                end
                
                % Velocity metrics (enhanced)
                if isfield(condData, 'VelocityMetrics') && ~isempty(condData.VelocityMetrics)
                    allPeakVel = [];
                    allMeanVel = [];
                    
                    for trialIdx = 1:length(condData.VelocityMetrics)
                        vm = condData.VelocityMetrics{trialIdx};
                        if ~isempty(vm) && isstruct(vm)
                            if isfield(vm, 'peakVelocity') && isfinite(vm.peakVelocity)
                                allPeakVel(end+1) = vm.peakVelocity;
                            end
                            if isfield(vm, 'meanVelocity') && isfinite(vm.meanVelocity)
                                allMeanVel(end+1) = vm.meanVelocity;
                            end
                        end
                    end
                    
                    if ~isempty(allPeakVel)
                        rowData.PeakVelocity_Mean = {mean(allPeakVel)};
                        rowData.PeakVelocity_Std = {std(allPeakVel)};
                    else
                        rowData.PeakVelocity_Mean = {NaN};
                        rowData.PeakVelocity_Std = {NaN};
                    end
                    
                    if ~isempty(allMeanVel)
                        rowData.MeanVelocity_Mean = {mean(allMeanVel)};
                        rowData.MeanVelocity_Std = {std(allMeanVel)};
                    else
                        rowData.MeanVelocity_Mean = {NaN};
                        rowData.MeanVelocity_Std = {NaN};
                    end
                else
                    rowData.PeakVelocity_Mean = {NaN};
                    rowData.PeakVelocity_Std = {NaN};
                    rowData.MeanVelocity_Mean = {NaN};
                    rowData.MeanVelocity_Std = {NaN};
                end
                
                % Mimicry metrics
                if isfield(condData, 'MimicryResponse') && ~isempty(condData.MimicryResponse)
                    validMimicry = condData.MimicryResponse(isfinite(condData.MimicryResponse));
                    rowData.MimicryResponse_Mean = {mean(validMimicry)};
                    rowData.MimicryResponse_Std = {std(validMimicry)};
                else
                    rowData.MimicryResponse_Mean = {NaN};
                    rowData.MimicryResponse_Std = {NaN};
                end
                
                % Convert struct to table row
                if isempty(summaryStats)
                    summaryStats = struct2table(rowData);
                else
                    newRow = struct2table(rowData);
                    summaryStats = [summaryStats; newRow];
                end
            end
        end
        
        % Save summary table
        summaryFile = fullfile(outputDir, ['ConditionSummaryStats_', participant, '.csv']);
        writetable(summaryStats, summaryFile);
        
        disp(['✓ Condition summary statistics saved: ', summaryFile]);
        
    catch ME
        disp(['Condition summary statistics error: ', ME.message]);
    end
end
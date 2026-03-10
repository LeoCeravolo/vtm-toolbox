function generateVocalTractBiomarkerComparison(participantConditionData, participant, conditions, outputDir)
    % Generate biomarker comparison focusing on vocal tract function
    
    try
        fig = figure('Position', [100, 100, 1600, 1200], 'Name', ['Vocal Tract Biomarker Analysis - ', participant]);
        
        % Define vocal tract-specific biomarkers
        biomarkerTypes = {
            'meanDisplacement', 'Mean Displacement (pixels)', 'Traditional';
            'maxDisplacement', 'Max Displacement (pixels)', 'Traditional';
            'flowMagnitude', 'Flow Magnitude', 'Traditional';
            'peakVelocity', 'Peak Velocity (pixels/s)', 'Enhanced';
            'pharyngealActivity', 'Pharyngeal Movement', 'Functional';
            'laryngealActivity', 'Laryngeal Movement', 'Functional';
            'vocalFoldActivity', 'Vocal Fold Movement', 'Functional';
            'epiglottalActivity', 'Epiglottal Movement', 'Functional'
        };
        
        validConditions = {};
        biomarkerData = struct();
        
        % Extract data for each condition
        for condIdx = 1:length(conditions)
            condName = conditions{condIdx};
            if isfield(participantConditionData, condName)
                validConditions{end+1} = condName;
                biomarkerData.(condName) = struct();
                
                % Traditional biomarkers
                if isfield(participantConditionData.(condName), 'StableMeanDisplacement')
                    biomarkerData.(condName).meanDisplacement = participantConditionData.(condName).StableMeanDisplacement(isfinite(participantConditionData.(condName).StableMeanDisplacement));
                end
                
                if isfield(participantConditionData.(condName), 'StableMaxDisplacement')
                    biomarkerData.(condName).maxDisplacement = participantConditionData.(condName).StableMaxDisplacement(isfinite(participantConditionData.(condName).StableMaxDisplacement));
                end
                
                if isfield(participantConditionData.(condName), 'ROIFlowMagnitude')
                    biomarkerData.(condName).flowMagnitude = participantConditionData.(condName).ROIFlowMagnitude(isfinite(participantConditionData.(condName).ROIFlowMagnitude));
                end
                
                % Velocity biomarkers
                if isfield(participantConditionData.(condName), 'PeakVelocities')
                    biomarkerData.(condName).peakVelocity = participantConditionData.(condName).PeakVelocities(isfinite(participantConditionData.(condName).PeakVelocities));
                end
                
                % Functional anatomical biomarkers
                if isfield(participantConditionData.(condName), 'AnatomicalMovement')
                    anatData = participantConditionData.(condName).AnatomicalMovement;
                    
                    if isfield(anatData, 'pharynx')
                        biomarkerData.(condName).pharyngealActivity = anatData.pharynx(isfinite(anatData.pharynx) & anatData.pharynx > 0);
                    end
                    
                    if isfield(anatData, 'larynx')
                        biomarkerData.(condName).laryngealActivity = anatData.larynx(isfinite(anatData.larynx) & anatData.larynx > 0);
                    end
                    
                    if isfield(anatData, 'vocal_folds')
                        biomarkerData.(condName).vocalFoldActivity = anatData.vocal_folds(isfinite(anatData.vocal_folds) & anatData.vocal_folds > 0);
                    end
                    
                    if isfield(anatData, 'epiglottis')
                        biomarkerData.(condName).epiglottalActivity = anatData.epiglottis(isfinite(anatData.epiglottis) & anatData.epiglottis > 0);
                    end
                end
            end
        end
        
        % Create subplots for each biomarker
        numBiomarkers = size(biomarkerTypes, 1);
        numCols = 4;
        numRows = ceil(numBiomarkers / numCols);
        
        conditionColors = [
            0.2, 0.6, 1.0;    % Blue for neutral
            0.9, 0.6, 0.1;    % Orange for pleasure
            0.2, 0.8, 0.2;    % Green for happiness
            0.8, 0.2, 0.2     % Red for anger
        ];
        
        for bioIdx = 1:numBiomarkers
            biomarkerName = biomarkerTypes{bioIdx, 1};
            biomarkerLabel = biomarkerTypes{bioIdx, 2};
            biomarkerCategory = biomarkerTypes{bioIdx, 3};
            
            subplot(numRows, numCols, bioIdx);
            
            % Collect data across conditions
            groupData = [];
            groupLabels = {};
            hasData = false;
            
            for condIdx = 1:length(validConditions)
                condName = validConditions{condIdx};
                
                if isfield(biomarkerData.(condName), biomarkerName) && ~isempty(biomarkerData.(condName).(biomarkerName))
                    data = biomarkerData.(condName).(biomarkerName);
                    if ~isempty(data)
                        groupData = [groupData; data(:)];
                        groupLabels = [groupLabels; repmat({condName}, length(data), 1)];
                        hasData = true;
                    end
                end
            end
            
            if hasData && ~isempty(groupData)
                % Create boxplot
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
                
                title([biomarkerLabel, ' (', biomarkerCategory, ')'], 'FontSize', 10, 'FontWeight', 'bold');
                ylabel(biomarkerLabel, 'FontSize', 9);
                xlabel('Condition', 'FontSize', 9);
                xtickangle(45);
                grid on;
            else
                text(0.5, 0.5, 'No Data Available', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
                title([biomarkerLabel, ' (', biomarkerCategory, ')'], 'FontSize', 10, 'FontWeight', 'bold');
            end
        end
        
        sgtitle(['Vocal Tract Functional Biomarker Analysis - ', participant], 'FontSize', 14, 'FontWeight', 'bold');
        
        % Save figure
        outputFile = fullfile(outputDir, ['VocalTractBiomarkerAnalysis_', participant, '.png']);
        saveas(fig, outputFile);
        close(fig);
        
        disp(['✓ Vocal tract biomarker analysis saved: ', outputFile]);
        
    catch ME
        disp(['Vocal tract biomarker analysis error: ', ME.message]);
        if exist('fig', 'var')
            close(fig);
        end
    end
end

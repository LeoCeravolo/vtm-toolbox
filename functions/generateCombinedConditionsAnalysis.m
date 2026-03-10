function generateCombinedConditionsAnalysis(groupData, outputDir)
    % Generate a combined analysis comparing all conditions at group level
    
    conditions = groupData.conditions;
    participants = groupData.participants;
    
    % Create figure comparing all conditions
    figure('Visible', 'off', 'Position', [100, 100, 2000, 1600]);
    
    colors = lines(length(conditions));
    
    % Panel 1: Group Mean Displacement Time Series by Condition
    subplot(4,3,1);
    legendEntries = {};
    for condIdx = 1:length(conditions)
        conditionName = conditions{condIdx};
        
        % Collect all participant means for this condition
        participantMeans = [];
        for p = 1:length(participants)
            participant = participants{p};
            participantData = groupData.participantData.(participant);
            
            if isfield(participantData, conditionName) && ~isempty(participantData.(conditionName).StableMeanDisplacement)
                participantMeans(end+1) = mean(participantData.(conditionName).StableMeanDisplacement);
            end
        end
        
        if ~isempty(participantMeans)
            % Create time series representation
            timePoints = 1:length(participantMeans);
            plot(timePoints, participantMeans, 'o-', 'Color', colors(condIdx,:), 'LineWidth', 2, 'MarkerSize', 8);
            hold on;
            legendEntries{end+1} = [conditionName, ' (N=', num2str(length(participantMeans)), ')'];
        end
    end
    
    if ~isempty(legendEntries)
        title('Mean Displacement by Condition (Individual Participants)');
        xlabel('Participant Index');
        ylabel('Mean Displacement (pixels)');
        legend(legendEntries, 'Location', 'best');
        grid on;
    end
    
    % Panel 2: Smoothed Group Comparison
    subplot(4,3,2);
    for condIdx = 1:length(conditions)
        conditionName = conditions{condIdx};
        
        participantMeans = [];
        for p = 1:length(participants)
            participant = participants{p};
            participantData = groupData.participantData.(participant);
            
            if isfield(participantData, conditionName) && ~isempty(participantData.(conditionName).StableMeanDisplacement)
                participantMeans(end+1) = mean(participantData.(conditionName).StableMeanDisplacement);
            end
        end
        
        if length(participantMeans) >= 3
            % Apply smoothing
            smoothedMeans = smooth(participantMeans, min(3, length(participantMeans)));
            timePoints = 1:length(smoothedMeans);
            plot(timePoints, smoothedMeans, '-', 'Color', colors(condIdx,:), 'LineWidth', 3);
            hold on;
        end
    end
    
    title('Smoothed Mean Displacement by Condition');
    xlabel('Participant Index');
    ylabel('Smoothed Displacement (pixels)');
    legend(conditions, 'Location', 'best');
    grid on;
    
    % Panel 3: Distribution Comparison
    subplot(4,3,3);
    allConditionData = [];
    conditionLabels = [];
    
    for condIdx = 1:length(conditions)
        conditionName = conditions{condIdx};
        
        participantMeans = [];
        for p = 1:length(participants)
            participant = participants{p};
            participantData = groupData.participantData.(participant);
            
            if isfield(participantData, conditionName) && ~isempty(participantData.(conditionName).StableMeanDisplacement)
                participantMeans(end+1) = mean(participantData.(conditionName).StableMeanDisplacement);
            end
        end
        
        if ~isempty(participantMeans)
            allConditionData = [allConditionData; participantMeans'];
            conditionLabels = [conditionLabels; repmat({conditionName}, length(participantMeans), 1)];
        end
    end
    
    if ~isempty(allConditionData)
        boxplot(allConditionData, conditionLabels);
        title('Displacement Distribution by Condition');
        ylabel('Mean Displacement (pixels)');
        grid on;
    end
    
    % Panel 4: Flow Magnitude Comparison
    subplot(4,3,4);
    for condIdx = 1:length(conditions)
        conditionName = conditions{condIdx};
        
        participantFlowMeans = [];
        for p = 1:length(participants)
            participant = participants{p};
            participantData = groupData.participantData.(participant);
            
            if isfield(participantData, conditionName) && ~isempty(participantData.(conditionName).ROIFlowMagnitude)
                participantFlowMeans(end+1) = mean(participantData.(conditionName).ROIFlowMagnitude);
            end
        end
        
        if ~isempty(participantFlowMeans)
            timePoints = 1:length(participantFlowMeans);
            plot(timePoints, participantFlowMeans, 's-', 'Color', colors(condIdx,:), 'LineWidth', 2, 'MarkerSize', 6);
            hold on;
        end
    end
    
    title('Flow Magnitude by Condition');
    xlabel('Participant Index');
    ylabel('Flow Magnitude');
    legend(conditions, 'Location', 'best');
    grid on;
    
    % Panel 5: Point Count Stability
    subplot(4,3,5);
    for condIdx = 1:length(conditions)
        conditionName = conditions{condIdx};
        
        participantPointMeans = [];
        for p = 1:length(participants)
            participant = participants{p};
            participantData = groupData.participantData.(participant);
            
            if isfield(participantData, conditionName) && ~isempty(participantData.(conditionName).StablePointCount)
                participantPointMeans(end+1) = mean(participantData.(conditionName).StablePointCount);
            end
        end
        
        if ~isempty(participantPointMeans)
            timePoints = 1:length(participantPointMeans);
            plot(timePoints, participantPointMeans, '^-', 'Color', colors(condIdx,:), 'LineWidth', 2, 'MarkerSize', 6);
            hold on;
        end
    end
    
    title('Stable Point Count by Condition');
    xlabel('Participant Index');
    ylabel('Stable Point Count');
    legend(conditions, 'Location', 'best');
    grid on;
    
    % Panel 6: Condition Variance Analysis
    subplot(4,3,6);
    conditionVariances = [];
    conditionNames = {};
    
    for condIdx = 1:length(conditions)
        conditionName = conditions{condIdx};
        
        participantMeans = [];
        for p = 1:length(participants)
            participant = participants{p};
            participantData = groupData.participantData.(participant);
            
            if isfield(participantData, conditionName) && ~isempty(participantData.(conditionName).StableMeanDisplacement)
                participantMeans(end+1) = mean(participantData.(conditionName).StableMeanDisplacement);
            end
        end
        
        if length(participantMeans) >= 3
            conditionVariances(end+1) = var(participantMeans);
            conditionNames{end+1} = conditionName;
        end
    end
    
    if ~isempty(conditionVariances)
        bar(conditionVariances, 'FaceColor', [0.6 0.6 0.9]);
        set(gca, 'XTickLabel', conditionNames);
        title('Between-Participant Variance by Condition');
        ylabel('Variance');
        grid on;
    end
    
    % Panel 7: Cross-Condition Correlation
    subplot(4,3,7);
    if length(conditions) >= 2
        % Create correlation matrix between conditions
        correlationMatrix = [];
        validConditions = {};
        
        % Build data matrix
        dataMatrix = [];
        for condIdx = 1:length(conditions)
            conditionName = conditions{condIdx};
            
            participantMeans = [];
            for p = 1:length(participants)
                participant = participants{p};
                participantData = groupData.participantData.(participant);
                
                if isfield(participantData, conditionName) && ~isempty(participantData.(conditionName).StableMeanDisplacement)
                    participantMeans(end+1) = mean(participantData.(conditionName).StableMeanDisplacement);
                end
            end
            
            if length(participantMeans) >= 3
                if isempty(dataMatrix)
                    dataMatrix = participantMeans';
                else
                    % Ensure same length
                    minLen = min(length(participantMeans), size(dataMatrix, 1));
                    dataMatrix = [dataMatrix(1:minLen, :), participantMeans(1:minLen)'];
                end
                validConditions{end+1} = conditionName;
            end
        end
        
        if size(dataMatrix, 2) >= 2
            correlationMatrix = corrcoef(dataMatrix);
            imagesc(correlationMatrix, [-1 1]);
            colormap('RdBu'); colorbar;
            set(gca, 'XTickLabel', validConditions);
            set(gca, 'YTickLabel', validConditions);
            title('Inter-Condition Correlations');
            
            % Add correlation values
            for i = 1:size(correlationMatrix, 1)
                for j = 1:size(correlationMatrix, 2)
                    text(j, i, sprintf('%.2f', correlationMatrix(i,j)), ...
                        'HorizontalAlignment', 'center', 'Color', 'white', 'FontWeight', 'bold');
                end
            end
        end
    end
    
    % Panel 8: Statistical Summary
    subplot(4,3,8);
    axis off;
    
    text(0.05, 0.95, summaryText, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
        'FontSize', 10, 'FontName', 'Courier');
    
    % Panel 9: Effect Size Comparison
    subplot(4,3,9);
    if length(conditions) >= 2
        % Calculate effect sizes between first condition and others
        refCondition = conditions{1};
        refData = [];
        
        for p = 1:length(participants)
            participant = participants{p};
            participantData = groupData.participantData.(participant);
            
            if isfield(participantData, refCondition) && ~isempty(participantData.(refCondition).StableMeanDisplacement)
                refData(end+1) = mean(participantData.(refCondition).StableMeanDisplacement);
            end
        end
        
        effectSizes = [];
        comparisonLabels = {};
        
        for condIdx = 2:length(conditions)
            conditionName = conditions{condIdx};
            
            condData = [];
            for p = 1:length(participants)
                participant = participants{p};
                participantData = groupData.participantData.(participant);
                
                if isfield(participantData, conditionName) && ~isempty(participantData.(conditionName).StableMeanDisplacement)
                    condData(end+1) = mean(participantData.(conditionName).StableMeanDisplacement);
                end
            end
            
            if ~isempty(refData) && ~isempty(condData) && length(refData) >= 2 && length(condData) >= 2
                % Calculate Cohen's d
                pooledSD = sqrt(((length(refData)-1)*var(refData) + (length(condData)-1)*var(condData)) / (length(refData) + length(condData) - 2));
                if pooledSD > 0
                    cohensD = (mean(condData) - mean(refData)) / pooledSD;
                    effectSizes(end+1) = cohensD;
                    comparisonLabels{end+1} = [conditionName, ' vs ', refCondition];
                end
            end
        end
        
        if ~isempty(effectSizes)
            bar(effectSizes, 'FaceColor', [0.8 0.4 0.4]);
            set(gca, 'XTickLabel', comparisonLabels);
            title(['Effect Sizes vs ', refCondition]);
            ylabel('Cohen''s d');
            grid on;
            
            % Add effect size interpretation lines
            hold on;
            yline(0.2, 'g--', 'Small', 'LineWidth', 1);
            yline(0.5, 'y--', 'Medium', 'LineWidth', 1);
            yline(0.8, 'r--', 'Large', 'LineWidth', 1);
        end
    end
    
    sgtitle(['Combined Conditions Analysis - Enhanced Moving Average Style (N=', num2str(length(participants)), ')'], 'FontSize', 18);
    
    % Save the combined analysis
    saveName = fullfile(outputDir, 'Combined_Conditions_Enhanced_Analysis.png');
    saveas(gcf, saveName, 'png');
    close(gcf);
    
    disp(['Combined conditions enhanced analysis saved to: ', saveName]);
end
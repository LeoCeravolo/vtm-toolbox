%% 14. ENHANCED PARTICIPANT CONDITION ANALYSIS
function generateEnhancedParticipantConditionAnalysis(participantConditionData, participant, conditions, config)
    % Generate enhanced condition analysis with mimicry metrics
    
    outputDir = ['ConditionAnalysis_', participant];
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Create comprehensive condition comparison figure
    figure('Visible', 'off', 'Position', [100, 100, 2000, 1600]);
    
    % Panel 1: Traditional displacement comparison
    subplot(4,4,1);
    conditionMeans = [];
    conditionStds = [];
    conditionLabels = {};
    
    for i = 1:length(conditions)
        condName = conditions{i};
        if isfield(participantConditionData, condName) && ~isempty(participantConditionData.(condName).StableMeanDisplacement)
            conditionMeans(end+1) = mean(participantConditionData.(condName).StableMeanDisplacement);
            conditionStds(end+1) = std(participantConditionData.(condName).StableMeanDisplacement);
            conditionLabels{end+1} = condName;
        end
    end
    
    if ~isempty(conditionMeans)
        bar(conditionMeans, 'FaceColor', [0.3 0.6 0.9]);
        hold on;
        errorbar(1:length(conditionMeans), conditionMeans, conditionStds, 'k.', 'LineWidth', 2);
        set(gca, 'XTickLabel', conditionLabels);
        title('Mean Movement by Condition');
        ylabel('Displacement (pixels)');
        xtickangle(45);
        grid on;
    end
    
    % Panel 2: NEW - Mimicry Response Comparison
    subplot(4,4,2);
    mimicryResponses = [];
    mimicryLabels = {};
    
    for i = 1:length(conditions)
        condName = conditions{i};
        if isfield(participantConditionData, condName) && isfield(participantConditionData.(condName), 'MimicryResponse') && ...
           ~isempty(participantConditionData.(condName).MimicryResponse)
            mimicryResponses(end+1) = mean(participantConditionData.(condName).MimicryResponse);
            mimicryLabels{end+1} = condName;
        end
    end
    
    if ~isempty(mimicryResponses)
        colors = [0.8 0.2 0.2; 0.2 0.8 0.2; 0.2 0.2 0.8; 0.8 0.8 0.2]; % Different colors per condition
        for i = 1:length(mimicryResponses)
            bar(i, mimicryResponses(i), 'FaceColor', colors(min(i, size(colors,1)), :));
            hold on;
        end
        set(gca, 'XTickLabel', mimicryLabels);
        title('Mimicry Response by Condition');
        ylabel('Mimicry Response (pixels)');
        xtickangle(45);
        grid on;
        yline(0, 'k--', 'Baseline', 'LineWidth', 1);
    end
    
    % Panel 3: NEW - Spectral Mimicry Index
    subplot(4,4,3);
    spectralIndices = [];
    spectralLabels = {};
    
    for i = 1:length(conditions)
        condName = conditions{i};
        if isfield(participantConditionData, condName) && isfield(participantConditionData.(condName), 'SpectralMimicryIndex') && ...
           ~isempty(participantConditionData.(condName).SpectralMimicryIndex)
            spectralIndices(end+1) = mean(participantConditionData.(condName).SpectralMimicryIndex);
            spectralLabels{end+1} = condName;
        end
    end
    
    if ~isempty(spectralIndices)
        bar(spectralIndices, 'FaceColor', [0.6 0.3 0.8]);
        set(gca, 'XTickLabel', spectralLabels);
        title('Spectral Mimicry Index');
        ylabel('Speech-like Movement Ratio');
        xtickangle(45);
        grid on;
        yline(0.3, 'r--', 'Speech Threshold', 'LineWidth', 1);
    end
    
    % Panel 4: NEW - Emotion-Specific Mimicry Metrics
    subplot(4,4,4);
    emotionScores = [];
    emotionNames = {};
    
    for i = 1:length(conditions)
        condName = conditions{i};
        if isfield(participantConditionData, condName)
            if isfield(participantConditionData.(condName), 'AngerMimicryScore')
                emotionScores(end+1) = participantConditionData.(condName).AngerMimicryScore;
                emotionNames{end+1} = [condName, ' (Anger)'];
            elseif isfield(participantConditionData.(condName), 'PleasureMimicryScore')
                emotionScores(end+1) = participantConditionData.(condName).PleasureMimicryScore;
                emotionNames{end+1} = [condName, ' (Pleasure)'];
            elseif isfield(participantConditionData.(condName), 'RelativeMovementIndex')
                emotionScores(end+1) = abs(participantConditionData.(condName).RelativeMovementIndex);
                emotionNames{end+1} = [condName, ' (Relative)'];
            end
        end
    end
    
    if ~isempty(emotionScores)
        bar(emotionScores, 'FaceColor', [0.8 0.6 0.2]);
        set(gca, 'XTickLabel', emotionNames);
        title('Emotion-Specific Scores');
        ylabel('Mimicry Score (0-1)');
        xtickangle(45);
        grid on;
    end
    
    % Continue with remaining panels (5-16) combining original analysis with new mimicry metrics...
    % [Additional panels would follow the same pattern, integrating new mimicry metrics]
    
    % Panel 16: Enhanced Summary Statistics
    subplot(4,4,16);
    axis off;
    
    summaryText = {['ENHANCED MIMICRY ANALYSIS - ', participant], ''};
    summaryText{end+1} = 'MIMICRY RANKINGS:';
    
    % Rank conditions by mimicry response
    if ~isempty(mimicryResponses)
        [sortedResponses, sortIdx] = sort(mimicryResponses, 'descend');
        for i = 1:length(sortedResponses)
            summaryText{end+1} = sprintf('%d. %s: %.3f', i, mimicryLabels{sortIdx(i)}, sortedResponses(i));
        end
    end
    
    summaryText{end+1} = '';
    summaryText{end+1} = 'KEY FINDINGS:';
    
    % Identify strongest mimicry conditions
    if ~isempty(mimicryResponses)
        [maxResponse, maxIdx] = max(mimicryResponses);
        if maxResponse > 0.5
            summaryText{end+1} = sprintf('• Strongest mimicry: %s (%.3f)', mimicryLabels{maxIdx}, maxResponse);
        end
        
        % Check for anger/pleasure specific findings
        angerIdx = find(contains(lower(mimicryLabels), 'anger'));
        pleasureIdx = find(contains(lower(mimicryLabels), 'pleasure'));
        
        if ~isempty(angerIdx) && mimicryResponses(angerIdx(1)) > 0.2
            summaryText{end+1} = '• Anger mimicry detected';
        end
        if ~isempty(pleasureIdx) && mimicryResponses(pleasureIdx(1)) > 0.2
            summaryText{end+1} = '• Pleasure mimicry detected';
        end
    end
    
    text(0.05, 0.95, summaryText, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'FontSize', 9, 'FontName', 'Courier', 'Interpreter', 'none');
    
    % Main title
    sgtitle(['Enhanced Mimicry Analysis - ', participant], 'FontSize', 16);
    
    % Save the enhanced analysis
    saveName = fullfile(outputDir, ['Enhanced_Condition_Analysis_', participant, '.png']);
    try
        saveas(gcf, saveName, 'png');
        close(gcf);
        disp(['✓ Enhanced condition analysis saved: ', saveName]);
    catch ME
        disp(['✗ Error saving enhanced condition analysis: ', ME.message]);
        close(gcf);
    end
end

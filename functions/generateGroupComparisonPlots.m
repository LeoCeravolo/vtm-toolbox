function generateGroupComparisonPlots(groupSummary, conditions, outputDir)
    % Generate group comparison plots
    
    try
        fig = figure('Position', [100, 100, 1400, 1000], 'Name', 'Group Level Comparison');
        
        % Peak Velocities comparison
        subplot(2, 2, 1);
        groupData = [];
        groupLabels = {};
        
        for condIdx = 1:length(conditions)
            condName = conditions{condIdx};
            if isfield(groupSummary.(condName), 'PeakVelocities') && ~isempty(groupSummary.(condName).PeakVelocities)
                data = groupSummary.(condName).PeakVelocities;
                if ~isempty(data)
                    groupData = [groupData; data(:)];
                    groupLabels = [groupLabels; repmat({condName}, length(data), 1)];
                end
            end
        end
        
        if ~isempty(groupData)
            boxplot(groupData, groupLabels);
            title('Peak Velocities Across Conditions');
            ylabel('Peak Velocity (pixels/s)');
            xtickangle(45);
            grid on;
        else
            text(0.5, 0.5, 'No Data Available', 'HorizontalAlignment', 'center');
            title('Peak Velocities Across Conditions');
        end
        
        % Displacement comparison
        subplot(2, 2, 2);
        groupData = [];
        groupLabels = {};
        
        for condIdx = 1:length(conditions)
            condName = conditions{condIdx};
            if isfield(groupSummary.(condName), 'StableMeanDisplacement') && ~isempty(groupSummary.(condName).StableMeanDisplacement)
                data = groupSummary.(condName).StableMeanDisplacement;
                if ~isempty(data)
                    groupData = [groupData; data(:)];
                    groupLabels = [groupLabels; repmat({condName}, length(data), 1)];
                end
            end
        end
        
        if ~isempty(groupData)
            boxplot(groupData, groupLabels);
            title('Mean Displacement Across Conditions');
            ylabel('Displacement (pixels)');
            xtickangle(45);
            grid on;
        else
            text(0.5, 0.5, 'No Data Available', 'HorizontalAlignment', 'center');
            title('Mean Displacement Across Conditions');
        end
        
        % Mimicry response comparison
        subplot(2, 2, 3);
        groupData = [];
        groupLabels = {};
        
        for condIdx = 1:length(conditions)
            condName = conditions{condIdx};
            if isfield(groupSummary.(condName), 'MimicryResponse') && ~isempty(groupSummary.(condName).MimicryResponse)
                data = groupSummary.(condName).MimicryResponse;
                if ~isempty(data)
                    groupData = [groupData; data(:)];
                    groupLabels = [groupLabels; repmat({condName}, length(data), 1)];
                end
            end
        end
        
        if ~isempty(groupData)
            boxplot(groupData, groupLabels);
            title('Mimicry Response Across Conditions');
            ylabel('Mimicry Response');
            xtickangle(45);
            grid on;
        else
            text(0.5, 0.5, 'No Data Available', 'HorizontalAlignment', 'center');
            title('Mimicry Response Across Conditions');
        end
        
        % Sample sizes
        subplot(2, 2, 4);
        sampleSizes = [];
        conditionNames = {};
        
        for condIdx = 1:length(conditions)
            condName = conditions{condIdx};
            if isfield(groupSummary.(condName), 'PeakVelocities')
                sampleSizes(end+1) = length(groupSummary.(condName).PeakVelocities);
                conditionNames{end+1} = condName;
            end
        end
        
        if ~isempty(sampleSizes)
            bar(sampleSizes);
            set(gca, 'XTickLabel', conditionNames);
            title('Sample Sizes by Condition');
            ylabel('Number of Observations');
            xtickangle(45);
            grid on;
            
            % Add sample size labels
            for i = 1:length(sampleSizes)
                text(i, sampleSizes(i) + max(sampleSizes)*0.02, num2str(sampleSizes(i)), ...
                     'HorizontalAlignment', 'center', 'FontWeight', 'bold');
            end
        else
            text(0.5, 0.5, 'No Data Available', 'HorizontalAlignment', 'center');
            title('Sample Sizes by Condition');
        end
        
        sgtitle('Group Level Analysis Across All Participants', 'FontSize', 14, 'FontWeight', 'bold');
        
        % Save figure
        outputFile = fullfile(outputDir, 'GroupLevelComparison.png');
        saveas(fig, outputFile);
        close(fig);
        
        disp(['✓ Group comparison plots saved: ', outputFile]);
        
    catch ME
        disp(['Group comparison plots error: ', ME.message]);
        if exist('fig', 'var')
            close(fig);
        end
    end
end

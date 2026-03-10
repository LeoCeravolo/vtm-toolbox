
function generateVelocityAnalysisPlot(mlSummary, participantID, outputDir)
    % Generate velocity analysis plot
    
    figure('Position', [100, 100, 1200, 800]);
    
    % Extract velocity data
    allPeakVelocities = [];
    allMeanVelocities = [];
    conditions = {};
    
    for i = 1:mlSummary.numTrials
        if i <= length(mlSummary.velocityMetrics)
            vm = mlSummary.velocityMetrics(i);
            
            if isfinite(vm.max_peak)
                allPeakVelocities(end+1) = vm.max_peak;
                conditions{end+1} = mlSummary.conditions{i};
            end
            
            if isfinite(vm.overall_mean)
                allMeanVelocities(end+1) = vm.overall_mean;
            end
        end
    end
    
    % Peak velocities by condition
    subplot(2, 2, 1);
    if ~isempty(allPeakVelocities) && ~isempty(conditions)
        uniqueCond = unique(conditions);
        conditionPeaks = cell(1, length(uniqueCond));
        
        for c = 1:length(uniqueCond)
            condIdx = strcmp(conditions, uniqueCond{c});
            conditionPeaks{c} = allPeakVelocities(condIdx);
        end
        
        boxplot([conditionPeaks{:}], 'Labels', uniqueCond);
        title('Peak Velocities by Condition');
        ylabel('Peak Velocity');
        xlabel('Condition');
        grid on;
    else
        text(0.5, 0.5, 'No velocity data', 'HorizontalAlignment', 'center');
    end
    
    % Velocity distribution
    subplot(2, 2, 2);
    if ~isempty(allMeanVelocities)
        histogram(allMeanVelocities, 10);
        title('Mean Velocity Distribution');
        xlabel('Mean Velocity');
        ylabel('Frequency');
        grid on;
    else
        text(0.5, 0.5, 'No velocity data', 'HorizontalAlignment', 'center');
    end
    
    % Additional velocity plots can be added here...
    
    sgtitle(['Velocity Analysis - ', participantID], 'FontSize', 14, 'FontWeight', 'bold');
    
    savePath = fullfile(outputDir, [participantID, '_VelocityAnalysis.png']);
    saveas(gcf, savePath);
    close(gcf);
    
    disp(['✓ Velocity analysis plot saved: ', savePath]);
end
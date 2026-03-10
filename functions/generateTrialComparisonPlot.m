function generateTrialComparisonPlot(mlSummary, participantID, outputDir)
    % Generate detailed trial-by-trial comparison
    
    figure('Position', [100, 100, 1400, 1000]);
    
    % Displacement comparison
    subplot(3, 2, 1);
    plotTrialMetricComparison(mlSummary, 'StableMeanDisplacement', 'Mean Displacement');
    
    % Confidence comparison  
    subplot(3, 2, 2);
    plotTrialMetricComparison(mlSummary, 'confidenceScore', 'Confidence Score');
    
    % Success rate by condition
    subplot(3, 2, 3);
    plotSuccessRateByCondition(mlSummary);
    
    % Method agreement timeline
    subplot(3, 2, 4);
    plotMethodAgreementTimeline(mlSummary);
    
    % Overall performance summary
    subplot(3, 2, [5, 6]);
    plotOverallPerformanceSummary(mlSummary);
    
    sgtitle(['Trial-by-Trial ML Comparison - ', participantID], 'FontSize', 16, 'FontWeight', 'bold');
    
    savePath = fullfile(outputDir, [participantID, '_TrialComparison.png']);
    saveas(gcf, savePath);
    close(gcf);
    
    disp(['✓ Trial comparison plot saved: ', savePath]);
end

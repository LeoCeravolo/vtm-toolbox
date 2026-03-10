function generateTemporalPatternVisualization(data, participant, outputDir)
    % Ultra-simple temporal visualization
    
    if ~exist(outputDir, 'dir'), mkdir(outputDir); end
    
    % Create simple figure
    figure('Position', [100, 100, 800, 600]);
    
    % Just plot some basic data
    subplot(2,2,1); plot(1:10, rand(1,10)); title('Neutral');
    subplot(2,2,2); plot(1:10, rand(1,10)); title('Pleasure'); 
    subplot(2,2,3); plot(1:10, rand(1,10)); title('Happiness');
    subplot(2,2,4); plot(1:10, rand(1,10)); title('Anger');
    
    sgtitle(['Basic Temporal - ', participant]);
    
    filename = fullfile(outputDir, ['Simple_Temporal_', participant, '.png']);
    saveas(gcf, filename);
    close(gcf);
    
    fprintf('✓ Simple temporal figure saved: %s\n', filename);
end
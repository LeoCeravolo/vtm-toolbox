
function createStandaloneTemporalDemo(outputDir)
    % Create demo figure without real data - just for illustration
    
    if ~exist(outputDir, 'dir'), mkdir(outputDir); end
    
    % Create the demo with simulated data only
    emptyData = struct();
    createSimpleTemporalDemo(emptyData, 'Demo', outputDir);
    
    fprintf('Standalone temporal demo created in: %s\n', outputDir);
end
function createSimpleTemporalDemo(data, participant, outputDir)
    % Create a simple but powerful demonstration of temporal patterns
    
    if ~exist(outputDir, 'dir'), mkdir(outputDir); end
    
    % Clean participant name  
    participantClean = strrep(participant, '_', '');
    
    % Create figure with 2x2 layout
    fig = figure('Position', [100, 100, 1200, 800], 'Color', 'white');
    
    %% Panel 1: Simulated Example Patterns (Top Left)
    subplot(2, 2, 1);
    
    % Create example time series for each emotion type
    t = 0:0.04:3; % 3 seconds, 25 fps
    
    % Neutral: minimal, brief movement
    neutral = 0.5 + 0.3*sin(2*pi*0.5*t) .* exp(-t/2) .* (t < 1);
    
    % Anger: sustained high amplitude  
    anger = 0.3 + 1.2*exp(-0.5*t) .* (t < 2.5) + 0.2*randn(size(t));
    
    % Happiness: oscillatory with multiple peaks
    happiness = 0.4 + 0.8*sin(2*pi*2*t) .* exp(-0.3*t) .* (t < 2.8) + 0.1*randn(size(t));
    
    % Pleasure: similar to happiness but different frequency
    pleasure = 0.3 + 0.9*sin(2*pi*1.5*t + pi/4) .* exp(-0.2*t) .* (t < 2.5) + 0.1*randn(size(t));
    
    % Plot all patterns with proper color specifications
    plot(t, neutral, 'Color', [0.7 0.7 0.7], 'LineWidth', 2, 'DisplayName', 'Neutral');
    hold on;
    plot(t, anger, 'Color', [0.8 0.2 0.2], 'LineWidth', 2, 'DisplayName', 'Anger');
    plot(t, happiness, 'Color', [1 0.6 0], 'LineWidth', 2, 'DisplayName', 'Happiness');
    plot(t, pleasure, 'Color', [0.2 0.8 0.2], 'LineWidth', 2, 'DisplayName', 'Pleasure');
    
    xlabel('Time (seconds)');
    ylabel('Movement Amplitude');
    title('Temporal Pattern Types', 'FontWeight', 'bold');
    legend('show', 'Location', 'best');
    grid on;
    
    % Add annotations with compatible colors
    text(0.5, max(anger)*0.8, 'Sustained', 'Color', 'red', 'FontWeight', 'bold');
    text(1.5, max(happiness)*0.8, 'Oscillatory', 'Color', [0.8 0.4 0], 'FontWeight', 'bold');
    text(2.5, max(neutral)*1.2, 'Brief', 'Color', [0.5 0.5 0.5], 'FontWeight', 'bold');
    
    %% Panel 2: Episode Detection Demo (Top Right)
    subplot(2, 2, 2);
    
    % Use anger example to show episode detection
    threshold = 0.8;
    aboveThreshold = anger > threshold;
    
    plot(t, anger, 'Color', 'red', 'LineWidth', 2);
    hold on;
    
    % Show threshold line
    yline(threshold, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Movement Threshold');
    
    % Highlight episodes
    episodes = findSimpleEpisodes(aboveThreshold);
    for ep = 1:length(episodes)
        epStart = t(episodes(ep).start);
        epEnd = t(episodes(ep).end);
        epDuration = epEnd - epStart;
        
        % Color-code episodes by duration
        if epDuration > 1.0
            episodeColor = 'red'; % Red for long episodes
            edgeColor = 'red';
        elseif epDuration > 0.5
            episodeColor = [1 0.6 0.2]; % Orange for medium (RGB triplet)
            edgeColor = [1 0.6 0.2];
        else
            episodeColor = 'yellow'; % Yellow for short
            edgeColor = 'yellow';
        end
        
        % Draw episode rectangle using patch (better compatibility)
        patch([epStart epStart+epDuration epStart+epDuration epStart], ...
              [0 0 max(anger) max(anger)], ...
              episodeColor, 'FaceAlpha', 0.3, ...
              'EdgeColor', edgeColor, 'LineWidth', 2);
        
        % Add duration label
        if epDuration > 1.0
            labelColor = 'red';
        elseif epDuration > 0.5
            labelColor = [0.8 0.4 0]; % Darker orange for text
        else
            labelColor = [0.6 0.6 0]; % Darker yellow for text
        end
        
        text(epStart + epDuration/2, max(anger)*0.9, ...
             sprintf('%.1fs', epDuration), 'HorizontalAlignment', 'center', ...
             'FontWeight', 'bold', 'Color', labelColor);
    end
    
    xlabel('Time (seconds)');
    ylabel('Movement Amplitude');
    title('Movement Episode Detection', 'FontWeight', 'bold');
    legend('Movement', 'Threshold', 'Location', 'best');
    grid on;
    
    %% Panel 3: Duration Metrics Comparison (Bottom Left)
    subplot(2, 2, 3);
    
    % Calculate metrics for each simulated pattern
    conditions = {'Neutral', 'Pleasure', 'Happiness', 'Anger'};
    patterns = {neutral, pleasure, happiness, anger};
    
    ctaiValues = zeros(1, 4);
    mpiValues = zeros(1, 4);
    episodeCounts = zeros(1, 4);
    
    for i = 1:4
        pattern = patterns{i};
        
        % Calculate CTAI components
        peakAmp = max(pattern);
        totalDuration = sum(pattern > prctile(pattern, 70)) / 25; % seconds
        avgAmp = mean(pattern(pattern > prctile(pattern, 70)));
        
        if isnan(avgAmp), avgAmp = 0; end
        
        % Simple CTAI calculation
        ctaiValues(i) = peakAmp * 0.3 + totalDuration * 0.4 + avgAmp * 0.3;
        
        % Simple MPI calculation
        mpiValues(i) = avgAmp * sqrt(totalDuration);
        
        % Episode count
        episodes = findSimpleEpisodes(pattern > prctile(pattern, 70));
        episodeCounts(i) = length(episodes);
    end
    
    % Create grouped bar chart
    x = 1:4;
    barWidth = 0.25;
    
    b1 = bar(x - barWidth, ctaiValues, barWidth, 'FaceColor', [0.2 0.6 0.8], 'DisplayName', 'CTAI');
    hold on;
    b2 = bar(x, mpiValues, barWidth, 'FaceColor', [0.8 0.4 0.2], 'DisplayName', 'MPI');
    b3 = bar(x + barWidth, episodeCounts, barWidth, 'FaceColor', [0.2 0.8 0.4], 'DisplayName', 'Episodes');
    
    set(gca, 'XTick', 1:4, 'XTickLabel', conditions);
    xlabel('Emotion Condition');
    ylabel('Metric Value (normalized)');
    title('Duration-Enhanced Metrics Comparison', 'FontWeight', 'bold');
    legend('show', 'Location', 'best');
    grid on;
    
    % Add value labels on bars
    for i = 1:4
        text(i - barWidth, ctaiValues(i) + 0.1, sprintf('%.1f', ctaiValues(i)), ...
             'HorizontalAlignment', 'center', 'FontSize', 8);
        text(i, mpiValues(i) + 0.1, sprintf('%.1f', mpiValues(i)), ...
             'HorizontalAlignment', 'center', 'FontSize', 8);
        text(i + barWidth, episodeCounts(i) + 0.1, sprintf('%d', episodeCounts(i)), ...
             'HorizontalAlignment', 'center', 'FontSize', 8);
    end
    
    %% Panel 4: Real Data Example (Bottom Right)
    subplot(2, 2, 4);
    
    % Try to plot actual data if available
    realDataPlotted = false;
    
    % Look for real trial data
    runs = fieldnames(data);
    for runIdx = 1:length(runs)
        runName = runs{runIdx};
        if ~isstruct(data.(runName)), continue; end
        
        trials = fieldnames(data.(runName));
        for trialIdx = 1:length(trials)
            trialName = trials{trialIdx};
            trialData = data.(runName).(trialName);
            
            if ~isstruct(trialData) || realDataPlotted, continue; end
            
            % Check if this trial has displacement data
            if isfield(trialData, 'AllDisplacements') && ~isempty(trialData.AllDisplacements)
                
                % Extract displacement time series
                displacements = [];
                for frameIdx = 1:length(trialData.AllDisplacements)
                    if ~isempty(trialData.AllDisplacements{frameIdx})
                        frameDisp = trialData.AllDisplacements{frameIdx};
                        displacements(frameIdx) = mean(frameDisp);
                    else
                        displacements(frameIdx) = NaN;
                    end
                end
                
                if length(displacements) > 10 && sum(~isnan(displacements)) > 5
                    timeVector = (1:length(displacements)) / 25; % Convert to seconds
                    validIdx = ~isnan(displacements);
                    
                    plot(timeVector(validIdx), displacements(validIdx), 'b-', 'LineWidth', 1.5);
                    hold on;
                    
                    % Show movement episodes if they exist
                    threshold = prctile(displacements(validIdx), 70);
                    aboveThreshold = displacements > threshold;
                    episodes = findSimpleEpisodes(aboveThreshold);
                    
                    for ep = 1:length(episodes)
                        if episodes(ep).start <= length(timeVector) && episodes(ep).end <= length(timeVector)
                            epStart = timeVector(episodes(ep).start);
                            epEnd = timeVector(episodes(ep).end);
                            
                            patch([epStart epEnd epEnd epStart], ...
                                  [min(displacements(validIdx)) min(displacements(validIdx)) ...
                                   max(displacements(validIdx)) max(displacements(validIdx))], ...
                                  'red', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                        end
                    end
                    
                    xlabel('Time (seconds)');
                    ylabel('Displacement (pixels)');
                    title(['Real Data Example: ', strrep(trialName, '_', '\_')], 'FontWeight', 'bold');
                    grid on;
                    
                    % Add metrics if available
                    if isfield(trialData, 'ComprehensiveTemporalAmplitudeIndex') && ...
                       ~isnan(trialData.ComprehensiveTemporalAmplitudeIndex)
                        
                        text(0.02, 0.98, sprintf('CTAI: %.2f', trialData.ComprehensiveTemporalAmplitudeIndex), ...
                             'Units', 'normalized', 'VerticalAlignment', 'top', ...
                             'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontWeight', 'bold');
                    end
                    
                    realDataPlotted = true;
                end
            end
        end
        if realDataPlotted, break; end
    end
    
    if ~realDataPlotted
        text(0.5, 0.5, 'No Real Data Available', 'HorizontalAlignment', 'center', ...
             'FontSize', 14, 'Color', [0.5 0.5 0.5]);
        title('Real Data Example', 'FontWeight', 'bold');
    end
    
    %% Add main title and save
    sgtitle(['Temporal Pattern Analysis Overview - Participant ', participantClean], ...
        'FontSize', 16, 'FontWeight', 'bold', 'Interpreter', 'none');
    
    % Save figure
    figFile = fullfile(outputDir, [participantClean, '_TemporalDemo.png']);
    saveas(fig, figFile);
    figFile2 = fullfile(outputDir, [participantClean, '_TemporalDemo.fig']);
    savefig(fig, figFile2);
    
    fprintf('✓ Temporal pattern demo saved: %s\n', figFile);
    close(fig);
end

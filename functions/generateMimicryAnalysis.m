%% 13. GENERATE MIMICRY ANALYSIS
function generateMimicryAnalysis(data, run, conditionName, outputDir, config)
    % Generate comprehensive mimicry-specific analysis plots
    
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
    
    % Extract run number for display
    runNumber = regexp(run, '\d+', 'match');
    if ~isempty(runNumber)
        runDisplay = ['Run', runNumber{1}];
    else
        runDisplay = run;
    end
    
    figure('Visible', 'off', 'Position', [100, 100, 1800, 1200]);
    
    % Panel 1: Stimulus-aligned movement
    subplot(3,4,1);
    if isfield(data.(run).(conditionName), 'StableMeanDisplacement')
        displacement = data.(run).(conditionName).StableMeanDisplacement;
        displacement = displacement(~isnan(displacement));
        
        if ~isempty(displacement)
            plot(1:length(displacement), displacement, 'b-', 'LineWidth', 2);
            hold on;
            
            % Mark stimulus onset and windows
            if isfield(data.(run).(conditionName), 'StimulusOnsetFrame')
                stimOnset = data.(run).(conditionName).StimulusOnsetFrame;
                xline(stimOnset, 'g--', 'Stimulus Onset', 'LineWidth', 2);
                
                if isfield(data.(run).(conditionName), 'MimicryWindow')
                    mimicryWin = data.(run).(conditionName).MimicryWindow;
                    if length(mimicryWin) >= 2
                        fill([mimicryWin(1), mimicryWin(2), mimicryWin(2), mimicryWin(1)], ...
                             [0, 0, max(displacement)*1.1, max(displacement)*1.1], ...
                             'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                    end
                end
            end
            
            title(['Stimulus-Aligned Movement - ', runDisplay]);
            xlabel('Frame'); ylabel('Displacement (pixels)');
            grid on;
        else
            text(0.5, 0.5, 'No Movement Data', 'HorizontalAlignment', 'center');
        end
    end
    
    % Panel 2: Mimicry response metrics
    subplot(3,4,2);
    if isfield(data.(run).(conditionName), 'MimicryResponse') && isfield(data.(run).(conditionName), 'BaselineMovement')
        mimicryResp = data.(run).(conditionName).MimicryResponse;
        baselineMove = data.(run).(conditionName).BaselineMovement;
        stimulusMove = data.(run).(conditionName).StimulusMovement;
        
        bar([1, 2, 3], [baselineMove, stimulusMove, mimicryResp], ...
            'FaceColor', [0.3 0.6 0.9]);
        set(gca, 'XTickLabel', {'Baseline', 'Stimulus', 'Response'});
        title('Mimicry Metrics');
        ylabel('Movement (pixels)');
        grid on;
        
        % Add significance indicator
        if isfield(data.(run).(conditionName), 'MimicrySignificance') && data.(run).(conditionName).MimicrySignificance
            text(3, mimicryResp + abs(mimicryResp)*0.1, '*', 'FontSize', 20, 'Color', 'r', 'HorizontalAlignment', 'center');
        end
    end
    
    % Panel 3: Frequency domain analysis
    subplot(3,4,3);
    if isfield(data.(run).(conditionName), 'FrequencyProfile') && isfield(data.(run).(conditionName), 'Frequencies')
        freqs = data.(run).(conditionName).Frequencies;
        psd = data.(run).(conditionName).FrequencyProfile;
        
        if ~isempty(freqs) && ~isempty(psd)
            loglog(freqs, psd, 'b-', 'LineWidth', 2);
            hold on;
            
            % Mark frequency bands
            speechBand = config.frequencyBands(2, :);
            ylims = ylim;
            fill([speechBand(1), speechBand(2), speechBand(2), speechBand(1)], ...
                 [ylims(1), ylims(1), ylims(2), ylims(2)], ...
                 'g', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
            
            title('Frequency Analysis');
            xlabel('Frequency (Hz)'); ylabel('Power');
            legend('PSD', 'Speech Band', 'Location', 'best');
            grid on;
        end
    end
    
    % Panel 4: Anatomical movement breakdown
    subplot(3,4,4);
    if isfield(data.(run).(conditionName), 'AnatomicalMovement')
        anatMovement = data.(run).(conditionName).AnatomicalMovement;
        regions = fieldnames(anatMovement);
        
        if ~isempty(regions)
            regionMeans = [];
            regionNames = {};
            
            for r = 1:length(regions)
                regionData = anatMovement.(regions{r});
                validData = regionData(isfinite(regionData));
                if ~isempty(validData)
                    regionMeans(end+1) = mean(validData);
                    regionNames{end+1} = regions{r};
                end
            end
            
            if ~isempty(regionMeans)
                bar(regionMeans, 'FaceColor', [0.8 0.4 0.6]);
                set(gca, 'XTickLabel', regionNames);
                title('Anatomical Movement');
                ylabel('Movement (pixels)');
                xtickangle(45);
                grid on;
            end
        end
    end
    
    % Panel 5: Tracking quality over time
    subplot(3,4,5);
    if isfield(data.(run).(conditionName), 'TrackingQuality')
        quality = data.(run).(conditionName).TrackingQuality;
        plot(1:length(quality), quality, 'g-', 'LineWidth', 2);
        hold on;
        yline(0.8, 'r--', 'Quality Threshold', 'LineWidth', 1);
        title('Tracking Quality');
        xlabel('Frame'); ylabel('Quality (0-1)');
        ylim([0, 1]);
        grid on;
    end
    
    % Panel 6: Point loss rate
    subplot(3,4,6);
    if isfield(data.(run).(conditionName), 'PointLossRate')
        lossRate = data.(run).(conditionName).PointLossRate;
        plot(1:length(lossRate), lossRate * 100, 'r-', 'LineWidth', 2);
        hold on;
        yline(30, 'k--', 'Refresh Threshold', 'LineWidth', 1);
        title('Point Loss Rate');
        xlabel('Frame'); ylabel('Loss Rate (%)');
        grid on;
    end
    
    % Panel 7: Velocity analysis
    subplot(3,4,7);
    if isfield(data.(run).(conditionName), 'MeanVelocity') && isfield(data.(run).(conditionName), 'MaxVelocity')
        meanVel = data.(run).(conditionName).MeanVelocity;
        maxVel = data.(run).(conditionName).MaxVelocity;
        
        plot(1:length(meanVel), meanVel, 'b-', 'LineWidth', 2, 'DisplayName', 'Mean Velocity');
        hold on;
        plot(1:length(maxVel), maxVel, 'r-', 'LineWidth', 2, 'DisplayName', 'Max Velocity');
        title('Velocity Analysis');
        xlabel('Frame'); ylabel('Velocity (pixels/s)');
        legend('Location', 'best');
        grid on;
    end
    
    % Panel 8: Temporal coherence
    subplot(3,4,8);
    if isfield(data.(run).(conditionName), 'TemporalCoherence')
        coherence = data.(run).(conditionName).TemporalCoherence;
        if ~isnan(coherence)
            bar(1, coherence, 'FaceColor', [0.2 0.8 0.6]);
            hold on;
            yline(0.5, 'r--', 'Coherence Threshold', 'LineWidth', 1);
            title('Temporal Coherence');
            ylabel('Coherence (0-1)');
            ylim([0, 1]);
            set(gca, 'XTickLabel', {''});
            grid on;
        end
    end
    
    % Panels 9-12: Summary statistics and interpretation
    subplot(3,4,[9,10,11,12]);
    axis off;
    
    % Create summary text
    summaryText = {['MIMICRY ANALYSIS SUMMARY - ', strrep(conditionName, '_', ' '), ' (', runDisplay, ')'], ''};
    
    if isfield(data.(run).(conditionName), 'MimicryResponse')
        summaryText{end+1} = sprintf('Mimicry Response: %.3f pixels', data.(run).(conditionName).MimicryResponse);
    end
    
    if isfield(data.(run).(conditionName), 'MimicryLatency')
        latency = data.(run).(conditionName).MimicryLatency;
        if ~isnan(latency)
            summaryText{end+1} = sprintf('Mimicry Latency: %.1f ms', latency);
        else
            summaryText{end+1} = 'Mimicry Latency: Not detected';
        end
    end
    
    if isfield(data.(run).(conditionName), 'SpectralMimicryIndex')
        summaryText{end+1} = sprintf('Spectral Mimicry Index: %.3f', data.(run).(conditionName).SpectralMimicryIndex);
    end
    
    if isfield(data.(run).(conditionName), 'TemporalCoherence')
        summaryText{end+1} = sprintf('Temporal Coherence: %.3f', data.(run).(conditionName).TemporalCoherence);
    end
    
    summaryText{end+1} = '';
    summaryText{end+1} = 'INTERPRETATION:';
    
    % Add interpretation based on metrics
    if isfield(data.(run).(conditionName), 'MimicryResponse')
        mimicryResp = data.(run).(conditionName).MimicryResponse;
        if mimicryResp > 0.5
            summaryText{end+1} = '• Strong mimicry response detected';
        elseif mimicryResp > 0.1
            summaryText{end+1} = '• Moderate mimicry response detected';
        else
            summaryText{end+1} = '• Weak or no mimicry response';
        end
    end
    
    if isfield(data.(run).(conditionName), 'SpectralMimicryIndex')
        spectralIdx = data.(run).(conditionName).SpectralMimicryIndex;
        if spectralIdx > 0.3
            summaryText{end+1} = '• Speech-like movement patterns';
        else
            summaryText{end+1} = '• Non-speech movement patterns';
        end
    end
    
    if contains(lower(conditionName), 'anger') || contains(lower(conditionName), 'pleasure')
        summaryText{end+1} = '• Target emotion for mimicry study';
    end
    
    text(0.05, 0.95, summaryText, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
         'FontSize', 10, 'FontName', 'Courier', 'Interpreter', 'none');
    
    % Main title
    sgtitle(['Comprehensive Mimicry Analysis - ', strrep(conditionName, '_', ' '), ' (', runDisplay, ')'], 'FontSize', 16);
    
    % Save the analysis
    saveName = fullfile(outputDir, ['Mimicry_Analysis_', conditionName, '_', runDisplay, '.png']);
    try
        saveas(gcf, saveName, 'png');
        close(gcf);
        disp(['✓ Mimicry analysis saved: ', saveName]);
    catch ME
        disp(['✗ Error saving mimicry analysis: ', ME.message]);
        close(gcf);
    end
end

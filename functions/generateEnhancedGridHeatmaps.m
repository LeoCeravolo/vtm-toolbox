function generateEnhancedGridHeatmaps(data, run, ConditionName, ROI, avgMagnitudeMap, avgVxMap, avgVyMap, outputDir)
    % Enhanced optical flow heatmaps with comprehensive units
    
    try
        fig = figure('Position', [100, 100, 1800, 600], 'Visible', 'off');
        sgtitle([strrep(ConditionName, '_', ' '), ' - Optical Flow Spatial Analysis'], ...
            'FontSize', 16, 'FontWeight', 'bold');
        
        % === SUBPLOT 1: Magnitude Heatmap ===
        subplot(1, 3, 1);
        h1 = imagesc(avgMagnitudeMap);
        colormap(gca, hot(256));
        
        xlabel('Horizontal Position (px)', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Vertical Position (px)', 'FontSize', 12, 'FontWeight', 'bold');
        title('Average Flow Magnitude', 'FontSize', 14, 'FontWeight', 'bold');
        
        % Enhanced colorbar with proper units
        c1 = colorbar;
        c1.Label.String = 'Flow Magnitude (px/frame)';
        c1.Label.FontSize = 12;
        c1.Label.FontWeight = 'bold';
        
        axis image;
        
        % Add scale information
        [rows, cols] = size(avgMagnitudeMap);
        text(cols*0.02, rows*0.95, sprintf('Scale: %d×%d px', cols, rows), ...
            'FontSize', 10, 'Color', 'white', 'FontWeight', 'bold');
        
        % === SUBPLOT 2: Horizontal Flow Component ===
        subplot(1, 3, 2);
        h2 = imagesc(avgVxMap);
        colormap(gca, 'jet');
        
        xlabel('Horizontal Position (px)', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Vertical Position (px)', 'FontSize', 12, 'FontWeight', 'bold');
        title('Horizontal Flow Component (Vx)', 'FontSize', 14, 'FontWeight', 'bold');
        
        % Enhanced colorbar with proper units
        c2 = colorbar;
        c2.Label.String = 'Horizontal Velocity (px/frame)';
        c2.Label.FontSize = 12;
        c2.Label.FontWeight = 'bold';
        
        axis image;
        
        % Add directional indicators
        text(cols*0.02, rows*0.95, '← Left    Right →', ...
            'FontSize', 10, 'Color', 'white', 'FontWeight', 'bold');
        
        % === SUBPLOT 3: Vertical Flow Component ===
        subplot(1, 3, 3);
        h3 = imagesc(avgVyMap);
        colormap(gca, 'jet');
        
        xlabel('Horizontal Position (px)', 'FontSize', 12, 'FontWeight', 'bold');
        ylabel('Vertical Position (px)', 'FontSize', 12, 'FontWeight', 'bold');
        title('Vertical Flow Component (Vy)', 'FontSize', 14, 'FontWeight', 'bold');
        
        % Enhanced colorbar with proper units
        c3 = colorbar;
        c3.Label.String = 'Vertical Velocity (px/frame)';
        c3.Label.FontSize = 12;
        c3.Label.FontWeight = 'bold';
        
        axis image;
        
        % Add directional indicators
        text(cols*0.02, rows*0.95, '↑ Up    Down ↓', ...
            'FontSize', 10, 'Color', 'white', 'FontWeight', 'bold');
        
        % Save figure
        outputFile = fullfile(outputDir, ['OpticalFlowHeatmaps_', ConditionName, '_', run, '.png']);
        print(fig, outputFile, '-dpng', '-r300');
        close(fig);
        
        disp(['✓ Optical flow heatmaps with units saved: ', outputFile]);
        
    catch ME
        disp(['Error in heatmap generation: ', ME.message]);
        if exist('fig', 'var')
            close(fig);
        end
    end
end

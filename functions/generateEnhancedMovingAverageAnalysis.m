function generateEnhancedMovingAverageAnalysis(data, run, conditionName, outputDir)
% Enhanced version with trial-level correlation plot and improved biomarkers

% Create run-specific output directory if not provided
if nargin < 4 || isempty(outputDir)
    outputDir = ['MovingAverage_Enhanced_', run];
    if ~exist(outputDir, 'dir')
        mkdir(outputDir);
    end
end

figure('Visible', 'off', 'Position', [100, 100, 1800, 1400]);

% Extract run number for display
runNumber = regexp(run, '\d+', 'match');
if ~isempty(runNumber)
    runDisplay = ['Run', runNumber{1}];
else
    runDisplay = run;
end

% Initialize progress tracking
totalPanels = 12;
currentPanel = 0;
progressColors = [
    0.9 0.1 0.1;  % Red - Starting
    0.9 0.5 0.1;  % Orange
    0.9 0.9 0.1;  % Yellow
    0.7 0.9 0.1;  % Yellow-Green
    0.5 0.9 0.1;  % Light Green
    0.3 0.9 0.1;  % Green
    0.1 0.9 0.3;  % Green-Cyan
    0.1 0.9 0.7;  % Cyan
    0.1 0.7 0.9;  % Light Blue
    0.1 0.5 0.9;  % Blue
    0.3 0.1 0.9;  % Blue-Purple
    0.1 0.9 0.1;  % Bright Green - Complete
];

% Helper function for progress updates
updateProgress = @(panelNum) fprintf('📊 Processing Panel %d/%d: %s [%s]\n', ...
    panelNum, totalPanels, ...
    sprintf('████████████', char(repmat('█', 1, round(12 * panelNum/totalPanels)))), ...
    sprintf('%.1f%%', 100 * panelNum/totalPanels));

% Panel 1: Stable Displacement Over Time with Run Info
currentPanel = 1;
updateProgress(currentPanel);
subplot(4,3,1);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
if isfield(data.(run).(conditionName), 'StableMeanDisplacement')
    meanDisp = data.(run).(conditionName).StableMeanDisplacement;
    validDisp = meanDisp(~isnan(meanDisp) & meanDisp > 0);
    validFrames = find(~isnan(meanDisp) & meanDisp > 0);

    if ~isempty(validDisp)
        plot(validFrames, validDisp, 'b-', 'LineWidth', 2, 'DisplayName', 'Fast Movements Only');
        hold on;

        % Add moving average with error handling
        if length(validDisp) >= 5
            try
                smoothDisp = movmean(validDisp, 5);
                plot(validFrames, smoothDisp, 'r-', 'LineWidth', 3, 'DisplayName', 'Smoothed (5-frame)');
            catch ME
                disp(['Warning: Smoothing failed: ', ME.message]);
            end
        end

        title(['Fast Movement Analysis - ', runDisplay]);
        xlabel('Frame'); ylabel('Displacement (pixels)');
        
        % CLEAN LEGEND
        if length(validDisp) >= 5
            addSimpleLegend('Fast Movements Only', 'Smoothed (5-frame)');
        else
            addSimpleLegend('Fast Movements Only');
        end
        grid on;
        ylim([0, max(validDisp)*1.1]);
    else
        text(0.5, 0.5, 'No Valid Fast Movement Data', 'HorizontalAlignment', 'center');
        title(['Fast Movement Analysis - ', runDisplay]);
    end
else
    text(0.5, 0.5, 'No Fast Movement Data', 'HorizontalAlignment', 'center');
    title(['Fast Movement Analysis - ', runDisplay]);
end

% Panel 2: Max vs Mean Displacement Comparison
currentPanel = 2;
updateProgress(currentPanel);
subplot(4,3,2);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
if isfield(data.(run).(conditionName), 'StableMeanDisplacement') && isfield(data.(run).(conditionName), 'StableMaxDisplacement')
    meanDisp = data.(run).(conditionName).StableMeanDisplacement;
    maxDisp = data.(run).(conditionName).StableMaxDisplacement;

    % Ensure arrays are same length
    minLen = min(length(meanDisp), length(maxDisp));
    if minLen > 0
        meanDisp = meanDisp(1:minLen);
        maxDisp = maxDisp(1:minLen);

        validIdx = ~isnan(meanDisp) & meanDisp > 0 & ~isnan(maxDisp) & maxDisp > 0;
        validMean = meanDisp(validIdx);
        validMax = maxDisp(validIdx);
        validFrames = find(validIdx);

        if ~isempty(validMean) && ~isempty(validMax)
            plot(validFrames, validMean, 'b-', 'LineWidth', 2, 'DisplayName', 'Mean Fast Movement');
            hold on;
            plot(validFrames, validMax, 'r-', 'LineWidth', 2, 'DisplayName', 'Max Fast Movement');
            title(['Mean vs Max - ', runDisplay]);
            xlabel('Frame'); ylabel('Displacement (pixels)');
            addSimpleLegend('Mean Fast Movement', 'Max Fast Movement');
            grid on;
        else
            text(0.5, 0.5, 'Insufficient Fast Movement Data', 'HorizontalAlignment', 'center');
            title(['Mean vs Max - ', runDisplay]);
        end
    else
        text(0.5, 0.5, 'No Data Available', 'HorizontalAlignment', 'center');
        title(['Mean vs Max - ', runDisplay]);
    end
else
    text(0.5, 0.5, 'No Displacement Data Available', 'HorizontalAlignment', 'center');
    title(['Mean vs Max - ', runDisplay]);
end

% Panel 3: Point Count Analysis with Tracker Reliability (FIXED BOUNDS)
currentPanel = 3;
updateProgress(currentPanel);
subplot(4,3,3);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
if isfield(data.(run).(conditionName), 'StablePointCount') && isfield(data.(run).(conditionName), 'PointCount')
    stableCount = data.(run).(conditionName).StablePointCount;
    totalCount = data.(run).(conditionName).PointCount;

    % CRITICAL FIX: Ensure both arrays exist and have data
    if ~isempty(stableCount) && ~isempty(totalCount)
        minLen = min(length(stableCount), length(totalCount));
        
        if minLen > 0
            % SAFE INDEXING: Truncate to common length
            stableCount = stableCount(1:minLen);
            totalCount = totalCount(1:minLen);

            % BOUNDS CHECK: Create safe logical indices
            validIdx = false(minLen, 1); % Initialize as false array
            for i = 1:minLen
                if ~isnan(totalCount(i)) && totalCount(i) > 0
                    validIdx(i) = true;
                end
            end
            
            if any(validIdx)
                validFrames = find(validIdx);
                validTotal = totalCount(validIdx);
                validStable = stableCount(validIdx);

                plot(validFrames, validTotal, 'g-', 'LineWidth', 2, 'DisplayName', 'Total Points');
                hold on;
                
                % SAFE STABLE POINTS PLOTTING
                stableValidIdx = false(length(validStable), 1);
                for i = 1:length(validStable)
                    if ~isnan(validStable(i)) && validStable(i) > 0
                        stableValidIdx(i) = true;
                    end
                end
                
                if any(stableValidIdx)
                    stableFramesToPlot = validFrames(stableValidIdx);
                    stablePointsToPlot = validStable(stableValidIdx);
                    plot(stableFramesToPlot, stablePointsToPlot, 'b-', 'LineWidth', 2, 'DisplayName', 'Fast Movement Points');
                end
                
                % Add reliability indicator
                meanReliability = mean(validTotal);
                yline(meanReliability, 'r--', ['Mean: ', num2str(round(meanReliability))], 'LineWidth', 1);
                
                title(['Tracker Reliability - ', runDisplay]);
                xlabel('Frame'); ylabel('Number of Points');
                
                % CLEAN LEGEND - only show what's actually plotted
                if any(stableValidIdx)
                    addSimpleLegend('Total Points', 'Fast Movement Points');
                else
                    addSimpleLegend('Total Points');
                end
                grid on;
            else
                text(0.5, 0.5, 'No Valid Point Count Data', 'HorizontalAlignment', 'center');
                title(['Tracker Reliability - ', runDisplay]);
            end
        else
            text(0.5, 0.5, 'Empty Arrays', 'HorizontalAlignment', 'center');
            title(['Tracker Reliability - ', runDisplay]);
        end
    else
        text(0.5, 0.5, 'Missing Point Count Arrays', 'HorizontalAlignment', 'center');
        title(['Tracker Reliability - ', runDisplay]);
    end
else
    text(0.5, 0.5, 'No Point Count Data Available', 'HorizontalAlignment', 'center');
    title(['Tracker Reliability - ', runDisplay]);
end

% Panel 4: Optical Flow Analysis
currentPanel = 4;
updateProgress(currentPanel);
subplot(4,3,4);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
if isfield(data.(run).(conditionName), 'ROIFlowMagnitude')
    flowMag = data.(run).(conditionName).ROIFlowMagnitude;
    if ~isempty(flowMag)
        plot(1:length(flowMag), flowMag, 'Color', [0.5 0 0.5], 'LineWidth', 2);
        hold on;
        if length(flowMag) >= 5
            try
                smoothFlow = movmean(flowMag, 5);
                plot(1:length(smoothFlow), smoothFlow, 'Color', [1 0.5 0], 'LineWidth', 3);
            catch ME
                disp(['Warning: Flow smoothing failed: ', ME.message]);
            end
        end
        title(['Optical Flow - ', runDisplay]);
        xlabel('Frame'); ylabel('Flow Magnitude');
        grid on;
    else
        text(0.5, 0.5, 'No Flow Data', 'HorizontalAlignment', 'center');
        title(['Optical Flow - ', runDisplay]);
    end
else
    text(0.5, 0.5, 'No Flow Data Available', 'HorizontalAlignment', 'center');
    title(['Optical Flow - ', runDisplay]);
end

% Panel 5: TRIAL-LEVEL Flow vs Displacement Correlation (FIXED BOUNDS)
currentPanel = 5;
updateProgress(currentPanel);
subplot(4,3,5);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
if isfield(data.(run).(conditionName), 'ROIFlowMagnitude') && isfield(data.(run).(conditionName), 'StableMeanDisplacement')
    flowMag = data.(run).(conditionName).ROIFlowMagnitude;
    meanDisp = data.(run).(conditionName).StableMeanDisplacement;

    % SAFE DATA VALIDATION
    if ~isempty(flowMag) && ~isempty(meanDisp) && isnumeric(flowMag) && isnumeric(meanDisp)
        
        % Enhanced data validation for trial-level correlation
        minLen = min(length(flowMag), length(meanDisp));
        correlationValue = NaN; % Initialize as NaN
        
        if minLen > 5  % Need at least 6 points for meaningful correlation
            % SAFE TRUNCATION
            flowMag = flowMag(1:minLen);
            meanDisp = meanDisp(1:minLen);

            % SAFE LOGICAL INDEXING: Create indices step by step
            validIdx = false(minLen, 1); % Initialize as false array
            for i = 1:minLen
                if ~isnan(meanDisp(i)) && meanDisp(i) > 0 && ~isnan(flowMag(i)) && flowMag(i) > 0
                    validIdx(i) = true;
                end
            end
            
            % SAFE EXTRACTION
            validFlow = flowMag(validIdx);
            validDisp = meanDisp(validIdx);

            if length(validFlow) > 5 && length(validDisp) > 5
                % Check for sufficient variance before correlation
                flowVar = var(validFlow);
                dispVar = var(validDisp);
                
                if flowVar > 1e-10 && dispVar > 1e-10  % Numerical tolerance check
                    try
                        corrMatrix = corrcoef(validFlow, validDisp);
                        correlationValue = corrMatrix(1,2);
                        
                        % Additional NaN check
                        if isnan(correlationValue)
                            correlationValue = 0;
                            disp(['Warning: Correlation returned NaN for ', runDisplay, ' - ', conditionName]);
                        end
                        
                        % Create scatter plot with enhanced visualization
                        scatter(validFlow, validDisp, 50, 'filled', 'MarkerFaceColor', [0.2 0.6 0.8], ...
                               'MarkerEdgeColor', 'k', 'MarkerEdgeAlpha', 0.3);
                        hold on;

                        % Add regression line with confidence bounds
                        try
                            [regressionCoeffs, S] = polyfit(validFlow, validDisp, 1);
                            
                            % Check if polyfit was successful
                            if length(regressionCoeffs) == 2 && ~any(isnan(regressionCoeffs))
                                xRange = linspace(min(validFlow), max(validFlow), 50);
                                
                                % Safe polyval call - only get regression line if confidence bounds fail
                                try
                                    [yRegression, delta] = polyval(regressionCoeffs, xRange, S);
                                    
                                    % Plot regression line
                                    plot(xRange, yRegression, 'r-', 'LineWidth', 3);
                                    
                                    % Plot confidence bounds only if delta is valid
                                    if exist('delta', 'var') && ~any(isnan(delta)) && length(delta) == length(yRegression)
                                        fill([xRange, fliplr(xRange)], [yRegression + delta, fliplr(yRegression - delta)], ...
                                             'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                                    end
                                    
                                catch polyvalError
                                    % Fallback - just plot simple regression line without confidence bounds
                                    yRegression = polyval(regressionCoeffs, xRange);
                                    plot(xRange, yRegression, 'r-', 'LineWidth', 3);
                                    disp(['Warning: Confidence bounds failed for ', runDisplay, ', using simple regression']);
                                end
                            end
                            
                        catch ME
                            disp(['Warning: Regression analysis failed for ', runDisplay, ': ', ME.message]);
                        end

                        xlabel('Flow Magnitude'); ylabel('Fast Movement (pixels)');
                        titleText = sprintf('Trial-Level Correlation - %s (r = %.3f)', runDisplay, correlationValue);
                        title(titleText);
                        grid on;
                        
                        % Add correlation strength indicator
                        if abs(correlationValue) >= 0.7
                            corrStrength = 'Strong';
                            textColor = [0 0.7 0]; % Green RGB
                        elseif abs(correlationValue) >= 0.3
                            corrStrength = 'Moderate';
                            textColor = [1 0.5 0]; % Orange RGB
                        else
                            corrStrength = 'Weak';
                            textColor = [0.8 0 0]; % Red RGB
                        end
                        
                        text(0.05, 0.95, [corrStrength, ' Correlation'], 'Units', 'normalized', ...
                             'FontSize', 10, 'Color', textColor, 'FontWeight', 'bold');
                        
                    catch ME
                        disp(['Correlation calculation error for ', runDisplay, ' - ', conditionName, ': ', ME.message]);
                        text(0.5, 0.5, 'Correlation Error', 'HorizontalAlignment', 'center');
                        title(['Trial-Level Correlation - ', runDisplay, ' (Error)']);
                    end
                else
                    disp(['Insufficient variance for correlation in ', runDisplay, ' - ', conditionName]);
                    disp(['Flow variance: ', num2str(flowVar), ', Displacement variance: ', num2str(dispVar)]);
                    text(0.5, 0.5, 'Insufficient Variance', 'HorizontalAlignment', 'center');
                    title(['Trial-Level Correlation - ', runDisplay, ' (Low Var)']);
                end
            else
                text(0.5, 0.5, 'Insufficient Data Points', 'HorizontalAlignment', 'center');
                title(['Trial-Level Correlation - ', runDisplay, ' (N<6)']);
            end
        else
            text(0.5, 0.5, 'Insufficient Data Length', 'HorizontalAlignment', 'center');
            title(['Trial-Level Correlation - ', runDisplay, ' (Short)']);
        end
    else
        text(0.5, 0.5, 'Invalid Flow/Displacement Data', 'HorizontalAlignment', 'center');
        title(['Trial-Level Correlation - ', runDisplay, ' (Invalid)']);
    end
else
    text(0.5, 0.5, 'No Flow/Displacement Data', 'HorizontalAlignment', 'center');
    title(['Trial-Level Correlation - ', runDisplay, ' (No Data)']);
end

% Panel 6: ENHANCED BIOMARKER - Movement Intensity (FIXED BOUNDS)
currentPanel = 6;
updateProgress(currentPanel);
subplot(4,3,6);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
if isfield(data.(run).(conditionName), 'StableMeanDisplacement') && isfield(data.(run).(conditionName), 'PointCount')
    meanDisp = data.(run).(conditionName).StableMeanDisplacement;
    pointCount = data.(run).(conditionName).PointCount;
    
    % SAFE DATA VALIDATION
    if ~isempty(meanDisp) && ~isempty(pointCount) && isnumeric(meanDisp) && isnumeric(pointCount)
        
        % BOUNDS CHECK: Ensure we have enough data
        minLen = min(length(meanDisp), length(pointCount));
        
        if minLen > 0
            % SAFE TRUNCATION
            meanDisp = meanDisp(1:minLen);
            pointCount = pointCount(1:minLen);
            
            % Calculate intensity for each frame with SAFE INDEXING
            maxExpectedPoints = 500; % Estimated maximum grid points
            intensityScores = [];
            intensityFrames = [];
            
            for f = 1:minLen
                try
                    if f <= length(meanDisp) && f <= length(pointCount) && ...
                       ~isnan(meanDisp(f)) && meanDisp(f) > 0 && ...
                       ~isnan(pointCount(f)) && pointCount(f) > 0
                        
                        % Point loss factor (0 = no loss, 1 = complete loss)
                        pointLossFactor = max(0, (maxExpectedPoints - pointCount(f)) / maxExpectedPoints);
                        
                        % Movement intensity = displacement × (1 + point_loss_factor)
                        intensity = meanDisp(f) * (1 + pointLossFactor);
                        
                        intensityScores(end+1) = intensity;
                        intensityFrames(end+1) = f;
                    end
                catch ME
                    % Skip problematic frames
                    continue;
                end
            end
            
            if ~isempty(intensityScores)
                plot(intensityFrames, intensityScores, 'Color', [0.8 0.2 0.6], 'LineWidth', 3, 'DisplayName', 'Movement Intensity');
                hold on;
                
                % Add smoothed version with BOUNDS CHECK
                if length(intensityScores) >= 5
                    try
                        smoothIntensity = movmean(intensityScores, 5);
                        plot(intensityFrames, smoothIntensity, 'Color', [0.4 0.1 0.3], 'LineWidth', 2, 'DisplayName', 'Smoothed');
                    catch ME
                        disp(['Warning: Intensity smoothing failed: ', ME.message]);
                    end
                end
                
                title(['Movement Intensity - ', runDisplay]);
                xlabel('Frame'); ylabel('Intensity Score');
                
                % CLEAN LEGEND
                if length(intensityScores) >= 5
                    addSimpleLegend('Movement Intensity', 'Smoothed');
                else
                    addSimpleLegend('Movement Intensity');
                end
                grid on;
                
                % Add summary statistics
                meanIntensity = mean(intensityScores);
                text(0.7, 0.8, sprintf('Mean: %.2f', meanIntensity), 'Units', 'normalized', ...
                     'FontSize', 10, 'BackgroundColor', 'white');
            else
                text(0.5, 0.5, 'No Valid Intensity Data', 'HorizontalAlignment', 'center');
                title(['Movement Intensity - ', runDisplay]);
            end
        else
            text(0.5, 0.5, 'No Data for Intensity Calculation', 'HorizontalAlignment', 'center');
            title(['Movement Intensity - ', runDisplay]);
        end
    else
        text(0.5, 0.5, 'Invalid Data for Intensity', 'HorizontalAlignment', 'center');
        title(['Movement Intensity - ', runDisplay]);
    end
else
    text(0.5, 0.5, 'No Intensity Data Available', 'HorizontalAlignment', 'center');
    title(['Movement Intensity - ', runDisplay]);
end

% Panel 7: Velocity Analysis with Enhanced Thresholding (FIXED BOUNDS)
currentPanel = 7;
updateProgress(currentPanel);
subplot(4,3,7);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
if isfield(data.(run).(conditionName), 'MaxVelocity')
    maxVel = data.(run).(conditionName).MaxVelocity;
    
    % SAFE VELOCITY PROCESSING
    if ~isempty(maxVel) && isnumeric(maxVel)
        % BOUNDS CHECK: Create safe logical indices
        validVelIdx = false(length(maxVel), 1);
        for i = 1:length(maxVel)
            if ~isnan(maxVel(i)) && maxVel(i) > 0
                validVelIdx(i) = true;
            end
        end
        
        validVelFrames = find(validVelIdx);

        if ~isempty(validVelFrames)
            plot(validVelFrames, maxVel(validVelFrames), 'r-', 'LineWidth', 3, 'DisplayName', 'Max Velocity');
            hold on;
            
            % SAFE MEAN VELOCITY PLOTTING (as secondary reference)
            if isfield(data.(run).(conditionName), 'MeanVelocity')
                meanVel = data.(run).(conditionName).MeanVelocity;
                if ~isempty(meanVel) && length(meanVel) >= max(validVelFrames)
                    % BOUNDS CHECK: Only plot where we have data
                    meanVelSafe = meanVel(validVelFrames);
                    validMeanIdx = ~isnan(meanVelSafe) & meanVelSafe > 0;
                    
                    if any(validMeanIdx)
                        plot(validVelFrames(validMeanIdx), meanVelSafe(validMeanIdx), 'b--', 'LineWidth', 2, 'DisplayName', 'Mean Velocity');
                    end
                end
            end

            % SAFE THRESHOLD PLOTTING
            if isfield(data.(run).(conditionName), 'VelocityThreshold')
                velThreshold = data.(run).(conditionName).VelocityThreshold;
                if ~isempty(velThreshold) && length(velThreshold) >= max(validVelFrames)
                    % BOUNDS CHECK: Only plot where we have data
                    thresholdSafe = velThreshold(validVelFrames);
                    validThreshIdx = ~isnan(thresholdSafe);
                    
                    if any(validThreshIdx)
                        plot(validVelFrames(validThreshIdx), thresholdSafe(validThreshIdx), 'g--', 'LineWidth', 2, 'DisplayName', 'Adaptive Threshold');
                    end
                end
            end

            title(['Peak Velocity Analysis - ', runDisplay]);
            xlabel('Frame'); ylabel('Velocity (pixels/sec)');
            
            % CLEAN LEGEND - build based on what's actually plotted
            legendEntries = {'Max Velocity'};
            if isfield(data.(run).(conditionName), 'MeanVelocity') && exist('meanVel', 'var') && ~isempty(meanVel) && length(meanVel) >= max(validVelFrames)
                legendEntries{end+1} = 'Mean Velocity';
            end
            if isfield(data.(run).(conditionName), 'VelocityThreshold')
                legendEntries{end+1} = 'Adaptive Threshold';
            end
            
            % Use cell array expansion safely
            if length(legendEntries) == 1
                addSimpleLegend(legendEntries{1});
            elseif length(legendEntries) == 2
                addSimpleLegend(legendEntries{1}, legendEntries{2});
            elseif length(legendEntries) == 3
                addSimpleLegend(legendEntries{1}, legendEntries{2}, legendEntries{3});
            end
            grid on;
            
            % Add peak velocity statistics
            meanMaxVel = mean(maxVel(validVelFrames));
            text(0.7, 0.8, sprintf('Mean Max Vel: %.1f', meanMaxVel), 'Units', 'normalized', ...
                 'FontSize', 9, 'BackgroundColor', 'white');
        else
            text(0.5, 0.5, 'No Valid Max Velocity Data', 'HorizontalAlignment', 'center');
            title(['Peak Velocity Analysis - ', runDisplay]);
        end
    else
        text(0.5, 0.5, 'Invalid Max Velocity Data', 'HorizontalAlignment', 'center');
        title(['Peak Velocity Analysis - ', runDisplay]);
    end
else
    text(0.5, 0.5, 'No Max Velocity Data Available', 'HorizontalAlignment', 'center');
    title(['Peak Velocity Analysis - ', runDisplay]);
end

% Panel 8: Movement Classification with Enhanced Analysis (FIXED BOUNDS)
currentPanel = 8;
updateProgress(currentPanel);
subplot(4,3,8);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
if isfield(data.(run).(conditionName), 'MovementClassification')
    movementClass = data.(run).(conditionName).MovementClassification;
    
    % SAFE MOVEMENT CLASSIFICATION PROCESSING
    if ~isempty(movementClass) && isstruct(movementClass)
        validFrames = [];
        fastMovements = [];
        slowMovements = [];
        totalMovements = [];

        % BOUNDS CHECK: Safely extract data
        for f = 1:length(movementClass)
            try
                if f <= length(movementClass) && ...
                   isfield(movementClass(f), 'TotalPoints') && ...
                   ~isempty(movementClass(f).TotalPoints) && ...
                   isfield(movementClass(f), 'FastMovements') && ...
                   isfield(movementClass(f), 'SlowMovements')
                    
                    validFrames(end+1) = f;
                    fastMovements(end+1) = movementClass(f).FastMovements;
                    slowMovements(end+1) = movementClass(f).SlowMovements;
                    totalMovements(end+1) = movementClass(f).TotalPoints;
                end
            catch ME
                % Skip problematic frames
                continue;
            end
        end

        if ~isempty(validFrames)
            plot(validFrames, fastMovements, 'r-', 'LineWidth', 3, 'DisplayName', 'Fast Movements');
            hold on;
            plot(validFrames, slowMovements, 'y-', 'LineWidth', 2, 'DisplayName', 'Slow Movements');
            plot(validFrames, totalMovements, 'b--', 'LineWidth', 1, 'DisplayName', 'Total Points');
            
            % SAFE MOVEMENT RATIO CALCULATION
            if ~isempty(fastMovements) && ~isempty(totalMovements)
                % BOUNDS CHECK: Avoid division by zero
                safeTotal = max(totalMovements, 1); % Replace zeros with 1
                movementRatio = fastMovements ./ safeTotal;
                
                yyaxis right;
                plot(validFrames, movementRatio, 'k:', 'LineWidth', 2);
                ylabel('Movement Ratio', 'Color', 'k');
                ylim([0, 1]);
                yyaxis left;
            end

            title(['Movement Classification - ', runDisplay]);
            xlabel('Frame'); ylabel('Number of Points');
            
            % SIMPLIFIED LEGEND: Just use the basic legend function
            addSimpleLegend('Fast Movements', 'Slow Movements', 'Total Points');
            grid on;
        else
            text(0.5, 0.5, 'No Valid Movement Classification', 'HorizontalAlignment', 'center');
            title(['Movement Classification - ', runDisplay]);
        end
    else
        text(0.5, 0.5, 'Invalid Movement Classification Data', 'HorizontalAlignment', 'center');
        title(['Movement Classification - ', runDisplay]);
    end
else
    text(0.5, 0.5, 'No Movement Classification Available', 'HorizontalAlignment', 'center');
    title(['Movement Classification - ', runDisplay]);
end

% Panel 9: ALTERNATIVE BIOMARKER - Flow-to-Point Efficiency (FIXED BOUNDS)
currentPanel = 9;
updateProgress(currentPanel);
subplot(4,3,9);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
if isfield(data.(run).(conditionName), 'ROIFlowMagnitude') && isfield(data.(run).(conditionName), 'PointCount')
    flowMag = data.(run).(conditionName).ROIFlowMagnitude;
    pointCount = data.(run).(conditionName).PointCount;
    
    % SAFE DATA VALIDATION
    if ~isempty(flowMag) && ~isempty(pointCount) && isnumeric(flowMag) && isnumeric(pointCount)
        
        minLen = min(length(flowMag), length(pointCount));
        if minLen > 0
            % SAFE TRUNCATION
            flowMag = flowMag(1:minLen);
            pointCount = pointCount(1:minLen);
            
            % SAFE LOGICAL INDEXING
            validIdx = false(minLen, 1);
            for i = 1:minLen
                if ~isnan(flowMag(i)) && flowMag(i) > 0 && ~isnan(pointCount(i)) && pointCount(i) > 10
                    validIdx(i) = true;
                end
            end
            
            if any(validIdx)
                % SAFE EXTRACTION
                validFlowMag = flowMag(validIdx);
                validPointCount = pointCount(validIdx);
                validFrames = find(validIdx);
                
                % Calculate flow efficiency (flow per tracked point)
                efficiency = validFlowMag ./ validPointCount * 1000; % Scaled for visibility
                
                plot(validFrames, efficiency, 'Color', [0.4 0.8 0.8], 'LineWidth', 3, 'DisplayName', 'Flow Efficiency');
                hold on;
                
                % Add trend line
                if length(efficiency) > 5
                    try
                        smoothEfficiency = movmean(efficiency, 5);
                        plot(validFrames, smoothEfficiency, 'Color', [0.2 0.4 0.4], 'LineWidth', 2, 'DisplayName', 'Trend');
                    catch ME
                        disp(['Warning: Efficiency smoothing failed: ', ME.message]);
                    end
                end
                
                title(['Flow Efficiency - ', runDisplay]);
                xlabel('Frame'); ylabel('Flow per Point (×1000)');
                
                % CLEAN LEGEND
                if length(efficiency) > 5
                    addSimpleLegend('Flow Efficiency', 'Trend');
                else
                    addSimpleLegend('Flow Efficiency');
                end
                grid on;
                
                % Add summary statistics
                meanEfficiency = mean(efficiency);
                text(0.7, 0.8, sprintf('Mean: %.2f', meanEfficiency), 'Units', 'normalized', ...
                     'FontSize', 10, 'BackgroundColor', 'white');
            else
                text(0.5, 0.5, 'No Valid Efficiency Data', 'HorizontalAlignment', 'center');
                title(['Flow Efficiency - ', runDisplay]);
            end
        else
            text(0.5, 0.5, 'No Data for Efficiency', 'HorizontalAlignment', 'center');
            title(['Flow Efficiency - ', runDisplay]);
        end
    else
        text(0.5, 0.5, 'Invalid Flow/Point Data', 'HorizontalAlignment', 'center');
        title(['Flow Efficiency - ', runDisplay]);
    end
else
    text(0.5, 0.5, 'No Flow/Point Data Available', 'HorizontalAlignment', 'center');
    title(['Flow Efficiency - ', runDisplay]);
end

% Panel 10: Change Rate Analysis
currentPanel = 10;
updateProgress(currentPanel);
subplot(4,3,10);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
if isfield(data.(run).(conditionName), 'StableMeanDisplacement')
    meanDisp = data.(run).(conditionName).StableMeanDisplacement;
    validDisp = meanDisp(~isnan(meanDisp) & meanDisp > 0);
    validFrames = find(~isnan(meanDisp) & meanDisp > 0);

    if length(validDisp) > 1
        dispRate = diff(validDisp);
        rateFrames = validFrames(2:end);
        
        plot(rateFrames, dispRate, 'k-', 'LineWidth', 2, 'DisplayName', 'Change Rate');
        hold on;
        
        % Add zero line
        yline(0, 'r--', 'No Change', 'LineWidth', 1);
        
        % Add acceleration/deceleration regions
        acceleration = dispRate > 0;
        deceleration = ~acceleration;
        
        if any(acceleration)
            scatter(rateFrames(acceleration), dispRate(acceleration), 50, 'g', 'filled', 'DisplayName', 'Acceleration');
        end
        if any(deceleration)
            scatter(rateFrames(deceleration), dispRate(deceleration), 50, 'r', 'filled', 'DisplayName', 'Deceleration');
        end
        
        title(['Movement Change Rate - ', runDisplay]);
        xlabel('Frame'); ylabel('Displacement Change (pixels)');
        
        % SIMPLIFIED LEGEND
        legendEntries = {'Change Rate'};
        if any(acceleration)
            legendEntries{end+1} = 'Acceleration';
        end
        if any(deceleration)
            legendEntries{end+1} = 'Deceleration';
        end
        
        % Safe legend creation
        if length(legendEntries) == 1
            addSimpleLegend(legendEntries{1});
        elseif length(legendEntries) == 2
            addSimpleLegend(legendEntries{1}, legendEntries{2});
        else
            addSimpleLegend(legendEntries{1}, legendEntries{2}, legendEntries{3});
        end
        grid on;
    else
        text(0.5, 0.5, 'Insufficient Data for Rate', 'HorizontalAlignment', 'center');
        title(['Movement Change Rate - ', runDisplay]);
    end
else
    text(0.5, 0.5, 'No Fast Movement Data', 'HorizontalAlignment', 'center');
    title(['Movement Change Rate - ', runDisplay]);
end

% Panel 11: Distribution Comparison
currentPanel = 11;
updateProgress(currentPanel);
subplot(4,3,11);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
if isfield(data.(run).(conditionName), 'StableMeanDisplacement')
    meanDisp = data.(run).(conditionName).StableMeanDisplacement;
    validDisp = meanDisp(~isnan(meanDisp) & meanDisp > 0);

    if ~isempty(validDisp)
        % Create histogram
        [counts, edges] = histcounts(validDisp, 20);
        centers = (edges(1:end-1) + edges(2:end)) / 2;
        
        bar(centers, counts, 'FaceColor', [0.3 0.6 0.9], 'EdgeColor', 'black', 'FaceAlpha', 0.7);
        hold on;
        
        % Add distribution statistics
        meanVal = mean(validDisp);
        medianVal = median(validDisp);
        stdVal = std(validDisp);
        
        xline(meanVal, 'r-', 'Mean', 'LineWidth', 2);
        xline(medianVal, 'g-', 'Median', 'LineWidth', 2);
        
        title(['Distribution Analysis - ', runDisplay]);
        xlabel('Displacement (pixels)'); ylabel('Frequency');
        grid on;

        % Add statistics text
        text(0.6, 0.8, sprintf('Mean: %.2f\nMedian: %.2f\nStd: %.2f\nSkew: %.2f', ...
             meanVal, medianVal, stdVal, skewness(validDisp)), ...
            'Units', 'normalized', 'FontSize', 9, 'BackgroundColor', 'white');
    else
        text(0.5, 0.5, 'No Valid Fast Movement Data', 'HorizontalAlignment', 'center');
        title(['Distribution Analysis - ', runDisplay]);
    end
else
    text(0.5, 0.5, 'No Fast Movement Data', 'HorizontalAlignment', 'center');
    title(['Distribution Analysis - ', runDisplay]);
end

% Panel 12: Summary Biomarkers Panel
currentPanel = 12;
updateProgress(currentPanel);
subplot(4,3,12);
set(gca, 'Color', progressColors(currentPanel, :) * 0.1 + [0.9 0.9 0.9]); % Light tinted background
axis off;

% Calculate summary biomarkers
summaryText = {['BIOMARKER SUMMARY - ', runDisplay], ''};

% Traditional biomarker
if isfield(data.(run).(conditionName), 'StableMeanDisplacement')
    meanDisp = data.(run).(conditionName).StableMeanDisplacement;
    validDisp = meanDisp(~isnan(meanDisp) & meanDisp > 0);
    if ~isempty(validDisp)
        tradBiomarker = mean(validDisp);
        summaryText{end+1} = sprintf('Traditional Biomarker: %.2f', tradBiomarker);
    end
end

% Enhanced biomarker (compensated for point loss)
if isfield(data.(run).(conditionName), 'StableMeanDisplacement') && isfield(data.(run).(conditionName), 'PointCount')
    meanDisp = data.(run).(conditionName).StableMeanDisplacement;
    pointCount = data.(run).(conditionName).PointCount;
    
    validDispIdx = ~isnan(meanDisp) & meanDisp > 0;
    validPointIdx = ~isnan(pointCount) & pointCount > 0;
    
    if any(validDispIdx) && any(validPointIdx)
        meanDispValue = mean(meanDisp(validDispIdx));
        meanPointValue = mean(pointCount(validPointIdx));
        maxPoints = 500;
        
        pointLossFactor = (maxPoints - meanPointValue) / maxPoints;
        enhancedBiomarker = meanDispValue * (1 + pointLossFactor);
        
        summaryText{end+1} = sprintf('Enhanced Biomarker: %.2f', enhancedBiomarker);
        summaryText{end+1} = sprintf('Point Loss Factor: %.1f%%', pointLossFactor * 100);
    end
end

% Peak velocity biomarker (NEW)
if isfield(data.(run).(conditionName), 'MaxVelocity')
    maxVel = data.(run).(conditionName).MaxVelocity;
    validVelIdx = ~isnan(maxVel) & maxVel > 0;
    
    if any(validVelIdx)
        meanMaxVel = mean(maxVel(validVelIdx));
        peakVelBiomarker = meanMaxVel;
        summaryText{end+1} = sprintf('Peak Velocity Biomarker: %.2f', peakVelBiomarker);
    end
end

% Flow efficiency biomarker
if isfield(data.(run).(conditionName), 'ROIFlowMagnitude') && isfield(data.(run).(conditionName), 'PointCount')
    flowMag = data.(run).(conditionName).ROIFlowMagnitude;
    pointCount = data.(run).(conditionName).PointCount;
    
    validFlowIdx = ~isnan(flowMag) & flowMag > 0;
    validPointIdx = ~isnan(pointCount) & pointCount > 10;
    
    if any(validFlowIdx) && any(validPointIdx)
        meanFlow = mean(flowMag(validFlowIdx));
        meanPoints = mean(pointCount(validPointIdx));
        
        efficiencyBiomarker = (meanFlow / meanPoints) * 1000;
        summaryText{end+1} = sprintf('Flow Efficiency: %.2f', efficiencyBiomarker);
    end
end

summaryText{end+1} = '';
summaryText{end+1} = 'RECOMMENDATIONS:';

% Add recommendations based on data quality and peak velocity
if exist('pointLossFactor', 'var') && pointLossFactor > 0.3
    summaryText{end+1} = '• High point loss detected';
    summaryText{end+1} = '• Use enhanced biomarkers';
elseif exist('pointLossFactor', 'var') && pointLossFactor < 0.1
    summaryText{end+1} = '• Good tracker reliability';
    summaryText{end+1} = '• Traditional measures valid';
end

if exist('peakVelBiomarker', 'var')
    if peakVelBiomarker > 50
        summaryText{end+1} = '• High peak velocity detected';
        summaryText{end+1} = '• Consider velocity-based analysis';
    elseif peakVelBiomarker < 10
        summaryText{end+1} = '• Low peak velocity';
        summaryText{end+1} = '• Focus on displacement metrics';
    end
end

text(0.1, 0.9, summaryText, 'Units', 'normalized', 'FontSize', 10, ...
    'VerticalAlignment', 'top', 'FontName', 'FixedWidth');

% Main title with enhanced information
sgtitle(['Enhanced Trial Analysis - ', strrep(conditionName, '_', ' '), ' (', runDisplay, ')'], 'FontSize', 16);

% Save with run-specific naming
fprintf('💾 Saving analysis...\n');
saveName = fullfile(outputDir, ['Enhanced_MovingAverage_Analysis_', conditionName, '_', runDisplay, '.png']);
try
    saveas(gcf, saveName, 'png');
    close(gcf);
    fprintf('✅ Enhanced analysis completed and saved: %s\n', saveName);
    fprintf('🎯 Analysis Summary: %d panels processed with color progression\n', totalPanels);
catch ME
    fprintf('❌ Error saving analysis: %s\n', ME.message);
    close(gcf);
end

end % END OF MAIN FUNCTION

%% HELPER FUNCTIONS FOR LEGEND MANAGEMENT

function addSimpleLegend(varargin)
% Add a simple legend with manual control
% Usage: addSimpleLegend('Entry1', 'Entry2', ...)

try
    if nargin == 0
        return;
    end
    
    % Get line objects in order they were plotted
    allLines = findobj(gca, 'Type', 'line');
    allScatter = findobj(gca, 'Type', 'scatter');
    allBars = findobj(gca, 'Type', 'bar');
    
    % Reverse order to match plotting order
    allLines = flipud(allLines);
    allScatter = flipud(allScatter);
    allBars = flipud(allBars);
    
    % Combine objects
    plotObjects = [allLines; allScatter; allBars];
    
    % Use only as many objects as we have labels
    numLabels = min(nargin, length(plotObjects));
    
    if numLabels > 0
        legend(plotObjects(1:numLabels), varargin(1:numLabels), 'Location', 'best', 'FontSize', 8);
    end
    
catch ME
    % Silently fail if legend creation has issues
    return;
end
end
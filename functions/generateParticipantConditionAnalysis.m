function generateParticipantConditionAnalysis(participantConditionData, participant, conditions)
% MINIMAL CHANGES to original - just adding units and SVG export

% Create output directory
outputDir = ['ConditionAnalysis_', participant];
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Create comprehensive condition comparison figure (KEEP ORIGINAL SIZE)
figure('Visible', 'off', 'Position', [100, 100, 1800, 1400]);

% Panel 1: Mean Displacement by Condition
subplot(4,3,1);
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
    bar(conditionMeans);
    hold on;
    errorbar(1:length(conditionMeans), conditionMeans, conditionStds, 'k.', 'LineWidth', 2);
    set(gca, 'XTickLabel', conditionLabels);
    title('Mean Fast Movement by Condition');
    ylabel('Displacement (pixels)'); % ADDED UNITS
    grid on;
end

% Panel 2: Max Displacement by Condition
subplot(4,3,2);
conditionMaxMeans = [];
conditionMaxStds = [];

for i = 1:length(conditions)
    condName = conditions{i};
    if isfield(participantConditionData, condName) && ~isempty(participantConditionData.(condName).StableMaxDisplacement)
        conditionMaxMeans(end+1) = mean(participantConditionData.(condName).StableMaxDisplacement);
        conditionMaxStds(end+1) = std(participantConditionData.(condName).StableMaxDisplacement);
    end
end

if ~isempty(conditionMaxMeans)
    bar(conditionMaxMeans);
    hold on;
    errorbar(1:length(conditionMaxMeans), conditionMaxMeans, conditionMaxStds, 'k.', 'LineWidth', 2);
    set(gca, 'XTickLabel', conditionLabels);
    title('Max Fast Movement by Condition');
    ylabel('Max Displacement (pixels)'); % ADDED UNITS
    grid on;
end

% Panel 3: Point Count by Condition
subplot(4,3,3);
conditionPointMeans = [];
conditionPointStds = [];

for i = 1:length(conditions)
    condName = conditions{i};
    if isfield(participantConditionData, condName) && ~isempty(participantConditionData.(condName).StablePointCount)
        conditionPointMeans(end+1) = mean(participantConditionData.(condName).StablePointCount);
        conditionPointStds(end+1) = std(participantConditionData.(condName).StablePointCount);
    end
end

if ~isempty(conditionPointMeans)
    bar(conditionPointMeans);
    hold on;
    errorbar(1:length(conditionPointMeans), conditionPointMeans, conditionPointStds, 'k.', 'LineWidth', 2);
    set(gca, 'XTickLabel', conditionLabels);
    title('Fast Movement Point Count by Condition');
    ylabel('Number of Points'); % ADDED UNITS
    grid on;
end

% Panel 4: Flow Magnitude by Condition
subplot(4,3,4);
conditionFlowMeans = [];
conditionFlowStds = [];

for i = 1:length(conditions)
    condName = conditions{i};
    if isfield(participantConditionData, condName) && ~isempty(participantConditionData.(condName).ROIFlowMagnitude)
        conditionFlowMeans(end+1) = mean(participantConditionData.(condName).ROIFlowMagnitude);
        conditionFlowStds(end+1) = std(participantConditionData.(condName).ROIFlowMagnitude);
    end
end

if ~isempty(conditionFlowMeans)
    bar(conditionFlowMeans);
    hold on;
    errorbar(1:length(conditionFlowMeans), conditionFlowMeans, conditionFlowStds, 'k.', 'LineWidth', 2);
    set(gca, 'XTickLabel', conditionLabels);
    title('Flow Magnitude by Condition');
    ylabel('Flow Magnitude (pixels/frame)'); % ADDED UNITS
    grid on;
end

% Panel 5: Entropy by Condition
subplot(4,3,5);
conditionEntropyMeans = [];
conditionEntropyStds = [];

for i = 1:length(conditions)
    condName = conditions{i};
    if isfield(participantConditionData, condName) && ~isempty(participantConditionData.(condName).Entropy)
        conditionEntropyMeans(end+1) = mean(participantConditionData.(condName).Entropy);
        conditionEntropyStds(end+1) = std(participantConditionData.(condName).Entropy);
    end
end

if ~isempty(conditionEntropyMeans)
    bar(conditionEntropyMeans);
    hold on;
    errorbar(1:length(conditionEntropyMeans), conditionEntropyMeans, conditionEntropyStds, 'k.', 'LineWidth', 2);
    set(gca, 'XTickLabel', conditionLabels);
    title('Entropy by Condition');
    ylabel('Entropy (bits)'); % ADDED UNITS
    grid on;
end

% Panel 6: **ENHANCED BIOMARKER PANEL** - Flow-Fast Movement Correlation
subplot(4,3,6);
correlationValues = [];
correlationColors = [];
correlationLabels = {};
validDataInfo = {};

for i = 1:length(conditions)
    condName = conditions{i};
    if isfield(participantConditionData, condName) && ...
       ~isempty(participantConditionData.(condName).StableMeanDisplacement) && ...
       ~isempty(participantConditionData.(condName).ROIFlowMagnitude)
        
        % Get actual trial-level data
        displacementData = participantConditionData.(condName).StableMeanDisplacement;
        flowData = participantConditionData.(condName).ROIFlowMagnitude;
        
        % Ensure same length and remove invalid data
        minLen = min(length(displacementData), length(flowData));
        if minLen > 0
            displacementData = displacementData(1:minLen);
            flowData = flowData(1:minLen);
            
            % Remove NaN and infinite values
            validIdx = isfinite(displacementData) & isfinite(flowData) & ...
                      displacementData > 0 & flowData >= 0;
            displacementData = displacementData(validIdx);
            flowData = flowData(validIdx);
        end
        
        % Check data quality
        nTrials = length(displacementData);
        dispVariance = 0;
        flowVariance = 0;
        
        if nTrials > 0
            dispVariance = var(displacementData);
            flowVariance = var(flowData);
        end
        
        % More detailed data quality info
        validDataInfo{end+1} = sprintf('%s: n=%d, DispVar=%.6f, FlowVar=%.6f', ...
            condName, nTrials, dispVariance, flowVariance);
        
        % Enhanced correlation calculation with multiple safeguards
        corrValue = 0; % Default value
        correlationStatus = '';
        
        if nTrials >= 3 && dispVariance > 1e-12 && flowVariance > 1e-12
            try
                corrMatrix = corrcoef(displacementData, flowData);
                corrValue = corrMatrix(1,2);
                
                % Handle NaN correlations
                if isnan(corrValue) || ~isfinite(corrValue)
                    corrValue = 0;
                    correlationStatus = ' [NaN->0]';
                else
                    correlationStatus = ' [OK]';
                end
                
            catch ME
                corrValue = 0;
                correlationStatus = [' [Error: ', ME.message(1:min(20,end)), ']'];
                disp(['Correlation error for ', condName, ': ', ME.message]);
            end
        else
            correlationStatus = ' [InsuffVar]';
        end
        
        % Update data info with status
        validDataInfo{end} = [validDataInfo{end}, correlationStatus];
        
        correlationValues(end+1) = corrValue;
        correlationLabels{end+1} = condName;
        
        % Color coding based on biomarker interpretation
        if abs(corrValue) < 0.2
            correlationColors(end+1,:) = [1 0 0]; % Red - Respiratory
        elseif abs(corrValue) < 0.5
            correlationColors(end+1,:) = [1 1 0]; % Yellow - Mixed/Weak
        else
            correlationColors(end+1,:) = [0 1 0]; % Green - Strong Mimicry
        end
    end
end

if ~isempty(correlationValues)
    for i = 1:length(correlationValues)
        bar(i, correlationValues(i), 'FaceColor', correlationColors(i,:));
        hold on;
    end
    set(gca, 'XTickLabel', correlationLabels);
    title('BIOMARKER: Flow-Movement Correlation');
    ylabel('Correlation Coefficient (r)'); % ADDED UNITS
    ylim([-1, 1]);
    grid on;
    
    % Add interpretation lines
    yline(0.2, 'g--', 'Mimicry Threshold', 'LineWidth', 1);
    yline(-0.2, 'g--', 'LineWidth', 1);
    yline(0.5, 'b--', 'Strong Mimicry', 'LineWidth', 1);
    yline(-0.5, 'b--', 'LineWidth', 1);
    
    % Add values on bars with error handling
    for i = 1:length(correlationValues)
        try
            if isfinite(correlationValues(i))
                yPos = correlationValues(i) + 0.05*sign(correlationValues(i));
                if abs(yPos) < 0.05, yPos = 0.05; end % Ensure visibility
                text(i, yPos, sprintf('%.3f', correlationValues(i)), ...
                    'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 10);
            end
        catch ME
            disp(['Error adding text for bar ', num2str(i), ': ', ME.message]);
        end
    end
end

% Panel 7: Condition Comparison Heatmap
subplot(4,3,7);
if length(conditionMeans) >= 2
    try
        % Ensure all arrays are same length
        numConds = length(conditionMeans);
        comparisonMatrix = nan(5, numConds);
        
        if length(conditionMeans) == numConds
            comparisonMatrix(1, 1:length(conditionMeans)) = conditionMeans;
        end
        if length(conditionMaxMeans) == numConds
            comparisonMatrix(2, 1:length(conditionMaxMeans)) = conditionMaxMeans;
        end
        if length(conditionPointMeans) == numConds
            comparisonMatrix(3, 1:length(conditionPointMeans)) = conditionPointMeans;
        end
        if length(conditionFlowMeans) == numConds
            comparisonMatrix(4, 1:length(conditionFlowMeans)) = conditionFlowMeans;
        end
        if length(conditionEntropyMeans) == numConds
            comparisonMatrix(5, 1:length(conditionEntropyMeans)) = conditionEntropyMeans;
        end
        
        % Remove rows with all NaN
        validRows = ~all(isnan(comparisonMatrix), 2);
        comparisonMatrix = comparisonMatrix(validRows, :);
        
        if ~isempty(comparisonMatrix) && size(comparisonMatrix, 1) > 0
            imagesc(comparisonMatrix);
            colormap('cool'); colorbar;
            set(gca, 'XTickLabel', conditionLabels);
            rowLabels = {'Mean Disp', 'Max Disp', 'Point Count', 'Flow Mag', 'Entropy'};
            set(gca, 'YTickLabel', rowLabels(validRows));
            title('Condition Comparison Heatmap');
        else
            text(0.5, 0.5, 'Insufficient Data for Heatmap', 'HorizontalAlignment', 'center');
        end
    catch ME
        disp(['Heatmap generation error: ', ME.message]);
        text(0.5, 0.5, 'Heatmap Error', 'HorizontalAlignment', 'center');
    end
end

% Panels 8-10: Individual condition distributions
plotIdx = 8;
for i = 1:min(3, length(conditions))
    subplot(4,3,plotIdx);
    condName = conditions{i};
    if isfield(participantConditionData, condName) && ~isempty(participantConditionData.(condName).StableMeanDisplacement)
        try
            histogram(participantConditionData.(condName).StableMeanDisplacement, 10, 'FaceAlpha', 0.7);
            title([condName, ' Fast Movement Distribution']);
            xlabel('Displacement (pixels)'); % ADDED UNITS
            ylabel('Frequency (trials)'); % ADDED UNITS
            grid on;
        catch ME
            text(0.5, 0.5, 'Histogram Error', 'HorizontalAlignment', 'center');
            title([condName, ' Distribution (Error)']);
        end
    else
        text(0.5, 0.5, 'No Data', 'HorizontalAlignment', 'center');
        title([condName, ' Distribution (No Data)']);
    end
    plotIdx = plotIdx + 1;
end

% Panel 11: Enhanced Data Quality Summary
subplot(4,3,11);
axis off;
if ~isempty(validDataInfo)
    summaryText = 'DATA QUALITY CHECK:';
    for i = 1:length(validDataInfo)
        if i == 1
            summaryText = [summaryText, sprintf('\n\n%s', validDataInfo{i})];
        else
            summaryText = [summaryText, sprintf('\n%s', validDataInfo{i})];
        end
    end
    
    % Add variance thresholds info
    summaryText = [summaryText, sprintf('\n\nThresholds:\nMin variance: 1e-12\nMin trials: 3')];
    
    try
        text(0.05, 0.95, summaryText, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
            'FontSize', 8, 'FontName', 'Courier', 'BackgroundColor', 'white', ...
            'Interpreter', 'none'); % FIXED: Added 'Interpreter', 'none'
    catch ME
        disp(['Text rendering error in panel 11: ', ME.message]);
    end
end

% Panel 12: Enhanced Biomarker Summary
subplot(4,3,12);
axis off;
if ~isempty(correlationValues)
    biomarkerText = 'BIOMARKER SUMMARY:';
    
    % Calculate valid correlations only
    validCorrs = correlationValues(isfinite(correlationValues));
    if ~isempty(validCorrs)
        biomarkerText = [biomarkerText, sprintf('\n\nMean Correlation: %.3f', mean(validCorrs))];
        biomarkerText = [biomarkerText, sprintf('\nStd Correlation: %.3f', std(validCorrs))];
        biomarkerText = [biomarkerText, sprintf('\nValid correlations: %d/%d', length(validCorrs), length(correlationValues))];
        
        % Count by category (using all correlations, including zeros)
        respiratoryCount = sum(abs(correlationValues) < 0.2);
        weakCount = sum(abs(correlationValues) >= 0.2 & abs(correlationValues) < 0.5);
        strongCount = sum(abs(correlationValues) >= 0.5);
        
        biomarkerText = [biomarkerText, sprintf('\n\nRespiratory: %d conditions', respiratoryCount)];
        biomarkerText = [biomarkerText, sprintf('\nWeak Mimicry: %d conditions', weakCount)];
        biomarkerText = [biomarkerText, sprintf('\nStrong Mimicry: %d conditions', strongCount)];
        
        % Overall assessment
        if strongCount > weakCount && strongCount > respiratoryCount
            assessment = 'STRONG MIMICRY';
        elseif weakCount > respiratoryCount
            assessment = 'WEAK MIMICRY';
        else
            assessment = 'RESPIRATORY DOMINANT';
        end
        biomarkerText = [biomarkerText, sprintf('\n\nAssessment: %s', assessment)];
    else
        biomarkerText = [biomarkerText, sprintf('\n\nNo valid correlations calculated')];
    end
    
    try
        text(0.05, 0.95, biomarkerText, 'Units', 'normalized', 'VerticalAlignment', 'top', ...
            'FontSize', 9, 'FontName', 'Courier', 'BackgroundColor', 'white', ...
            'Interpreter', 'none'); % FIXED: Added 'Interpreter', 'none'
    catch ME
        disp(['Text rendering error in panel 12: ', ME.message]);
    end
end

% FIXED: Clean participant name for title (remove special characters)
cleanParticipant = regexprep(participant, '[^a-zA-Z0-9]', '_');

try
    % SIMPLE title approach - just add some space
    sgtitle(['Mimicry Analysis - ' cleanParticipant], 'FontSize', 16, 'Interpreter', 'none');
catch ME
    disp(['Title setting error: ', ME.message]);
end

% DUAL SAVE: Both PNG and SVG formats
baseName = ['Condition_Analysis_', cleanParticipant];
pngName = fullfile(outputDir, [baseName, '.png']);
svgName = fullfile(outputDir, [baseName, '.svg']);

try
    % Set figure properties before saving
    set(gcf, 'PaperPositionMode', 'auto');
    set(gcf, 'InvertHardcopy', 'off');
    set(gcf, 'Color', 'white');
    
    % Save PNG (high resolution raster)
    print(gcf, pngName, '-dpng', '-r300');
    disp(['PNG saved: ', pngName]);
    
    % Save SVG (vector format)
    print(gcf, svgName, '-dsvg', '-r300');
    disp(['SVG saved: ', svgName]);
    
catch ME
    disp(['Save error: ', ME.message]);
    try
        % Fallback save methods
        saveas(gcf, pngName, 'png');
        saveas(gcf, svgName, 'svg');
        disp(['Fallback saves successful']);
    catch ME2
        disp(['Fallback saves also failed: ', ME2.message]);
    end
end

close(gcf);

disp(['Enhanced condition analysis completed for participant: ', participant]);
end
function cleanupLegend(axesHandle, maxEntries)
% Clean up legend to avoid too many entries warning
% axesHandle: handle to the axes (default: gca)
% maxEntries: maximum number of legend entries (default: 8)

if nargin < 1 || isempty(axesHandle)
    axesHandle = gca;
end

if nargin < 2 || isempty(maxEntries)
    maxEntries = 8;
end

try
    % Get all line objects with DisplayName
    allLines = findobj(axesHandle, 'Type', 'line', '-not', 'DisplayName', '');
    allScatter = findobj(axesHandle, 'Type', 'scatter', '-not', 'DisplayName', '');
    allBars = findobj(axesHandle, 'Type', 'bar', '-not', 'DisplayName', '');
    allPatches = findobj(axesHandle, 'Type', 'patch', '-not', 'DisplayName', '');
    
    % Combine all objects
    allObjects = [allLines; allScatter; allBars; allPatches];
    
    if isempty(allObjects)
        return;
    end
    
    % Get unique DisplayNames
    displayNames = {};
    uniqueObjects = [];
    
    for i = 1:length(allObjects)
        objName = get(allObjects(i), 'DisplayName');
        if ~isempty(objName) && ~any(strcmp(displayNames, objName))
            displayNames{end+1} = objName;
            uniqueObjects(end+1) = allObjects(i);
        end
    end
    
    % Limit to maxEntries
    if length(uniqueObjects) > maxEntries
        uniqueObjects = uniqueObjects(1:maxEntries);
        displayNames = displayNames(1:maxEntries);
        warning('Legend limited to %d entries', maxEntries);
    end
    
    % Create legend with unique objects only
    if ~isempty(uniqueObjects)
        legend(uniqueObjects, displayNames, 'Location', 'best', 'FontSize', 8);
    end
    
catch ME
    % If legend creation fails, just skip it
    disp(['Legend cleanup failed: ', ME.message]);
end
end

%% ENHANCED LEGEND MANAGEMENT FOR MULTI-AXIS PLOTS
function cleanupDualAxisLegend(leftAxisHandle, rightAxisHandle)
% Special cleanup for plots with yyaxis (dual y-axes)

if nargin < 1
    leftAxisHandle = gca;
end

try
    % Switch to left axis
    yyaxis left;
    leftObjects = findobj(leftAxisHandle, 'Type', 'line', '-not', 'DisplayName', '');
    leftNames = {};
    for i = 1:length(leftObjects)
        name = get(leftObjects(i), 'DisplayName');
        if ~isempty(name)
            leftNames{end+1} = name;
        end
    end
    
    % Switch to right axis if it exists
    if nargin > 1 && ~isempty(rightAxisHandle)
        yyaxis right;
        rightObjects = findobj(rightAxisHandle, 'Type', 'line', '-not', 'DisplayName', '');
        rightNames = {};
        for i = 1:length(rightObjects)
            name = get(rightObjects(i), 'DisplayName');
            if ~isempty(name)
                rightNames{end+1} = [name, ' (R)'];
            end
        end
    else
        rightObjects = [];
        rightNames = {};
    end
    
    % Combine and create legend
    allObjects = [leftObjects; rightObjects];
    allNames = [leftNames, rightNames];
    
    % Limit entries
    maxEntries = 6;
    if length(allObjects) > maxEntries
        allObjects = allObjects(1:maxEntries);
        allNames = allNames(1:maxEntries);
    end
    
    if ~isempty(allObjects)
        % Return to left axis for legend
        yyaxis left;
        legend(allObjects, allNames, 'Location', 'best', 'FontSize', 8);
    end
    
catch ME
    disp(['Dual axis legend cleanup failed: ', ME.message]);
end
end

%% SIMPLIFIED LEGEND FUNCTION FOR PROBLEM PANELS
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
    disp(['Simple legend failed: ', ME.message]);
end
end
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
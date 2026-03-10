function pointIndices = findPointsInROI(points, roi)
    % Find which points fall within a specific anatomical ROI
    % ENHANCED with input validation
    
    pointIndices = [];
    
    if isempty(points) || size(points, 2) < 2
        return;
    end
    
    if length(roi) < 4
        warning('Invalid ROI format, expected [x, y, width, height]');
        return;
    end
    
    x = roi(1); y = roi(2); w = roi(3); h = roi(4);
    
    % Validate ROI
    if w <= 0 || h <= 0
        warning('Invalid ROI dimensions');
        return;
    end
    
    try
        withinX = points(:,1) >= x & points(:,1) <= (x + w);
        withinY = points(:,2) >= y & points(:,2) <= (y + h);
        
        pointIndices = find(withinX & withinY);
    catch ME
        warning(['Error in findPointsInROI: ', ME.message]);
        pointIndices = [];
    end
end

%% 1. CREATE DENSE GRID FUNCTION
function gridPoints = createDenseGrid(roi, spacing)
% Create a dense grid of points within the ROI
% roi: [x, y, width, height]
% spacing: distance between grid points

x = roi(1);
y = roi(2);
width = roi(3);
height = roi(4);

% Create grid coordinates
[X, Y] = meshgrid(x:spacing:(x+width), y:spacing:(y+height));

% Convert to point list
gridPoints = [X(:), Y(:)];

% Remove points outside ROI bounds
validPoints = gridPoints(:,1) >= x & gridPoints(:,1) <= (x+width) & ...
              gridPoints(:,2) >= y & gridPoints(:,2) <= (y+height);
gridPoints = gridPoints(validPoints, :);

disp(['Created grid with ', num2str(size(gridPoints,1)), ' points']);
end

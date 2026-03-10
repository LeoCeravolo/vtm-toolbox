function concentrationScore = calculateConcentrationScore(displacements)
% Calculate how concentrated the movements are (higher = more localized)

if length(displacements) < 3
    concentrationScore = zeros(size(displacements));
    return;
end

% Method 1: Relative displacement (how much each point moves compared to others)
totalMovement = sum(displacements);
relativeMovement = displacements / (totalMovement + eps);

% Method 2: Local clustering (points moving together)
concentrationScore = zeros(size(displacements));
for i = 1:length(displacements)
    % Find nearby movements (simple version - in real implementation, 
    % you'd use spatial coordinates)
    localWindow = max(1, i-2):min(length(displacements), i+2);
    localMovements = displacements(localWindow);
    concentrationScore(i) = std(localMovements) / (mean(localMovements) + eps);
end

% Higher concentration score = more localized movement pattern
concentrationScore = 1 ./ (concentrationScore + eps);
end
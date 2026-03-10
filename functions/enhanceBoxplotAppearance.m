function enhanceBoxplotAppearance(h, conditionLabels)
% Enhance the visual appearance of boxplots
try
    % Set line widths
    set(h, 'LineWidth', 1.5);
    
    % Enhance median lines
    medianLines = findobj(gca, 'Tag', 'Median');
    set(medianLines, 'LineWidth', 2);
    
catch ME
    % Continue if enhancement fails
end
end

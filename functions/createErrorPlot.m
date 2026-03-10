function createErrorPlot(fig, ConditionName, errorMessage)
    % Create error plot when analysis completely fails
    
    clf(fig);
    text(0.5, 0.7, 'ML ANALYSIS ERROR', 'HorizontalAlignment', 'center', ...
        'FontSize', 20, 'FontWeight', 'bold', 'Color', 'red');
    text(0.5, 0.5, ['Condition: ', ConditionName], 'HorizontalAlignment', 'center', ...
        'FontSize', 14);
    text(0.5, 0.3, ['Error: ', errorMessage], 'HorizontalAlignment', 'center', ...
        'FontSize', 12, 'Color', 'red');
    
    xlim([0 1]); ylim([0 1]); axis off;
    title(['ML Analysis Failed: ', ConditionName], 'FontSize', 16, 'Color', 'red');
end

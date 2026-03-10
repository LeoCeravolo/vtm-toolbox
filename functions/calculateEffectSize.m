function effectSize = calculateEffectSize(accuracyVector, chanceLevel)
% Calculate Cohen's d effect size

try
    meanAccuracy = nanmean(accuracyVector);
    stdAccuracy = nanstd(accuracyVector);
    
    if stdAccuracy > 0
        effectSize = (meanAccuracy - chanceLevel) / stdAccuracy;
    else
        effectSize = 0;
    end
    
catch ME
    effectSize = 0;
end

end

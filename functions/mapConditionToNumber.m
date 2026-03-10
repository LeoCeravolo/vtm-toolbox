function num = mapConditionToNumber(condition)
    try
        conditionMap = containers.Map(...
            {'neutral', 'pleasure', 'happiness', 'anger', 'unknown'}, ...
            {1, 2, 3, 4, 0});
        
        if conditionMap.isKey(lower(condition))
            num = conditionMap(lower(condition));
        else
            num = 0; % Unknown condition
        end
    catch
        num = 0;
    end
end

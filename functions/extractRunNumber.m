function num = extractRunNumber(runName)
    try
        num = str2double(regexp(runName, '\d+', 'match', 'once'));
        if isempty(num), num = NaN; end
    catch
        num = NaN;
    end
end

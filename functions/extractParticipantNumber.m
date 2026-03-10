function num = extractParticipantNumber(participant)
    try
        num = str2double(regexp(participant, '\d+', 'match', 'once'));
        if isempty(num), num = NaN; end
    catch
        num = NaN;
    end
end

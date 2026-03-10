function str = convertAgeToString(age)
    try
        if isnumeric(age) && isfinite(age)
            str = num2str(age);
        elseif ischar(age) || isstring(age)
            str = char(age);
        else
            str = 'Unknown';
        end
    catch
        str = 'Unknown';
    end
end

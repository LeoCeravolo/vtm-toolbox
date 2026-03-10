function writeDataValue(fid, value, isString, addTab)
    % Helper function to write data values with proper formatting
    if addTab
        fprintf(fid, '\t');
    end
    
    if isString
        if ischar(value) || isstring(value)
            fprintf(fid, '%s', char(value));
        else
            fprintf(fid, '%s', 'Unknown');
        end
    else
        if isnumeric(value) && isfinite(value)
            fprintf(fid, '%.6f', value);
        else
            fprintf(fid, 'NaN');
        end
    end
end

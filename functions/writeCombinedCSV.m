function writeCombinedCSV(filename, headers, csvData)
% Write CSV file with headers and data

try
    fid = fopen(filename, 'w');
    
    % Write headers
    fprintf(fid, '%s', headers{1});
    for i = 2:length(headers)
        fprintf(fid, ',%s', headers{i});
    end
    fprintf(fid, '\n');
    
    % Write data rows
    for rowIdx = 1:length(csvData)
        rowData = csvData{rowIdx};
        
        % Write first column
        if ischar(rowData{1}) || isstring(rowData{1})
            fprintf(fid, '%s', rowData{1});
        else
            fprintf(fid, '%.6f', rowData{1});
        end
        
        % Write remaining columns
        for colIdx = 2:length(rowData)
            if ischar(rowData{colIdx}) || isstring(rowData{colIdx})
                fprintf(fid, ',%s', rowData{colIdx});
            elseif isnan(rowData{colIdx})
                fprintf(fid, ',NaN');
            else
                fprintf(fid, ',%.6f', rowData{colIdx});
            end
        end
        fprintf(fid, '\n');
    end
    
    fclose(fid);
    
catch ME
    disp(['CSV writing error: ', ME.message]);
    if exist('fid', 'var') && fid ~= -1
        fclose(fid);
    end
end
end

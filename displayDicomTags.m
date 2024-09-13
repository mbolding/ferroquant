function displayDicomTags(dicomFilePath)
    % If no file path is provided, open a file selection dialog
    if nargin < 1 || isempty(dicomFilePath)
        [filename, pathname] = uigetfile('*.dcm', 'Select a DICOM file');
        if isequal(filename, 0) || isequal(pathname, 0)
            error('User canceled file selection');
        end
        dicomFilePath = fullfile(pathname, filename);
    end

    % Read the DICOM metadata
    try
        info = dicominfo(dicomFilePath);
    catch
        error('Error reading DICOM file: %s', dicomFilePath);
    end

    % Get all field names
    fieldNames = fieldnames(info);

    % Display the tags
    fprintf('DICOM Tags for file: %s\n', dicomFilePath);
    fprintf('------------------------------\n');
    for i = 1:length(fieldNames)
        fieldName = fieldNames{i};
        fieldValue = info.(fieldName);
        
        % Convert the field value to a string for display
        if isnumeric(fieldValue)
            if numel(fieldValue) == 1
                fieldValueStr = num2str(fieldValue);
            else
                fieldValueStr = '[numeric array]';
            end
        elseif ischar(fieldValue)
            fieldValueStr = fieldValue;
        elseif iscell(fieldValue)
            fieldValueStr = '[cell array]';
        elseif isstruct(fieldValue)
            fieldValueStr = '[struct]';
        else
            fieldValueStr = class(fieldValue);
        end
        
        % Truncate long strings
        if length(fieldValueStr) > 50
            fieldValueStr = [fieldValueStr(1:47) '...'];
        end
        
        fprintf('%s: %s\n', fieldName, fieldValueStr);
    end
end
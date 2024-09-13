function [imageStack, info] = loadDicomStack(parentFolder)
    % If no parent folder is provided, open a folder selection dialog
    if nargin < 1 || isempty(parentFolder)
        parentFolder = uigetdir('Select the parent folder containing DICOM subfolders');
        if isequal(parentFolder, 0)
            error('User canceled folder selection');
        end
    end

    % Get a list of all subfolders
    subFolders = dir(parentFolder);
    subFolders = subFolders([subFolders.isdir]);
    subFolders = subFolders(~ismember({subFolders.name}, {'.', '..'}));

    if isempty(subFolders)
        error('No subfolders found in the selected directory');
    end

    % Initialize variables
    imageStack = [];
    info = [];

    % Loop through each subfolder
    for i = 1:length(subFolders)
        folderPath = fullfile(parentFolder, subFolders(i).name);
        disp(folderPath)
        
        % Find the DICOM file in the current subfolder
        dicomFile = dir(fullfile(folderPath, 'IM-*-0001.dcm'));
        
        if isempty(dicomFile)
            warning('No DICOM file found in folder: %s', folderPath);
            continue;
        end
        
        % Read the DICOM file
        filePath = fullfile(folderPath, dicomFile(1).name);
        try
            img = dicomread(filePath);
            if isempty(imageStack)
                imageStack = zeros([size(img), length(subFolders)], class(img));
            end
            imageStack(:,:,i) = img;
            
            % Store DICOM info for the first slice
            if isempty(info)
                info = dicominfo(filePath);
            end
        catch
            warning('Error reading DICOM file: %s', filePath);
        end
    end

    % Remove any empty slices (in case some folders didn't have valid DICOM files)
    imageStack = imageStack(:,:,any(any(imageStack, 1), 2));

    if isempty(imageStack)
        error('No valid DICOM images were loaded');
    end

    fprintf('Loaded %d slices into a 3D stack\n', size(imageStack, 3));
end
function analyzeROIAcrossStack(parentFolder)
    % Load the DICOM stack
    if nargin < 1 || isempty(parentFolder)
        [imageStack, ~] = loadDicomStack();
    else
        [imageStack, ~] = loadDicomStack(parentFolder);
    end
    
    % Display the top slice and let the user click the center for ROI
    figure('Name', 'Select ROI Center on Top Slice');
    imshow(imageStack(:,:,1), []);
    title('Click the center for ROI (20px radius)');
    [x, y] = ginput(1);
    
    % Create a circular mask with 20px radius
    [height, width, ~] = size(imageStack);
    [XX, YY] = meshgrid(1:width, 1:height);
    mask = (XX - x).^2 + (YY - y).^2 <= 20^2;
    
    % Display the ROI on the image
    hold on;
    viscircles([x, y], 20, 'Color', 'r', 'LineWidth', 1);
    hold off;
    
    % Calculate the average intensity within the ROI for each slice
    numSlices = size(imageStack, 3);
    avgIntensities = zeros(1, numSlices);
    
    for i = 1:numSlices
        slice = imageStack(:,:,i);
        roiPixels = slice(mask);
        avgIntensities(i) = mean(roiPixels);
    end
    
    % Plot the results
    figure('Name', 'ROI Average Intensity Across Slices');
    plot(1:numSlices, avgIntensities, '-o');
    xlabel('Slice Number');
    ylabel('Average Intensity in ROI');
    title('ROI Average Intensity Across Slices');
    grid on;
end

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
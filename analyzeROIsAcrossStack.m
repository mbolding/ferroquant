function analyzeROIsAcrossStack(parentFolder)
    % Load the DICOM stack
    if nargin < 1 || isempty(parentFolder)
        [imageStack, ~] = loadDicomStack();
    else
        [imageStack, ~] = loadDicomStack(parentFolder);
    end
    
    % Create Maximum Intensity Projection (MIP)
    mipImage = max(imageStack, [], 3);
    
    % Display the MIP and let the user click multiple centers for ROIs
    figure('Name', 'Select ROI Centers on MIP');
    imshow(mipImage, []);
    title('Click centers for ROIs (20px radius) on MIP. Press Enter when done.');
    hold on;
    
    [height, width, numSlices] = size(imageStack);
    [XX, YY] = meshgrid(1:width, 1:height);
    
    roiCenters = [];
    masks = {};
    colors = ['r', 'g', 'b', 'c', 'm', 'y'];  % Colors for different ROIs
    
    while true
        [x, y, button] = ginput(1);
        if isempty(button) || button ~= 1  % Check if Enter was pressed or non-left click
            break;
        end
        
        roiCenters = [roiCenters; x, y];
        mask = (XX - x).^2 + (YY - y).^2 <= 20^2;
        masks{end+1} = mask;
        
        colorIndex = mod(length(roiCenters) - 1, length(colors)) + 1;
        viscircles([x, y], 20, 'Color', colors(colorIndex), 'LineWidth', 1);
    end
    
    hold off;
    
    if isempty(roiCenters)
        error('No ROIs selected. Please run the function again and select at least one ROI.');
    end
    
    % Calculate the average intensity within each ROI for each slice
    numROIs = length(masks);
    avgIntensities = zeros(numSlices, numROIs);
    
    for i = 1:numSlices
        slice = imageStack(:,:,i);
        for j = 1:numROIs
            roiPixels = slice(masks{j});
            avgIntensities(i, j) = mean(roiPixels);
        end
    end
    
    % Plot the results
    figure('Name', 'ROI Average Intensities Across Slices');
    hold on;
    for j = 1:numROIs
        colorIndex = mod(j - 1, length(colors)) + 1;
        plot(1:numSlices, avgIntensities(:, j), '-o', 'Color', colors(colorIndex), 'DisplayName', sprintf('ROI %d', j));
    end
    hold off;
    
    xlabel('Slice Number');
    ylabel('Average Intensity in ROI');
    title('ROI Average Intensities Across Slices');
    legend('Location', 'best');
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
        disp(dicomFile(1).name)
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
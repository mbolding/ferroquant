function displayDicomMosaic(imageStack, rows, cols)
    % Check input parameters
    if nargin < 1
        error('imageStack is required');
    end
    if nargin < 2
        rows = [];
    end
    if nargin < 3
        cols = [];
    end

    % Get the number of slices
    numSlices = size(imageStack, 3);

    % If rows and cols are not specified, calculate them
    if isempty(rows) && isempty(cols)
        cols = ceil(sqrt(numSlices));
        rows = ceil(numSlices / cols);
    elseif isempty(rows)
        rows = ceil(numSlices / cols);
    elseif isempty(cols)
        cols = ceil(numSlices / rows);
    end

    % Ensure we have enough cells for all slices
    while rows * cols < numSlices
        cols = cols + 1;
    end

    % Create the mosaic
    mosaic = zeros(size(imageStack,1)*rows, size(imageStack,2)*cols, class(imageStack));

    % Fill the mosaic with slices
    for i = 1:numSlices
        row = ceil(i / cols);
        col = mod(i-1, cols) + 1;
        rowRange = (row-1)*size(imageStack,1) + 1 : row*size(imageStack,1);
        colRange = (col-1)*size(imageStack,2) + 1 : col*size(imageStack,2);
        mosaic(rowRange, colRange) = imageStack(:,:,i);
    end

    % Display the mosaic
    figure;
    imshow(mosaic, []);
    title(sprintf('DICOM Mosaic (%d slices)', numSlices));
    colorbar;

    % % Add slice numbers
    % for i = 1:numSlices
    %     row = ceil(i / cols);
    %     col = mod(i-1, cols) + 1;
    %     xCenter = (col-0.5) * size(imageStack,2);
    %     yCenter = (row-0.5) * size(imageStack,1);
    %     text(xCenter, yCenter, sprintf('%d', i), 'Color', 'white', ...
    %          'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    %          'FontWeight', 'bold', 'FontSize', 12);
    % end
end
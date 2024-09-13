function viewDicomImage(filename)
    % If no filename is provided, open a file selection dialog
    if nargin < 1 || isempty(filename)
        [file, path] = uigetfile({'*.dcm', 'DICOM Files (*.dcm)'; '*.*', 'All Files (*.*)'}, 'Select a DICOM file');
        if isequal(file, 0)
            disp('User canceled file selection');
            return;
        end
        filename = fullfile(path, file);
    end

    % Load the DICOM image
    try
        dicomImage = dicomread(filename);
    catch
        error('Error reading DICOM file. Please ensure it is a valid DICOM image.');
    end

    % Display the image
    figure;
    imshow(dicomImage, []);
    title('DICOM Image');

    % Add color bar
    colorbar;

    % Display DICOM header information
    info = dicominfo(filename);
    disp(info);
end
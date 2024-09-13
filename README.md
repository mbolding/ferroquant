mbolding: @workspace write a README.md for these files

Workspace: # DICOM Analysis Tools

This repository contains MATLAB scripts for analyzing and visualizing DICOM image stacks. The primary functionality includes loading DICOM images, selecting regions of interest (ROIs), and plotting average intensities across different inversion times.


### Main Scripts

- **`analyzeROIsAcrossStackTI.m`**: This script allows users to load a DICOM stack, select multiple ROIs on a Maximum Intensity Projection (MIP) image, and plot the average intensities within each ROI across different inversion times.
- **`displayDicomMosaic.m`**: Displays a mosaic of DICOM images from a specified folder.
- **`displayDicomTags.m`**: Displays DICOM tags for a given DICOM file.
- **`loadDicomStack.m`**: Loads a stack of DICOM images from a specified folder.
- **`viewDicomImage.m`**: Displays a single DICOM image.

### DICOM Folders

The folders `se_ir0050ms_stanford_4/` to `se_ir2500ms_stanford_14/` contain DICOM images with different inversion times.

## Usage

1. **Load and Analyze DICOM Stack**:
   - Run the `analyzeROIsAcrossStackTI.m` script to load a DICOM stack, select ROIs, and plot average intensities.
   - Example:
     ```matlab
     analyzeROIsAcrossStackTI('path/to/dicom/folder');
     ```

2. **Display DICOM Mosaic**:
   - Run the `displayDicomMosaic.m` script to display a mosaic of DICOM images.
   - Example:
     ```matlab
     displayDicomMosaic('path/to/dicom/folder');
     ```

3. **Display DICOM Tags**:
   - Run the `displayDicomTags.m` script to display DICOM tags for a given file.
   - Example:
     ```matlab
     displayDicomTags('path/to/dicom/file.dcm');
     ```

4. **View Single DICOM Image**:
   - Run the `viewDicomImage.m` script to view a single DICOM image.
   - Example:
     ```matlab
     viewDicomImage('path/to/dicom/file.dcm');
     ```

## Dependencies

- MATLAB
- Image Processing Toolbox

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Acknowledgments

Special thanks to the contributors and the MATLAB community for their support and resources.

---

For any issues or contributions, please open an issue or submit a pull request on the repository.
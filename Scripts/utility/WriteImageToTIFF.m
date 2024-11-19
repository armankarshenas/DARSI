function [] = WriteImageToTIFF(seq_read, Path_to_save, gene, RNA_label, name)
% WriteImageToTIFF saves a one-hot encoded DNA sequence as a binary TIFF image.
%
% This function creates a directory structure based on the provided gene 
% and RNA label, and then saves the one-hot encoded sequence as a 32-bit 
% binary TIFF file in the specified location.
%
% Inputs:
%   - seq_read: A 3D binary matrix representing the one-hot encoded sequence.
%               Typically output from `OneHotEncoder`.
%   - Path_to_save: String specifying the root directory where the image will be saved.
%   - gene: String representing the gene name. Used as a folder name.
%   - RNA_label: Numeric or string label associated with RNA expression. Used as a subfolder.
%   - name: String specifying the file name (without extension) for the saved image.
%
% Output:
%   - None. The function writes the TIFF image to disk.
%
% Example Usage:
%   WriteImageToTIFF(seq_read, '/path/to/save', 'GeneX', 'High', 'SeqImage1');
%   % This will create the directory structure:
%   % /path/to/save/GeneX/High/SeqImage1.tif
%
% Notes:
%   - If the directories for `gene` or `RNA_label` do not exist, they are created.
%   - The saved TIFF image uses 32-bit floating-point representation.
%
% Written by A. Karshenas -- Nov, 2024
%--------------------------------------------------------------------------

% Change to the specified save path
cd(Path_to_save);

% Ensure the sequence data is in single precision
seq_read = single(seq_read);

% Check if the directory for the gene exists; create it if necessary
if exist(gene, 'dir') == 7
    cd(gene);
else
    mkdir(gene);
    cd(gene);
end

% Check if the directory for the RNA label exists; create it if necessary
if exist(string(RNA_label), 'dir') == 7
    cd(string(RNA_label));
else
    mkdir(string(RNA_label));
    cd(string(RNA_label));
end

% Construct the full file name for the TIFF file
fileName = name + ".tif";

% Create a TIFF object and set its tags
tiffObject = Tiff(fileName, 'w');

% Set TIFF image properties
tagstruct.ImageLength = size(seq_read, 1);  % Number of rows
tagstruct.ImageWidth = size(seq_read, 2);   % Number of columns
tagstruct.Compression = Tiff.Compression.None;  % No compression
tagstruct.SampleFormat = Tiff.SampleFormat.IEEEFP;  % Floating-point format
tagstruct.Photometric = Tiff.Photometric.MinIsBlack;  % Black represents minimum intensity
tagstruct.BitsPerSample = 32;  % Each sample is 32 bits
tagstruct.SamplesPerPixel = size(seq_read, 3);  % Number of samples per pixel (e.g., 4 for RGB+Alpha)
tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;  % Data is stored in chunky format

% Apply the tags to the TIFF object
tiffObject.setTag(tagstruct);

% Write the one-hot encoded sequence to the TIFF file
tiffObject.write(seq_read);

% Close the TIFF object
tiffObject.close;

end

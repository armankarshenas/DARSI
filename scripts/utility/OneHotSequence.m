function [] = OneHotSequence(Path_to_data, Path_to_save)
% OneHotSequence processes DNA sequences and generates one-hot encoded matrices.
%
% This function reads DNA sequences from FASTA (.fa) files and associated
% metadata from text (.txt) files located in the specified input directory.
% For each sequence, it creates a one-hot encoded matrix, saves it as a 
% .tiff image, and organizes the output into subdirectories. A .mat file 
% containing the one-hot encoded data is also saved for each FASTA file.
%
% Inputs:
%   - Path_to_data: String, path to the directory containing .fa and .txt files.
%   - Path_to_save: String, path to the directory where processed files will be saved.
%
% Outputs:
%   - None (processed files are saved to disk).
%
% Example Usage:
%   OneHotSequence('/path/to/input', '/path/to/output');
%
% Notes:
%   - Each .fa file must have a corresponding .txt file with the same prefix.
%   - The .txt file must contain columns for 'gene', 'label_RNA_DNA', and 'Header'.
%   - The output directory will be structured with subdirectories for each file set.
%
% Written by A. Karshenas -- Nov, 2024
%--------------------------------------------------------------------------

%% Step 1: Navigate to the input data directory and load files
cd(Path_to_data);
TXT_files = dir(fullfile(pwd, "*.txt")); % Locate all .txt files
FST_files = dir(fullfile(pwd, "*.fa"));  % Locate all .fa files

% Check if the number of .fa and .txt files match
if length(FST_files) ~= length(TXT_files)
    error('The number of .fa files must match the number of .txt files.');
end

% Process each .fa and .txt file pair
for i = 1:length(FST_files)
    fprintf("Processing %s ... \n", FST_files(i).name);
    
    % Initialize storage structure
    OneHot = struct();
    
    % Read FASTA file and metadata table
    fst = fastaread(fullfile(FST_files(i).folder, FST_files(i).name));
    tb = readtable(fullfile(TXT_files(i).folder, TXT_files(i).name));
    
    % Create a subdirectory for the current dataset
    path_name = split(FST_files(i).name, "_");
    path_name = path_name{1};
    mkdir(fullfile(Path_to_save, path_name));
    cd(fullfile(Path_to_save, path_name)); % Navigate to the new subdirectory
    
    % Step 2: Process each sequence and save results
    for j = 1:height(tb)
        % One-hot encode the DNA sequence
        seq_read = OneHotEncoder(fst(j).Sequence);
        
        % Save the one-hot encoded matrix as a .tiff image
        WriteImageToTIFF(seq_read, fullfile(Path_to_save, path_name), ...
            string(tb.gene{j}), tb.label_RNA_DNA(j), string(tb.Header{j}));
        
        % Store the encoded data in a structure
        OneHot(j).data = seq_read;
        OneHot(j).index = fst(j).Header;
        OneHot(j).RNA_label = tb.label_RNA_DNA(j);
        
        % Display progress
        waitbar(j / height(tb), [], sprintf('Processing %d/%d sequences', j, height(tb)));
    end
    
    % Step 3: Save the processed data as a .mat file
    cd(Path_to_data); % Return to input directory
    name = split(FST_files(i).name, ".fa");
    name = name{1} + ".mat";
    save(name, 'OneHot', '-v7.3');
end
end

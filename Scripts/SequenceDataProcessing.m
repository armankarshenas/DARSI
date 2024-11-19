% SequenceDataProcessing
% This function reads a CSV, txt, or Excel file containing sequence data, processes
% the sequences by reshaping them into images, labels the dataset based on
% gene expression levels, and saves the results into specified directories.
% It also generates training, testing, and validation datasets and
% exports the sequences and labels accordingly.

% Inputs:
% - Path_to_data: Path to the CSV, txt or Excel file containing the data (mandatory input).
% - Path_to_save: (Optional) Path to the folder where processed results will be saved (default: current directory).
% - Path_to_save_histograms: (Optional) Path for saving histograms (default: current directory).
% - Path_to_save_imgs: (Optional) Path for saving images (default: current directory).
% - max_iteration_for_binning: (Optional) Maximum iterations for binning (default: 1e4).
% - train_f: (Optional) Fraction of data for training (default: 0.7).
% - test_f: (Optional) Fraction of data for testing (default: 0.15).

% Written by A. Karshenas -- Nov, 2024
%----------------------------------------------------

function sequenceDataProcessing(Path_to_data, Path_to_save, Path_to_save_histograms, Path_to_save_imgs, max_iteration_for_binning, train_f, test_f)

    
    % Check if Path_to_data is provided
    if nargin < 1 || isempty(Path_to_data)
        error('Path_to_data is a mandatory input and must point to a CSV or Excel file.');
    end

    % Set default paths if not provided
    if nargin < 2 || isempty(Path_to_save)
        Path_to_save = fullfile(pwd);  % Default: current directory 
    end
    if nargin < 3 || isempty(Path_to_save_histograms)
        Path_to_save_histograms = fullfile(pwd, 'DARSI','histograms');
    end
    if nargin < 4 || isempty(Path_to_save_imgs)
        Path_to_save_imgs = fullfile(pwd, 'DARSI', 'imgs');
    end
    if nargin < 5 || isempty(max_iteration_for_binning)
        max_iteration_for_binning = 1e4;  % Default: 1e4 iterations for binning
    end
    if nargin < 6 || isempty(train_f)
        train_f = 0.7;  % Default: 70% of data for training
    end
    if nargin < 7 || isempty(test_f)
        test_f = 0.15;  % Default: 15% of data for testing
    end
    
    % Create directories if they don't exist
    if ~exist(Path_to_save_histograms, 'dir')
        mkdir(Path_to_save_histograms);
    end
    if ~exist(Path_to_save_imgs, 'dir')
        mkdir(Path_to_save_imgs);
    end
    
   % Add all scripts from the current repository (including subdirectories)
    currentScriptDir = fileparts(mfilename('fullpath'));
    addpath(genpath(currentScriptDir));
    %% Main processing body
    % Check the file extension (CSV, txt or Excel)
    [~,~,ext] = fileparts(Path_to_data);
    if strcmp(ext, '.csv')
        % Load the CSV file
        sequences = readtable(Path_to_data);
    elseif strcmp(ext, '.xls') || strcmp(ext, '.xlsx')
        % Load the Excel file
        sequences = readtable(Path_to_data);
    elseif strcmp(ext, ".txt")
        % Load the txt file 
        sequences = readtable(Path_to_data);
    else
        error('The provided file must be a CSV or Excel file.');
    end

    % Load the dataset and clean up the columns
    fprintf("Showing a preview of the data...\n");
    head(sequences);

    % Clean sequence data (remove last 20 bases for barcode)
    sequences.Properties.VariableNames{'seq'} = 'sequence';
    sequences.sequence = cellfun(@(x) x(1:end-20), sequences.sequence, 'UniformOutput', false);
    sequences.barcode = cellfun(@(x) x(end-19:end), sequences.sequence, 'UniformOutput', false);


    % Filter sequences based on operon size (more than 1000 variants)
    summaryTable = groupsummary(sequences, 'gene', 'IncludeEmptyGroups', true);
    writetable(summaryTable, "summaryTable.txt");
    genesAboveThreshold = summaryTable.gene(summaryTable.GroupCount > 1000);
    sequences = sequences(ismember(sequences.gene, genesAboveThreshold), :);
    
    % Generate a header combining gene and barcode info
    header = string(sequences.gene(:)) + "_" + cell2mat(sequences.barcode(1:height(sequences)));
    sequences{:, width(sequences) + 1} = header;
    sequences.Properties.VariableNames{'Var7'} = 'Header';
    sequences(any(ismissing(sequences), 2), :) = [];

    % Label the dataset
    [bin_count, sequences] = RNA_DNASeqLabel(sequences, max_iteration_for_binning, Path_to_save_histograms);
    writetable(bin_count, 'bin_count.txt');

    % Partition the dataset into training, testing, and validation sets
    [tb_test, tb_train, tb_val] = PartitionDataSet(train_f, test_f, sequences);
    
    cd(Path_to_save);  % Change to the directory where results will be saved
    
    % Save training data
    fastawrite("Train_sequences.fa", string(tb_train.Header(:)), string(tb_train.sequence(:)));
    writetable(tb_train, "Train_activity.txt");
    Train_label = table2array(tb_train(:, width(tb_train)));
    save("Train_label.mat", 'Train_label');
    
    % Save testing data
    fastawrite("Test_sequences.fa", string(tb_test.Header(:)), string(tb_test.sequence(:)));
    writetable(tb_test, "Test_activity.txt");
    Test_label = table2array(tb_test(:, width(tb_train)));
    save("Test_label.mat", 'Test_label');
    
    % Save validation data
    fastawrite("Valid_sequences.fa", string(tb_val.Header(:)), string(tb_val.sequence(:)));
    writetable(tb_val, "Valid_activity.txt");
    Valid_label = table2array(tb_val(:, width(tb_val)));
    save("Valid_label.mat", 'Valid_label');
    
    % Generate images for OneHotEncoding
    OneHotSequence(Path_to_save, Path_to_save_imgs);
    
    fprintf('Data processing complete. Results saved to %s\n', Path_to_save);
    
end
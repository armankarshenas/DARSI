function [tb_test, tb_train, tb_valid] = PartitionDataSet(frac_train, frac_test, dataset)
% PartitionDataSet partitions a given dataset into training, testing, and
% validation subsets after shuffling the data randomly.
%
% Inputs:
%   - frac_train: Proportion of the dataset to be used for training (e.g., 0.7).
%   - frac_test: Proportion of the dataset to be used for testing (e.g., 0.2).
%   - dataset: A table or matrix containing the dataset to be partitioned.
%
% Outputs:
%   - tb_train: Subset of the dataset for training.
%   - tb_test: Subset of the dataset for testing.
%   - tb_valid: Subset of the dataset for validation (remaining portion).
%
% Description:
%   This function randomizes the order of rows in the input dataset before
%   dividing it into training, testing, and validation subsets based on
%   the specified proportions.
%
% Example Usage:
%   [train_set, test_set, valid_set] = PartitionDataSet(0.7, 0.2, my_dataset);
%
% Notes:
%   - The sum of `frac_train` and `frac_test` should not exceed 1.
%   - The remaining proportion (1 - frac_train - frac_test) is allocated to validation.
%
% Written by A. Karshenas -- Nov, 2024
%--------------------------------------------------------------------------

% Step 1: Shuffle the dataset
index = randperm(size(dataset, 1)); % Generate random permutation of row indices
dataset = dataset(index, :);       % Reorder rows of the dataset randomly

% Step 2: Compute partition indices
train_idx = floor(size(dataset, 1) * frac_train); % Number of rows for training
test_idx = floor(size(dataset, 1) * frac_test);   % Number of rows for testing

% Step 3: Split the dataset into train, test, and validation subsets
tb_train = dataset(1:train_idx, :);                               % Training subset
tb_test = dataset(train_idx + 1:train_idx + test_idx, :);         % Testing subset
tb_valid = dataset(train_idx + test_idx + 1:end, :);             % Validation subset

end

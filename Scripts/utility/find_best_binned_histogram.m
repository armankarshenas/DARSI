function [optimal_M, bin_labels] = find_best_binned_histogram(data, max_iteration, Path_to_save_histograms, name)
% find_best_binned_histogram determines the optimal number of bins (M) for
% binning a given dataset and assigns data to bins.
%
% Inputs:
%   - data: A numeric vector representing the data to be binned.
%   - max_iteration: Maximum number of random binning iterations for optimization.
%   - Path_to_save_histograms: Path where the histogram plot should be saved.
%   - name: A string representing the name of the dataset (used for saving the plot).
%
% Outputs:
%   - optimal_M: The optimal number of bins based on statistical fit.
%   - bin_labels: A numeric vector indicating the bin assignment for each data point.
%
% Written by A. Karshenas -- Nov, 2024
%--------------------------------------------------------------------------

    % Define the range for the number of bins
    min_bins = 3;
    max_bins = 9;
    
    % Initialize variables to track the best configuration
    best_p_sum = inf; % Lowest sum of p-values
    optimal_M = min_bins; % Optimal number of bins
    best_bins = []; % Store bin edges for the optimal configuration
    bin_labels = zeros(size(data)); % Initialize bin labels
    
    % Iterate through possible numbers of bins (M)
    for M = min_bins:max_bins
        % Determine bins and p-values for the current M
        [bins, p_values] = find_optimal_bins(data, M, max_iteration);
        
        % Calculate the sum of p-values (measure of fit)
        p_sum = sum(p_values);
        
        % Update the best configuration if the current p_sum is lower
        if p_sum < best_p_sum
            best_p_sum = p_sum;
            optimal_M = M;
            best_bins = bins;
        end
    end

    % Assign data points to bins based on the best bin configuration
    bin_labels = categorize_data(data, best_bins);

    % Plot and save the histogram for the best binning configuration
    cd(Path_to_save_histograms);
    name = name + "_expression_distribution.png";
    plot_binned_histogram(best_bins); % Generate the histogram plot
    saveas(gcf, name); % Save the plot as a .png file
    close(gcf); % Close the figure to free resources

    % Display the optimal number of bins
    fprintf('Optimal number of bins (M): %d\n', optimal_M);

end

%% Helper Functions

%--------------------------------------------------------------------------
function [best_bins, best_p_values] = find_optimal_bins(data, M, max_iteration)
% find_optimal_bins identifies the best bin configuration for a given
% number of bins (M) using statistical testing.
%
% Inputs:
%   - data: Numeric vector to be binned.
%   - M: Number of bins to divide the data into.
%   - max_iteration: Number of random binning iterations.
%
% Outputs:
%   - best_bins: Cell array containing data points for each bin.
%   - best_p_values: Vector of p-values from statistical tests between bins.

    % Initialize variables
    best_bins = cell(1, M); % Store best bins configuration
    best_p_values = inf * ones(1, M - 1); % Initialize with high p-values
    
    % Perform random binning for the specified number of iterations
    for iter = 1:max_iteration
        % Generate random thresholds for bin edges
        thresholds = sort(rand(1, M - 1) * (max(data) - min(data)) + min(data));
        
        % Bin the data based on thresholds
        bins = cell(1, M);
        bins{1} = data(data <= thresholds(1));
        for j = 2:M - 1
            bins{j} = data(data > thresholds(j - 1) & data <= thresholds(j));
        end
        bins{M} = data(data > thresholds(M - 1));
        
        % Perform statistical tests (two-sample t-tests) between adjacent bins
        p_values = zeros(1, M - 1);
        for j = 1:M - 1
            [~, p_values(j)] = ttest2(bins{j}, bins{j + 1});
        end
        
        % Update the best configuration if the current p-values sum is lower
        if sum(p_values) < sum(best_p_values)
            best_p_values = p_values;
            best_bins = bins;
        end
    end
end

%--------------------------------------------------------------------------
function bin_labels = categorize_data(data, best_bins)
% categorize_data assigns each data point to its corresponding bin.
%
% Inputs:
%   - data: Numeric vector to be binned.
%   - best_bins: Cell array containing the best bin configuration.
%
% Outputs:
%   - bin_labels: Numeric vector of bin indices for each data point.

    bin_labels = zeros(size(data)); % Initialize bin labels
    for i = 1:length(best_bins)
        bin_labels(ismember(data, best_bins{i})) = i; % Assign bin index
    end
end

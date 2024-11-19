function [optimal_M, bin_labels] = find_best_binned_histogram(data,max_iteration,Path_to_save_histograms,name)
    % Range for the number of bins
    min_bins = 3;
    max_bins = 9;
    
    % Initialize variables to store optimal results
    best_p_sum = inf;
    optimal_M = min_bins;
    best_bins = [];
    bin_labels = zeros(size(data));
    % Iterate through different values of M (number of bins)
    for M = min_bins:max_bins
        % Find bins and p-values for current M
        [bins, p_values] = find_optimal_bins(data, M,max_iteration);
        
        % Calculate the sum of p-values as a measure of fit
        p_sum = sum(p_values);
        
        % If the current configuration is better (lower p-values sum), update best
        if p_sum < best_p_sum
            best_p_sum = p_sum;
            optimal_M = M;
            best_bins = bins;
        end
    end
    % Generate bin_labels based onbest_bins 
    bin_labels = categorize_data(data,best_bins);

    % Plot histogram of the best bins configuration
    cd(Path_to_save_histograms)
    name = name +"_expression_distribution.png";
    plot_binned_histogram(best_bins);
    saveas(gcf,name);
    close(gcf);

    % Display optimal number of bins
    fprintf('Optimal number of bins (M): %d\n', optimal_M);
end

% Helper functions
function [best_bins, best_p_values] = find_optimal_bins(data, M,max_iteration)
    % Initialize variables to store best bins and lowest p-values
    best_bins = cell(1, M);
    best_p_values = inf * ones(1, M - 1); % Start with high p-values
    
    % Number of random binning iterations
    num_iterations = max_iteration;
    for iter = 1:num_iterations
        % Generate random thresholds for bin edges
        thresholds = sort(rand(1, M - 1) * (max(data) - min(data)) + min(data));
        
        % Bin data based on thresholds
        bins = cell(1, M);
        bins{1} = data(data <= thresholds(1));
        for j = 2:M - 1
            bins{j} = data(data > thresholds(j - 1) & data <= thresholds(j));
        end
        bins{M} = data(data > thresholds(M - 1));
        
        % Calculate mean of each bin and perform statistical test
        p_values = zeros(1, M - 1);
        for j = 1:M - 1
            [~, p_values(j)] = ttest2(bins{j}, bins{j + 1}); % Two-sample t-test
        end
        
        % Check if this set of p-values is lower than previously recorded
        if sum(p_values) < sum(best_p_values)
            best_p_values = p_values;
            best_bins = bins;
        end
    end
end
function bin_labels = categorize_data(data,best_bins)
bin_labels = zeros(size(data));
for i=1:length(best_bins)
    bin_labels(ismember(data,best_bins{i})) = i;
end
end


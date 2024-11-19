function plot_binned_histogram(best_bins)
% plot_binned_histogram creates a histogram to visualize data grouped
% into bins based on the optimal binning configuration.
%
% Inputs:
%   - best_bins: Cell array where each cell contains the data points for a
%     specific bin.
%
% Description:
%   This function generates a histogram where each bin is represented with
%   a unique color, allowing for a clear visualization of the data
%   distribution within each bin.
%
% Written by A. Karshenas -- Nov, 2024
%--------------------------------------------------------------------------

    % Define distinct colors for each bin
    colors = lines(length(best_bins)); % Generate a colormap
    
    % Create a new figure for the histogram
    figure;
    hold on;
    
    % Plot each bin as a separate histogram
    for i = 1:length(best_bins)
        histogram(best_bins{i}, ...
                  'FaceColor', colors(i, :), ... % Assign unique color
                  'EdgeColor', 'none', ...       % No edge color for cleaner look
                  'DisplayName', sprintf('Bin %d', i)); % Label for legend
    end
    
    % Add labels and title to the plot
    xlabel('Expression Value'); % X-axis label
    ylabel('Frequency');        % Y-axis label
    title('Histogram of Data by Optimal Binned Groups'); % Plot title
    
    % Add legend to identify bins
    legend show;
    
    % Release the hold on the current figure
    hold off;

end

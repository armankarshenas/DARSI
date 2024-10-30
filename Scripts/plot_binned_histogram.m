function plot_binned_histogram(best_bins)
    % Define colors for each bin
    colors = lines(length(best_bins));
    
    % Create histogram plot
    figure;
    hold on;
    
    % Plot each bin
    for i = 1:length(best_bins)
        histogram(best_bins{i}, 'FaceColor', colors(i, :), 'EdgeColor', 'none', 'DisplayName', sprintf('Bin %d', i));
    end
    
    % Set plot labels and title
    xlabel('Expression Value');
    ylabel('Frequency');
    title('Histogram of Data by Optimal Binned Groups');
    legend show;
    hold off;
end

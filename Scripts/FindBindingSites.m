function findBindingSites(Path_to_data, Path_to_save)
    % find_binding_sites processes saliency maps to generate expression shift
    % and identifies statistically significant peaks. It saves the resulting 
    % plots in the specified directory.
    %
    % Inputs:
    %   Path_to_data   - Path to the directory containing the gene subfolders with FinalSaliencyMap.mat files.
    %   Path_to_save    - Path to the directory where the resulting plots will be saved.
    %
    % Written by A. Karshenas -- Nov, 2024
    %----------------------------------------------------
    
    % Add all scripts from the current repository (including subdirectories)
    currentScriptDir = fileparts(mfilename('fullpath'));
    addpath(genpath(currentScriptDir));
    
    % Change directory to the Path_to_data
    cd(Path_to_data);
    
    % Get list of genes (subdirectories)
    genes = dir(pwd);
    
    % Loop through each gene
    for i = 5:length(genes)
        waitbar(i / length(genes));
        
        % Only process directories (genes)
        if genes(i).isdir == 1
            % Change directory to the current gene folder
            cd(Path_to_data);
            cd(genes(i).name);
            
            % Load the FinalSaliencyMap.mat file
            load("FinalSaliencyMap.mat", "Final_saliency_map");
            A = Final_saliency_map;
            
            % Normalize the data
            b = max(A);
            normalized_b = (b - mean(b)) / std(b);
            
            % Plot the unfiltered shift
            fig_1 = bar(normalized_b);
            cd(Path_to_save);
            name = genes(i).name;
            save_figure(fig_1, name, 'unfiltered_shift');
            
            % Compute the exponential of the absolute normalized values with a moving average filter
            exp_b = movmean(exp(abs(normalized_b)), 5);
            
            % Separate positive and negative values for plotting
            idx_pos = normalized_b >= 0;
            idx_neg = normalized_b < 0;
            exp_b_pos = exp_b .* double(idx_pos);
            exp_b_neg = exp_b .* double(idx_neg);
            
            % Combine positive and negative components for plotting
            exp_plot = [exp_b_pos' exp_b_neg'];
            fig_1 = bar(exp_plot);
            save_figure(fig_1, name, 'exp_shift');
            
            % Apply a threshold to filter the data
            threshold_bs = mean(exp_b) + std(exp_b);
            idx = exp_b >= threshold_bs;
            filtered_b = double(idx) .* exp_b;
            
            % Plot and save the filtered shift
            fig_1 = bar(filtered_b);
            save_figure(fig_1, name, 'filtered_shift');
        end
    end
end

function save_figure(fig_1, name, suffix)
    % save_figure saves the figure in multiple formats
    name_to_write_fig = sprintf('%s_%s.fig', name, suffix);
    name_to_write_eps = sprintf('%s_%s.eps', name, suffix);
    name_to_write_png = sprintf('%s_%s.png', name, suffix);
    
    saveas(fig_1, name_to_write_fig);
    saveas(fig_1, name_to_write_eps);
    saveas(fig_1, name_to_write_png);
    close(fig_1);
end

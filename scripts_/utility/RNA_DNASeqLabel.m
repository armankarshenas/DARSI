function [bin_count, tb_output] = RNA_DNASeqLabel(tb_input, max_iteration, Path_to_save_histograms)
% RNA_DNASeqLabel Bins RNA count data based on the log-transformed RNA/DNA ratio 
% and labels each RNA count to a discrete bin. The function returns a table 
% of sequences along with their corresponding RNA count bin.
%
% This function processes input data, calculates the RNA/DNA ratio, and 
% creates bins based on the distribution of the RNA/DNA ratio for each gene. 
% It also saves histograms for each gene's RNA/DNA ratio distribution in 
% the specified path. The bins are then labeled and added to the input table.
%
% INPUTS:
%   - tb_input: A table containing the data with at least the following columns:
%               'gene', 'ct_RNA', and 'ct_DNA' (RNA and DNA counts for each sequence).
%   - max_iteration: Maximum number of iterations for histogram binning.
%   - Path_to_save_histograms: Path to the directory where histograms will be saved.
%
% OUTPUTS:
%   - bin_count: A table containing the optimal binning information for each gene,
%                 including the gene name and the optimal bin count.
%   - tb_output: The input table (tb_input) with an additional column 
%                ('label_RNA_DNA') indicating the bin label for each RNA count.
%
% Written by A. Karshenas -- Nov, 2024
%----------------------------------------------------

%% Initialize the bin count table and other variables
% Initialize an empty table to store bin count information.
bin_count = table('Size', [0, 2], 'VariableTypes', {'string', 'double'}, ...
    'VariableNames', {'gene', 'M_optimal'});

% Copy input table to work with
tb = tb_input;

% Calculate the RNA/DNA ratio in log scale and store it in a new column 'ctr'.
tb.ctr = log(tb.ct_RNA ./ tb.ct_DNA);

% Initialize a label column for RNA/DNA bin labels (initialized to zero).
label_RNA_DNA = zeros(height(tb), 1);

% Add the label column to the table and set its name to 'label_RNA_DNA'.
tb{:, width(tb) + 1} = label_RNA_DNA;
tb.Properties.VariableNames{width(tb)} = 'label_RNA_DNA';

% Get a list of unique gene names from the table.
genes = unique(string(tb.gene));

% Create a waitbar to track the progress of binning each gene's data.
hWaitbar = waitbar(0, 'Binning expression shifts');

%% Loop through each gene and process its data
for gene = 1:length(genes)
    % Extract the RNA/DNA ratio data for the current gene
    data = table2array(tb(string(tb.gene) == genes(gene), 'ctr'));
    
    % Handle any infinite values in the data by replacing them with a large negative value
    data(isinf(data)) = -10;
    
    % Call the helper function to find the optimal binning and corresponding labels for the gene.
    [M_optimal, label_RNA_DNA] = find_best_binned_histogram(data, max_iteration, ...
        Path_to_save_histograms, genes(gene));
    
    % Store the optimal bin count for the gene in the bin_count table.
    bin_count.gene(gene) = genes(gene);
    bin_count.M_optimal(gene) = M_optimal;
    
    % Update the progress in the waitbar.
    waitbar(gene / length(genes), hWaitbar, sprintf('Processing... %d%%', round(gene / length(genes) * 100)));
    
    % Assign the calculated bin labels to the input table.
    tb(string(tb.gene) == genes(gene), 'label_RNA_DNA') = table(categorical(label_RNA_DNA));
end

% Close the waitbar once processing is complete.
close(hWaitbar);

% Return the modified table with labels and bin counts.
tb_output = tb;

end

function [bin_count,tb_output] = RNA_DNASeqLabel(tb_input,max_iteration,Path_to_save_histograms)
% RNA_DNASeqLabel creates bins and labels each RNA count to a discrete 
% bins and returns a table of sequences and their corresponding RNA count bin

% Written by A. Karshenas -- Feb 22, 2024
%----------------------------------------------------
%% Main body code 
    bin_count = table('Size', [0, 2], 'VariableTypes', {'string', 'double'},'VariableNames', {'gene', 'M_optimal'});
    tb = tb_input;
    tb.ctr = log(tb.ct_RNA./tb.ct_DNA);
    label_RNA_DNA = zeros(height(tb),1);
    tb{:,width(tb)+1} = label_RNA_DNA;
    tb.Properties.VariableNames{width(tb)} = 'label_RNA_DNA';
    genes = unique(string(tb.gene));

    hWaitbar = waitbar(0, 'Binning expression shifts');
    for gene=1:length(genes)
        data = table2array(tb(string(tb.gene)==genes(gene),'ctr'));
        data(isinf(data)) = -10;
        [M_optimal,label_RNA_DNA] = find_best_binned_histogram(data,max_iteration,Path_to_save_histograms,genes(gene));
        bin_count.gene(gene) = genes(gene);
        bin_count.M_optimal(gene) = M_optimal;
        waitbar(gene / length(genes), hWaitbar, sprintf('Processing... %d%%', round(gene / length(genes) * 100)));
        tb(string(tb.gene)==genes(gene),'label_RNA_DNA') = table(categorical(label_RNA_DNA));
    end
    tb_output = tb;
    
end

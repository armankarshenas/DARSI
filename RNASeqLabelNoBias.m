function tb_output = RNASeqLabelNoBias(tb_input,act_thresh)
% This function labels the ct_RNA to up regulatory, down regulatory and neutral

%% Main body code 
    tb = tb_input;
    label_RNA = zeros(height(tb),1);
    label_DNA = zeros(height(tb),1);
    tb{:,width(tb)+1} = label_RNA;
    tb.Properties.VariableNames{width(tb)} = 'label_RNA';
    tb{:,width(tb)+1} = label_DNA;
    tb.Properties.VariableNames{width(tb)} = 'label_DNA';
    genes = unique(string(tb.gene));
    for gene=1:length(genes)
        idx = tb.gene == genes(gene);
        if sum(idx(:) == 1) > 100
            tb_gene = tb(idx,:);
            % First ct_RNA
            [th_up,th_down,th_med_down,th_med_up] = FindThresholdAndMedian(tb_gene,'ct_RNA',act_thresh);
            tb((idx & tb.ct_RNA >=th_up),width(tb)-1) = table(1);
            tb((idx & tb.ct_RNA <= th_down),width(tb)-1) = table(-1);
            tb((idx & tb.ct_RNA > th_med_up & tb.ct_RNA < th_med_down),:) = [];
    
            % Now ct_DNA
            [th_up,th_down,th_med_down,th_med_up] = FindThresholdAndMedian(tb_gene,'ct_DNA',act_thresh);
            tb((idx & tb.ct_DNA >=th_up),width(tb)) = table(1);
            tb((idx & tb.ct_DNA <= th_down),width(tb)) = table(-1);
            tb((idx & tb.ct_DNA > th_med_up & tb.ct_DNA < th_med_down),:) = [];
        else 
            fprintf("Too few data points for %s \n",string(genes(gene)));
            % Removing these from the activity files 
            tb(idx,:) = [];
        end
    end
    RNA_vector = categorical(tb.label_RNA);
    tb.label_RNA = RNA_vector;
    DNA_vector = categorical(tb.label_DNA);
    tb.label_DNA = DNA_vector;
    tb_output = tb;
    
end

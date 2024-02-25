function tb_output = RNA_DNASeqLabel(tb_input,act_thresh)
% This function labels the ct_RNA to up regulatory, down regulatory and neutral

%% Main body code 
    tb = tb_input;
    tb.ctr = tb.ct_RNA./tb.ct_DNA;
    label_RNA_DNA = zeros(height(tb),1);
    tb{:,width(tb)+1} = label_RNA_DNA;
    tb.Properties.VariableNames{width(tb)} = 'label_RNA_DNA';
    genes = unique(string(tb.gene));
    for gene=1:length(genes)
        idx = tb.gene == genes(gene);
        if sum(idx(:) == 1) > 100
            tb_gene = tb(idx,:);
            % ct_RNA/DNA
            [th_up,th_down] = FindThreshold(tb_gene,'ctr',act_thresh);
            tb((idx & tb.ctr >=th_up),width(tb)) = table(1);
            tb((idx & tb.ctr <= th_down),width(tb)) = table(-1);
        else 
            fprintf("Too few data points for %s \n",string(genes(gene)));
            % Removing these from the activity files 
            tb(idx,:) = [];
        end
    end
    RNA_vector = categorical(tb.label_RNA_DNA);
    tb.label_RNA_DNA = RNA_vector;
    tb_output = tb;
    
end

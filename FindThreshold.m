function [th_up,th_down] = FindThreshold(tb_gene,tb_col,act_thresh)
    tb_col_name = string(tb_gene.Properties.VariableNames);
    tb_col_name = tb_col_name == tb_col;
    vec_values = table2array(tb_gene(:,tb_col_name));
    vec_sorted = sort(vec_values);
    th_down = vec_sorted(floor(act_thresh*length(vec_sorted)));
    th_up = vec_sorted(floor((1-act_thresh)*length(vec_sorted)));
end
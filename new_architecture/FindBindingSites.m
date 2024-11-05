
% find_binding_sites uses the saliency maps and generates expression shift
% that can be used to then find the statistically significant peaks

% Written by A. Karshenas -- Feb 24, 2024
%----------------------------------------------------
addpath(genpath("~/Desktop/DARSI/Scripts/"))
Path_to_data = "~/Desktop/DARSI/new_architecture/model";
Path_to_save = "~/Desktop/DARSI/new_architecture/final_shift_plots";
cd(Path_to_data)

genes = dir(pwd);

for i=5:length(genes)
    waitbar(i/length(genes))
    if genes(i).isdir == 1
        cd(Path_to_data)
        cd(genes(i).name)
        load("FinalSaliencyMap.mat","Final_saliency_map");
        A = Final_saliency_map;
        b = max(A);
        normalized_b = (b-mean(b))/std(b);
        
        fig_1 = bar(normalized_b);
        cd(Path_to_save);
        name = genes(i).name;
        name_to_write_fig = name+"_unfiltered_shift.fig";
        name_to_write_eps = name+"_unfiltered_shift.eps";
        name_to_write_png = name+"_unfiltered_shift.png";
        saveas(fig_1,name_to_write_fig)
        saveas(fig_1,name_to_write_eps)
        saveas(fig_1,name_to_write_png)
        close
        exp_b = movmean(exp(abs(normalized_b)),5);
        idx_pos = normalized_b >=0;
        idx_neg = normalized_b <0;
        exp_b_pos = exp_b.*double(idx_pos);
        exp_b_neg = exp_b.*double(idx_neg);
        exp_plot = [exp_b_pos' exp_b_neg'];
        fig_1 = bar(exp_plot);
        name_to_write_fig = name+"_exp_shift.fig";
        saveas(fig_1,name_to_write_fig)
        close 
        fig_1 = bar(exp_plot);
        name_to_write_eps = name+"_exp_shift.eps";
        exportgraphics(gca,name_to_write_eps)
        close 
        fig_1 = bar(exp_plot);
        name_to_write_png = name+"_exp_shift.png";
        exportgraphics(gca,name_to_write_png)
        close
        threshold_bs = mean(exp_b)+std(exp_b);
        idx = exp_b >= threshold_bs;
        filtered_b = double(idx).*exp_b;
        fig_1 = bar(filtered_b);
        name_to_write_fig = name+"_filtered_shift.fig";
        name_to_write_eps = name+"_filtered_shift.eps";
        name_to_write_png = name+"_filtered_shift.png";
        saveas(fig_1,name_to_write_fig)
        saveas(fig_1,name_to_write_eps)
        saveas(fig_1,name_to_write_png)
        close

    end
end


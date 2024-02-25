function find_binding_sites(Path_to_data,Path_to_save)
% find_binding_sites uses the saliency maps and generates expression shift
% that can be used to then find the statistically significant peaks

% Written by A. Karshenas -- Feb 24, 2024
%----------------------------------------------------
addpath(genpath("/mnt/3dda8c88-9203-43bd-b240-4a31fecd10c3/Arman/PhD/Reg-seq/Matlab/"))
cd(Path_to_data)

genes = dir(pwd);

for i=3:length(genes)
    if genes(i).isdir == 1
        cd(Path_to_data)
        cd(genes(i).name)
        load("SalientMapData.mat","SalientMaps");
        A = SalientMaps(2).Map;
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
        exp_b = exp(abs(normalized_b));
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
        b_sign_filt = zeros([1,160]);
        for j=1:160
            if idx(j) == 1
                flag = true;
                counter = 1;
                while flag == true && counter+j<=160
                    if normalized_b(j+counter)*normalized_b(j+counter-1)<0 || j+counter==160
                        flag = false;
                        if counter >=10 || j+counter==160
                            b_sign_filt(j:j+counter-1) = exp_b(j:j+counter-1);
                        end
                    else
                        counter = counter+1;
                    end
                end
            end
        end
        b_sign_filt_act = double(idx_pos).*b_sign_filt;
        b_sign_filt_rep = double(idx_neg).*b_sign_filt;
        exp_plot_final = [b_sign_filt_act' b_sign_filt_rep'];
        fig_1 = bar(exp_plot_final);
        name_to_write_fig = name+"_final_shift.fig";
        name_to_write_eps = name+"_final_shift.eps";
        name_to_write_png = name+"_final_shift.png";
        saveas(fig_1,name_to_write_fig)
        exportgraphics(gca,name_to_write_eps)
        exportgraphics(gca,name_to_write_png)
        close

    end
end

end

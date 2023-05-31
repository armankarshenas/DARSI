%% Info
% This script generats plots for the training data, performs ANOVA, and
% finds the optimal point in the parameter space 

%% Spec
addpath(genpath("/media/zebrafish/Data2/Arman/PhD/Reg-seq/Matlab"))
Path_to_data = "/media/zebrafish/Data2/Arman/Data/LB_dataset/0.20";
Path_to_save = Path_to_data + "/ANOVA";
%% Main code 
cd(Path_to_data)
mkdir("ANOVA")
act_files = dir(fullfile(pwd,"*_activity.txt"));
mat_files = dir(fullfile(pwd,"*_sequences.mat"));
cd(Path_to_save)
for f=1:length(act_files)
tb = readtable(act_files(f).folder+"/"+act_files(f).name);
load(mat_files(f).folder+"/"+mat_files(f).name);
genes = unique(tb.gene);
OH = struct2table(OneHot);
Measure_dist = struct();
for i=1:length(genes)
    cd(Path_to_save)
    mkdir(string(genes(i)))
    Path_to_save_s = Path_to_save + "/"+genes(i);
    tb_gene = tb(string(tb.gene) == genes(i),:);
    OH_gene = OH(contains((string(OH.index)),genes(i)+"_"),:);
    % Ploting the distribution
    PlotDistribution(tb_gene,OH_gene,Path_to_save_s,act_files(f).name);
    % performing ANOVA 
    Measure_dist(i).anova = PerformANOVA(tb_gene,OH_gene,Path_to_save_s,act_files(f).name);
    Measure_dist(i).gene = genes(i);

end
cd(Path_to_save)
save("ANOVA.mat",'Measure_dist')
end
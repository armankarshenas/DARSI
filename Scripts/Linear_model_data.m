% Linear_model_data uses the one-hot encodings generated for DARSI to
% generate data for a linear model that we use for comparison in the paper 

% Written by A. Karshenas -- Feb 22, 2024
%----------------------------------------------------
addpath(genpath("/mnt/3dda8c88-9203-43bd-b240-4a31fecd10c3/Arman/PhD/Reg-seq/Matlab"))
Path_to_data = "/mnt/3dda8c88-9203-43bd-b240-4a31fecd10c3/Arman/PhD/DARSI/Data/LB_dataset/Linear_model/";
Path_to_save = "/mnt/3dda8c88-9203-43bd-b240-4a31fecd10c3/Arman/PhD/DARSI/Data/LB_dataset/Linear_model/data/";

cd(Path_to_data)
files = dir(fullfile(pwd,"*_activity.txt"));

for f =1:length(files)
   cd(Path_to_data)
   TB = readtable(files(f).name);
   folder_name = files(f).name;
   folder_name = split(folder_name,"_");
   folder_name = folder_name{1};
   mkdir(folder_name);
   cd(folder_name)
   local_path = Path_to_data+"/"+folder_name;
   genes = unique(TB.gene);
   dividedTables = cell(length(genes), 1);

% Iterate over categories
for i = 1:length(genes)
    category = genes{i};
    % Filter rows based on category
    dividedTables{i} = TB(TB.gene == string(category), :);
end

% Access divided tables
for i = 1:length(dividedTables)
    cd(Path_to_save)
    if exist(string(genes{i})) ~= 7
        mkdir(string(genes{i}))
    end
    cd(string(genes{i}))
    seq = dividedTables{i}.sequence;
    X = Sequence_to_mat(seq);
    y = dividedTables{i}.label_RNA_DNA;
    fprintf('Table for category %s:\n', genes{i});
    data = [X,y];
    write_name = folder_name;
    writematrix(data,write_name)        
end
end
%% Plotting 
% This script plots figures using raw Reg-Seq data 
%% Specifications 
Path_to_data = "~/Arman/BerkeleyPhD/Yr2/Reg-seq";

%% Main code body
cd(Path_to_data);
seq_file = dir(fullfile(pwd,"*.csv"));
sequences = readtable(seq_file(1).name);
fprintf("Showing a preview of the data ...\n");
head(sequences)
Genes = unique(sequences.gene);
figure;
for i=1:2
    temp = sequences(strcmp(sequences.gene,Genes{i}),:);
    nmut = (temp.n_mut)';
    act = log10(temp.ct_RNA');
    name = Genes{i};
    hold on;
    scatter(nmut,act,'DisplayName',name,'LineWidth',2);
end
xlabel("N mutation",'Interpreter','latex','FontSize',15);
ylabel("$$\log(ct_{RNA})$$",'Interpreter','latex','FontSize',15);
grid on


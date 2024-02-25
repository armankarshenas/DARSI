% Sequence_to_mat takes the sequences and generates a feature matrix X

% Written by A. Karshenas -- Feb 22, 2024
%----------------------------------------------------
function X = Sequence_to_mat(seq)
seq_1 = char(seq(1));
X = zeros(length(seq),length(seq_1));
for i=1:length(seq)
    seq_local = char(seq(i));
    for j=1:length(seq_1)
        if seq_local(j) == "A"
            X(i,j) = 1;
        elseif seq_local(j) == "T"
            X(i,j) = 2;
        elseif seq_local(j) == "C"
            X(i,j) = 3;
        else
            X(i,j) = 4;
        end
    end
end
for i=1:size(X,2)
    local_mean = mean(X(:,i));
    local_std = std(X(:,i));
    X(:,i) = (X(:,i)-local_mean)/local_std;
end
 
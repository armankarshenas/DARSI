function seq_read = OneHotEncoder(Seq)
% OneHotEncoder assigns a numerical value to each nt in the input sequence Seq

% Written by A. Karshenas -- Feb 25, 2024
%----------------------------------------------------
seq_read = zeros(4,length(Seq));
for i=1:length(Seq)
    switch Seq(i)
        case "A"
            seq_read(1,i) = 1;
        case "T"
            seq_read(2,i) = 1;
        case "C"
            seq_read(3,i) = 1;
        case "G"
            seq_read(4,i) = 1;
    end
end

end

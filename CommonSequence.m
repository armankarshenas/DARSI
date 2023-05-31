function [seq_out] = CommonSequence(seq_in)
if ~istable(seq_in)
    seq_in = struct2table(seq_in);
end
All_seq = string(seq_in.Sequence);
All_seq = char(All_seq);
seq_out = [];
for i=1:length(All_seq(1,:))
    [count,cat] = hist(categorical(cellstr(All_seq(:,i))));
    [~,indx] = max(count);
    seq_out = [seq_out char(cat(indx))];
end
end
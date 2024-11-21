function seq_read = OneHotEncoder(Seq)
% OneHotEncoder converts a DNA sequence into a one-hot encoded matrix.
%
% This function assigns a binary matrix representation to each nucleotide 
% ('A', 'T', 'C', 'G') in the input sequence. Each nucleotide corresponds
% to a specific row in the matrix, with the row set to 1 for the presence 
% of the nucleotide at that position.
%
% Input:
%   - Seq: A string representing a DNA sequence, composed of 'A', 'T', 'C', and 'G'.
%
% Output:
%   - seq_read: A 4xN binary matrix, where N is the length of the sequence.
%     Each column corresponds to a nucleotide position in the sequence, with
%     rows representing 'A', 'T', 'C', and 'G' respectively.
%
% Example Usage:
%   encoded_sequence = OneHotEncoder("ATCG");
%   % Output:
%   % encoded_sequence =
%   %     1 0 0 0
%   %     0 1 0 0
%   %     0 0 1 0
%   %     0 0 0 1
%
% Notes:
%   - Non-standard nucleotides (e.g., 'N') are ignored in this implementation.
%
% Written by A. Karshenas -- Nov, 2024
%--------------------------------------------------------------------------

% Initialize a zero matrix of size 4 x length(Seq) for the encoding
seq_read = zeros(4, length(Seq));

% Iterate over each character in the sequence
for i = 1:length(Seq)
    % Assign a one-hot value based on the nucleotide
    switch Seq(i)
        case "A"
            seq_read(1, i) = 1; % 'A' is encoded as [1; 0; 0; 0]
        case "T"
            seq_read(2, i) = 1; % 'T' is encoded as [0; 1; 0; 0]
        case "C"
            seq_read(3, i) = 1; % 'C' is encoded as [0; 0; 1; 0]
        case "G"
            seq_read(4, i) = 1; % 'G' is encoded as [0; 0; 0; 1]
        % Additional cases can be added here for ambiguous bases if needed.
    end
end

end

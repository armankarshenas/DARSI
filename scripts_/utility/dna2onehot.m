function onehot = dna2onehot(sequence)
    % dna2onehot Converts a DNA sequence to one-hot encoded format.
    %
    %
    %
    % Inputs:
    % - sequence: A string representing the DNA sequence (e.g., 'ATCG')
    %
    % Outputs:
    % - onehot: A 4xN matrix, where N is the length of the DNA sequence, 
    %           representing the one-hot encoded form of the sequence.
    %           Each row corresponds to a nucleotide (A, T, C, G), and
    %           the columns correspond to positions in the sequence.
    %
    % Written by A. Karshenas -- Feb 25, 2024
    %----------------------------------------------------
    % Create a map from bases to numerical indices
    baseMap = containers.Map(["A","T","C","G"], 1:4);
    
    % Initialize the one-hot encoded matrix
    onehot = zeros(4, length(sequence));
    
    % Loop over each nucleotide in the sequence
    for j = 1:length(sequence)
        % Set the appropriate element in the one-hot matrix to 1
        onehot(baseMap(sequence(j)), j) = 1;
    end
end

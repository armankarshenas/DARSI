## Confusion matrices 
---- 

To more rigorously evaluate the effectiveness of our DARSI model in predicting gene expression from raw sequence input, we generated confusion matrices. In these matrices, each column represents predicted expression bin (i.e., zero expression, low expression or high expression), while each row indicates the actual bin to which the sequences belong as reported by measurements. The numbers inside each entry in the matrix indicate the number of sequences belonging to each combination of predicted and measured gene expression bin. Consequently, these matrices provide a summary of false positives, false negatives, true positives, and true negatives for each of the three discrete expression bins.


It should be noted that the row projections in blue and red are true positive and false positive rates respectively, while the column projections in blue and red are the true negative and false negative rates respectively. 

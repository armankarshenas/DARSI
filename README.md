# DARSI (Deep Learning Adaptable Regulatory Sequence Identifier) Package  

The DARSI package trains Convolutional Neural Networks (CNNs) for MPRA (Massively Parallel Reporter Assays) datasets. The trained models predict expression levels from raw DNA sequences and generate saliency maps for each trained model to predict binding site locations. This README file introduces the scripts and how they can be used. For more comprehensive guidance, please see the comments in each of the scripts.

## Repository Content

Below is a description of the directories and their content in this repository:

| Directory/ File        | Description                                                                 |
|------------------------|-----------------------------------------------------------------------------|
| **Data**               | Contains the fasta, txt, and mat files used for training the models.        |
| **Plots**              | Stores the generated confusion matrices, saliency maps, expression plots, and input data distribution for the *E. coli* dataset. |
| **Scripts**            | Contains the MATLAB scripts for preprocessing, classification, and generating saliency maps for the *E. coli* dataset. |
| **RNA-SeqProcessing**  | Includes Jupyter notebooks for filtering and processing raw sequencing data into the necessary input files for the pipeline. |
| **trained_networks**   | Directory for storing trained CNN models.                                   |
| **DARSI.sh**           | The main bash script used to automate the process of running various MATLAB functions to process data, train the model, and generate results. |

## How to Install the DARSI Package

The DARSI package can be easily installed by cloning the repository to your local machine. Run the following command:

```bash
git clone https://github.com/armankarshenas/DARSI


## How to Use the DARSI Package

The DARSI package is designed to work with MPRA datasets that consist of thousands of mutated DNA sequences and corresponding gene expression activity measurements. The processed data is used to train a CNN for each gene/operon in the dataset, and the trained model is then used to:

- Predict expression activity for *de-novo* sequences.
- Generate saliency maps and expression shifts to identify binding sites.

The `DARSI.sh` script is the primary interface for using this pipeline. It automates the following steps:

1. Preprocessing the data.
2. Training CNN models.
3. Generating saliency maps.
4. Identifying binding sites in the dataset.

### Input Table for `DARSI.sh`

| Flag          | Description                                                   | Required | Default Value    |
|---------------|---------------------------------------------------------------|----------|------------------|
| `-i`          | Path to the input MPRA data (CSV/Excel file)                  | Yes      | N/A              |
| `-s`          | Path to save the output files                                 | No       | Current directory |
| `-m`      | Path to save image outputs (e.g., saliency maps)              | No       | None             |
| `-h`          | Path to save histogram outputs                                | No       | None             |
| `-l`   | Maximum number of iterations for binning                      | No       | 10000            |
| `-t`         | Training split percentage                                     | No       | 0.7              |
| `-e`         | Evaluation split percentage                                   | No       | 0.15             |

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

# transcriptomic_snakes
demo of a snakemake pipeline

This workflow is based on an exercise in expression analysis. The workflow starts with single end reads, a reference genome .fna and an annotated genome .gff
and goes through 4 main steps:
* Quality Checking with FastQC
* Mapping reads to reference 
* Read count with Htseq-count
* Differential expression and plotting with DeSeq2 in R

This is a short version of the README which focuses on getting set up quickly, please read all of it before running the pipeline.

## Setup conda:
https://docs.conda.io/en/latest/miniconda.html
## Setup snakemake:
https://snakemake.readthedocs.io/en/stable/getting_started/installation.html


Clone this git, make sure you have snakemake available in your $PATH and run:
```
snakemake --cores 8 --use-conda
```
From  within ./transcriptomic_snakes/ first run takes longer because R needs to be setup. 

When satisfied that everything works as it should, replace single-end reads
genome.fna and genes.gff in the 1_Reads directory, run 
```
sh cleanup.sh
```
and then:
```
snakemake --cores 8 --use-conda
```
This pipeline requires that you are in a linux environment with conda and snakemake set up, no other requirements. 

All results are found in the 5_Results/ directory after running
the pipeline.

# Singularity
First make sure you have singularity installed. If it isn't and you don't have super user access to your system
you should use conda. When using singularity, images will override the conda environments, the idea is to avoid setting
up the environments and just using the frozen environments in the images. This could potentially solve the dependency hell in
the R-environment, which takes a long time on first run, when it is setting up the R + DESeq2 environment. So if you have singularity,
here's a quick guide:

### 1: Change settings in conf/config.yaml
```
make_plots: "make_plots.R"
```
Needs to be changed to:
```
make_plots: "singularity_make_plots.R"
```
In the config.yaml that sits in the conf/ directory.
### 2: Run snakemake with use singularity
```
snakemake --cores 8 --use-singularity
```
Note that singularity overrides --use-conda!

# Settings
You find a file with different settings in conf/config.yaml, here you can specify paths to reference  genome, gff file
and change trimmomatic settings depending on what you find in qc. It is recommended that when you run this pipeline the first time
on your own dataset you start by specifying:
```
snakemake -U qc --cores 8 --use-conda
```
this command only produces FastQC reports for your reads, have a look at them and the default settings in the conf.yaml file to adjust appropriately.

Then if you rerun, snakemake will know to skip rule qc and carry on with the rest of the analysis.

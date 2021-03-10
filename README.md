# transcriptomic_snakes
demo of a snakemake pipeline

## Setup conda:
[https://docs.conda.io/en/latest/miniconda.html]
## Setup snakemake:
[https://snakemake.readthedocs.io/en/stable/getting_started/installation.html]


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
This pipeline requires that you are in a linux environment with conda set up, no other requirements. 

All results are found in the 5_Results/ directory after running
the pipeline.

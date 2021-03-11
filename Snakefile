SAMPLE, = glob_wildcards('1_Reads/{sample}.fastq')
ref_genome = "1_Reads/genome.fna"
gff_file = "1_Reads/genes.gff"
#need to require at least 1 genome.X.ht2
rule all:
	input:
		expand('4_Mapped/{sample}.count', sample = SAMPLE),
		expand('2_Quality/{sample}_fastqc.html', sample = SAMPLE),
		"5_Results/fig1.pca.pdf",
		"5_Results/fig2.heatmap.pdf",
		"5_Results/fig3.MA.pdf",
		"5_Results/fig4.heatmap_sig_diff_exp.pdf"


rule qc:
	input:
		'1_Reads/{sample}.fastq'
	output:
		'2_Quality/{sample}_fastqc.html'
	conda:
		"envs/quality.yaml"
	shell:
		'fastqc -o "2_Quality/" {input} '

rule trimming:
	input:
		'1_Reads/{sample}.fastq'
	output:
		'3_Trimmed/{sample}_clean.fastq'
	conda:
		"envs/quality.yaml"
	shell:
		'trimmomatic SE {input} {output} AVGQUAL:28 MINLEN:46 CROP:46 SLIDINGWINDOW:8:20'

rule map_reference:
	output:
		dynamic("4_Mapped/genome.{id}.ht2")
	conda:
		"envs/mapping.yaml"
	shell:
		'hisat2-build {ref_genome} "4_Mapped/genome" '

rule mapping:
	input:
		'3_Trimmed/{sample}_clean.fastq',
		dynamic("4_Mapped/genome.{id}.ht2")
	output:
		'4_Mapped/{sample}.sam'
	conda:
		"envs/mapping.yaml"
	shell:
		'hisat2 -p 8 --max-intronlen 5000 -U {input[0]} -x "4_Mapped/genome" \
		-S {output} --summary-file {output}.summary'

rule count:
	input:
		'4_Mapped/{sample}.sam'
	output:
		'4_Mapped/{sample}.count'
	conda:
		"envs/readcount.yaml"
	shell:
		'htseq-count -s no -t CDS -i name -m intersection-nonempty {input} '
		f"{gff_file} "
		'| grep -v "^__" > {output}'

rule count_matrix:
	input:
		expand('4_Mapped/{sample}.count', sample=SAMPLE)
	output:
		"5_Results/count.matrix"
	shell:
		'paste 4_Mapped/*.count | cut -f 1,2,4,6,8,10,12 > {output}'

rule final_matrix:
	input:
		"5_Results/count.matrix"
	output:
		"5_Results/final.matrix"
	shell:
		'echo -e "#gene_id\tfh1\tfh2\tfh3\tref1\tref2\tref3" > 5_Results/header.tsv ; '
		'cat 5_Results/header.tsv {input} | tr -d "#" > {output}'

rule get_plots:
	input:
		"5_Results/final.matrix"
	output:
		"5_Results/fig1.pca.pdf",
		"5_Results/fig2.heatmap.pdf",
		"5_Results/fig3.MA.pdf",
		"5_Results/fig4.heatmap_sig_diff_exp.pdf"
	conda:
		"envs/renv.yaml"
	log:
		"logs/make_plots.log"
	shell:
		'Rscript make_plots.R &> {log}'
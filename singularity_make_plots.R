#!/usr/bin/Rscript
# Title     : Differential expression
# Objective : produce plots for differential expression pipeline
# Created by: Mattis
# Created on: 2021-03-13
setwd("5_Results/")

library(DESeq2) ; library(gplots) ; library(RColorBrewer)
#parallelization
library("BiocParallel")
register(MulticoreParam(detectCores()))
#DESeq2
#Imports
count_mat <- as.matrix(read.csv("final.matrix", sep="\t", row.names = "gene_id"))
head(count_mat)
sampleConditions <- c("rich","rich","rich","poor","poor","poor")
sampleConditions
sampleNames = c("fh1","fh2","fh3","ref1","ref2","ref3")
sampleTable = data.frame(sampleName = sampleNames, condition = sampleConditions)
row.names(sampleTable) <- sampleTable$sampleName
sampleTable[1] <- NULL
# DESEQ
dds <- DESeqDataSetFromMatrix(countData = count_mat, colData = sampleTable, design = ~ condition)
dds
dds <- estimateSizeFactors(dds)
sizeFactors(dds)
normalized_counts <- as.data.frame(counts(dds, normalized=T))
head(normalized_counts)
summary(normalized_counts)
rld <- rlogTransformation(dds, blind = T)

#PCA plot
pdf("fig1.pca.pdf")
print(plotPCA(rld, intgroup = c("condition")))
dev.off()

#Heatmap of similarity between replicates
#Distance matrix
distsRL <- dist(t(assay(rld)))
mat <- as.matrix(distsRL)
rownames(mat) <- colnames(mat) <- with(colData(dds), paste(condition, sampleNames, sep=" : "))
hc <- hclust(distsRL)
hmcol <- colorRampPalette(brewer.pal(9,"GnBu"))(100)
# Heatmap plot
pdf("fig2.heatmap.pdf")
heatmap.2(mat, Rowv=as.dendrogram(hc), symm = T, trace="none", col=rev(hmcol), margin=c(13,13))
dev.off()

dds <- DESeq(dds, parallel=TRUE)
contrast_pr <- c("condition", "poor", "rich")
res_table <- results(dds, contrast=contrast_pr, parallel=TRUE)
res_table <- res_table[order(res_table$padj),]
head(res_table)
genename = rownames(res_table)
res_table <- cbind(genename, data.frame(res_table, row.names = NULL))
write.table(res_table, file = "diffExp.tab", sep="\t", quote=F, row.names = F)

# list genes with adjusted p cutoff below threshold
resSig <- subset(res_table, padj < 0.05)
write.table(resSig, file = "diffExp.0.05.tab", sep="\t", quote=F, row.names = F)
pdf("fig3.MA.pdf")
plotMA(dds, ylim=c(-2,2), main="DESeq2")
dev.off()

select <- order(rowMeans(counts(dds, normalized=T)), decreasing = T)[1:30]
hmcol <- colorRampPalette(brewer.pal(9,"GnBu"))(100)
pdf("fig4.heatmap_sig_diff_exp.pdf")
heatmap.2(counts(dds, normalized=T)[select,],col=hmcol, Rowv = F, Colv = F, scale = "none", dendrogram = "none", trace = "none")
dev.off()
#fin

# Tree of life endogenous viral element (EVE) discovery

![EVE2_Grid1_Spot1_120k_scale-01](https://user-images.githubusercontent.com/27350062/185241664-aa96486b-e61e-423e-9264-c3fbd7d8625b.jpg)
Putative virus-like particles self-assembled from an expressed EVE (capsid protein associated with either Rep family *Naryaviridae* or *Nenyaviridae*) in *Entamoeba dispar* contig AANV02000527.1. Credit to Tim C. Passchier who ran the negative stain microscopy.

## Linux workflow for processing 100s to 1000s of genomes to discover EVEs

# Highlights:

- No storage issues when processing 1000s of genomes. Using cressdnavirus queries, total output for ~25,000 eukaryotic genomes was <2 GB
- Custom protein queries can be used to target any virus/EVE lineage
- Each element represents a region of interest (ROI) in the assembly. ROIs are likely to get multiple distinct alignments. This workflow first merges overlapping alignments to record the maximal ranges of a ROI, before extracting the predicted protein sequence of the best single alignment (unlikely to span the maximal ranges)
- Older EVEs often contain stop codons. These are retained in the final ".fmt6" output, as they are potentially informative. Ensure they are removed prior to phylogenetic analysis, or BLAST curation of sequences
- Information such as assembly, contig, maximal ROI ranges, putative EVE amino acid sequence, frame, and exact sequence coordinates are straightforward to extract or calculate from outputs

# Usage:

Prerequisite programmes in $PATH:
- BLAST+
- samtools
- bedtools

Alternatively, a conda environment.yml is provided in this repository for fast setup.
Get conda here:
https://docs.conda.io/en/latest/miniconda.html#linux-installers

Create, activate, and check environment:
```
conda EVE_discovery create -f environment.yml
conda activate EVE_discovey
conda list
```

The workflow itself is provided as a Linux command line script for use on a HPC environment. Adapt this to your system, e.g.:
- Workload manager information
- Input file locations
- $num_threads
- $outdir

# Required input files:
- Custom "proteins.fasta" query file. Recommend no spaces in headers & informative labelling
- A text list of ftp repositories to target, for example:
```
ftp.ncbi.nlm.nih.gov/genomes/all/GCA/014/108/235/GCA_014108235.1_mMyoMyo1.p
ftp.ncbi.nlm.nih.gov/genomes/all/GCA/016/865/085/GCA_016865085.1_ASM1686508v1
ftp.ncbi.nlm.nih.gov/genomes/all/GCF/003/704/035/GCF_003704035.1_HU_Pman_2.1.3
ftp.ncbi.nlm.nih.gov/genomes/all/GCA/913/844/085/GCA_913844085.1_s3r1_clone4_genome
ftp.ncbi.nlm.nih.gov/genomes/all/GCA/001/662/575/GCA_001662575.1_ASM166257v1 
```

# Notes
- For 200+ genomes, splitting up the input ftp list into multiple subfiles is recommended, with subsets run in parallel using copies of the script
- First shuffle complete list: 
```
shuf ftp.list > ftp_shuffled.list
```
Sequential assembly accessions often have similar size, if they are submitted together, shuffling will ensure a more similar work burden and therefore runtime for each job.
```
split -l 100 ftp_shuffled.list
```
- Approximate run time (Intel® Xeon® Gold 6130 - 2.10GHz, 16 cores): 100 eukaryotic genomes in 1-2 days
- For best performance, work with all files within a compute environment/compute node
- It's recommended to carry out quality control on the resulting sequences. E.g. with a DIAMOND installation:
```
diamond blastp --very-sensitive --query pEVE_queries.faa --db nr --unal 1 --max-target-seqs 1 --outfmt 6 qseqid sseqid pident length evalue bitscore stitle --out pEVE_queries.faa.diamond.fmt6 --threads 8
```
